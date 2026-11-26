-- PT_ACTIVITIES_V: what the Schedule Gantt (page 4) reads. One row per operation and resource.
-- Run after db/pt_gantt_tables.sql, db/pt_jobs_load.sql and db/pt_job_operations_load.sql.
-- Safe to re-run.
--
-- 1. PlanetTogether operations (PT_JOB_OPERATIONS) joined to their job (PT_JOBS) on JOBID:
--      project   = PT_JOBS.NOTES, text before any "_" ("Project 1", "Project1_Job035" -> "Project1")
--      job       = PT_JOBS.EXTERNALID (JOB-26041) and PT_JOBS.NAME
--      name      = PT_JOB_OPERATIONS.NAME (Cutting ...)
--      external  = PT_JOB_OPERATIONS.EXTERNALID (Op010 = sequence)
--      product   = PT_JOB_OPERATIONS.PRODUCTSLIST (filled on one operation per job), else PT_JOBS.PRODUCT
--      start/end = SCHEDULEDSTART / SCHEDULEDEND, need date = NEEDDATE, late = LATE
--    An operation on several resources ("SAW Cell 01, Welder Pool") gives one row per resource.
--    Departments come from PT_RESOURCES by resource name; unknown resources go under "Other".
-- 2. Activities entered by hand on page 5 (PT_ACTIVITIES rows without a source file).
--    Rows loaded from the earlier activities export are not shown: the operations replace them.
--
-- PlanetTogether writes 01-01-0001 / 01-01-1800 / 01-01-9000 for "no date": those become NULL.
set define off

create or replace view pt_activities_v as
with ops as (
  select o.*,
         max(o.productslist) over (partition by o.jobid) as job_products_list
    from pt_job_operations o
),
op_res as (
  select o.operationid, r.n, trim(r.res) as resource_name
    from ops o
    cross join lateral (
      select regexp_substr(o.resourcesused, '[^,]+', 1, level) as res, level as n
        from dual
     connect by level <= nvl(regexp_count(o.resourcesused, ','), 0) + 1
    ) r
),
job_codes as (
  select externalid as job_external_id, max(regexp_substr(notes, '^[^_]+')) as project_code
    from pt_jobs
   where notes is not null
   group by externalid
)
select to_char(o.operationid) || '-' || orr.n                         as activity_id,
       nvl(regexp_substr(j.notes, '^[^_]+'), j.externalid)            as project_name,
       cast(null as number)                                          as project_id,
       nvl(to_number(regexp_substr(j.notes, '\d+')), 999)            as project_sort,
       j.externalid                                                  as job_external_id,
       j.name                                                        as job_name,
       coalesce(o.job_products_list, j.product)                      as job_product,
       j.qty                                                         as job_quantity,
       o.externalid                                                  as operation_external_id,
       o.name                                                        as operation_name,
       r.resource_id,
       nvl(orr.resource_name, '(no resource)')                       as resource_name,
       nvl(r.department_name, 'Other')                               as department_name,
       r.plant_name,
       case when o.finished = 1 then 'Finished' when o.started = 1 then 'Started' else 'Scheduled' end
                                                                     as production_status,
       o.scheduledstart                                              as scheduled_start,
       o.scheduledend                                                as scheduled_end,
       case when extract(year from o.needdate) between 1900 and 8999 then o.needdate end
                                                                     as need_date,
       case o.late when 1 then 'Y' else 'N' end                      as is_late,
       o.setuphours * 60                                             as setup_minutes,
       o.runhrs * 60                                                 as run_minutes,
       o.requiredfinishqty                                           as activity_quantity,
       o.remainingfinishqty                                          as remaining_quantity,
       to_number(null)                                               as percent_finished,
       case o.bottleneck when 1 then o.requiredcapabilities end      as bottlenecks
  from ops o
  join pt_jobs j on j.jobid = o.jobid
  join op_res orr on orr.operationid = o.operationid
  left join pt_resources r on r.resource_name = orr.resource_name
 where o.scheduledstart is not null
   and o.scheduledend is not null
union all
select 'M' || a.activity_id,
       coalesce(jc.project_code, p.project_name, a.job_product, a.job_name, a.job_external_id),
       p.project_id,
       case when jc.project_code is not null
            then nvl(to_number(regexp_substr(jc.project_code, '\d+')), 999)
            else 1000 + nvl(p.sort_order, 999) end,
       a.job_external_id, a.job_name, a.job_product, a.job_quantity,
       a.operation_external_id, a.operation_name,
       r.resource_id, r.resource_name, r.department_name, r.plant_name,
       a.production_status,
       a.scheduled_start, a.scheduled_end, a.need_date, a.is_late,
       a.setup_minutes, a.run_minutes,
       a.activity_quantity, a.remaining_quantity, a.percent_finished, a.bottlenecks
  from pt_activities a
  join pt_resources r on r.resource_id = a.resource_id
  left join job_codes jc on jc.job_external_id = a.job_external_id
  left join pt_job_projects jp on jp.job_external_id = a.job_external_id and jc.job_external_id is null
  left join pt_projects p on p.project_id = jp.project_id
 where a.source_file is null;
