-- Editing PT_JOBS and PT_JOB_OPERATIONS on page 5 (Schedule Data).
-- Run as WKSP_WKSPDATAPULSE after db/pt_jobs_load.sql and db/pt_job_operations_load.sql.
-- Safe to re-run.
--
-- Rows added on page 5 get INSTANCEID = 'MANUAL'. db/pt_load.py replaces only the other rows,
-- so they survive loading a new PlanetTogether export. Edits to PlanetTogether's own rows are
-- replaced by the next load.
--
-- Rollback: DROP TRIGGER pt_jobs_biu; DROP TRIGGER pt_job_operations_biu;
--           DROP SEQUENCE pt_jobs_manual_seq; DROP SEQUENCE pt_job_operations_manual_seq;
--           ALTER TABLE pt_job_operations DROP COLUMN late_yn;
set define off

-- Manual ids start far above PlanetTogether's (1407 jobs, 1428 operations on 26 Nov 2026).
create sequence if not exists pt_jobs_manual_seq start with 1000000;
create sequence if not exists pt_job_operations_manual_seq start with 1000000;

-- Yes/No for the grid; LATE stays 1/0 as PlanetTogether publishes it.
declare
  l_n pls_integer;
begin
  select count(*) into l_n from user_tab_columns where table_name = 'PT_JOB_OPERATIONS' and column_name = 'LATE_YN';
  if l_n = 0 then
    execute immediate q'[alter table pt_job_operations add (late_yn varchar2(3) generated always as
      (case late when 1 then 'Yes' else 'No' end) virtual)]';
  end if;
end;
/

create or replace trigger pt_jobs_biu
  before insert or update on pt_jobs
  for each row
begin
  if inserting then
    :new.jobid       := nvl(:new.jobid, pt_jobs_manual_seq.nextval);
    :new.instanceid  := nvl(:new.instanceid, 'MANUAL');
    :new.publishdate := nvl(:new.publishdate, systimestamp);
    :new.scheduled   := nvl(:new.scheduled, 1);
    :new.entrydate   := nvl(:new.entrydate, systimestamp);
  end if;
  :new.externalid := trim(:new.externalid);
  :new.notes      := trim(:new.notes);
end;
/

-- Late = scheduled end after need date: the rule PlanetTogether's own LATE follows
-- (true for all 56 operations of the 26 Nov 2026 publish), so it holds for loaded rows too.
create or replace trigger pt_job_operations_biu
  before insert or update on pt_job_operations
  for each row
begin
  if inserting then
    :new.operationid := nvl(:new.operationid, pt_job_operations_manual_seq.nextval);
    :new.instanceid  := nvl(:new.instanceid, 'MANUAL');
    :new.publishdate := nvl(:new.publishdate, sysdate);
    :new.scheduled   := nvl(:new.scheduled, 1);
  end if;
  if :new.scheduledend < :new.scheduledstart then
    raise_application_error(-20001, 'Scheduled End must be after Scheduled Start.');
  end if;
  :new.late := case when :new.needdate is not null and :new.scheduledend > :new.needdate then 1 else 0 end;
  -- Several resources are stored as "A,B" (the page 5 picker's separator); PlanetTogether
  -- publishes "A, B", so loaded rows are normalised the same way. PT_ACTIVITIES_V splits on ",".
  :new.resourcesused := regexp_replace(trim(:new.resourcesused), '\s*,\s*', ',');
end;
/

-- Normalise rows loaded before this trigger existed (fires the trigger; no other change).
update pt_job_operations set resourcesused = resourcesused where resourcesused like '%, %';
commit;
