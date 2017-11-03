
connect fd/fd

create table emp
tablespace tbsfd
as select * from hr.employees;

create table dept
tablespace tbsfd
as select * from hr.departments;

create or replace trigger nothing
before delete or insert or update on emp
begin
null;
end;
/

alter table emp 
add constraint emppk primary key(employee_id);

alter table dept
add constraint deptpk primary key(department_id);

alter table emp
add constraint empfk 
foreign key(department_id) references dept(department_id);

create index empfkindx on emp(department_id);

alter table emp add CONSTRAINT empsalcons CHECK(salary > 0);

alter table emp add CONSTRAINT empidmgrfk 
FOREIGN KEY(manager_id) references emp;

CREATE MATERIALIZED VIEW LOG ON emp;
