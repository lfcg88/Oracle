/******************************************************/
--  DBMS_TRANSACTION.USE_ROLLBACK_SEGMENT('BSIZE');
--  Execute Immediate 'SET TRANSACTION USE ROLLBACK SEGMENT BSIZE';
/******************************************************/


SELECT b.name
     , b.username 
     , a.username
     , a.osuser
     , a.machine
     , a.module
     , a.logon_time
From v$session a
   , ( SELECT r.name ,
                      p.pid "ORACLE PID",
                      p.spid ,
                      NVL ( p.username , 'NO TRANSACTION') username ,
                      p.terminal, l.sid
       FROM v$lock l, v$process p, v$rollname r
       WHERE  l.sid = p.pid(+)
       AND TRUNC (l.id1(+)/65536) = r.usn
       AND l.type(+) = 'TX'
       AND l.lmode(+) = 6
       ORDER BY r.name) b
Where b.sid = a.sid;
