
-- wait for 10 minutes. No rows from outstanding.
select reason, message_level
from dba_outstanding_alerts
where object_name='TBSALERT';
