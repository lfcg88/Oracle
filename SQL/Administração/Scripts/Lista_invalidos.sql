Prompt #############################################################
Prompt #                                                           #
Prompt #                     Lista todos os                        #
Prompt #                   objetos inválidos                       #
Prompt #                                                           #
Prompt #############################################################

set verify off
set heading off
COL OBJECT_TYPE FORMAT A20
COL OBJETO FORMAT A40

SELECT OBJECT_TYPE , OWNER||'.'||OBJECT_NAME OBJETO, TO_CHAR(LAST_DDL_TIME, 'DD/MM/YY HH24:MI:SS') LAST_DDL_TIME
FROM ALL_OBJECTS
WHERE STATUS = 'INVALID'
AND OBJECT_TYPE <> 'UNDEFINED'
/

select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)
|| ' '||owner||'.'|| object_name ||' compile' ||
decode(object_type, 'PACKAGE BODY', ' body;', ';')
from dba_objects
where status = 'INVALID' order by object_type,owner,object_name
/


CLEAR COLUMNS
set verify on
set heading oN

