
select reason,message_level,resolution 
from dba_alert_history
where object_name='TBSALERT';
