Prompt #############################################################
Prompt #                                                           #
Prompt #             Cria comando para recompilar                  #
Prompt #                   objetos inválidos                       #
Prompt #                                                           #
Prompt #############################################################

set verify off
set heading off


SELECT 'Prompt Compilando '||OBJECT_TYPE||' - '||OWNER||'.'||OBJECT_NAME||'...'||chr(10)||
       'ALTER '||DECODE(OBJECT_TYPE,'PACKAGE BODY','PACKAGE',OBJECT_TYPE)
       ||' '||OWNER||'.'||OBJECT_NAME||' COMPILE '||
       Decode(Object_type,'PACKAGE BODY',' BODY','')||';'||chr(10)|| 'SHOW ERRORS'  Comando
FROM ALL_OBJECTS
WHERE STATUS = 'INVALID'
  AND OBJECT_TYPE <> 'UNDEFINED'
  AND OWNER NOT IN ('SYSTEM','SYS')
/


set verify on
set heading oN
