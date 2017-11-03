
create table dept2 tablespace tbsfd as select * from hr.departments;

drop table emp;

create table emp2 tablespace tbsfd as select * from hr.employees;

flashback table FD.EMP to before drop;
