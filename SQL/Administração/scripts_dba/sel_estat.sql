/* Lista estatisticas (exatas) de tabela(s) de um owner */

set space 3 

column table_name format a28 heading "NOME DA TABELA" 
column tablespace_name format a25 heading "TABLESPACE" fold_after 1

select table_name,
       tablespace_name,
       num_rows              "Num.linhas", 
       blocks + empty_blocks "Total de blocos", 
       avg_space             "Freespc/blk",
       chain_cnt             "Chained",
       avg_row_len           "Tam.med.linha"
from sys.dba_tables
where owner = upper('ops$&owner') and
      table_name like upper('&tabela')
order by table_name
/

set space 1

