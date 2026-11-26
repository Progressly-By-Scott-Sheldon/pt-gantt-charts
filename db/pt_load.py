"""Generate SQL that loads two PlanetTogether publish exports into the Progressly DB.

    python -I db/pt_load.py <jobs.xlsx> <operations.xlsx>

  jobs.xlsx        PlanetTogether Jobs publish (e.g. 1st.xlsx): one row per job, with
                   Job Id, External Id, Name, Notes (= project), Product ...
  operations.xlsx  PlanetTogether Operations publish (e.g. "Data - ... Op.xlsx"): one row per
                   operation, with Job Id, Name, External Id (Op010 = sequence), ProductsList,
                   Scheduled Start / End, Need Date, Late, ResourcesUsed ...

Writes, next to this script:
  pt_jobs_load.sql            replaces the contents of PT_JOBS (pages 2-4 read it)
  pt_job_operations_load.sql  creates PT_JOB_OPERATIONS if needed, replaces its contents

Every column of both exports is stored as it is (header -> upper case, letters and digits
only, e.g. "External Id" -> EXTERNALID). Values are converted the way PT_JOBS stores them:
Checked/Unchecked -> 1/0, "1,359" / "0%" -> numbers, "11-26-2026 05:49:36 PM" -> dates.
Standard library only, so it runs on any machine with Python 3.
"""
import os
import re
import sys
import zipfile
import xml.etree.ElementTree as ET

NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
HERE = os.path.dirname(os.path.abspath(__file__))

# PT_JOBS as it exists in WKSP_WKSPDATAPULSE (column -> type). Columns of the export that are
# not listed here are skipped for PT_JOBS.
PT_JOBS_TYPES = {
    "PUBLISHDATE": "TIMESTAMP", "INSTANCEID": "VARCHAR2", "JOBID": "NUMBER", "CUSTOMERS": "VARCHAR2",
    "ENTRYDATE": "TIMESTAMP", "NEEDDATETIME": "TIMESTAMP", "CLASSIFICATION": "VARCHAR2", "COMMITMENT": "VARCHAR2",
    "HOT": "NUMBER", "HOTREASON": "VARCHAR2", "IMPORTANCE": "NUMBER", "CANCELLED": "NUMBER", "LATEPENALTYCOST": "NUMBER",
    "MAXEARLYDELIVERYDAYS": "NUMBER", "PRIORITY": "NUMBER", "TYPE": "VARCHAR2", "REVENUE": "NUMBER", "PROFIT": "NUMBER",
    "SCHEDULED": "NUMBER", "SCHEDULEDSTARTDATETIME": "TIMESTAMP", "SCHEDULEDENDDATETIME": "TIMESTAMP",
    "LEADRESOURCE": "VARCHAR2", "STARTSINDAYS": "NUMBER", "LATENESSDAYS": "NUMBER", "LATE": "NUMBER", "OVERDUE": "NUMBER",
    "DESCRIPTION": "VARCHAR2", "NOTES": "VARCHAR2", "FINISHED": "NUMBER", "NAME": "VARCHAR2", "DONOTDELETE": "NUMBER",
    "EXTERNALID": "VARCHAR2", "LOCKED": "VARCHAR2", "ANCHORED": "VARCHAR2", "ORDERNUMBER": "VARCHAR2", "ONHOLD": "VARCHAR2",
    "ONHOLDREASON": "VARCHAR2", "TEMPLATE": "NUMBER", "CUSTOMEREMAIL": "VARCHAR2", "AGENTEMAIL": "VARCHAR2",
    "DONOTSCHEDULE": "NUMBER", "COLORCODE": "VARCHAR2", "ENTRYMETHOD": "VARCHAR2", "HOLDUNTIL": "TIMESTAMP",
    "PERCENTFINISHED": "NUMBER", "SCHEDULEDSTATUS": "VARCHAR2", "STANDARDHOURS": "NUMBER", "BOTTLENECKS": "VARCHAR2",
    "CANSPANPLANTS": "NUMBER", "COMMITMENTPRESERVED": "NUMBER", "DONOTDELETEPRESERVED": "NUMBER",
    "DONOTSCHEDULEPRESERVED": "NUMBER", "EARLIESTDELIVERY": "TIMESTAMP", "ENTEREDTODAY": "NUMBER",
    "EXPECTEDRUNHOURS": "NUMBER", "EXPECTEDSETUPHOURS": "NUMBER", "FAILEDTOSCHEDULEREASON": "VARCHAR2", "HOLD": "NUMBER",
    "HOLDREASON": "VARCHAR2", "LABORCOST": "NUMBER", "MACHINECOST": "NUMBER", "MATERIALCOST": "NUMBER",
    "OVERDUEDAYS": "NUMBER", "PERCENTOFSTANDARDHRS": "NUMBER", "PERCENTOVERSTANDARDHRS": "NUMBER", "PRODUCT": "VARCHAR2",
    "PRODUCTDESCRIPTION": "VARCHAR2", "QTY": "NUMBER", "REPORTEDRUNHOURS": "NUMBER", "REPORTEDSETUPHOURS": "NUMBER",
    "SCHEDULINGHOURS": "NUMBER", "STARTED": "NUMBER", "THROUGHPUT": "NUMBER", "SHIPPINGCOST": "NUMBER",
    "EXPECTEDLATEPENALTYCOST": "NUMBER", "SUBCONTRACTCOST": "NUMBER", "TOTALCOST": "NUMBER", "PRINTED": "NUMBER",
    "INVOICED": "NUMBER", "SHIPPED": "VARCHAR2", "DESTINATION": "VARCHAR2", "REVIEWED": "NUMBER",
    "PERCENTOFMATERIALSAVAILABLE": "NUMBER", "SUCCESSORORDERNUMBERS": "VARCHAR2", "RESOURCENAMES": "VARCHAR2",
    "LOWLEVELCODE": "NUMBER",
}

