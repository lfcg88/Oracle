/**********************************************************************
 * File:        schema_show_space.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        01-Feb-02
 *
 * Description:
 *      SQL*Plus script to generate another SQL*Plus script to
 *	call the SHOW_SPACE stored procedure for each space-consuming
 *	object in the current schema.
 *
 * Modifications:
 *********************************************************************/
REM
REM Comment this out after the first time you run this script...
start show_space
set echo off feedback off timing off
set pagesize 0 linesize 500 trimspool on trimout on pause off
col current_user new_value V_CURRUSER noprint
select lower(user) current_user from dual;

spool &&V_CURRUSER._show_space.sql
prompt set echo on feedback on timing on serveroutput on size 1000000
prompt
prompt spool &&V_CURRUSER._show_space
prompt
select 'exec show_space('''||object_name||''',p_type=>'''||
	object_type||''',p_partition=>'''||subobject_name||''');'
from	user_objects
where	object_type like 'TABLE%' or object_type like 'INDEX%'
order by object_type desc, object_name asc;
prompt
prompt spool off
spool off
set feedback on timing off
REM
REM Uncomment the next line if you want the generated script to run
REM automatically...
REM start run_schema_show_space
