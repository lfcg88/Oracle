connect / as sysdba

create table emp tablespace tbsbf as select * from hr.employees;
