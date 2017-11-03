Prompt #############################################################
Prompt #                                                           #
Prompt #             Gera script de grants em uma tabela           #
Prompt #                                                           #
Prompt #############################################################

undefine Nm_Owner
undefine Nome_tabela
set verify off
col owner format a12
col grantor like owner
col grantee format a20
COL PRIVILEGE  FORMAT A20

Accept Nm_Owner prompt "Digite o owner da tabela : "
Accept Nome_tabela prompt "Digite o nome da tabela : "

SELECT 'grant '||PRIVILEGE|| ' on '|| owner||'.'||TABLE_NAME|| ' to '||GRANTEE ||';' Comando
 FROM dba_tab_privs
WHERE TABLE_NAME LIKE UPPER('%&&Nome_tabela%')
  and owner LIKE UPPER('%&&Nm_Owner%')
ORDER BY owner
    , TABLE_NAME;

undefine Nm_Owner
undefine Nome_tabela
clear columns
set verify on
