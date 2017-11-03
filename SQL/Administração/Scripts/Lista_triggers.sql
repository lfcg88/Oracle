Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista as triggers de uma tabela               #
Prompt #                                                           #
Prompt #############################################################


set verify off
undefine nome_tabela
col table_owner format a12
col owner format a12

Accept nome_tabela prompt "Digite o nome da Tabela : "

SELECT TABLE_OWNER
     , TABLE_NAME
     , OWNER
     , TRIGGER_NAME
     , STATUS
  FROM ALL_TRIGGERS
 WHERE TABLE_NAME LIKE upper('%&NOME_TABELA%')
 ORDER BY TABLE_OWNER, TABLE_NAME, OWNER
/

undefine nome_tabela
set verify on
clear columns
