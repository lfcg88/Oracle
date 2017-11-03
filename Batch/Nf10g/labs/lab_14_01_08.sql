connect / as sysdba

exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(10080,30);

drop tablespace tbs_lfszadv including contents and datafiles;

alter database add logfile group 1
'/u01/app/oracle/oradata/orcl/redo01.log' size 10m reuse;

alter database add logfile group 2
'/u01/app/oracle/oradata/orcl/redo02.log' size 10m reuse;

alter database add logfile group 3
'/u01/app/oracle/oradata/orcl/redo03.log' size 10m reuse;

alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 4;

alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 5;

host rm /u01/app/oracle/oradata/orcl/redo4.log
host rm /u01/app/oracle/oradata/orcl/redo5.log

shutdown immediate;

startup;
