Prompt --###################################################
Prompt --#                                                 #
Prompt --#        Cria scripts para desabilitar as         #
Prompt --#           FKs de um determinado owner           #
Prompt --#                                                 #
Prompt --###################################################

Accept Owner prompt "--Digite o owner : "

set feedback off
set verify off
set trimspool on
set linesize 1000
set pagesize 1000

SELECT 'alter table '||OWNER||'.'||TABLE_NAME||' disable constraint '||CONSTRAINT_NAME||';' "-- Comando"
  FROM DBA_CONSTRAINTS
 WHERE OWNER = UPPER('&Owner')
   AND CONSTRAINT_TYPE = 'R'
   AND STATUS = 'ENABLED'
/

set feedback on
set verify on
undefine Owner
