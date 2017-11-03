
connect / as sysdba

exec DBMS_SERVER_ALERT.set_threshold(-
dbms_server_alert.user_commits_sec,-
null,null, -
null,null, -
1, 1, 'orcl', -
dbms_server_alert.object_type_system, null);

exec dbms_aqadm.disable_db_access('ALERT_USR1','SYSTEM');

exec DBMS_AQADM.REMOVE_SUBSCRIBER('SYS.ALERT_QUE',-
AQ$_AGENT('ALERT_USR1','',0));

-- exec DBMS_AQADM.REMOVE_SUBSCRIBER('SYS.ALERT_QUE',-
-- AQ$_AGENT('ALERT_USR1',null,0));
