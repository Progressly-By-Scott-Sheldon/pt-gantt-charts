-- PT_IMPORT: imports a PlanetTogether Jobs or Operations export (.xlsx) uploaded on page 5
-- (Schedule Data) into PT_JOBS or PT_JOB_OPERATIONS. Same rules as db/pt_load.py:
--   * every column of the file whose header matches a table column is stored
--     (header -> upper case, letters and digits only: "External Id" -> EXTERNALID);
--     other columns are skipped and named in the message
--   * Checked/Unchecked -> 1/0, "1,359" / "0%" -> numbers, "11-26-2026 05:49:36 PM" -> dates
--   * PlanetTogether's earlier rows are replaced; rows added on page 5 (INSTANCEID = 'MANUAL') are kept
--   * on any error nothing changes and the error names the column and value
-- Run as WKSP_WKSPDATAPULSE after db/pt_gantt_edit.sql. Safe to re-run.
-- Rollback: DROP PACKAGE pt_import;
set define off

create or replace package pt_import as
  -- Used inside the generated INSERT; p_col names the column in error messages.
  function num (p_value in varchar2, p_col in varchar2) return number;
  function dt  (p_value in varchar2, p_col in varchar2) return date;

  -- p_table: PT_JOBS or PT_JOB_OPERATIONS. Returns a message for the page.
  procedure import_xlsx (p_table     in varchar2,
                         p_content   in blob,
                         p_file_name in varchar2,
                         p_message   out varchar2);
end pt_import;
/

