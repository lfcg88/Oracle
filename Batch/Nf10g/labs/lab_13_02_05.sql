
set echo on

connect jfv/jfv

create table emp
tablespace jfvtbs
as select * from hr.employees;

select sum(salary) from emp;

-- scn2
select current_scn from v$database;

select undoblks from v$undostat;

select * from V$FLASHBACK_DATABASE_LOG;

select * from V$FLASHBACK_DATABASE_STAT;
