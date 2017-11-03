
create table employees1 tablespace tbsalert as select * from hr.employees;
create table employees2 tablespace tbsalert as select * from hr.employees;
create table employees3 tablespace tbsalert as select * from hr.employees;
create table employees4 tablespace tbsalert as select * from hr.employees;
create table employees5 tablespace tbsalert as select * from hr.employees;

alter table employees1 enable row movement;
alter table employees2 enable row movement;
alter table employees3 enable row movement;

-- exec dbms_workload_repository.create_snapshot();

BEGIN
 FOR i in 1..5 LOOP
   insert into employees1 select * from employees1;
   insert into employees2 select * from employees2;
   insert into employees3 select * from employees3;
   insert into employees4 select * from employees4;
   insert into employees5 select * from employees5;
   commit;   
 END LOOP;
END;
/

-- exec dbms_workload_repository.create_snapshot();

-- 37.97%
-- select (select sum(bytes) 
--        from dba_extents 
--        where tablespace_name='TBSALERT')*100/5177344
-- from dual;

insert into employees1 select * from employees1;
insert into employees2 select * from employees2;
insert into employees3 select * from employees3;

commit;

-- exec dbms_workload_repository.create_snapshot();
