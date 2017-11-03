
connect jfv/jfv

create table emp2
tablespace jfvtbs2
as select * from hr.employees;

select * from V$FLASHBACK_DATABASE_STAT;

select undoblks from v$undostat;

begin
 for i in 1..10000 loop
  update emp2 set salary=salary+1;
 end loop;
 commit;
end;
/

select undoblks from v$undostat;

select * from V$FLASHBACK_DATABASE_STAT;
