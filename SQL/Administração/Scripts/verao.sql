
Prompt ##################################
Prompt #                                #
Prompt #             CONSULTAS          #
Prompt #          EM TODAS AS BASES     #
Prompt #                                #
Prompt ##################################

prompt #########################################
prompt #                                       #
prompt # VERIFICAÇÃO DOS BANCOS DE PRODUÇÃO    #
prompt #                                       #
prompt #########################################

ACCEPT senha CHAR PROMPT 'Digite a senha do lfantoni:'HIDE

SET DEFINE ON
SET LINESIZE 2000
SET PAGESIZE 1000



prompt ######################
Prompt Consulta banco DBPTN
Prompt ===================
conn lfantoni/&senha@dbptn
SET SERVEROUTPUT ON
@onde
select count(1) from v$session
select to_char(sysdate,'cc dd/mm/yyyy hh24:mi:ss') data from dual



prompt ######################
Prompt Consulta banco DBPAG
Prompt ===================
conn lfantoni/&senha@dbpag
SET SERVEROUTPUT ON
@onde
select count(1) from v$session
select * from v$session
select to_char(sysdate,'cc dd/mm/yyyy hh24:mi:ss') data from dual


