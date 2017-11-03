/* Lista espaco disponivel (2) nos extents dos tablespaces */
column bytes heading "Livre (bytes)" format 999,999,999
column blocks heading "Livre (blocos)" format 999,999,999
select substr(tablespace_name,1,10) "Tablespace",
       file_id,
       block_id,
       bytes,
       blocks
from sys.dba_free_space
/
