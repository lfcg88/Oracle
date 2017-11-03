set heading off
set verify off
set feedback off
set linesize 150

## -----------------------------------------------------------------------
## Abre spool para criação do arquivo *.sql captando todos objetos ativos 
##('PACKAGE BODY', 'PACKAGE', 'FUNCTION', 'PROCEDURE','TRIGGER', 'VIEW') 
## na instância oracle de produção bdep para compilar os mesmos.
spool /pub/bkp_oracle/script/compile_objects_01.sql

select decode( OBJECT_TYPE, 'PACKAGE BODY', 'alter package ' || OWNER||'.'||OBJECT_NAME || ' compile body;', 'alter ' || OBJECT_TYPE || ' ' || OWNER||'.'||OBJECT_NAME || ' compile;' ) FROM dba_objects WHERE OWNER='CONTBDEPTST' AND OBJECT_TYPE in ( 'PACKAGE BODY', 'PACKAGE', 'FUNCTION', 'PROCEDURE','TRIGGER', 'VIEW' );

select 'exit' from dual;

spool off

## -----------------------------------------------------------------------

exit
