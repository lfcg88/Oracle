
set echo on

connect / as sysdba

drop tablespace tbsasmmig including contents and datafiles;

drop tablespace tbsasm including contents and datafiles;

host rm $ORACLE_HOME/dbs/asmmig1.dbf
