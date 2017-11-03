
insert into employees4 select * from employees4;
commit; 

-- 58.22%
-- select (select sum(bytes) 
--        from dba_extents 
--        where tablespace_name='TBSALERT')*100/5177344
-- from dual;

-- wait for 10 minutes and see warning: Still shows 52%!
-- select reason 
-- from dba_outstanding_alerts
-- where object_name='TBSALERT';

-- select reason,resolution 
-- from dba_alert_history
-- where object_name='TBSALERT';

-- exec dbms_workload_repository.create_snapshot();

insert into employees5 select * from employees5;
commit; 

-- exec dbms_workload_repository.create_snapshot();
