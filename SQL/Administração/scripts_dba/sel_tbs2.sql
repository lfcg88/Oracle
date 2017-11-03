/* Lista tablespaces, tamanhos e nomes dos datafiles */
column bytes heading "Tamanho (bytes)" format 999,999,999
select substr(tablespace_name,1,15) "Tablespace",
       substr(file_name,1,40) "Arquivo Unix", 
       bytes 
from sys.dba_data_files
order by tablespace_name
/
