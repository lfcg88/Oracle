COLUMN "File Name" format A50
COLUMN "% em uso" format 999.99
COLUMN "File Size(K)" format 999,999,999
COLUMN "Em uso(K)" format 999,999,999
COLUMN "Tablespace" format A20


select f.file_name as "File Name",
f.bytes/1024 as "File Size(K)",
(f.bytes - (select sum(fs.bytes) from dba_free_space fs where f.file_id=fs.file_id))/1024 as "Em uso(K)",
100-(select sum(fs.bytes) from dba_free_space fs where f.file_id=fs.file_id)/f.bytes*100 as "% em uso",
f.autoextensible as "Expandivel",
f.tablespace_name as "Tablespace"
from dba_data_files f
order by 4 desc
/