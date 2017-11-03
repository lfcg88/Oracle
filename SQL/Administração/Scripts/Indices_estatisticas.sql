set trimspool on
set linesize 190
set pagesize 64

Accept Indeex_name Prompt 'Digite o nome do Indice : '

ttitle center "Estatisticas - Indices" skip 1 

column owner                   heading "Owner"          format a10
column table_name              heading "Table"          format a25
column index_name              heading "Index"          format a25
column pct_free                heading "% Free"         format 990
column ini_trans               heading "Init.Trans."    format 990
column max_trans               heading "Max.Trans."     format 990
column blevel                  heading "B-Lvl"          format 990
column leaf_blocks             heading "Leaf Blks"      format 9G999G990
column distinct_keys           heading "# Keys"         format 9G999G990
column avg_leaf_blocks_per_key heading "Lf Blk/Key"     format 9G999G990
column avg_data_blocks_per_key heading "Dt Blk/Key"     format 9G999G990
column clustering_factor       heading "Clust."         format 9G999G990
column status                  heading "Status"         format a10

break on owner on table_name

select owner, 
       table_name,
       index_name,
       uniqueness,
       pct_free,
       ini_trans,
       max_trans,
       blevel,
       leaf_blocks,
       distinct_keys,
       avg_leaf_blocks_per_key,
       avg_data_blocks_per_key,
       clustering_factor,
       status
from dba_indexes
where index_name like upper('%&Indeex_name%')
order by owner, 
         table_name,
         index_name
/
