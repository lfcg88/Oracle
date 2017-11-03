/* Lista espaco disponivel totalizado nos extents dos tablespaces */
column sum(bytes) heading " Livre (bytes)" format 999,999,999
column sum(blocks) heading " Livre (blocos)" format 999,999,999
select substr(tablespace_name,1,10) "Tablespace",
       sum(bytes),
       sum(blocks)
from dba_free_space
group by tablespace_name
/
