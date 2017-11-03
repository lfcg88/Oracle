column c1  heading "TABLE NAME"      format a15;
column c2  heading "EXTS"            format 999;
column c3  heading "FL"              format 99;
column c4  heading "# OF ROWS"       format 99,999,999;
column c5  heading "#_rows*row_len"  format 9,999,999,999;
column c6  heading "SPACE ALLOCATED" format 9,999,999,999;
column c7  heading "PCT USED"        format 999;
column db_block_size new_value blksz noprint

select value db_block_size from v$parameter where name = 'db_block_size';

set pages 999;
set lines 80;

spool tab_rpt.lst

select
        table_name            c1,
        b.extents             c2,
        b.freelists           c3,
        num_rows              c4,
        num_rows*avg_row_len  c5,
        blocks*&blksz          c6,
        ((num_rows*avg_row_len)/(blocks*&blksz))*100 c7
from
   perfstat.stats$tab_stats a,
   dba_segments b
where
 b.segment_name = a.table_name
and
   to_char(snap_time,'yyyy-mm-dd') = 
      (select max(to_char(snap_time,'yyyy-mm-dd')) from perfstat.stats$tab_stats)
and
   avg_row_len > 500
order by c5 desc
;

spool off;

