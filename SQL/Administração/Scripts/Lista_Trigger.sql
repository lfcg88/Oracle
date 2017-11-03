rem
rem
set pages 0 feedback off lines 200 long 32000 verify off
Accept Owner Prompt 'Digite o nome do Owner :'
Accept Tabela Prompt 'Digite o nome da Tabela:'

select '/************  STATUS = '||STATUS||'  **************/'
       ||chr(10)||'.'||chr(10)
       ||'create or replace trigger '||DESCRIPTION, trigger_body
from all_triggers
where TABLE_OWNER = upper('&Owner')
  AND TABLE_NAME  = upper('&Tabela')
/

set pages 80 feedback on lines 80 verify on
prompt
prompt
undefine Owner
undefine Tabela
