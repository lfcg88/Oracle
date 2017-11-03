
set echo on

connect / as sysdba

drop user jf cascade;

create user jf identified by jf
default tablespace example
temporary tablespace temp;

grant connect, resource to jf;

drop user mh cascade;

create user mh identified by mh
default tablespace example
temporary tablespace temp;

grant connect, resource to mh;

drop user vpd cascade;

create user vpd identified by vpd
default tablespace example
temporary tablespace temp;

grant connect, resource, dba to vpd;

connect vpd/vpd

drop table employees purge;

create table employees as select * from hr.employees where 1=2;

insert into employees values
(300,'JF','JF','jf@oracle.com','6500000',sysdate,58,1000,0.5,500,10);

insert into employees values
(400,'MH','MH','mh@oracle.com','6500001',sysdate,59,2000,0.6,500,10);

insert into employees values
(500,'CL','CL','cl@oracle.com','6500002',sysdate,60,3000,0.7,600,10);

commit;

grant select on employees to jf;
grant select on employees to mh;
