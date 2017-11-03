--**************************************************************
--   rpt_avg_sorts_dy.sql
--
--   © 2001 by Donald K. Burleson
--
--   No part of this SQL script may be copied. Sold or distributed
--   without the express consent of Donald K. Burleson
--**************************************************************
set pages 9999;

column sorts_memory  format 999,999,999
column sorts_disk    format 999,999,999
column ratio         format .99999

select 
   to_char(snap_time,'day'),
   avg(newmem.value-oldmem.value) sorts_memory,
   avg(newdsk.value-olddsk.value) sorts_disk
from
   perfstat.stats$sysstat oldmem,
   perfstat.stats$sysstat newmem,
   perfstat.stats$sysstat newdsk,
   perfstat.stats$sysstat olddsk,
   perfstat.stats$snapshot   sn
where
   newdsk.snap_id = sn.snap_id
and
   olddsk.snap_id = sn.snap_id-1
and
   newmem.snap_id = sn.snap_id
and
   oldmem.snap_id = sn.snap_id-1
and
   oldmem.name = 'sorts (memory)'
and
   newmem.name = 'sorts (memory)'
and
   olddsk.name = 'sorts (disk)'
and
   newdsk.name = 'sorts (disk)'
and
   newmem.value-oldmem.value > 0
group by
   to_char(snap_time,'day')
;