DATE_RE = re.compile(r"^\d\d-\d\d-\d{4} \d\d:\d\d:\d\d [AP]M$")
NUM_RE = re.compile(r"^-?[\d,]*\.?\d+%?$")
FLAG = {"Checked": "1", "Unchecked": "0"}


def read_xlsx(path):
    """First sheet as (headers, rows of strings). Stops at the first empty header."""
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        ss = []
        if "xl/sharedStrings.xml" in names:
            for si in ET.fromstring(z.read("xl/sharedStrings.xml")).findall(NS + "si"):
                ss.append("".join(t.text or "" for t in si.iter(NS + "t")))
        sheet = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))

    def col(ref):
        n = 0
        for ch in re.match(r"[A-Z]+", ref).group():
            n = n * 26 + ord(ch) - 64
        return n - 1

    rows = []
    for r in sheet.iter(NS + "row"):
        row = {}
        for c in r.findall(NS + "c"):
            v, t = c.find(NS + "v"), c.get("t")
            if t == "inlineStr":
                val = "".join(x.text or "" for x in c.iter(NS + "t"))
            elif v is None:
                val = ""
            elif t == "s":
                val = ss[int(v.text)]
            else:
                val = v.text
            row[col(c.get("r"))] = val
        rows.append(row)
    hdr = []
    for i in range(max(rows[0]) + 1):
        h = rows[0].get(i, "")
        if not h:
            break
        hdr.append(h)
    data = [[r.get(i, "") for i in range(len(hdr))] for r in rows[1:]]
    return hdr, [d for d in data if any(x.strip() for x in d)]


def colname(h):
    return re.sub(r"[^A-Za-z0-9]", "", h).upper()


