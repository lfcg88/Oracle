                                                

ACCEPT SENHA CHAR PROMPT 'Digite a senha do dbptn_xt:' HIDE
SET LINESIZE 900
SET PAGESIZE 1000
COLUMN WHAT FORMAT a100
COLUMN NLS_ENV FORMAT a250
COLUMN INTERVAL FORMAT a50
COLUMN MISC_ENV FORMAT a20
COLUMN LOG_USER FORMAT a10                      
COLUMN PRIV_USER FORMAT a10
COLUMN SCHEMA_USER FORMAT a10


spool oracle_operacao.log
conn dbptn_xt/&senha@dsvcgmi11
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@select_tabelas_dbptn_xt.sql

Prompt ============================================ nconectados======================================
 


prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

spool off





