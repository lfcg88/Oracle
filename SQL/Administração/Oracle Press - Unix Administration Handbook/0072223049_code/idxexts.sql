rem idxexts.sql - Lists all indexes where extents are > 5

spool idxexts.lst
set pause off;
set linesize 150;
set pagesize 60;
column c1  heading "Tablespace";
column c2  heading "Owner";
column c3  heading "Index";
column c4  heading "Size (KB)";
column c5  heading "Alloc. Ext";
column c6  heading "Max Ext";
column c7  heading "Init Ext (KB)";
column c8  heading "Next Ext (KB)";
column c9  heading "Pct Inc";
column c10 heading "Pct Free";
break on c1 skip 2 on c2 skip 2
ttitle "dbname Database|Fragmented Indexes";

select  substr(ds.tablespace_name,1,10) c1,
        substr(di.owner||'.'||di.table_name,1,30) c2,
        substr(di.index_name,1,20) c3,
        ds.bytes/1024 c4,
        ds.extents c5,
        di.max_extents c6,
        di.initial_extent/1024 c7,
        di.next_extent/1024 c8,
        di.pct_increase c9,
        di.pct_free c10
from    sys.dba_segments ds,
        sys.dba_indexes di
where   ds.tablespace_name = di.tablespace_name
  and   ds.owner = di.owner
  and   ds.segment_name = di.index_name 
  and   ds.extents > 3
order by 1,2;
