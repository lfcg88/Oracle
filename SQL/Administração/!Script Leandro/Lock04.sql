set heading on
       set pages 70
       set lines 1000
       col wu format A20 head "USER aguardando..."
       col ws format A5 head "SID"
       col ws1 format A7 head "Serial"
       col wp format A7 head "SPID"
       col wd format A20 head "Logon Time"
       col hu format A20 head "-- USER Lockador --"
       col hs format A5 head "SID"
       col hs1 format A7 head "Serial "
       col hp format A7 head "SPID"
       col hd format A20 head "Logon Time"
       col hk format A15 head "Kill command"
       col ha format A40 head "Alter command"


SELECT /*+ RULE */
 substr(A.USERNAME, 1, 15) wu, 
 to_char(W.SID) ws,
 to_char(a.serial#) ws1,
 to_char(p1.spid) wp,
 to_char(a.LOGON_TIME,'dd/mm/yyyy HH24:mi:ss') wd,
 substr(B.USERNAME, 1, 15) hu,
 to_char(H.SID) hs,
 to_char(b.serial#) hs1,
 to_char(p2.spid) hp,
 to_char(b.LOGON_TIME,'dd/mm/yyyy HH24:mi:ss') hd,
 'kill -9 '||rpad(substr(to_char(p2.spid), 1, 12), 12, ' ') hk,
 'ALTER SYSTEM KILL SESSION '''||H.SID||','||b.serial#||''';' HA
  FROM GV$SESSION B,
       GV$LOCK    H,
       GV$LOCK    W,
       GV$SESSION A,
       GV$process p1,
       GV$process p2
 WHERE H.LMODE <> 0
   AND H.LMODE <> 1
   AND W.REQUEST <> 0
   AND H.CTIME > 60
   AND B.USERNAME NOT IN ('PERFANALYSIS')
   AND H.TYPE = W.TYPE
   AND H.ID1 = W.ID1
   AND H.ID2 = W.ID2
   AND B.SID = H.SID
   AND B.INST_ID = H.INST_ID
   AND W.SID = A.SID
   AND W.INST_ID = A.INST_ID
   AND A.paddr = P1.addr
   AND B.paddr = P2.addr
 ORDER BY H.ctime desc;