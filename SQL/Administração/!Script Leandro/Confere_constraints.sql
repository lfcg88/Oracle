Prompt --###################################################
Prompt --#                                                 #
Prompt --#        Cria scripts para reabilitar as          #
Prompt --#           FKs de um determinado owner           #
Prompt --#                                                 #
Prompt --###################################################


set feedback off
set verify off
set trimspool on
set linesize 1000
set pagesize 1000

SELECT 'alter table '||OWNER||'.'||TABLE_NAME||' ENABLE NOVALIDATE CONSTRAINT '||CONSTRAINT_NAME||';' "-- Comando"
  FROM DBA_CONSTRAINTS
 WHERE CONSTRAINT_TYPE = 'R'
   AND STATUS = 'DISABLED'
/

set feedback on
set verify on
