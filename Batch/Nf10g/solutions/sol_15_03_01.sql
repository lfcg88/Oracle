
set echo on

connect / as sysdba

create tablespace tbsasmmig
datafile 'asmmig1.dbf' size 10M;

col file_name format a52
col tablespace_name format a10

select file_name,tablespace_name
from dba_data_files;

create table t2(c number) tablespace tbsasmmig;

insert into t2 values(1);

commit;
