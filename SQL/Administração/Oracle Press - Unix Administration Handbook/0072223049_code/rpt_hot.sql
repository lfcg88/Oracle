set pages 9999;
set feedback off;
set verify off;


--prompt
--prompt
--prompt ***********************************************************
--prompt  This will identify any single disk who's read I/O
--prompt  is more than 25% of the total read I/O of the database.
--prompt
--prompt  The "hot" disk should be examined, and the hot table/index
--prompt  should be identified using STATSPACK.
--prompt
--prompt ***********************************************************
--prompt
--prompt
column mydate format a16
column hdisk format a40
column reads  format 999,999,999

select 
   to_char(new.snap_time,'yyyy-mm-dd HH24')  mydate,
   new.hdisk                                 file_name,
   new.kb_read-old.kb_read                   reads
from
   perfstat.stats$iostat old,
   perfstat.stats$iostat new
where
   new.snap_time > sysdate-&1
and
   old.snap_time = new.snap_time-1
and
   new.hdisk = old.hdisk
and
   (new.kb_read-old.kb_read)*10 >
(
select
   (newreads.kb_read-oldreads.kb_read) reads
from
   perfstat.stats$iostat oldreads,
   perfstat.stats$iostat newreads
where
   new.snap_time = newreads.snap_time
and
   newreads.snap_time = new.snap_time
and
   oldreads.snap_time = new.snap_time-1
and
  (newreads.kb_read-oldreads.kb_read) > 0
)
;

--prompt
--prompt
--prompt ***********************************************************
--prompt  This will identify any single disk who's write I/O
--prompt  is more than 10% of the total write I/O of the database.
--prompt ***********************************************************
--prompt

column mydate format a16
column file_name format a40
column writes  format 999,999,999

select 
   to_char(new.snap_time,'yyyy-mm-dd HH24')  mydate,
   new.hdisk                                 file_name,
   new.kb_write-old.kb_write                 writes
from
   perfstat.stats$iostat old,
   perfstat.stats$iostat new
where
   new.snap_time > sysdate-&1
and
   old.snap_time = new.snap_time-1
and
   new.hdisk = old.hdisk
and
   (new.kb_write-old.kb_write)*10 >
(
select
   (newwrites.kb_read-oldwrites.kb_read) writes
from
   perfstat.stats$iostat oldwrites,
   perfstat.stats$iostat newwrites
where
   new.snap_time = newwrites.snap_time
and
   newwrites.snap_time = new.snap_time
and
   oldwrites.snap_time = new.snap_time-1
and
  (newwrites.kb_read-oldwrites.kb_read) > 0
)
;
