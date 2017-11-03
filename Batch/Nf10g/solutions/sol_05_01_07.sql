
connect / as sysdba

select reason from dba_outstanding_alerts;

select reason
from dba_alert_history
where upper(reason) like '%COMMIT%' and
      to_date(substr(to_char(creation_time),1,18)||
              substr(to_char(creation_time),26,3)  ,
              'DD-MON-YY HH:MI:SS AM') > sysdate-30/1440
order by creation_time desc;

