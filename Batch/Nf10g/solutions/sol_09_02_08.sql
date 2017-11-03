
set echo on

connect hr/hr

SELECT * 
FROM SESSION_HISTORY
ORDER BY snap_time;
