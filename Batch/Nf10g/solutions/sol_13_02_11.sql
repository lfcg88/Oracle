
set echo on

connect / as sysdba

select name from v$datafile;

alter database 
datafile '/u01/app/oracle/product/10.1.0/db_1/dbs/jfvtbs2.dbf' offline for drop;

-- scn1
flashback database to scn &scn;

alter database open read only;

select count(*) from jfv.emp;

select sum(salary) from jfv.emp;

shutdown immediate;

startup mount;

