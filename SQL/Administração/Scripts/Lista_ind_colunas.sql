Prompt #############################################################
Prompt #                                                           #
Prompt #      Lista os índices com suas colunas por tabela         #
Prompt #                                                           #
Prompt #############################################################


set verify off
undefine nome_tabela
col table_name format a33
col index_name format a35
col column_name format a30
set lines 1000
break on TABLE_OWNER on TABLE_NAME on OWNER on INDEX_NAME on STATUS

Accept nome_tabela prompt "Digite o nome da Tabela : "

SELECT INDS.TABLE_OWNER||'.'|| INDS.TABLE_NAME  TABLE_NAME
     , INDS.OWNER||'.'||INDS.INDEX_NAME         INDEX_NAME
     , INDS.STATUS
     , COLS.COLUMN_NAME
  FROM ALL_INDEXES      INDS
     , ALL_IND_COLUMNS  COLS
 WHERE COLS.INDEX_OWNER = INDS.OWNER
   AND COLS.INDEX_NAME  = INDS.INDEX_NAME
   AND COLS.TABLE_OWNER = INDS.TABLE_OWNER
   AND COLS.TABLE_NAME  = INDS.TABLE_NAME
   AND INDS.TABLE_NAME LIKE upper('%&NOME_TABELA%')
 ORDER BY INDS.TABLE_OWNER, INDS.TABLE_NAME, INDS.OWNER, INDS.INDEX_NAME, INDS.STATUS, COLS.COLUMN_POSITION
/

undefine nome_tabela
set verify on
clear columns
clear breaks
