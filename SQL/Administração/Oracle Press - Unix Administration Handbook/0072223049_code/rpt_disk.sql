column hdisk            format a10;
column mydate           format a15;
column sum_kb_read      format 999,999;
column sum_kb_write     format 999,999;

set pages 999;

break on hdisk skip 1;

select
   hdisk,
--   to_char(snap_time,'yyyy-mm-dd HH24:mi:ss') mydate,
--   to_char(snap_time,'yyyy-mm-dd HH24') mydate,
   to_char(snap_time,'day') mydate,
   sum(kb_read)  sum_kb_read,
   sum(kb_write) sum_kb_write
from
   stats$iostat
group by
   hdisk
   ,to_char(snap_time,'day')
--  ,to_char(snap_time,'yyyy-mm-dd HH24:mi:ss')
--  ,to_char(snap_time,'yyyy-mm-dd HH24')
;
