Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica as sessões, os programas e a última query      #
Prompt #            que foi rodada pelo usuário.                   #
Prompt #                                                           #
Prompt #############################################################

set pages 400
COL KILL FORMAT A16
COL OSUSER FORMAT A15
COL HORA FORMAT A18
COL program FORMAT A50
BREAK ON KILL ON OSUSER on HORA

select   B.SID||','||B.SERIAL#||' - '||username KILL
     , B.OSUSER
     , to_char(LOGON_TIME, 'dd/mm hh24:mi:ss') HORA
     , A.sql_text
     , b.program
  from V$sqltext_with_newlines  A
     , V$session                B
 where A.address = B.prev_sql_addr
   AND  username like upper('%&username%')
 ORDER BY B.SID,A.piece
/


clear columns