create or replace package body pt_import as

  c_max_cols constant pls_integer := 300;  -- APEX_DATA_PARSER returns COL001 .. COL300

  function num (p_value in varchar2, p_col in varchar2) return number is
    l_v varchar2(4000) := trim(p_value);
  begin
    if l_v is null then return null; end if;
    if l_v = 'Checked' then return 1; end if;
    if l_v = 'Unchecked' then return 0; end if;
    l_v := replace(replace(l_v, ',', ''), '%', '');
    return to_number(l_v, '9999999999999999999999D9999999999', 'NLS_NUMERIC_CHARACTERS=''.,''');
  exception
    when value_error or invalid_number then
      raise_application_error(-20011, 'Column ' || p_col || ': "' || substr(p_value, 1, 100) || '" is not a number.');
  end num;

  function dt (p_value in varchar2, p_col in varchar2) return date is
    l_v varchar2(4000) := trim(p_value);
  begin
    if l_v is null then return null; end if;
    if regexp_like(l_v, '^\d\d-\d\d-\d{4} \d\d?:\d\d(:\d\d)? ?[AP]M$', 'i') then
      return to_date(l_v, case when l_v like '%:%:%' then 'MM-DD-YYYY HH:MI:SS AM' else 'MM-DD-YYYY HH:MI AM' end);
    elsif regexp_like(l_v, '^\d\d-\d\d-\d{4}( \d\d:\d\d(:\d\d)?)?$') then
      return to_date(l_v, case when l_v like '%:%:%' then 'MM-DD-YYYY HH24:MI:SS'
                               when l_v like '%:%' then 'MM-DD-YYYY HH24:MI' else 'MM-DD-YYYY' end);
    elsif regexp_like(l_v, '^\d{4}-\d\d-\d\d([T ]\d\d:\d\d(:\d\d)?)?') then
      return to_date(substr(replace(l_v, 'T', ' '), 1, 19),
                     case when length(l_v) >= 19 then 'YYYY-MM-DD HH24:MI:SS'
                          when length(l_v) >= 16 then 'YYYY-MM-DD HH24:MI' else 'YYYY-MM-DD' end);
    elsif regexp_like(l_v, '^\d+(\.\d+)?$') then
      return date '1899-12-30' + to_number(l_v, '99999999D9999999999', 'NLS_NUMERIC_CHARACTERS=''.,''');  -- Excel serial date
    end if;
    raise_application_error(-20012, 'Column ' || p_col || ': "' || substr(p_value, 1, 100) || '" is not a date.');
  exception
    when others then
      if sqlcode = -20012 then raise; end if;
      raise_application_error(-20012, 'Column ' || p_col || ': "' || substr(p_value, 1, 100) || '" is not a date.');
  end dt;

  procedure import_xlsx (p_table     in varchar2,
                         p_content   in blob,
                         p_file_name in varchar2,
                         p_message   out varchar2) is
    l_table    varchar2(30) := upper(trim(p_table));
    l_label    varchar2(30);
    l_required apex_t_varchar2;
    l_heads    apex_t_varchar2;
    l_sql      varchar2(32767);
    l_cols     varchar2(32767);
    l_vals     varchar2(32767);
    l_skipped  varchar2(4000);
    l_missing  varchar2(4000);
    l_keycol   varchar2(10);
    l_has_inst boolean := false;
    l_rows     pls_integer;
    l_orphans  pls_integer := 0;
    l_seen     apex_t_varchar2 := apex_t_varchar2();

    function norm (p in varchar2) return varchar2 is
    begin
      return upper(regexp_replace(p, '[^A-Za-z0-9]', ''));
    end norm;

    function colref (i in pls_integer) return varchar2 is
    begin
      return 'COL' || lpad(i, 3, '0');
    end colref;
  begin
    if l_table = 'PT_JOBS' then
      l_label := 'job';
      l_required := apex_t_varchar2('JOBID', 'EXTERNALID', 'NAME', 'NOTES');
    elsif l_table = 'PT_JOB_OPERATIONS' then
      l_label := 'operation';
      l_required := apex_t_varchar2('JOBID', 'OPERATIONID', 'NAME', 'EXTERNALID', 'SCHEDULEDSTART', 'SCHEDULEDEND');
    else
      raise_application_error(-20001, 'Unknown table ' || p_table || '.');
    end if;

    if p_content is null or dbms_lob.getlength(p_content) = 0 then
      raise_application_error(-20002, 'Choose a file to import.');
    end if;
    if lower(p_file_name) not like '%.xlsx' or rawtohex(dbms_lob.substr(p_content, 4, 1)) <> '504B0304' then
      raise_application_error(-20003, 'The file is not an Excel workbook (.xlsx).');
    end if;

    -- Header row: the first line of the first sheet, read as one row and turned into a list.
    l_sql := 'select h from (select ';
    for i in 1 .. c_max_cols loop
      l_sql := l_sql || colref(i) || case when i < c_max_cols then ', ' end;
    end loop;
    l_sql := l_sql || ' from table(apex_data_parser.parse(p_content => :b, p_file_name => :n,'
                   || ' p_detect_data_types => ''N'', p_max_rows => 1)) where line_number = 1)'
                   || ' unpivot include nulls (h for c in (';
    for i in 1 .. c_max_cols loop
      l_sql := l_sql || colref(i) || ' as ' || i || case when i < c_max_cols then ', ' end;
    end loop;
    l_sql := l_sql || ')) order by c';
    execute immediate l_sql bulk collect into l_heads using p_content, p_file_name;

    -- Match headers to the table's real (not virtual) columns.
    for i in 1 .. l_heads.count loop
      continue when l_heads(i) is null;
      declare
        l_name varchar2(128) := norm(l_heads(i));
        l_type user_tab_cols.data_type%type;
        l_len  user_tab_cols.char_length%type;
      begin
        if l_name member of l_seen then
          l_skipped := l_skipped || case when l_skipped is not null then ', ' end || l_heads(i) || ' (repeated)';
          continue;
        end if;
        select data_type, char_length into l_type, l_len
          from user_tab_cols
         where table_name = l_table and column_name = l_name and virtual_column = 'NO' and hidden_column = 'NO';
        l_seen.extend; l_seen(l_seen.count) := l_name;
        l_cols := l_cols || case when l_cols is not null then ', ' end || l_name;
        l_vals := l_vals || case when l_vals is not null then ', ' end ||
                  case when l_type = 'NUMBER' then 'pt_import.num(' || colref(i) || ', ''' || l_name || ''')'
                       when l_type = 'DATE' or l_type like 'TIMESTAMP%' then 'pt_import.dt(' || colref(i) || ', ''' || l_name || ''')'
                       else 'substr(' || colref(i) || ', 1, ' || greatest(l_len, 1) || ')' end;
        if l_name = 'INSTANCEID' then l_has_inst := true; end if;
        if l_name = 'JOBID' then l_keycol := colref(i); end if;
      exception
        when no_data_found then
          l_skipped := l_skipped || case when l_skipped is not null then ', ' end || l_heads(i);
      end;
    end loop;

    -- The Operations export also has Job Id, Name and External Id: tell the two files apart.
    declare
      l_all apex_t_varchar2 := apex_t_varchar2();
    begin
      for i in 1 .. l_heads.count loop
        -- no NULLs: MEMBER OF returns NULL, not FALSE, on a list that holds one
        if l_heads(i) is not null then
          l_all.extend; l_all(l_all.count) := norm(l_heads(i));
        end if;
      end loop;
      if l_table = 'PT_JOBS' and 'OPERATIONID' member of l_all then
        raise_application_error(-20008, 'This is the Operations export: import it in the Operations grid. Nothing was imported.');
      elsif l_table = 'PT_JOB_OPERATIONS' and not 'OPERATIONID' member of l_all and 'NOTES' member of l_all then
        raise_application_error(-20008, 'This is the Jobs export: import it in the Jobs grid. Nothing was imported.');
      end if;
    end;

    for i in 1 .. l_required.count loop
      if not l_required(i) member of l_seen then
        l_missing := l_missing || case when l_missing is not null then ', ' end || l_required(i);
      end if;
    end loop;
    if l_missing is not null then
      raise_application_error(-20004, 'This does not look like the PlanetTogether ' || initcap(l_label) ||
        's export: column(s) ' || l_missing || ' not found. Nothing was imported.');
    end if;

    -- Rows without an INSTANCEID would count as manual and never be replaced: mark them.
    if not l_has_inst then
      l_cols := l_cols || ', INSTANCEID';
      l_vals := l_vals || ', ''PT-IMPORT''';
    end if;

    savepoint pt_import_start;
    begin
      execute immediate 'delete from ' || l_table || ' where instanceid <> ''MANUAL''';
      execute immediate 'insert into ' || l_table || ' (' || l_cols || ') select ' || l_vals ||
                        ' from table(apex_data_parser.parse(p_content => :b, p_file_name => :n, p_detect_data_types => ''N''))' ||
                        ' where line_number > 1 and trim(' || l_keycol || ') is not null'
        using p_content, p_file_name;
      l_rows := sql%rowcount;
    exception
      when dup_val_on_index then
        rollback to pt_import_start;
        raise_application_error(-20005, 'The file has the same ' || l_label ||
          ' twice, or one that is already entered by hand. Nothing was imported.');
      when others then
        rollback to pt_import_start;
        if sqlcode = -1400 then  -- cannot insert NULL into ("SCHEMA"."TABLE"."COLUMN")
          raise_application_error(-20006, 'Column ' || regexp_substr(sqlerrm, '"([^"]+)"\)', 1, 1, null, 1) ||
            ' is empty in some rows; it must be filled in. Nothing was imported.');
        end if;
        raise_application_error(-20006, regexp_replace(sqlerrm, '^ORA-\d+: ', '') || ' Nothing was imported.');
    end;

    if l_rows = 0 then
      rollback to pt_import_start;
      raise_application_error(-20007, 'The file has no ' || l_label || ' rows. Nothing was imported.');
    end if;

    if l_table = 'PT_JOB_OPERATIONS' then
      select count(*) into l_orphans
        from pt_job_operations o
       where not exists (select 1 from pt_jobs j where j.jobid = o.jobid);
    end if;

    p_message := 'Imported ' || l_rows || ' ' || l_label || case when l_rows <> 1 then 's' end ||
                 ' from ' || p_file_name || '.' ||
                 case when l_skipped is not null then ' Skipped column(s) not in ' || l_table || ': ' || l_skipped || '.' end ||
                 case when l_orphans > 0 then ' ' || l_orphans || ' operation(s) belong to jobs that are not in Jobs and do not show on the Gantt: import the Jobs file too.' end;
  end import_xlsx;

end pt_import;
/
