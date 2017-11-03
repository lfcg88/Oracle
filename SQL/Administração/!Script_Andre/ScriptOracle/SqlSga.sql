rem
rem FUNCTION: Generate a report of SQL Area Memory Usage
rem           showing SQL Text and memory catagories
rem
rem sqlmem.sql 
rem
column sql_text      format a60   heading Text word_wrapped
column sharable_mem               heading Shared|Bytes
column persistent_mem             heading Persistent|Bytes
column loads                      heading Loads
column users         format a15   heading "User"
column executions		  heading "Executions"
column users_executing		  heading "Used By"
start title132 "Users SQL Area Memory Use"
spool rep_out\&db\sqlmem
set long 2000 pages 59 lines 500
break on users
compute sum of sharable_mem on users
compute sum of persistent_mem on users
compute sum of runtime_mem on users
select username users, sql_text, Executions, loads, users_executing, 
sharable_mem, persistent_mem 
from sys.v_$sqlarea a, dba_users b
where a.parsing_user_id = b.user_id
and b.username like upper('%&user_name%')
order by 3 desc,1;
spool off
pause Press enter to continue
clear columns
clear computes
clear breaks
set pages 22 lines 80
ttitle off