def lit(v, typ):
    v = (v or "").strip()
    if v == "":
        return "null"
    if typ == "NUMBER":
        v = FLAG.get(v, v)
        if not NUM_RE.match(v):
            raise ValueError("not a number: %r" % v)
        return v.replace(",", "").rstrip("%")
    if typ in ("DATE", "TIMESTAMP"):
        if not DATE_RE.match(v):
            raise ValueError("not a date: %r" % v)
        return "to_date('%s', 'MM-DD-YYYY HH:MI:SS AM')" % v
    return "'" + v.replace("'", "''") + "'"


def infer(values):
    vals = [v.strip() for v in values if v.strip()]
    if not vals:
        return "VARCHAR2"
    if all(DATE_RE.match(v) for v in vals):
        return "DATE"
    if all(v in FLAG or NUM_RE.match(v) for v in vals):
        return "NUMBER"
    return "VARCHAR2"


def inserts(table, cols, types, rows, idx):
    out = []
    for r in rows:
        out.append("insert into %s (%s)\nvalues (%s);" % (
            table, ", ".join(cols), ", ".join(lit(r[idx[c]], types[c]) for c in cols)))
    return out


def main(jobs_path, ops_path):
    # ---- PT_JOBS ----
    jh, jrows = read_xlsx(jobs_path)
    jidx = {colname(h): i for i, h in enumerate(jh)}
    jcols = [c for c in jidx if c in PT_JOBS_TYPES]
    for need in ("JOBID", "EXTERNALID", "NAME", "NOTES"):
        if need not in jidx:
            sys.exit("%s: column for %s not found" % (jobs_path, need))
    out = ["-- Generated by db/pt_load.py from %s (%d jobs). Replaces PT_JOBS." % (os.path.basename(jobs_path), len(jrows)),
           "-- Skipped export columns (not in PT_JOBS): %s" % (", ".join(c for c in jidx if c not in PT_JOBS_TYPES) or "none"),
           "set define off", "whenever sqlerror exit failure rollback", "delete from pt_jobs;"]
    out += inserts("pt_jobs", jcols, PT_JOBS_TYPES, jrows, jidx)
    out.append("commit;")
    open(os.path.join(HERE, "pt_jobs_load.sql"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")

    # ---- PT_JOB_OPERATIONS ----
    oh, orows = read_xlsx(ops_path)
    ocols = [colname(h) for h in oh]
    if len(set(ocols)) != len(ocols):
        sys.exit("%s: two headers give the same column name" % ops_path)
    oidx = {c: i for i, c in enumerate(ocols)}
    for need in ("JOBID", "OPERATIONID", "NAME", "EXTERNALID", "SCHEDULEDSTART", "SCHEDULEDEND"):
        if need not in oidx:
            sys.exit("%s: column for %s not found" % (ops_path, need))
    otypes = {c: infer([r[oidx[c]] for r in orows]) for c in ocols}
    otypes["JOBID"] = otypes["OPERATIONID"] = "NUMBER"
    ddl = ",\n".join("  %-40s %s" % (c, "VARCHAR2(4000 CHAR)" if otypes[c] == "VARCHAR2" else otypes[c]) for c in ocols)
    out = ["-- Generated by db/pt_load.py from %s (%d operations)." % (os.path.basename(ops_path), len(orows)),
           "-- PlanetTogether Operations publish, every column as it is. Replaces the contents of PT_JOB_OPERATIONS.",
           "-- Links to PT_JOBS on JOBID. Rollback: DROP TABLE pt_job_operations;",
           "set define off", "whenever sqlerror exit failure rollback",
           "create table if not exists pt_job_operations (\n%s,\n  constraint pt_job_operations_pk primary key (operationid)\n);" % ddl,
           "create index if not exists pt_job_operations_job_ix on pt_job_operations (jobid);",
           "delete from pt_job_operations;"]
    out += inserts("pt_job_operations", ocols, otypes, orows, oidx)
    out.append("commit;")
    open(os.path.join(HERE, "pt_job_operations_load.sql"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print("PT_JOBS: %d rows, %d columns; PT_JOB_OPERATIONS: %d rows, %d columns" % (len(jrows), len(jcols), len(orows), len(ocols)))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
