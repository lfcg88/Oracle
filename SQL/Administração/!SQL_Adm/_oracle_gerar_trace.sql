select * from v$session
where username = 'RM'


-- 62
-- 242

100, 122, 143, 162, 182, 221, 242


show parameter USER_DUMP_DEST

-- local do trace
D:\oracle\diag\rdbms\rmstg\rmstg\trace 

EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(82);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(100);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(122);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(143);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(162);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(182);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(221);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(242);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(262);
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(282);


EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(82);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(100);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(122);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(143);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(162);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(182);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(221);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(242);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(262);
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE(282);

