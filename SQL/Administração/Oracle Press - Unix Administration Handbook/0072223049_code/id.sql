select file_name,
   bytes/1048576
from dba_data_files
where
tablespace_name = upper('&1');
