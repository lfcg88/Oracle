
set echo on

connect hr/hr

BEGIN
  DBMS_SCHEDULER.CREATE_SCHEDULE (
   schedule_name => 'SESS_UPDATE_SCHED',
   start_date => SYSTIMESTAMP,
   repeat_interval => 'FREQ=SECONDLY;INTERVAL=3',
   comments => 'Every three seconds');
END;
/

