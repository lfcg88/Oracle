-- You need to update the path and the size!!!

alter database add logfile 
'/home/oracle/oradata/orcl/redo4.log' size 50m reuse;

alter database add logfile 
'/home/oracle/oradata/orcl/redo5.log' size 50m reuse;

-- drop all logs except the ones added previously with recommended size.

-- need to modify clearly the steps bellow.

col member format a50

select f.member,l.status
from v$log l, v$logfile f
where l.group#=f.group#;

alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 1;

alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 2;

alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 3;
