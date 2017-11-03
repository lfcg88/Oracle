
set echo on

connect / as sysdba

select * from v$asm_diskgroup;

host ps -ef | grep orcl

create tablespace tbsasm
datafile '+DGROUP1' size 200M;

host ps -ef | grep orcl

col file_name format a46

select file_name,tablespace_name
from dba_data_files;

