/* Schedule Gantt (page 4): renders PT_ACTIVITIES_V, written by the page as JSON into
 * <script type="application/json" id="ptg-data">, into <div id="ptg">. Logic lives in ptg-core.js. */
(function () {
  "use strict";
  var P = window.PTG;
  var root = document.getElementById("ptg"), src = document.getElementById("ptg-data");
  if (!root || !src || !P) return;
  var DATA = JSON.parse(src.textContent || "{}");
  var A = P.fromRows(DATA.acts || []);
  var DAY = P.DAY, BRK = P.BRK, PAD = 300, MON = P.MON, DOW = P.DOW, p2 = P.p2, fD = P.fD, dur = P.dur;
  var refYear = A.length ? new Date(A[0].s).getUTCFullYear() : null;
  var fDT = function (t) { return P.fDT(t, refYear); };
  var esc = function (s) {
    return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; });
  };

  /* dark theme? switch to the dark project colours */
  (function () {
    var c = getComputedStyle(document.body).backgroundColor.match(/\d+/g);
    if (c && (0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]) < 110) root.classList.add("ptg--dark");
  })();

  root.innerHTML =
    '<p class="sub" data-r="sub"></p><div class="stats" data-r="stats"></div>' +
    '<div class="bar-row">' +
      '<div class="seg" role="group" aria-label="View">' +
        '<button type="button" data-v="project" aria-pressed="true">By project</button>' +
        '<button type="button" data-v="resource" aria-pressed="false">By resource</button>' +
        '<button type="button" data-v="table" aria-pressed="false">Table</button></div>' +
      '<span data-r="ganttctl" style="display:contents">' +
        '<div class="seg" role="group" aria-label="Zoom">' +
          '<button type="button" data-z="out" title="Zoom out" aria-label="Zoom out">−</button>' +
          '<button type="button" data-z="fit" aria-label="Fit to screen">Fit</button>' +
          '<button type="button" data-z="in" title="Zoom in" aria-label="Zoom in">+</button></div>' +
        '<label class="chk"><input type="checkbox" data-r="compress" checked> Hide idle gaps</label>' +
        '<span data-r="lvlwrap" style="display:contents"><span class="flab" id="ptg-lvl">Show down to</span>' +
          '<div class="seg" role="group" aria-labelledby="ptg-lvl">' +
            '<button type="button" data-l="project">Project</button>' +
            '<button type="button" data-l="job">Job</button>' +
            '<button type="button" data-l="operation">Operation</button></div></span>' +
      '</span></div>' +
    '<div class="bar-row" data-r="filters"><span class="flab">Filter</span>' +
      '<details class="dd" data-f="proj"><summary aria-label="Project filter"></summary><div class="menu" role="group" aria-label="Projects"></div></details>' +
      '<details class="dd" data-f="job"><summary aria-label="Job filter"></summary><div class="menu" role="group" aria-label="Jobs"></div></details>' +
      '<details class="dd" data-f="op"><summary aria-label="Operation filter"></summary><div class="menu" role="group" aria-label="Operations"></div></details>' +
      '<button type="button" class="btn" data-r="clear">Clear filters</button>' +
      '<span class="flab" data-r="count" aria-live="polite"></span></div>' +
    '<div class="legend" data-r="legend"></div>' +
    '<div class="board" data-r="board"><div class="inner" data-r="inner"></div></div>' +
    '<div class="tblwrap" data-r="tblwrap" hidden></div>' +
    '<p class="note">Bars run from Scheduled Start to Scheduled End, so they include setup and any off-shift or weekend time the activity spans. ' +
      'A red end cap marks an activity PlanetTogether flags as late against its need date. Jobs are grouped into projects by PT_JOB_PROJECTS.</p>' +
    '<div class="tip" role="tooltip" data-r="tip"></div>';
  var $ = function (r) { return root.querySelector('[data-r="' + r + '"]'); };

  if (!A.length) { $("inner").innerHTML = '<div class="empty">No scheduled activities in PT_ACTIVITIES.</div>'; return; }

  /* projects in PT_PROJECTS.sort_order; colour fixed per project regardless of filters */
  var PROJECTS = P.uniq(A.slice().sort(function (a, b) { return (a.projSort - b.projSort) || (a.proj < b.proj ? -1 : a.proj > b.proj ? 1 : 0); }).map(function (a) { return a.proj; }));
  var pc = function (p) { return "c" + (PROJECTS.indexOf(p) % 8 + 1); };
  var DEPTS = P.uniq(A.slice().sort(function (a, b) { return a.s - b.s; }).map(function (a) { return a.dept; }));
  var state = { view: "project", ppd: 150, compress: true, level: "operation" };
  var F = { proj: new Set(), job: new Set(), op: new Set() };
  var FL = { proj: ["All projects", "projects"], job: ["All jobs", "jobs"], op: ["All operations", "operations"] };
  var visible = function () { return A.filter(function (a) { return P.pass(a, F, 3); }); };
  var tips = [], scale;
  var mx = function (arr, k) { return Math.max.apply(null, arr.map(function (a) { return a[k]; })); };
  var mn = function (arr, k) { return Math.min.apply(null, arr.map(function (a) { return a[k]; })); };

  function buildFilters() {
    var opt = P.filterOptions(A, F, PROJECTS);
    root.querySelectorAll('[data-r="filters"] .dd').forEach(function (d) {
      var k = d.dataset.f, set = F[k], sm = d.querySelector("summary");
      var one = set.size === 1 ? opt[k].find(function (o) { return o[0] === Array.from(set)[0]; }) : null;
      sm.textContent = !set.size ? FL[k][0] : one ? one[1] : set.size + " " + FL[k][1];
      sm.classList.toggle("on", set.size > 0);
      d.querySelector(".menu").innerHTML = opt[k].map(function (o, i) {
        return '<label for="ptg-f-' + k + '-' + i + '"><input type="checkbox" id="ptg-f-' + k + '-' + i + '" value="' + esc(o[0]) + '"' + (set.has(o[0]) ? " checked" : "") + '>' + esc(o[1]) + '</label>';
      }).join("");
    });
    var n = visible().length;
    $("count").textContent = n === A.length ? "" : n + " of " + A.length + " activities shown";
    $("clear").hidden = !(F.proj.size || F.job.size || F.op.size);
  }

  (function headerNumbers() {
    var jobs = P.uniq(A.map(function (a) { return a.jobId; })), res = P.uniq(A.map(function (a) { return a.res; }));
    var ops = new Set(A.map(function (a) { return a.jobId + "\u0000" + a.opId; })).size;
    var lateJobs = new Set(A.filter(function (a) { return a.late; }).map(function (a) { return a.jobId; })).size;
    $("sub").textContent = (DATA.plant ? DATA.plant + " · " : "") + "scheduled " + P.fDY(mn(A, "s")) + " to " + P.fDY(mx(A, "e")) +
      (DATA.loaded ? " · loaded " + P.fDY(P.parseDate(DATA.loaded)) : "");
    $("stats").innerHTML = "<div><b>" + PROJECTS.length + "</b>projects</div><div><b>" + jobs.length + "</b>jobs</div><div><b>" + ops +
      "</b>operations</div><div><b>" + A.length + "</b>resource activities</div><div><b>" + res.length + "</b>resources</div>" +
      '<div class="crit"><b>' + lateJobs + "</b>jobs late against need date</div>";
  })();

  function legend() {
    var on = new Set(visible().map(function (a) { return a.proj; }));
    $("legend").innerHTML = PROJECTS.map(function (p) {
      return '<span class="chip' + (on.has(p) ? "" : " off") + '"><span class="sw ' + pc(p) + '"></span>' + esc(p) + "</span>";
    }).join("") + '<span class="key"><i></i>late against need date</span>';
  }

  function header() {
    var segs = scale.segs, ppd = state.ppd, h = "", g = "";
    var hours = ppd >= 320, hstep = ppd >= 1000 ? 2 : ppd >= 560 ? 4 : 6;
    segs.forEach(function (sg, i) {
      var mStart = sg.s;
      for (var d = sg.s; d < sg.e; d += DAY) {
        var dt = new Date(d), x = sg.x0 + (d - sg.s) / DAY * ppd, dow = dt.getUTCDay(), wk = dow === 0 || dow === 6;
        var nxt = new Date(d + DAY);
        if (d + DAY >= sg.e || nxt.getUTCMonth() !== dt.getUTCMonth()) {
          var mxp = sg.x0 + (mStart - sg.s) / DAY * ppd;
          h += '<div class="m" style="left:' + mxp + 'px;width:' + (x + ppd - mxp) + 'px">' + MON[dt.getUTCMonth()] + " " + dt.getUTCFullYear() + "</div>";
          mStart = d + DAY;
        }
        var lab = "", ov = "";
        if (ppd >= 92) lab = DOW[dow] + " " + dt.getUTCDate() + " " + MON[dt.getUTCMonth()];
        else if (ppd >= 46) lab = dt.getUTCDate() + " " + DOW[dow][0];
        else if (ppd >= 20) lab = dt.getUTCDate();
        else if (dow === 1) { lab = dt.getUTCDate(); ov = " ov"; }
        h += '<div class="dy' + ov + '" style="left:' + x + 'px;width:' + ppd + 'px">' + lab + "</div>";
        g += '<div class="d' + (wk ? " wk" : "") + '" style="left:' + x + 'px;width:' + ppd + 'px"></div>';
        if (ppd >= 160) for (var k = hstep; k < 24; k += hstep) {
          var hx = x + k / 24 * ppd;
          g += '<div class="hr" style="left:' + hx + 'px"></div>';
          if (hours) h += '<div class="h" style="left:' + hx + 'px">' + p2(k) + ":00</div>";
        }
      }
      if (i < segs.length - 1) {
        var bx = sg.x0 + sg.w, gap = Math.round((segs[i + 1].s - sg.e) / DAY);
        h += '<div class="brk" style="left:' + bx + 'px;width:' + BRK + 'px" title="' + gap + ' idle days hidden">' + gap + "d</div>";
        g += '<div class="brk" style="left:' + bx + 'px;width:' + BRK + 'px"></div>';
      }
    });
    return { h: h, g: g, hh: hours ? 62 : 44 };
  }

  function tipOf(o) { tips.push(o); return tips.length - 1; }
  function actTip(a, resList) {
    return { t: a.opId + " · " + a.op, late: a.late, rows: [
      ["Project", a.proj], ["Job", a.jobId + " · " + a.job], ["Product", a.product + " × " + a.qty],
      ["Resource", resList || a.res], ["Department", a.dept], ["Start", fDT(a.s)], ["End", fDT(a.e)],
      ["Span", dur(a.e - a.s) + " (run " + P.hm(a.runMin) + " h)"], ["Need date", fDT(a.need)],
      ["Status", a.status + (a.late && a.need != null ? " · late " + dur(a.e - a.need) : a.late ? " · late" : "")]] };
  }
  var textW = function (s) { return s.length * 6.3 + 10; };

  function barHTML(a, cls, label, resList, nextX) {
    var x = scale.x(a.s), w = Math.max(3, scale.x(a.e) - x), i = tipOf(actTip(a, resList));
    var h = '<div class="bar ' + pc(a.proj) + (a.late ? " late" : "") + '" style="left:' + x + "px;width:" + w + 'px" data-i="' + i +
      '" tabindex="0" aria-label="' + esc(a.jobId + " " + a.op + " on " + (resList || a.res) + ", " + fDT(a.s) + " to " + fDT(a.e)) + '"></div>';
    if (cls === "out") h += '<span class="bl" style="left:' + (x + w + 7) + 'px">' + label + "</span>";
    else {
      var plain = label.replace(/<[^>]+>/g, ""), tw = textW(plain);
      if (tw <= w - 6) h += '<span class="bl in" style="left:' + (x + 6) + "px;width:" + (w - 12) + 'px">' + plain + "</span>";
      else if (nextX == null || x + w + 7 + tw < nextX) h += '<span class="bl" style="left:' + (x + w + 7) + 'px">' + label + "</span>";
    }
    return h;
  }

  function projectRows(acts) {
    var out = "", TW = scale.W + PAD;
    PROJECTS.forEach(function (p) {
      var pa = acts.filter(function (a) { return a.proj === p; });
      if (!pa.length) return;
      var ps = mn(pa, "s"), pe = mx(pa, "e"), jobs = P.uniq(pa.map(function (a) { return a.jobId; }));
      var x = scale.x(ps), w = scale.x(pe) - x;
      var pl = Math.max.apply(null, [0].concat(jobs.map(function (j) { return P.jobLateness(pa.filter(function (a) { return a.jobId === j; })); })));
      var pi = tipOf({ t: p, late: pl > 0, rows: [["Jobs", jobs.join(", ")], ["Start", fDT(ps)], ["End", fDT(pe)], ["Span", dur(pe - ps)]].concat(pl > 0 ? [["Late by", dur(pl)]] : []) });
      out += '<div class="row p"><div class="lc"><span class="sw ' + pc(p) + '"></span><span class="t">' + esc(p) + "</span>" +
        (pl > 0 ? '<span class="pill">LATE ' + dur(pl) + "</span>" : "") + '</div><div class="tc" style="width:' + TW + 'px">' +
        '<div class="psum" style="left:' + x + "px;width:" + w + 'px" data-i="' + pi + '" tabindex="0" aria-label="' + esc(p) + '"></div>' +
        '<span class="bl" style="left:' + (x + w + 9) + 'px"><small>' + jobs.length + " job" + (jobs.length > 1 ? "s" : "") + " · " + fD(ps) + " → " + fD(pe) + "</small></span></div></div>";
      if (state.level === "project") return;
      jobs.forEach(function (j) {
        var ja = pa.filter(function (a) { return a.jobId === j; }), a0 = ja[0], js = mn(ja, "s"), je = mx(ja, "e");
        var needs = ja.map(function (a) { return a.need; }).filter(function (n) { return n != null; });
        var need = needs.length ? Math.max.apply(null, needs) : null;
        var lateBy = P.jobLateness(ja), late = ja.some(function (a) { return a.late; }), jx = scale.x(js), jw = scale.x(je) - jx;
        var ji = tipOf({ t: j + " · " + a0.job, late: late, rows: [["Project", p], ["Product", a0.product + " × " + a0.qty], ["Start", fDT(js)], ["End", fDT(je)],
          ["Span", dur(je - js)], ["Need date", fDT(need)], ["Status", late ? "Late by " + dur(lateBy) : need != null ? "On time, " + dur(Math.max(0, need - je)) + " float" : "On time"]] });
        out += '<div class="row j"><div class="lc"><span class="id">' + esc(j) + '</span><span class="t">' + esc(a0.job) + "</span>" +
          (lateBy > 0 ? '<span class="pill">LATE ' + dur(lateBy) + "</span>" : "") + '</div><div class="tc" style="width:' + TW + 'px">' +
          '<div class="sum ' + pc(p) + '" style="left:' + jx + "px;width:" + jw + 'px" data-i="' + ji + '" tabindex="0" aria-label="' + esc(j + " " + a0.job) + '"></div>' +
          '<span class="bl" style="left:' + (jx + jw + 9) + 'px"><small>' + esc(a0.product) + " × " + a0.qty + (need != null ? " · need " + fD(need) : "") + "</small></span></div></div>";
        if (state.level !== "operation") return;
        P.groupOperations(ja).forEach(function (o) {
          var a = o.a;
          out += '<div class="row o"><div class="lc"><span class="id">' + esc(o.opId) + '</span><span class="t" title="' + esc(a.op) + '">' + esc(a.op) + "</span></div>" +
            '<div class="tc" style="width:' + TW + 'px">' + barHTML(a, "out", esc(o.label) + " <small>· " + dur(a.e - a.s) + "</small>", o.label) + "</div></div>";
        });
      });
    });
    return out;
  }

  function resourceRows(acts) {
    var out = "", TW = scale.W + PAD;
    DEPTS.forEach(function (d) {
      var da = acts.filter(function (a) { return a.dept === d; });
      if (!da.length) return;
      var rs = P.uniq(da.map(function (a) { return a.res; }));
      out += '<div class="row p"><div class="lc"><span class="t">' + esc(d) + '</span></div><div class="tc" style="width:' + TW + 'px"><span class="bl" style="left:8px"><small>' +
        rs.length + " resource" + (rs.length > 1 ? "s" : "") + " · " + da.length + " activities</small></span></div></div>";
      rs.forEach(function (r) {
        var ra = da.filter(function (a) { return a.res === r; }).sort(function (x, y) { return x.s - y.s; });
        out += '<div class="row r"><div class="lc"><span class="t" title="' + esc(r) + '">' + esc(r) + '</span></div><div class="tc" style="width:' + TW + 'px">' +
          ra.map(function (a, i) { return barHTML(a, "auto", esc(a.jobId) + " <small>· " + esc(a.op) + "</small>", null, ra[i + 1] ? scale.x(ra[i + 1].s) : null); }).join("") + "</div></div>";
      });
    });
    return out;
  }

  function table(acts) {
    var rows = acts.slice().sort(function (a, b) {
      return PROJECTS.indexOf(a.proj) - PROJECTS.indexOf(b.proj) || a.jobId.localeCompare(b.jobId) || a.opId.localeCompare(b.opId);
    });
    $("tblwrap").innerHTML = "<table><caption class=\"u-VisuallyHidden\">Scheduled activities</caption><thead><tr><th>Project</th><th>Job</th><th>Operation</th><th>Resource</th><th>Department</th><th>Start</th><th>End</th><th>Span</th><th>Need date</th><th>Status</th></tr></thead><tbody>" +
      rows.map(function (a) {
        return '<tr><td><span class="sw ' + pc(a.proj) + '"></span>' + esc(a.proj) + "</td><td>" + esc(a.jobId) + " · " + esc(a.job) + "</td><td>" + esc(a.opId) + " · " + esc(a.op) +
          "</td><td>" + esc(a.res) + "</td><td>" + esc(a.dept) + "</td><td>" + fDT(a.s) + "</td><td>" + fDT(a.e) + "</td><td>" + dur(a.e - a.s) + "</td><td>" + fDT(a.need) +
          '</td><td class="' + (a.late ? "lt" : "") + '">' + esc(a.status) + (a.late && a.need != null ? " · late " + dur(a.e - a.need) : "") + "</td></tr>";
      }).join("") + "</tbody></table>";
  }

  function render() {
    var acts = visible();
    buildFilters(); legend();
    root.querySelectorAll("[data-l]").forEach(function (b) { b.setAttribute("aria-pressed", state.level === b.dataset.l); });
    root.querySelectorAll("[data-v]").forEach(function (b) { b.setAttribute("aria-pressed", state.view === b.dataset.v); });
    $("lvlwrap").style.display = state.view === "project" ? "contents" : "none";
    var isT = state.view === "table";
    $("board").hidden = isT; $("tblwrap").hidden = !isT; $("ganttctl").style.display = isT ? "none" : "contents";
    if (isT) return table(acts);
    tips = []; scale = P.makeScale(acts, state);
    var hd = header(), W = scale.W + PAD;
    var body = state.view === "project" ? projectRows(acts) : resourceRows(acts);
    $("inner").style.width = "calc(var(--lw) + " + W + "px)";
    $("inner").innerHTML = '<div class="grid" style="width:' + W + "px;top:" + hd.hh + 'px">' + hd.g + '</div><div class="hd" style="height:' + hd.hh + 'px"><div class="lc">' +
      (state.view === "project" ? "Project / Job / Operation" : "Department / Resource") + '</div><div class="tc" style="width:' + W + 'px">' + hd.h + "</div></div>" +
      (body || '<div class="row"><div class="lc">No activities match the filters</div></div>');
  }

  var ZOOMS = [8, 14, 24, 40, 64, 100, 150, 230, 340, 520, 800, 1200];
  function fit() {
    var t = P.extent(visible(), state.compress), lw = parseFloat(getComputedStyle(root).getPropertyValue("--lw")) || 290;
    state.ppd = Math.max(4, ($("board").clientWidth - lw - t.breaks * BRK - 230) / Math.max(1, t.days));
    render();
  }
  root.querySelectorAll("[data-z]").forEach(function (b) {
    b.onclick = function () {
      var z = b.dataset.z;
      if (z === "fit") return fit();
      if (z === "in") state.ppd = ZOOMS.find(function (v) { return v > state.ppd * 1.05; }) || state.ppd;
      else state.ppd = ZOOMS.slice().reverse().find(function (v) { return v < state.ppd / 1.05; }) || state.ppd;
      render();
    };
  });
  $("compress").onchange = function (e) { state.compress = e.target.checked; if (!state.compress) fit(); else { state.ppd = 150; render(); } };
  root.querySelectorAll("[data-v]").forEach(function (b) { b.onclick = function () { state.view = b.dataset.v; render(); }; });
  root.querySelectorAll("[data-l]").forEach(function (b) { b.onclick = function () { state.level = b.dataset.l; render(); }; });
  $("filters").addEventListener("change", function (e) {
    var d = e.target.closest(".dd"); if (!d) return;
    var set = F[d.dataset.f];
    if (e.target.checked) set.add(e.target.value); else set.delete(e.target.value);
    if (state.view === "table") render(); else fit();
  });
  $("clear").onclick = function () { F.proj.clear(); F.job.clear(); F.op.clear(); if (state.view === "table") render(); else fit(); };
  document.addEventListener("click", function (e) {
    root.querySelectorAll('[data-r="filters"] .dd[open]').forEach(function (d) { if (!d.contains(e.target)) d.removeAttribute("open"); });
  });
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") root.querySelectorAll('[data-r="filters"] .dd[open]').forEach(function (d) { d.removeAttribute("open"); });
  });

  var tip = $("tip");
  function showTip(el, cx, cy) {
    var t = tips[el.dataset.i]; if (!t) return;
    tip.innerHTML = "<h4>" + esc(t.t) + "</h4><dl>" + t.rows.map(function (r) {
      return "<dt>" + r[0] + "</dt><dd" + ((r[0] === "Status" && t.late) || r[0] === "Late by" ? ' class="lt"' : "") + ">" + esc(r[1]) + "</dd>";
    }).join("") + "</dl>";
    tip.style.display = "block";
    var r = tip.getBoundingClientRect(), x = cx + 14, y = cy + 14;
    if (x + r.width > innerWidth - 8) x = Math.max(8, cx - r.width - 14);
    if (y + r.height > innerHeight - 8) y = Math.max(8, cy - r.height - 14);
    tip.style.left = x + "px"; tip.style.top = y + "px";
  }
  var inner = $("inner");
  inner.addEventListener("mousemove", function (e) { var b = e.target.closest("[data-i]"); if (b) showTip(b, e.clientX, e.clientY); else tip.style.display = "none"; });
  inner.addEventListener("mouseleave", function () { tip.style.display = "none"; });
  inner.addEventListener("focusin", function (e) { var b = e.target.closest("[data-i]"); if (b) { var r = b.getBoundingClientRect(); showTip(b, r.left, r.bottom); } });
  inner.addEventListener("focusout", function () { tip.style.display = "none"; });
  $("board").addEventListener("scroll", function () { tip.style.display = "none"; });

  fit();
})();
