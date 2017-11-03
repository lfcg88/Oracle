
set echo on

connect / as sysdba

-- scn 2
flashback database to scn &scn;

alter database open resetlogs;

select tablespace_name from dba_tablespaces;

select count(*) from jfv.emp;

select sum(salary) from jfv.emp;

