set pages 9999;
set lines 80;
set feedback on;
set echo off;
set verify off;

Spool check_env.lst;

Prompt - check for LONG columns
Prompt - These can be converted to CLOB or BLOB datatypes
select 
   '&1 '||owner||'.'||table_name||'.'||column_name 
from 
dba_tab_columns 
where 
   data_type in ('LOMG','LONG RAW')
and
   owner not in ('CODEMGR','SYS','SYSTEM')
;

Prompt - count tables
Select '&1', count(*) from dba_tables where owner not in ('SYS','SYSTEM');

Prompt - count indexes
Select '&1', count(*) from dba_indexes where owner not in ('SYS','SYSTEM');

Prompt - check for snapshots
select '&1', owner, name, master from dba_snapshots;

Prompt - check for database links
select * from dba_db_links;

Prompt - check for MTS
select '&1', substr(name,1,20), value from v$parameter
where name = 'mts_servers' and value not like '0%';

Prompt check for multiple freelists in tables
select '&1', table_name, freelists from dba_tables
where freelists > 1;

Prompt - check for multiple freelists in indexes
select '&1', index_name, freelists from dba_indexes
where freelists > 1;

Prompt - check for multiple freelist groups in indexes
select '&1', index_name, freelist_groups from dba_indexes
where freelist_groups > 1;

Prompt - count chained rows
column percent format 99
column owner format a10
column table_name format a20
column index_name format a20
select
   '&1', 
   owner,
   table_name,
   num_rows,
   chain_cnt ,
   (chain_cnt/num_rows)*100 percent
from 
   dba_tables
where
chain_cnt > 100
;
Prompt - check parallel tables
select '&1', table_name, degree from dba_tables
where degree > 1;

Prompt - check SGA parms:
select '&1', substr(name,1,20), value from v$parameter
where name in (
'shared_pool_size',
'db_block_buffers',
'db_block_size',
'sort_area_size',
'optimizer_mode');

Prompt - High-use sql
select '&1', max(executions) from v$sql;

Prompt check for tables where pctused > 50
select '&1', table_name, pct_used from dba_tables
where pct_used > 50 and table_name not like 'EXP%';

Prompt - Check redo log space requests
select '&1', name, value from v$sysstat where name like 'redo log space requests';

Prompt - Check log switch frequency
set lines 120;
set pages 999;

select substr(first_time,1,5) day,
   to_char(sum(decode(substr(first_time,10,2),'00',1,0)),'99') "00",
   to_char(sum(decode(substr(first_time,10,2),'01',1,0)),'99') "01",
   to_char(sum(decode(substr(first_time,10,2),'02',1,0)),'99') "02",
   to_char(sum(decode(substr(first_time,10,2),'03',1,0)),'99') "03",
   to_char(sum(decode(substr(first_time,10,2),'04',1,0)),'99') "04",
   to_char(sum(decode(substr(first_time,10,2),'05',1,0)),'99') "05",
   to_char(sum(decode(substr(first_time,10,2),'06',1,0)),'99') "06",
   to_char(sum(decode(substr(first_time,10,2),'07',1,0)),'99') "07",
   to_char(sum(decode(substr(first_time,10,2),'08',1,0)),'99') "08",
   to_char(sum(decode(substr(first_time,10,2),'09',1,0)),'99') "09",
   to_char(sum(decode(substr(first_time,10,2),'10',1,0)),'99') "10",
   to_char(sum(decode(substr(first_time,10,2),'11',1,0)),'99') "11",
   to_char(sum(decode(substr(first_time,10,2),'12',1,0)),'99') "12",
   to_char(sum(decode(substr(first_time,10,2),'13',1,0)),'99') "13",
   to_char(sum(decode(substr(first_time,10,2),'14',1,0)),'99') "14",
   to_char(sum(decode(substr(first_time,10,2),'15',1,0)),'99') "15",
   to_char(sum(decode(substr(first_time,10,2),'16',1,0)),'99') "16",
   to_char(sum(decode(substr(first_time,10,2),'17',1,0)),'99') "17",
   to_char(sum(decode(substr(first_time,10,2),'18',1,0)),'99') "18",
   to_char(sum(decode(substr(first_time,10,2),'19',1,0)),'99') "19",
   to_char(sum(decode(substr(first_time,10,2),'20',1,0)),'99') "20",
   to_char(sum(decode(substr(first_time,10,2),'21',1,0)),'99') "21",
   to_char(sum(decode(substr(first_time,10,2),'22',1,0)),'99') "22",
   to_char(sum(decode(substr(first_time,10,2),'23',1,0)),'99') "23"
from v$log_history
group by substr(first_time,1,5)
;

spool off;
