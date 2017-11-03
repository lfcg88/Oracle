Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista objetos e tipos                         #
Prompt #                                                           #
Prompt #############################################################

col tabela format a40
set lines 500
UNDEFINE object_name
set verify off

accept 1 prompt "Digite o nome do Objeto: "

SELECT OWNER||'.'||OBJECT_NAME TABELA
     , OBJECT_TYPE
     , TO_CHAR(CREATED,'DD/MM/YY HH24:MI') CREATED
     , STATUS
  FROM DBA_OBJECTS
 WHERE OBJECT_NAME LIKE UPPER('%&1%')
--   and OBJECT_NAME NOT LIKE UPPER('%$%')
 ORDER BY 2,1
/


CLEAR COLUMNS
UNDEFINE object_name
set verify on
