
connect / as sysdba

select reason from dba_outstanding_alerts;

select reason
from dba_alert_history
where upper(reason) like '%COMMIT%' and
      to_date(substr(to_char(creation_time),1,18)||
              substr(to_char(creation_time),26,3)  ,
              'DD-MON-YY HH:MI:SS AM') > sysdate-30/1440
order by creation_time desc;

exec DBMS_SERVER_ALERT.set_threshold(      -
dbms_server_alert.user_commits_sec,        -
dbms_server_alert.operator_ge, 3,          -
dbms_server_alert.operator_ge, 6,          -
1, 2, 'orcl',                              -
dbms_server_alert.object_type_system, null);

col object_name format a20
col metrics_name format a25
col warning_value format a10
col critical_value format a10

select metrics_name,warning_value,critical_value, object_name 
from dba_thresholds;

select reason from dba_outstanding_alerts;

select reason
from dba_alert_history
where upper(reason) like '%COMMIT%' and
      to_date(substr(to_char(creation_time),1,18)||
              substr(to_char(creation_time),26,3)  ,
              'DD-MON-YY HH:MI:SS AM') > sysdate-30/1440
order by creation_time desc;

