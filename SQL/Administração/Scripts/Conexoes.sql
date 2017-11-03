Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica quais coneções estão ativas no Banco           #
Prompt #                                                           #
Prompt #############################################################


col username format a15
col osuser format a15
col machine format a25
COL SID_SERIAL FORMAT A20

select ''''||SID||','||SERIAL#||'''' SID_SERIAL
,USERNAME
,STATUS
,OSUSER
,to_char(LOGON_TIME,'dd/mm hh24:mi:ss') LOGON_TIME
,MACHINE
,PROGRAM
,MODULE
from v$session
where username is not null
order by status, OSUSER
/


clear columns
