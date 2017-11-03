set heading off
set verify off
set feedback off
set linesize 150

spool /pub/bkp_oracle/script/bkp_ol.sql

select 'alter tablespace ' || name || ' begin backup;' from v$tablespace;

select 'host /bin/cp ' || name || ' /pub/bkp_oracle/backup_online/' from v$datafile;

select 'alter tablespace ' || name || ' end backup;' from v$tablespace;

select 'exit' from dual;

spool off

exit
