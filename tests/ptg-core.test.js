// Unit tests for the Schedule Gantt logic. Run: node --test tests/
// Fixture: tests/fixtures/activities.json is the JSON page 4 receives from PT_ACTIVITIES_V
// (PlanetTogether Jobs + Operations publish of 26 Nov 2026: 8 jobs, 56 operations).
const test = require("node:test");
const assert = require("node:assert/strict");
const P = require("../shared-components/static-files/ptg-core.js");
const DATA = require("./fixtures/activities.json");
const A = P.fromRows(DATA.acts);
const DAY = P.DAY;
const F0 = () => ({ proj: new Set(), job: new Set(), op: new Set() });

test("parseDate: database and export formats, as wall-clock UTC", () => {
  assert.equal(P.parseDate("2026-11-19T08:00"), Date.UTC(2026, 10, 19, 8, 0));
  assert.equal(P.parseDate("19-11-2026 08:00"), Date.UTC(2026, 10, 19, 8, 0));
  assert.equal(P.parseDate("20-11-2026 15:48:06"), Date.UTC(2026, 10, 20, 15, 48, 6));
  assert.equal(new Date(P.parseDate("19-11-2026 23:30")).getUTCHours(), 23);
});

test("parseDate: PlanetTogether sentinels and junk are null", () => {
  assert.equal(P.parseDate("01-01-1800 00:00"), null);
  assert.equal(P.parseDate("01-01-9000 00:00"), null);
  assert.equal(P.parseDate("01-01-1800"), null);
  assert.equal(P.parseDate(""), null);
  assert.equal(P.parseDate(null), null);
  assert.equal(P.parseDate("46347.333333333336"), null);
});

test("parseDuration: HH:mm:ss and d.HH:mm:ss", () => {
  assert.equal(P.parseDuration("03:00:00"), 180);
  assert.equal(P.parseDuration("1.06:00:00"), 1800);
  assert.equal(P.parseDuration("00.00:30:00"), 30);
  assert.equal(P.parseDuration("x"), null);
});

test("dataset counts: PT_JOBS (8 jobs, 3 projects) + PT_JOB_OPERATIONS (56 operations)", () => {
  // 7 operations run on two resources, so 56 operations give 63 rows
  assert.equal(A.length, 63);
  assert.equal(P.uniqueActs(A).length, 63);
  assert.deepEqual([...new Set(A.map(a => a.proj))], ["Project 1", "Project 2", "Project 3"]);
  assert.equal(new Set(A.map(a => a.jobId)).size, 8);
  assert.equal(new Set(A.map(a => a.jobId + "|" + a.opId)).size, 56);
  assert.equal(new Set(A.map(a => a.res)).size, 13);
  assert.equal(new Set(A.filter(a => a.late).map(a => a.jobId)).size, 4);
  assert.equal(A.filter(a => a.dept === "Other").length, 0);
  const F = F0(); F.proj.add("Project 2");
  assert.deepEqual(P.filterOptions(A, F, ["Project 1", "Project 2", "Project 3"]).job.map(o => o[0]).sort(), ["JOB-26054", "JOB-26074"]);
  assert.equal(A.filter(a => P.pass(a, F, 3)).length, 18);
  // Name = operation name, External ID = sequence, Product = ProductsList
  const op = A.find(a => a.jobId === "JOB-26041" && a.opId === "Op010");
  assert.equal(op.op, "Cutting");
  assert.equal(op.product, "Boiler Header Assembly 600 NB 2");
});

test("uniqueActs keeps one row per activity id", () => {
  const rows = [{ id: 1, proj: "Project1" }, { id: 1, proj: "Project2" }, { id: 2, proj: "Project2" }, { proj: "x" }, { proj: "y" }];
  assert.deepEqual(P.uniqueActs(rows).map(r => r.proj), ["Project1", "Project2", "x", "y"]);
});

test("cascading filters: project limits jobs; pruned selections are dropped", () => {
  const t = Date.UTC(2026, 0, 5);
  const mk = (proj, jobId, op) => ({ proj, jobId, job: jobId, op, opId: "Op010", s: t, e: t + 3600e3 });
  const S = [mk("Project1", "J1", "Cut"), mk("Project1", "J2", "Bend"), mk("Project2", "J3", "Weld"), mk("Project2", "J1", "Cut")];
  const F = F0();
  F.proj.add("Project2");
  let opt = P.filterOptions(S, F, ["Project1", "Project2"]);
  assert.deepEqual(opt.job.map(o => o[0]).sort(), ["J1", "J3"]);
  F.job.add("J3"); F.op.add("Weld");
  opt = P.filterOptions(S, F, ["Project1", "Project2"]);
  assert.deepEqual(opt.op.map(o => o[0]), ["Weld"], "ops limited to the selected job");
  F.proj.clear(); F.proj.add("Project1");
  P.filterOptions(S, F, ["Project1", "Project2"]);
  assert.equal(F.job.size, 0);
  assert.equal(F.op.size, 0);
});

