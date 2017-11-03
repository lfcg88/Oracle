rem pctused.sql
set heading off;
set pages 9999;
set feedback off;

spool pctused.lst;
column db_block_size new_value blksz noprint
select value db_block_size from v$parameter where name='db_block_size';

define spare_rows = 2;

select
   ' alter table '||owner||'.'||table_name||
   ' pctused '||least(round(100-((&spare_rows*avg_row_len)/(&blksz/10))),95)||
   ' '||
   ' pctfree '||greatest(round((&spare_rows*avg_row_len)/(&blksz/10)),5)||
   ';'
from
   dba_tables
where 
avg_row_len > 1
and 
avg_row_len < .5*&blksz
and
table_name not in
 (select table_name from dba_tab_columns b
   where
 data_type in ('RAW','LONG RAW','BLOB','CLOB','NCLOB')
 )
order by 
   owner, 
   table_name
;

spool off;
