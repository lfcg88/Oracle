Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #             Lista código da Procedure                     #
Prompt -- #                                                           #
Prompt -- #############################################################

set trimspool on
set feedback off
set heading off
set verify off
set lines 32767
set pages 0


accept wrk_nome_obj prompt "-- Digite o Owner.Nome da Procedure: "

Prompt -- .

SELECT DECODE(ROWNUM,1,'CREATE '||TYPE
       ||' '||OWNER||'.'||ltrim(replace(upper(TEXT),TYPE,'')),text)
  FROM all_source
 WHERE name  = upper(substr('&wrk_nome_obj',instr('&wrk_nome_obj','.',1,1)+1))
   AND owner = upper(substr('&wrk_nome_obj',1,instr('&wrk_nome_obj','.',1,1)-1) )
 ORDER BY type, line
/

Prompt /

undefine objectstr
set feedback on
set heading on
set verify on
set feedback oN
set heading oN
set verify oN
set lines 100
set pages 100
set linesize 150