test("groupOperations: one bar per operation, resources joined with +", () => {
  const ja = A.filter(a => a.jobId === "JOB-26050");
  const ops = P.groupOperations(ja);
  const tig = ops.find(o => o.opId === "Op010");
  assert.deepEqual(tig.res.sort(), ["TIG Cell 01", "Welder Pool"]);
  assert.match(tig.label, /^(TIG Cell 01 \+ Welder Pool|Welder Pool \+ TIG Cell 01)$/);
  const U = A;
  const all = new Set(U.map(a => a.jobId + "|" + a.opId)).size;
  const grouped = [...new Set(U.map(a => a.jobId))].reduce((n, j) => n + P.groupOperations(U.filter(a => a.jobId === j)).length, 0);
  assert.equal(grouped, all);
});

test("jobLateness: latest end minus latest need, 0 when not late", () => {
  const ja = A.filter(a => a.jobId === "JOB-26041");
  // PlanetTogether reports 6.49 lateness days for JOB-26041 in the Jobs publish
  assert.equal(P.dur(P.jobLateness(ja)), "6d 11h");
  assert.equal(P.jobLateness(A.filter(a => a.jobId === "JOB-26044")), 0);
  const t = Date.UTC(2026, 0, 10);
  assert.equal(P.jobLateness([{ late: true, s: t, e: t + DAY, need: t }]), DAY);
  assert.equal(P.jobLateness([{ late: false, s: t, e: t + DAY, need: t }]), 0);
});

test("makeScale: idle gaps hidden -> one break of 80 days", () => {
  const sc = P.makeScale(A, { ppd: 10, compress: true });
  assert.equal(sc.segs.length, 2);
  const gaps = sc.segs.slice(1).map((g, i) => Math.round((g.s - sc.segs[i].e) / DAY));
  assert.deepEqual(gaps, [80]);
  sc.segs.forEach(g => { assert.equal(g.s % DAY, 0); assert.equal(g.e % DAY, 0); });
  // width = days * ppd + one 30 px break per gap
  const days = sc.segs.reduce((n, g) => n + (g.e - g.s) / DAY, 0);
  assert.equal(sc.W, days * 10 + 1 * P.BRK);
  // x is monotonic and maps the first day start to 0
  assert.equal(sc.x(sc.segs[0].s), 0);
  assert.ok(sc.x(sc.segs[1].s) > sc.x(sc.segs[0].e));
});

test("makeScale: t is the inverse of x, breaks snap to a segment edge", () => {
  const sc = P.makeScale(A, { ppd: 10, compress: true });
  sc.segs.forEach(g => {
    const mid = g.s + Math.round((g.e - g.s) / 2);
    assert.equal(sc.t(sc.x(mid)), mid);
  });
  const g0 = sc.segs[0], g1 = sc.segs[1];
  assert.equal(sc.t(g0.x0 + g0.w + 1), g0.e);
  assert.equal(sc.t(g1.x0 - 1), g1.s);
  assert.equal(sc.t(-50), g0.s);
  assert.equal(sc.t(sc.W + 50), sc.segs[sc.segs.length - 1].e);
});

test("makeScale: without compression, one continuous axis", () => {
  const sc = P.makeScale(A, { ppd: 10, compress: false });
  assert.equal(sc.segs.length, 1);
  const s = Math.min(...A.map(a => a.s)), e = Math.max(...A.map(a => a.e));
  assert.equal(sc.segs[0].s, Math.floor(s / DAY) * DAY);
  assert.equal(sc.segs[0].e, Math.ceil(e / DAY) * DAY);
  assert.equal(sc.W, (sc.segs[0].e - sc.segs[0].s) / DAY * 10);
  assert.equal(sc.x(sc.segs[0].s + DAY / 2), 5);
});

test("makeScale: gaps under 36 hours are merged, empty input is safe", () => {
  const t = Date.UTC(2026, 0, 5);
  const acts = [{ s: t, e: t + 3600e3 }, { s: t + 35 * 3600e3, e: t + 36 * 3600e3 }];
  assert.equal(P.makeScale(acts, { ppd: 1, compress: true }).segs.length, 1);
  const acts2 = [{ s: t, e: t + 3600e3 }, { s: t + 4 * DAY, e: t + 4 * DAY + 3600e3 }];
  assert.equal(P.makeScale(acts2, { ppd: 1, compress: true }).segs.length, 2);
  assert.equal(P.makeScale([], { ppd: 1, compress: true }).W, 0);
});
