
connect / as sysdba

exec DBMS_SERVER_ALERT.SET_THRESHOLD(-
dbms_server_alert.tablespace_pct_full,-
NULL,NULL,NULL,NULL,1,1,NULL,-
dbms_server_alert.object_type_tablespace,NULL);
