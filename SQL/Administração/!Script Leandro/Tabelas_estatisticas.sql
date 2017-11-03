set trimspool on
set linesize 200
set pagesize 58

ttitle center "Estatisticas - Tabelas" skip 1

column owner           heading "Owner"              format a8 
column table_name      heading "Table"              format a21
column pct_free        heading "% Free"             format 990
column pct_used        heading "% Used"             format 990
column ini_trans       heading "Init.Trans."        format 990
column max_trans       heading "Max.Trans."         format 990
column num_rows        heading "# Rows"             format 9G999G990
column empty_blocks    heading "Free Blocks"        format 9G999G990
column avg_space       heading "Avg.Space"          format 9G999G990
column chain_cnt       heading "# Chain."           format 9G999G990
column avg_row_len     heading "Avg.Row"            format 99G990
column degree          heading "Degree"             format 990
column instances       heading "Instances"          format 990
column cache           heading "Cache"              format a5

break on owner

select owner, 
       table_name,
       pct_free,
       pct_used,
       ini_trans,
       max_trans,
       num_rows,
       empty_blocks,
       avg_space, 
       chain_cnt, 
       avg_row_len, 
       degree, 
       instances, 
       cache
from dba_tables
where owner not in ( 'SYS', 'SYSTEM' )
order by owner, 
         table_name
/
