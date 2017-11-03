
connect / as sysdba

host ps -ef | grep orcl

archive log list

select flashback_on from v$database;

host ls -l $ORACLE_BASE/flash_recovery_area/ORCL*/flashback
