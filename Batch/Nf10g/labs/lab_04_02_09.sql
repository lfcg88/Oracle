
connect / as sysdba

drop tablespace tbssga including contents and datafiles;

shutdown immediate;

startup;
