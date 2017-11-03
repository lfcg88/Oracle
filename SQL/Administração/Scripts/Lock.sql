Prompt #############################################################
Prompt #                                                           #
Prompt #            Mostra os objetos que estão em lock            #
Prompt #     e também mosta o comando que está causando o lock.    #
Prompt #                                                           #
Prompt #############################################################

SET LINESIZE 1000
set echo off
set feedback on
set linesize 500
col SID_SERIAL format a12
col usuario format a15
col osuser format a15
col owner format a10
col object_name format a30
col machine format a15
col program format a35
col machine format a20
col lockmode format a15
col module format a15
col nom_pessoa format a30

prompt ---- Sessões e objetos envolvidos no lock

Select distinct s.sid||','||s.serial# SID_SERIAL
     , s.username usuario
     , s.logon_time
     , s.status
     , s.osuser
     , p.spid "OS Pid"
     , o.owner||'.'||o.object_name object_name
     , machine
     , module
     , decode( l.locked_mode,
               0, 'None',
               1, 'Null',
               2, 'Row Share',
               3, 'Row Exclusive',
               4, 'Share',
               5, 'SRow-Exclusive',
               6, 'Exclusive',
               to_char(l.locked_mode)) "LockMode"
     , s.lockwait
     , to_char(LOGON_TIME,'dd/mm hh24:mi:ss') LOGON_TIME
     , V.START_TIME
     , s.program
     , s.taddr
     , v.status
     , l.XIDUSN
from dba_objects o 
   , v$locked_object l
   , v$session s
   , v$process p
   , v$sqltext t
   , V$TRANSACTION V
where l.object_id=o.object_id
   and  l.session_id = s.sid
   and  s.paddr = p.addr
   and  t.address = s.sql_address
   and  t.hash_value = s.sql_hash_value
   AND V.ADDR = S.TADDR
   order by l.XIDUSN, s.sid||','||s.serial#;
   
prompt ---- comandos SQL que estão executando no momento

break on SID_SERIAL
col piece format 99

Select distinct s.sid||','||s.serial# SID_SERIAL
     , t.piece
     , t.sql_text
from dba_objects o , v$locked_object l, v$session s,v$process p, v$sqltext t
where l.object_id=o.object_id
   and  l.session_id = s.sid
   and  s.paddr = p.addr
   and  t.address = s.sql_address
   and  t.hash_value = s.sql_hash_value
   order by s.sid||','||s.serial#;


clear columns
clear breaks
