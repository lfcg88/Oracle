column c1  heading "Tablespace";
column c2  heading "Owner";
column c3  heading "Table";
column c4  heading "Bytes M" format 9,999;
column c5  heading "Extents" format 999;
column c7  heading "Empty M" format 9,999;
column c6  heading "Blocks M" format 9,999;
column c8  heading "NEXT M" format 999;
column c9  heading "Row space M" format 9,999;
column c10  heading "Pct Full" format .99;
column db_block_size new_value blksz noprint
select value db_block_size from v$parameter where name = 'db_block_size';

select
        substr(dt.table_name,1,10) c3,
        ds.extents c5,
        ds.bytes/1048576 c4,
        dt.next_extent/1048576 c8,
       (dt.empty_blocks*4096)/1048576 c7,
       (avg_row_len*num_rows)/1048576 c9,
       (ds.blocks*&blksize)/1048576 c6,
       (avg_row_len*num_rows)/(ds.blocks*&blksize) c10
from    sys.dba_segments ds,
        sys.dba_tables dt
where   ds.tablespace_name = dt.tablespace_name
and   ds.owner = dt.owner
and   ds.segment_name = dt.table_name
and dt.freelists > 1
and ds.extents > 1
and dt.owner not in ('SYS','SYSTEM')
and (avg_row_len*num_rows)/1048576 > 50
and ds.bytes/1048576 > 20
order by c10;
