set heading off
set verify off
set feedback off
set linesize 150

spool /pub/bkp_oracle/script/kill_users_01.sql

select 'alter system kill session ''' || sid || ',' || SERIAL# || '''  IMMEDIATE;' from v$session where username NOT IN ('SYS','SYSTEM',);

select 'exit' from dual;

spool off

exit
