SET LINESIZE 500
SET PAGESIZE 1000
 
COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20
 
SELECT DISTINCT
       NVL(s.username, '(oracle)') AS username,
       s.schemaname,
       s.inst_id,
       s.status,
       s.osuser,
       s.sid,
       s.serial#,
       p.spid,
       s.lockwait,
       s.status,
       s.module,
       s.machine,
       s.program,
       s.blocking_session,
       s.event,
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
                    Q1.SQL_TEXT SQLATUAL,
       dbms_lob.substr(Q1.SQL_TEXT,4000) SQLATUAL2,
       Q1.SQL_ID,
       Q2.SQL_TEXT SQLANTERIOR
FROM   gv$session s,
       gv$process p,
       gv$sql q1,
       gv$sql q2
WHERE  s.paddr   = p.addr
AND    s.inst_id = p.inst_id
AND    p.spid    in (&1)
AND    s.sql_id = q1.sql_id (+)
AND    s.inst_id = q1.inst_id (+)
AND    s.prev_sql_id = q2.sql_id (+)
AND    s.inst_id = q2.inst_id (+)
--AND    s.sid IN (240)
--AND    s.inst_id = 1
--AND    s.status = 'ACTIVE'
--AND    s.username is not null
--AND    s.username IN ('DWDISCOVERER')
--AND    s.machine like 'TRTRIO\ARCHON'
--AND    s.program like '%J0%'
--AND      s.osuser like '%edmar%'
--AND    q1.sql_text LIKE 'INSERT INTO TB_TEMP_PARTE%'
--AND    s.state in ('WAITING')
--AND    wait_class != 'Idle'
--AND    event='enq: TX - row lock contention'
--AND      s.lockwait is not null
ORDER
BY s.sid,
s.serial#
/