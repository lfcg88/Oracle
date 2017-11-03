
exec DBMS_SERVER_ALERT.SET_THRESHOLD(-
dbms_server_alert.tablespace_pct_full,-
dbms_server_alert.operator_ge,50,-
dbms_server_alert.operator_ge,60,-
1,1,NULL,-
dbms_server_alert.object_type_tablespace,'TBSALERT');
