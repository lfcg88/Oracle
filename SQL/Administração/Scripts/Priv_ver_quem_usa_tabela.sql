Prompt #############################################################
Prompt #                                                           #
Prompt #              Verifica grants para uma tabela              #
Prompt #                                                           #
Prompt #############################################################

set verify off
col owner format a12
col grantor like owner
col grantee format a20
COL PRIVILEGE  FORMAT A20
BREAK ON owner ON TABLE_NAME

Accept Nome_tabela prompt "Digite o nome da tabela : "

SELECT owner
    , TABLE_NAME
    , GRANTEE 
    , PRIVILEGE 
    , GRANTOR
    , GRANTABLE
 FROM dba_tab_privs
WHERE TABLE_NAME LIKE UPPER('%&Nome_tabela%')
ORDER BY owner
    , TABLE_NAME
    , GRANTEE;

clear columns
set verify on
