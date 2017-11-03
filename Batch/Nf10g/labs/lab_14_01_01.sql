
set echo on

connect / as sysdba

exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(10080,0);

drop tablespace tbs_lfszadv including contents and datafiles;

create tablespace tbs_lfszadv
datafile 'lfszadvA.dbf' size 50m;

drop table t_lfszadv purge;

create table t_lfszadv
(c1 number, c2 char(1), c3 char(1), c4 char(1), c5 char(1000))
tablespace tbs_lfszadv
pctfree 0 storage (initial 4M next 2M pctincrease 0);


begin
 for i in 1 .. 10000 loop
  insert into t_lfszadv values (i, 'a', 'a', 'a', NULL);
 end loop;
 commit;
end;
/
