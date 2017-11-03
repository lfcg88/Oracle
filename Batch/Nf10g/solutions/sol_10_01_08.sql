
-- 53.16%
select (select sum(bytes)
        from dba_extents
        where tablespace_name='TBSALERT')*100/5177344
from dual;

-- wait for 10 minutes and see warning
select reason
from dba_outstanding_alerts
where object_name='TBSALERT';
