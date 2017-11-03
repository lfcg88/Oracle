conn hr/hr

spool lab_09_02_01.log
create table session_history (
  snap_time  TIMESTAMP WITH LOCAL TIME ZONE,
  num_sessions NUMBER);
exit;
