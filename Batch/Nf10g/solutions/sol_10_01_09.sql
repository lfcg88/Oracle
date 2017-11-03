
@$HOME/labs/lab_10_01_09.sql

-- 63.29%
select (select sum(bytes) 
       from dba_extents 
       where tablespace_name='TBSALERT')*100/5177344
from dual;

-- wait for 10 minutes and see critical.
select reason, message_level
from dba_outstanding_alerts
where object_name='TBSALERT';


