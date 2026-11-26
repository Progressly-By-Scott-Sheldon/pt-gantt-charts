/* Schedule Gantt: pure logic (no DOM). Loaded by page 4 as window.PTG and by the Node tests.
 * Times are plant-local wall-clock values held as UTC milliseconds, so they are never shifted by
 * the browser's time zone: always read them back with getUTC*. */
(function (root, factory) {
  if (typeof module === "object" && module.exports) module.exports = factory();
  else root.PTG = factory();
})(typeof self !== "undefined" ? self : this, function () {
  "use strict";
  var DAY = 864e5, HR = 36e5, BRK = 30, GAP_HOURS = 36;

  /* "2026-11-19T08:00[:00]" (from the database) or "19-11-2026 08:00[:ss]" (PlanetTogether export).
   * PlanetTogether writes 01-01-1800 and 01-01-9000 for "no date": both give null. */
  function parseDate(v) {
    if (v == null) return null;
    var s = String(v).trim(), m, y, mo, d, h, mi, se;
    if ((m = /^(\d{4})-(\d\d)-(\d\d)(?:[T ](\d\d):(\d\d)(?::(\d\d))?)?$/.exec(s))) {
      y = +m[1]; mo = +m[2]; d = +m[3]; h = +(m[4] || 0); mi = +(m[5] || 0); se = +(m[6] || 0);
    } else if ((m = /^(\d\d)-(\d\d)-(\d{4})(?: (\d\d):(\d\d)(?::(\d\d))?)?$/.exec(s))) {
      d = +m[1]; mo = +m[2]; y = +m[3]; h = +(m[4] || 0); mi = +(m[5] || 0); se = +(m[6] || 0);
    } else return null;
    if (y === 1800 || y === 9000) return null;
    return Date.UTC(y, mo - 1, d, h, mi, se);
  }

  /* "HH:mm:ss" or "d.HH:mm:ss" -> minutes. */
  function parseDuration(v) {
    var m = /^(?:(\d+)\.)?(\d+):(\d\d):(\d\d)(?:\.\d+)?$/.exec(String(v == null ? "" : v).trim());
    if (!m) return null;
    return (+(m[1] || 0)) * 1440 + (+m[2]) * 60 + (+m[3]) + (+m[4]) / 60;
  }

  var MON = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  var DOW = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
  function p2(n) { return String(n).padStart(2, "0"); }
  function fD(t) { var d = new Date(t); return d.getUTCDate() + " " + MON[d.getUTCMonth()]; }
  function fDY(t) { return fD(t) + " " + new Date(t).getUTCFullYear(); }
  function fDT(t, refYear) {
    if (t == null) return "—";
    var d = new Date(t);
    return fD(t) + (refYear != null && d.getUTCFullYear() !== refYear ? " " + d.getUTCFullYear() : "") +
      " " + p2(d.getUTCHours()) + ":" + p2(d.getUTCMinutes());
  }
  function dur(ms) {
    var m = Math.round(ms / 6e4), d = Math.floor(m / 1440), h = Math.floor(m % 1440 / 60), mm = m % 60;
    return d ? d + "d " + h + "h" : h ? h + "h" + (mm ? " " + mm + "m" : "") : mm + "m";
  }
  /* minutes -> "3:00", "30:00" */
  function hm(min) {
    if (min == null) return "—";
    var t = Math.round(min);
    return Math.floor(t / 60) + ":" + p2(t % 60);
  }
  function uniq(a) { return Array.from(new Set(a)); }

  /* ---- filters: n = how many levels of the cascade to apply (1 project, 2 + job, 3 + operation) ---- */
  function pass(a, F, n) {
    return (!F.proj.size || F.proj.has(a.proj)) &&
      (n < 2 || !F.job.size || F.job.has(a.jobId)) &&
      (n < 3 || !F.op.size || F.op.has(a.op));
  }
  /* Options for each filter, limited by the filters upstream of it. Selections an upstream
   * change made impossible are removed from F (mutates F). */
  function filterOptions(A, F, projects) {
    var jobs = uniq(A.filter(function (a) { return pass(a, F, 1); }).map(function (a) { return a.jobId; }));
    F.job.forEach(function (j) { if (jobs.indexOf(j) < 0) F.job.delete(j); });
    var ops = uniq(A.filter(function (a) { return pass(a, F, 2); }).map(function (a) { return a.op; }));
    F.op.forEach(function (o) { if (ops.indexOf(o) < 0) F.op.delete(o); });
    return {
      proj: projects.map(function (p) { return [p, p]; }),
      job: jobs.map(function (j) {
        var a = A.find(function (x) { return x.jobId === j; });
        return [j, j + " · " + a.job];
      }),
      op: ops.map(function (o) { return [o, o]; })
    };
  }

  /* Operations of a list of activities (one job): one entry per opId, with every resource it runs on. */
  function groupOperations(acts) {
    var by = new Map();
    acts.forEach(function (a) {
      var k = a.jobId + "\u0000" + a.opId;
      if (!by.has(k)) by.set(k, { a: a, res: [] });
      by.get(k).res.push(a.res);
    });
    return Array.from(by.values()).map(function (g) {
      return { a: g.a, opId: g.a.opId, res: g.res, label: g.res.join(" + ") };
    });
  }

  /* Lateness of one job: latest scheduled end minus latest need date, 0 when no activity is late. */
  function jobLateness(ja) {
    if (!ja.some(function (a) { return a.late; })) return 0;
    var e = Math.max.apply(null, ja.map(function (a) { return a.e; }));
    var needs = ja.map(function (a) { return a.need; }).filter(function (n) { return n != null; });
    if (!needs.length) return 0;
    return Math.max(0, e - Math.max.apply(null, needs));
  }

  /* ---- time scale with collapsed idle gaps (ported unchanged from the reference) ---- */
  function makeScale(acts, opt) {
    var ppd = opt.ppd, compress = opt.compress;
    var iv = acts.map(function (a) { return [a.s, a.e]; }).sort(function (x, y) { return x[0] - y[0]; });
    var segs = [];
    if (!iv.length) return { segs: [], W: 0, x: function () { return 0; } };
    if (compress) {
      var cur = iv[0].slice();
      iv.slice(1).forEach(function (p) {
        if (p[0] - cur[1] < GAP_HOURS * HR) cur[1] = Math.max(cur[1], p[1]);
        else { segs.push(cur); cur = [p[0], p[1]]; }
      });
      segs.push(cur);
      segs = segs.map(function (p) { return [Math.floor(p[0] / DAY) * DAY, Math.ceil(p[1] / DAY) * DAY]; });
      var m = [segs[0]];
      segs.slice(1).forEach(function (s) {
        var l = m[m.length - 1];
        if (s[0] <= l[1]) l[1] = Math.max(l[1], s[1]); else m.push(s);
      });
      segs = m;
    } else {
      segs = [[Math.floor(iv[0][0] / DAY) * DAY,
               Math.ceil(Math.max.apply(null, iv.map(function (i) { return i[1]; })) / DAY) * DAY]];
    }
    var x0 = 0;
    segs = segs.map(function (p, i) {
      var o = { s: p[0], e: p[1], x0: x0, w: (p[1] - p[0]) / DAY * ppd };
      x0 += o.w + (i < segs.length - 1 ? BRK : 0);
      return o;
    });
    var x = function (t) {
      for (var i = 0; i < segs.length; i++) {
        var g = segs[i];
        if (t < g.s) return g.x0 - BRK / 2;
        if (t <= g.e) return g.x0 + (t - g.s) / DAY * ppd;
      }
      return x0;
    };
    return { segs: segs, W: x0, x: x };
  }
  /* Days shown and number of breaks, independent of zoom (used by Fit). */
  function extent(acts, compress) {
    var w = makeScale(acts, { ppd: 1, compress: compress });
    return { days: w.segs.reduce(function (n, g) { return n + (g.e - g.s) / DAY; }, 0), breaks: Math.max(0, w.segs.length - 1) };
  }

  /* Rows from the database (strings) -> activities the screen works with. */
  function fromRows(rows) {
    return rows.map(function (r) {
      return {
        proj: r.proj, projSort: r.projSort, job: r.job, jobId: r.jobId, product: r.product, qty: r.qty,
        op: r.op, opId: r.opId, dept: r.dept, res: r.res, status: r.status,
        s: parseDate(r.s), e: parseDate(r.e), need: parseDate(r.need), late: !!r.late,
        setupMin: r.setupMin, runMin: r.runMin
      };
    }).filter(function (a) { return a.s != null && a.e != null; });
  }

  return {
    DAY: DAY, HR: HR, BRK: BRK, MON: MON, DOW: DOW,
    parseDate: parseDate, parseDuration: parseDuration, fD: fD, fDY: fDY, fDT: fDT, dur: dur, hm: hm, p2: p2, uniq: uniq,
    pass: pass, filterOptions: filterOptions, groupOperations: groupOperations, jobLateness: jobLateness,
    makeScale: makeScale, extent: extent, fromRows: fromRows
  };
});
