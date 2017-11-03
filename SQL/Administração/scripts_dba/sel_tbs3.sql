/* Lista espaco disponivel nos extents dos tablespaces */
select substr(tablespace_name,1,10) "Tablespace",
       file_id,
       count(*)        "Pieces",
       max(blocks)     "Maximo",
       min(blocks)     "Minimo",
       avg(blocks)     "Media",
       sum(blocks)     "Total (blocos)"
from sys.dba_free_space
group by tablespace_name, file_id
/
