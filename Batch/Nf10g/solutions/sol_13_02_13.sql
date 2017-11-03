
connect / as sysdba

drop tablespace jfvtbs including contents and datafiles;

drop user jfv cascade;

shutdown immediate;

startup mount

alter database flashback off;

alter database noarchivelog;

alter database open;


