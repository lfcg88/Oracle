set heading on
       set pages 70
       set lines 150
       col wu format A18 head "USER aguardando..."
       col ws format A17 head "SID Aguardando... "
       col ws1 format A17 head "Serial Aguardando... "
       col wp format A17 head "PID Aguardando... "
       col hu format A17 head "-- USER Lockador --"
       col hs format A17 head "-- SID Lockador -- "
       col hs1 format A17 head "-- Serial Lockador -- "
       col hp format A17 head "-- PID Lockador --"


SELECT /*+ RULE */
 rpad(substr(A.USERNAME, 1, 15), 15, ' ') wu,
 rpad(substr(to_char(W.SID), 1, 12), 12, ' ') ws,
 rpad(substr(to_char(a.serial#), 1, 12), 12, ' ') ws1,
 rpad(substr(to_char(p1.spid), 1, 12), 12, ' ') wp,
 rpad(substr(B.USERNAME, 1, 15), 15, ' ') hu,
 rpad(substr(to_char(H.SID), 1, 12), 12, ' ') hs,
 rpad(substr(to_char(b.serial#), 1, 12), 12, ' ') hs1,
 rpad(substr(to_char(p2.spid), 1, 12), 12, ' ') hp
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