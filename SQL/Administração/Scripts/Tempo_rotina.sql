SELECT b.username
     , b.logon_time
     , DECODE (target_desc, NULL, DECODE (target, NULL, opname, CONCAT (opname, CONCAT (' - ', target)))
        , DECODE (target, NULL, CONCAT (opname, CONCAT (' : ', target_desc))
        , CONCAT (opname, CONCAT (' : ', CONCAT (target_desc, CONCAT (' - ', target)))))) DESCRICAO
     , sofar blocos_ja_lidos
     , totalwork Blocos_necessarios
     , units
     , start_time
     , trunc(elapsed_seconds/60,2) tempo_decorrido_min
     , trunc((DECODE (sofar, 0, 0, ROUND (elapsed_seconds * (totalwork - sofar) / sofar) ))/60,2) tempo_restante_min
  FROM v$session_longops  a
     , v$session          b
 WHERE a.sid     = b.sid
   And a.serial# = b.serial#
   And sofar     < totalwork
/
