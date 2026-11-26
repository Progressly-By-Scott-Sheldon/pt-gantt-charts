-- Loads the PlanetTogether Activities export 'activities - 2026-11-26 17.27.14.xlsx' (36 activities). Generated; safe to re-run.
-- Run after db/pt_gantt_tables.sql. Re-running replaces the activities of this file.
set define off
merge into pt_projects t using (select 'Boiler Header Assembly' project_name, 1 sort_order from dual) s on (t.project_name = s.project_name)
  when matched then update set t.sort_order = s.sort_order
  when not matched then insert (project_name, sort_order) values (s.project_name, s.sort_order);
merge into pt_projects t using (select 'Boiler Piping Spool' project_name, 2 sort_order from dual) s on (t.project_name = s.project_name)
  when matched then update set t.sort_order = s.sort_order
  when not matched then insert (project_name, sort_order) values (s.project_name, s.sort_order);
merge into pt_projects t using (select 'Membrane Waterwall Panel' project_name, 3 sort_order from dual) s on (t.project_name = s.project_name)
  when matched then update set t.sort_order = s.sort_order
  when not matched then insert (project_name, sort_order) values (s.project_name, s.sort_order);
merge into pt_projects t using (select 'Superheater Coil' project_name, 4 sort_order from dual) s on (t.project_name = s.project_name)
  when matched then update set t.sort_order = s.sort_order
  when not matched then insert (project_name, sort_order) values (s.project_name, s.sort_order);
merge into pt_job_projects t using (select 'JOB-26041' job_external_id, (select project_id from pt_projects where project_name = 'Boiler Header Assembly') project_id from dual) s
  on (t.job_external_id = s.job_external_id)
  when matched then update set t.project_id = s.project_id
  when not matched then insert (job_external_id, project_id) values (s.job_external_id, s.project_id);
merge into pt_job_projects t using (select 'JOB-26044' job_external_id, (select project_id from pt_projects where project_name = 'Boiler Piping Spool') project_id from dual) s
  on (t.job_external_id = s.job_external_id)
  when matched then update set t.project_id = s.project_id
  when not matched then insert (job_external_id, project_id) values (s.job_external_id, s.project_id);
merge into pt_job_projects t using (select 'JOB-26042' job_external_id, (select project_id from pt_projects where project_name = 'Membrane Waterwall Panel') project_id from dual) s
  on (t.job_external_id = s.job_external_id)
  when matched then update set t.project_id = s.project_id
  when not matched then insert (job_external_id, project_id) values (s.job_external_id, s.project_id);
merge into pt_job_projects t using (select 'JOB-26049' job_external_id, (select project_id from pt_projects where project_name = 'Superheater Coil') project_id from dual) s
  on (t.job_external_id = s.job_external_id)
  when matched then update set t.project_id = s.project_id
  when not matched then insert (job_external_id, project_id) values (s.job_external_id, s.project_id);
merge into pt_job_projects t using (select 'JOB-26050' job_external_id, (select project_id from pt_projects where project_name = 'Superheater Coil') project_id from dual) s
  on (t.job_external_id = s.job_external_id)
  when matched then update set t.project_id = s.project_id
  when not matched then insert (job_external_id, project_id) values (s.job_external_id, s.project_id);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'CNC Tube/Plate/Sheet Cutter 01' resource_name, 'Plate, Tube & Pipe Cutting' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'CNC Tube/Plate/Sheet Cutter 02' resource_name, 'Plate, Tube & Pipe Cutting' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'CNC Tube Bender 01' resource_name, 'Bending & Forming' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'CNC Tube Bender 02' resource_name, 'Bending & Forming' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Fit-up Bay 01' resource_name, 'Fit-up & Assembly' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Fit-up Bay 02' resource_name, 'Fit-up & Assembly' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Welder 1' resource_name, 'Welding' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'TIG Cell 01' resource_name, 'Welding' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'SAW Cell 01' resource_name, 'Welding' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Welder 2' resource_name, 'Welding' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'RT / NDT Inspection Bay 01' resource_name, 'NDT / Radiography' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'PWHT Furnace 01' resource_name, 'Heat Treatment' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Hydro Test Station 01' resource_name, 'Hydrostatic Testing' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
merge into pt_resources t using (select 'L&T MHI Power Boilers Pvt Ltd' plant_name, 'Final Inspection & Dispatch Bay 01' resource_name, 'Final Inspection & Dispatch' department_name from dual) s
  on (t.plant_name = s.plant_name and t.resource_name = s.resource_name)
  when matched then update set t.department_name = s.department_name
  when not matched then insert (plant_name, resource_name, department_name) values (s.plant_name, s.resource_name, s.department_name);
