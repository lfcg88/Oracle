Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista os índices de uma tabela                #
Prompt #                                                           #
Prompt #############################################################


set verify off
undefine nome_tabela
col TB_OWNER format a8
col table_name format a30
col index_name format a30
col column_name format a30
col IN_OWNER format a8
set lines 1000
break on TB_OWNER on TABLE_NAME on OWNER on IN_OWNER

Accept nome_tabela prompt "Digite o nome da Tabela : "

SELECT INDS.TABLE_OWNER TB_OWNER
     , INDS.TABLE_NAME
     , INDS.OWNER       IN_OWNER
     , INDS.INDEX_NAME
     , INDS.STATUS
  FROM ALL_INDEXES      INDS
 WHERE INDS.TABLE_NAME LIKE upper('%&NOME_TABELA%')
 ORDER BY INDS.TABLE_OWNER, INDS.TABLE_NAME, INDS.OWNER, INDS.INDEX_NAME
/

undefine nome_tabela
set verify on
clear columns
clear breaks