delete from pt_activities where source_file = 'activities - 2026-11-26 17.27.14.xlsx';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op010', 'Cutting', 'Ready', to_date('19-11-2026 08:00','DD-MM-YYYY HH24:MI'), to_date('19-11-2026 11:30','DD-MM-YYYY HH24:MI'), to_date('16-11-2026 13:48','DD-MM-YYYY HH24:MI'), 'Y', 30.0, 180.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube/Plate/Sheet Cutter 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op010', 'Cutting', 'Ready', to_date('19-11-2026 08:00','DD-MM-YYYY HH24:MI'), to_date('19-11-2026 11:30','DD-MM-YYYY HH24:MI'), to_date('08-12-2026 16:12','DD-MM-YYYY HH24:MI'), 'N', 30.0, 180.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube/Plate/Sheet Cutter 02';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op020', 'Bending', 'Waiting', to_date('19-11-2026 11:30','DD-MM-YYYY HH24:MI'), to_date('19-11-2026 16:24','DD-MM-YYYY HH24:MI'), to_date('16-11-2026 18:12','DD-MM-YYYY HH24:MI'), 'Y', 30.0, 264.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube Bender 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op020', 'Bending', 'Waiting', to_date('19-11-2026 11:30','DD-MM-YYYY HH24:MI'), to_date('19-11-2026 16:12','DD-MM-YYYY HH24:MI'), to_date('09-12-2026 10:24','DD-MM-YYYY HH24:MI'), 'N', 30.0, 252.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube Bender 02';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op030', 'Fit-up', 'Waiting', to_date('19-11-2026 16:12','DD-MM-YYYY HH24:MI'), to_date('20-11-2026 12:06','DD-MM-YYYY HH24:MI'), to_date('09-12-2026 15:48','DD-MM-YYYY HH24:MI'), 'N', 30.0, 324.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Fit-up Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op030', 'Fit-up', 'Waiting', to_date('19-11-2026 16:24','DD-MM-YYYY HH24:MI'), to_date('20-11-2026 12:12','DD-MM-YYYY HH24:MI'), to_date('16-11-2026 23:00','DD-MM-YYYY HH24:MI'), 'Y', 60.0, 288.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Fit-up Bay 02';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op040', 'Welding - TIG', 'Waiting', to_date('20-11-2026 12:06','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 11:48','DD-MM-YYYY HH24:MI'), 'N', 0.0, 720.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Welder 1';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op040', 'Welding - TIG', 'Waiting', to_date('20-11-2026 12:06','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 11:48','DD-MM-YYYY HH24:MI'), 'N', 0.0, 720.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'TIG Cell 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op040', 'Welding - SAW', 'Waiting', to_date('20-11-2026 12:12','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 08:42','DD-MM-YYYY HH24:MI'), to_date('17-11-2026 12:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 780.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'SAW Cell 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op040', 'Welding - SAW', 'Waiting', to_date('20-11-2026 12:12','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 08:42','DD-MM-YYYY HH24:MI'), to_date('17-11-2026 12:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 780.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Welder 2';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op050', 'NDT / RT', 'Waiting', to_date('23-11-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 10:45','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 14:12','DD-MM-YYYY HH24:MI'), 'N', 15.0, 144.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'RT / NDT Inspection Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op050', 'NDT / RT', 'Waiting', to_date('23-11-2026 10:45','DD-MM-YYYY HH24:MI'), to_date('23-11-2026 13:21','DD-MM-YYYY HH24:MI'), to_date('17-11-2026 14:36','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 156.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'RT / NDT Inspection Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op060', 'PWHT / Heat Treatment', 'Waiting', to_date('23-11-2026 10:45','DD-MM-YYYY HH24:MI'), to_date('24-11-2026 10:51','DD-MM-YYYY HH24:MI'), to_date('11-12-2026 13:48','DD-MM-YYYY HH24:MI'), 'N', 30.0, 576.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'PWHT Furnace 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op060', 'PWHT / Heat Treatment', 'Waiting', to_date('24-11-2026 10:51','DD-MM-YYYY HH24:MI'), to_date('24-11-2026 16:51','DD-MM-YYYY HH24:MI'), to_date('17-11-2026 20:36','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 360.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'PWHT Furnace 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op070', 'Hydro Test', 'Waiting', to_date('24-11-2026 10:51','DD-MM-YYYY HH24:MI'), to_date('24-11-2026 14:21','DD-MM-YYYY HH24:MI'), to_date('11-12-2026 16:48','DD-MM-YYYY HH24:MI'), 'N', 30.0, 180.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Hydro Test Station 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26044', 'Boiler Piping Spool', 'Boiler Piping Spool 350 NB', 12.0, 'Op080', 'Final Inspection & Dispatch', 'Waiting', to_date('24-11-2026 14:21','DD-MM-YYYY HH24:MI'), to_date('25-11-2026 08:58','DD-MM-YYYY HH24:MI'), to_date('12-12-2026 00:00','DD-MM-YYYY HH24:MI'), 'N', 15.0, 72.0, 12.0, 12.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Final Inspection & Dispatch Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op070', 'Hydro Test', 'Waiting', to_date('24-11-2026 16:51','DD-MM-YYYY HH24:MI'), to_date('25-11-2026 09:15','DD-MM-YYYY HH24:MI'), to_date('17-11-2026 23:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 144.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Hydro Test Station 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26041', 'Header Assembly', 'Boiler Header Assembly 600 NB', 2.0, 'Op080', 'Final Inspection & Dispatch', 'Waiting', to_date('25-11-2026 09:15','DD-MM-YYYY HH24:MI'), to_date('25-11-2026 10:15','DD-MM-YYYY HH24:MI'), to_date('18-11-2026 00:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 60.0, 2.0, 2.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Final Inspection & Dispatch Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op010', 'Cutting', 'Waiting', to_date('30-11-2026 11:18','DD-MM-YYYY HH24:MI'), to_date('30-11-2026 14:54','DD-MM-YYYY HH24:MI'), to_date('07-12-2026 13:36','DD-MM-YYYY HH24:MI'), 'N', 0.0, 216.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube/Plate/Sheet Cutter 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op020', 'Bending', 'Waiting', to_date('30-11-2026 14:54','DD-MM-YYYY HH24:MI'), to_date('01-12-2026 11:18','DD-MM-YYYY HH24:MI'), to_date('08-12-2026 10:00','DD-MM-YYYY HH24:MI'), 'N', 0.0, 384.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube Bender 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op030', 'Fit-up', 'Waiting', to_date('01-12-2026 11:18','DD-MM-YYYY HH24:MI'), to_date('02-12-2026 09:18','DD-MM-YYYY HH24:MI'), to_date('09-12-2026 08:00','DD-MM-YYYY HH24:MI'), 'N', 0.0, 480.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Fit-up Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op040', 'Welding - TIG', 'Waiting', to_date('02-12-2026 09:18','DD-MM-YYYY HH24:MI'), to_date('03-12-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('09-12-2026 16:48','DD-MM-YYYY HH24:MI'), 'N', 0.0, 1056.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Welder 1';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op040', 'Welding - TIG', 'Waiting', to_date('02-12-2026 09:18','DD-MM-YYYY HH24:MI'), to_date('03-12-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('09-12-2026 16:48','DD-MM-YYYY HH24:MI'), 'N', 0.0, 1056.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'TIG Cell 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op050', 'NDT / RT', 'Waiting', to_date('03-12-2026 08:06','DD-MM-YYYY HH24:MI'), to_date('03-12-2026 11:42','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 10:24','DD-MM-YYYY HH24:MI'), 'N', 0.0, 216.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'RT / NDT Inspection Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op060', 'PWHT / Heat Treatment', 'Waiting', to_date('03-12-2026 11:42','DD-MM-YYYY HH24:MI'), to_date('04-12-2026 13:42','DD-MM-YYYY HH24:MI'), to_date('11-12-2026 12:24','DD-MM-YYYY HH24:MI'), 'N', 0.0, 720.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'PWHT Furnace 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op070', 'Hydro Test', 'Waiting', to_date('04-12-2026 13:42','DD-MM-YYYY HH24:MI'), to_date('04-12-2026 17:42','DD-MM-YYYY HH24:MI'), to_date('11-12-2026 16:24','DD-MM-YYYY HH24:MI'), 'N', 0.0, 240.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Hydro Test Station 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26042', 'Membrane Waterfall Panel', 'Membrane Waterwall Panel 5000 mm', 8.0, 'Op080', 'Final Inspection & Dispatch', 'Waiting', to_date('04-12-2026 17:42','DD-MM-YYYY HH24:MI'), to_date('07-12-2026 09:18','DD-MM-YYYY HH24:MI'), to_date('14-12-2026 00:00','DD-MM-YYYY HH24:MI'), 'N', 0.0, 96.0, 8.0, 8.0, 0.0, null, 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Final Inspection & Dispatch Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26049', 'Superheater Coil Bent Tube Subassembly (SFG)', 'Superheater Coil - Bent Tube Subassembly', 6.0, 'Op010', 'Cut Superheater Tube Lengths', 'Ready', to_date('19-02-2027 11:37','DD-MM-YYYY HH24:MI'), to_date('19-02-2027 14:01','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 13:42','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 144.0, 6.0, 6.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube/Plate/Sheet Cutter 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26050', 'Superheater Coil Final Welding & Test', 'Superheater Coil Assembly 4200 mm', 6.0, 'Op010', 'TIG Connection Welding', 'Ready', to_date('19-02-2027 11:37','DD-MM-YYYY HH24:MI'), to_date('20-02-2027 13:14','DD-MM-YYYY HH24:MI'), to_date('16-12-2026 15:36','DD-MM-YYYY HH24:MI'), 'Y', 60.0, 1800.0, 6.0, 6.0, 0.0, 'TIG Welding, Welders', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Welder 1';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26050', 'Superheater Coil Final Welding & Test', 'Superheater Coil Assembly 4200 mm', 6.0, 'Op010', 'TIG Connection Welding', 'Ready', to_date('19-02-2027 11:37','DD-MM-YYYY HH24:MI'), to_date('20-02-2027 13:14','DD-MM-YYYY HH24:MI'), to_date('16-12-2026 15:36','DD-MM-YYYY HH24:MI'), 'Y', 60.0, 1800.0, 6.0, 6.0, 0.0, 'TIG Welding, Welders', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'TIG Cell 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26049', 'Superheater Coil Bent Tube Subassembly (SFG)', 'Superheater Coil - Bent Tube Subassembly', 6.0, 'Op020', 'Tube End Preparation / Beveling', 'Waiting', to_date('19-02-2027 14:01','DD-MM-YYYY HH24:MI'), to_date('19-02-2027 15:49','DD-MM-YYYY HH24:MI'), to_date('10-12-2026 15:30','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 108.0, 6.0, 6.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube/Plate/Sheet Cutter 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26049', 'Superheater Coil Bent Tube Subassembly (SFG)', 'Superheater Coil - Bent Tube Subassembly', 6.0, 'Op030', 'Serpentine Tube Bending', 'Waiting', to_date('19-02-2027 15:49','DD-MM-YYYY HH24:MI'), to_date('20-02-2027 06:49','DD-MM-YYYY HH24:MI'), to_date('14-12-2026 10:30','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 900.0, 6.0, 6.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'CNC Tube Bender 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26049', 'Superheater Coil Bent Tube Subassembly (SFG)', 'Superheater Coil - Bent Tube Subassembly', 6.0, 'Op040', 'Coil Geometry / Fixture Fit-up', 'Waiting', to_date('20-02-2027 06:49','DD-MM-YYYY HH24:MI'), to_date('20-02-2027 14:19','DD-MM-YYYY HH24:MI'), to_date('15-12-2026 00:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 450.0, 6.0, 6.0, 0.0, 'Cutting', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Fit-up Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26050', 'Superheater Coil Final Welding & Test', 'Superheater Coil Assembly 4200 mm', 6.0, 'Op020', 'NDT / RT Inspection', 'Waiting', to_date('20-02-2027 13:14','DD-MM-YYYY HH24:MI'), to_date('20-02-2027 20:26','DD-MM-YYYY HH24:MI'), to_date('17-12-2026 12:48','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 432.0, 6.0, 6.0, 0.0, 'TIG Welding, Welders', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'RT / NDT Inspection Bay 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26050', 'Superheater Coil Final Welding & Test', 'Superheater Coil Assembly 4200 mm', 6.0, 'Op030', 'PWHT / Heat Treatment', 'Waiting', to_date('20-02-2027 20:26','DD-MM-YYYY HH24:MI'), to_date('21-02-2027 14:26','DD-MM-YYYY HH24:MI'), to_date('21-12-2026 10:48','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 1080.0, 6.0, 6.0, 0.0, 'TIG Welding, Welders', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'PWHT Furnace 01';
insert into pt_activities (resource_id, job_external_id, job_name, job_product, job_quantity, operation_external_id, operation_name, production_status, scheduled_start, scheduled_end, need_date, is_late, setup_minutes, run_minutes, activity_quantity, remaining_quantity, percent_finished, bottlenecks, source_file)
select resource_id, 'JOB-26050', 'Superheater Coil Final Welding & Test', 'Superheater Coil Assembly 4200 mm', 6.0, 'Op040', 'Hydrostatic Test & Final Release', 'Waiting', to_date('21-02-2027 14:26','DD-MM-YYYY HH24:MI'), to_date('21-02-2027 21:38','DD-MM-YYYY HH24:MI'), to_date('22-12-2026 00:00','DD-MM-YYYY HH24:MI'), 'Y', 0.0, 432.0, 6.0, 6.0, 0.0, 'TIG Welding, Welders', 'activities - 2026-11-26 17.27.14.xlsx'
  from pt_resources where plant_name = 'L&T MHI Power Boilers Pvt Ltd' and resource_name = 'Hydro Test Station 01';
commit;
