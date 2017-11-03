-------------------------------------------------------------------------------------------------------
-- quicktune.sql
-------------------------------------------------------------------------------------------------------
SET FEEDBACK OFF;
SET HEADING ON;
SET ECHO OFF;
SET PAGESIZE 50000;
SET LINESIZE 122;
CLEAR SCREEN;
spool quicktune.log;

prompt
prompt =======================================================================================================
prompt QUICK TUNE PARAMETERS
prompt =======================================================================================================
prompt
prompt DATABASE INFO
column date_of_run                format a30;
column open_time                  format a30;
column block_size_bytes           format a20;

select d.name DATABASE,
       to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') DATE_OF_RUN,
       to_char(open_time, 'DD-MON-YYYY HH24:MI:SS') OPEN_TIME,
       value BLOCK_SIZE_BYTES
  from v$database d,
       v$parameter p,
       v$thread t
 where p.name = 'db_block_size';

prompt
prompt
prompt =======================================================================================================
prompt
prompt DB BUFFER CACHE HIT RATIO > 80%
prompt else increase DB_BLOCK_BUFFERS
column "DB BUFFER CACHE HIT RATIO" format 999,999,999,999,999,999.9999

select (1-c.value/(a.value+b.value+0.000001))*100 "DB BUFFER CACHE HIT RATIO"
  from v$sysstat a, v$sysstat b, v$sysstat c, v$sysstat d
 where a.name = 'db block gets' -- 'logical_reads' = 'db block gets' + 'consistent gets'
   and b.name = 'consistent gets'
   and c.name = 'physical reads'
   and d.name = 'physical writes';

prompt
prompt
prompt =======================================================================================================
prompt
prompt DICTIONARY CACHE HIT RATIO > 99%
prompt else increase SHARED_POOL_SIZE
column "DICTIONARY CACHE HIT RATIO" format 999.9999

select (1-sum(getmisses)/sum(gets))*100 "DICTIONARY CACHE HIT RATIO"
  from v$rowcache;

prompt
prompt
prompt =======================================================================================================
prompt
prompt LIBRARY CACHE HIT RATIO > 99%
prompt else increase SHARED_POOL_SIZE, OPEN_CURSORS
column "LIBRARY CACHE HIT RATIO" format 999.9999

select (1-sum(reloads)/sum(pins))*100 "LIBRARY CACHE HIT RATIO"
  from v$librarycache;

prompt
prompt
prompt =======================================================================================================
prompt
prompt LIBRARY CACHE - GET and PIN HIT RATIO > 70%
prompt else increase SHARED_POOL_SIZE
column "LIBRARY CACHE GET HIT RATIO" format 999.9999
column "LIBRARY CACHE PIN HIT RATIO" format 999.9999

select min(gethitratio)*100 "LIBRARY CACHE GET HIT RATIO",
       min(pinhitratio)*100 "LIBRARY CACHE PIN HIT RATIO"
  from v$librarycache
 where namespace IN ('SQL AREA', 'TABLE/PROCEDURE', 'BODY', 'TRIGGER');

prompt
prompt
prompt =======================================================================================================
prompt
prompt REDO BUFFER ALLOCATION RETRIES RATIO < 1%
prompt else increase LOG_BUFFER
column "REDO ALLOCATION RETRIES RATIO" format 999.9999

select a.value/(b.value+0.0001)*100 "REDO ALLOCATION RETRIES RATIO"
  from v$sysstat a, v$sysstat b
 where a.name = 'redo buffer allocation retries'
   and b.name = 'redo writes';

prompt
prompt
prompt =======================================================================================================
prompt
prompt REDO BUFFER SPACE REQUEST RATIO < 0.02%
prompt else increase LOG_BUFFER
column "REDO SPACE REQUEST RATIO" format 999.9999

select a.value/(b.value+0.0001)*100 "REDO SPACE REQUEST RATIO"
  from v$sysstat a, v$sysstat b
 where a.name = 'redo log space requests'
   and b.name = 'redo entries';

prompt
prompt
prompt =======================================================================================================
prompt
prompt FREE_MEMORY/SHARED_POOL RATIO < 1%
prompt else decrease SHARED_POOL_SIZE
column "FREE_MEMORY/SHARED_POOL RATIO" format 999.9999

select min(least((b.bytes/(c.value+0.0001)),1)*100) "FREE_MEMORY/SHARED_POOL RATIO"
  from v$sgastat b, v$parameter c
 where b.name = 'free memory'      -- sometimes 'free memory' shows all RAM
   and c.name = 'shared_pool_size';

prompt
prompt
prompt =======================================================================================================
prompt
prompt FREE_MEMORY/SHARED_POOL_RESERVED RATIO < 50%
prompt else decrease SHARED_POOL_RESERVED_SIZE, SHARED_POOL_RESERVED_MIN_ALLOC
column "FREE_MEMORY/SP_RES RATIO" format 999.9999

select min(least((b.bytes/(c.value+0.0001)),1)*100) "FREE_MEMORY/SP_RES RATIO"
  from v$sgastat b, v$parameter c
 where b.name = 'free memory'      -- sometimes 'free memory' shows all RAM
   and c.name = 'shared_pool_reserved_size';

prompt
prompt
prompt =======================================================================================================
prompt
prompt SHARED POOL SIZES RATIOS < 10%
prompt else decrease SHARED_POOL_RESERVED_SIZE, SHARED_POOL_RESERVED_MIN_ALLOC
column "SP_RES/SP RATIO" format 999.9999
column "SP_RES_MIN_ALLOC/SP_RES RATIO" format 999.9999

select (b.value/(a.value+0.0001))*100 "SP_RES/SP RATIO",
       (to_number(replace(c.value,'K','000'))/(b.value+1000))*100 "SP_RES_MIN_ALLOC/SP_RES RATIO"
  from v$parameter a, v$parameter b, v$parameter c
 where a.name = 'shared_pool_size'
   and b.name = 'shared_pool_reserved_size'
   and c.name = 'shared_pool_reserved_min_alloc';

prompt
prompt
prompt =======================================================================================================
prompt
prompt SHARED POOL REQUESTS RATIOS < 1%
prompt else increase SHARED_POOL_RESERVED_SIZE, SHARED_POOL_RESERVED_MIN_ALLOC
column "REQUEST MISSES RATIO" format 999.9999
column "REQUEST FAILURES RATIO" format 999.9999

select (request_misses/(requests+0.0001))*100 "REQUEST MISSES RATIO",
       (request_failures/(requests+0.0001))*100 "REQUEST FAILURES RATIO"
  from v$shared_pool_reserved;

prompt
prompt
prompt =======================================================================================================
prompt
prompt SHARED POOL RESERVED MINALLOC SIZE RATIOS < 99%
prompt else increase SHARED_POOL_RESERVED_SIZE, SHARED_POOL_RESERVED_MIN_ALLOC
column "SP_RES_MIN_ALLOC/LAST_FAIL" format 999.9999
column "SP_RES_MIN_ALLOC/AVG_FREE" format 999.9999

select (to_number(replace(a.value,'K','000'))
             /greatest(b.max_used_size,b.last_failure_size,(to_number(replace(a.value,'K','000')))))*100
             "SP_RES_MIN_ALLOC/LAST_FAIL",
       (to_number(replace(a.value,'K','000'))
             /greatest(b.avg_free_size,(to_number(replace(a.value,'K','000')))))*100
             "SP_RES_MIN_ALLOC/AVG_FREE"
  from v$parameter a, v$shared_pool_reserved b
 where a.name = 'shared_pool_reserved_min_alloc';

prompt
prompt
prompt =======================================================================================================
prompt
prompt SORT AREA SIZE RATIOS < 50%
prompt else decrease SORT_AREA_SIZE, SORT_AREA_RETAINED_SIZE
column "SORT_AREA/SHARED_POOL" format 999.9999
column "SA_RETAINED/SORT_AREA" format 999.9999

select (b.value/(a.value+0.0001))*100 "SORT_AREA/SHARED_POOL",
       (c.value/(b.value+0.0001))*100 "SA_RETAINED/SORT_AREA"
  from v$parameter a, v$parameter b, v$parameter c
 where a.name = 'shared_pool_size'
   and b.name = 'sort_area_size'
   and c.name = 'sort_area_retained_size';

prompt
prompt
prompt =======================================================================================================
prompt
prompt SORT IN MEMORY/TOTAL RATIO > 99%
prompt else increase SORT_AREA_SIZE, SORT_AREA_RETAINED_SIZE
column "SORT IN MEMORY/TOTAL RATIO" format 999.9999

select (a.value/(a.value+b.value+0.0001))*100 "SORT IN MEMORY/TOTAL RATIO"
  from v$sysstat a, v$sysstat b
 where a.name = 'sorts (memory)'
   and b.name = 'sorts (disk)';

prompt
prompt
prompt =======================================================================================================
prompt
prompt CPU TIME WAIT RATIO < 1%
prompt else increase SESSION_CACHED_CURSORS, DB_BLOCK_BUFFERS
column "CPU TIME WAIT RATIO" format 999.9999

select (a.value-b.value)/(c.value+0.0001)*100 "CPU TIME WAIT RATIO"
  from v$sysstat a, v$sysstat b, v$sysstat c
 where a.name = 'parse time elapsed'
   and b.name = 'parse time cpu'
   and c.name IN ('parse count', 'parse count (total)');

prompt
prompt
prompt =======================================================================================================
prompt
prompt RBS PERFORMANCE HIT RATIO > 99%
prompt else more RBS are needed
column "RBS PERFORMANCE HIT RATIO" format 999.9999;

select (1-max(w.count/sum(s.value)))*100 "RBS PERFORMANCE HIT RATIO"
  from v$waitstat w, v$sysstat s
 where w.class IN ('system undo header',
                   'system undo block',
                   'undo header',
                   'undo block')
   and s.name IN  ('db block gets', 'consistent gets') -- "Total Number of Requests for Data"
 group by w.count;

prompt
prompt
prompt =======================================================================================================
prompt
prompt RBS SEGMENT CONTENTION RATIO < 1%
prompt else more RBS are needed
column "RBS SEGMENT CONTENTION RATIO" format 999.9999

select max(waits/gets)*100 "RBS SEGMENT CONTENTION RATIO"
  from v$rollstat;

prompt
prompt
prompt =======================================================================================================
prompt
prompt FREELIST CONTENTION RATIO < 1%
prompt else recreate table with increased freelists
column "FREELIST CONTENTION RATIO" format 999.9999;

select w.count/sum(s.value)*100 "FREELIST CONTENTION RATIO"
  from v$waitstat w, v$sysstat s
 where w.class IN ('free list')
   and s.name IN  ('db block gets', 'consistent gets') -- "Total Number of Requests for Data"
 group by w.count;

prompt
prompt
prompt =======================================================================================================
prompt
prompt LATCH W2W_MISS/IMMED_MISS RATIO < 1%
prompt else decrease LOG_SMALL_ENTRY_MAX_SIZE
column "LATCH W2W MISS RATIO" format 999.9999
column "LATCH IMMED MISS RATIO" format 999.9999

select max((l.misses/(l.gets+l.misses+0.0001))*100) "LATCH W2W MISS RATIO",
       max((l.immediate_misses/(l.immediate_gets+l.immediate_misses+0.0001))*100) "LATCH IMMED MISS RATIO"
  from v$latch l;

prompt
prompt
prompt =======================================================================================================
prompt
prompt MAX SESSION EVENT AVERAGE WAIT = 0
prompt else contention exists
column "MAX SESSION EVENT AVERAGE WAIT" format 999,999,999.9999;

select max(average_wait) "MAX SESSION EVENT AVERAGE WAIT"
  from v$session_event;

prompt
prompt
prompt =======================================================================================================
prompt
prompt MTS DISPATCHER BUSY RATE RATIO < 50%
prompt else increase MTS_MAX_DISPATCHERS
column "MTS DISPATCHER BUSY RATE RATIO" format 999.9999

select NVL(sum(busy)/sum(busy+idle),0)*100 "MTS DISPATCHER BUSY RATE RATIO"
  from v$dispatcher;

prompt
prompt
prompt =======================================================================================================
prompt
prompt MTS DISPATCHER TIME WAIT RATIO < 1%
prompt else increase MTS_MAX_DISPATCHERS
column "MTS DISPATCHER TIME WAIT RATIO" format 999.9999

select NVL(sum(q.wait)/(sum(q.totalq)+0.0001),0)*100 "MTS DISPATCHER TIME WAIT RATIO"
  from v$queue q, v$dispatcher d
 where q.type IN ('DISPATCHER', 'COMMON')
   and q.paddr = d.paddr;

prompt
prompt
prompt =======================================================================================================
prompt
prompt I/O BALANCE RATIOS < 100%
prompt else re-locate datafiles
column FS_SIZE_STDDEV_RATIO       format 999.999   heading "FILE|SYSTEM|SIZES|STANDARD|DEVIATION|RATIO"
column PHYS_READS_STDDEV_RATIO    format 999.999   heading "PHYSICAL|READS|STANDARD|DEVIATION|RATIO"
column PHYS_WRITES_STDDEV_RATIO   format 999.999   heading "PHYSICAL|WRITES|STANDARD|DEVIATION|RATIO"

select stddev(sum(a.bytes))/avg(sum(a.bytes))*100 FS_SIZE_STDDEV_RATIO,
       stddev(sum(b.phyrds))/avg(sum(b.phyrds))*100 PHYS_READS_STDDEV_RATIO,
       stddev(sum(b.phywrts))/avg(sum(b.phywrts))*100 PHYS_WRITES_STDDEV_RATIO
  from v$datafile a,
       v$filestat b
 where a.file# = b.file#
 group by substr(name,1,instr(name,'/',-1)), substr(name,1,instr(name,'\',-1));

prompt
prompt
prompt =======================================================================================================
prompt
prompt I/O CONTENTION
prompt
prompt =======================================================================================================
prompt
column TOTALS                     format a44               heading "DATABASE";
column file_system_name           format a44               heading "File System|Name";
column tablespace_name            format a44               heading "TableSpace|Name";
column file_name                  format a44               heading "File|Name";
column MBytes                     format 9,999,999         heading "Size|(MBytes)";
column phyblkrd                   format 9,999,999         heading "Number|Blocks|Read|(000's)";
column phyblkwrt                  format 9,999,999         heading "Number|Blocks|Written|(000's)";
column read_time_per_block_msec   format 9,999,999         heading "Time|to|Read|1 Block|(msecs)";
column write_time_per_block_msec  format 9,999,999         heading "Time|to|Write|1 Block|(msecs)";
column avg_access_time_tot        format 9,999,999         heading "Average|Time|to|Read/Write|1 Block|(msecs/blk)";
column avg_access_time            format 9,999,999         heading "SORTED|ON THIS|COLUMN|:|Average|Time|to|Read/Write|1 Block|(msecs/blk)";
column avg_access_speed           format 9,999,999         heading "Average|Speed|to|Read/Write|1 Second|(blks/sec)";
column avg_estimated_srcer_speed  format 9,999.999         heading "Estimated|Average|SRCER|Perform.|(recs/sec)";
column avg_estimated_rlser_speed  format 9,999.999         heading "Estimated|Average|RLSER|Perform.|(recs/sec)";
column tps                        format 9,999.999         heading "ORACLE TRANSACTIONS PER SECOND";
column spt                        format 9,999.999         heading "     SECONDS PER ORACLE TRANSACTION";

select d.name DATABASE,
       to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') DATE_OF_RUN,
       to_char(open_time, 'DD-MON-YYYY HH24:MI:SS') OPEN_TIME,
       value BLOCK_SIZE_BYTES
  from v$database d,
       v$parameter p,
       v$thread t
 where p.name = 'db_block_size';

SET FEEDBACK ON;

select 'TOTALS' TOTALS ,
       sum(bytes)/(1024*1024) MBytes,
       sum(phyblkrd)/1000 phyblkrd,
       sum(phyblkwrt)/1000 phyblkwrt,
       (sum(readtim)*10)/(sum(phyblkrd)+1) read_time_per_block_msec,
       (sum(writetim)*10)/(sum(phyblkwrt)+1) write_time_per_block_msec,
       (((sum(readtim)*10)/(sum(phyblkrd)+1))*(sum(phyblkrd)) + ((sum(writetim)*10)/(sum(phyblkwrt)+1))*(sum(phyblkwrt))) /
         (sum(phyblkrd) + sum(phyblkwrt) + 1)
          avg_access_time_tot,
       (sum(phyblkrd) + sum(phyblkwrt)) /
         (((((sum(readtim)*10)/(sum(phyblkrd)+1))*(sum(phyblkrd)) + ((sum(writetim)*10)/(sum(phyblkwrt)+1))*(sum(phyblkwrt))) + 1)) * 1000
          avg_access_speed
  from v$filestat,
       dba_data_files
 where file_id = file#;

select substr(name,1,instr(name,'/',-1))||substr(name,1,instr(name,'\',-1)) file_system_name,
       sum(bytes)/(1024*1024) MBytes,
       sum(phyblkrd)/1000 phyblkrd,
       sum(phyblkwrt)/1000 phyblkwrt,
       avg((readtim*10)/(phyblkrd+1)) read_time_per_block_msec,
       avg((writetim*10)/(phyblkwrt+1)) write_time_per_block_msec,
       (avg((readtim*10)/(phyblkrd+1))*sum(phyblkrd)/1000 + avg((writetim*10)/(phyblkwrt+1))*sum(phyblkwrt)/1000) /
           (sum(phyblkrd)/1000 + sum(phyblkwrt)/1000 + 1)
            avg_access_time,
       ((sum(phyblkrd) + sum(phyblkwrt)) /
           (avg((readtim*10)/(phyblkrd+1))*sum(phyblkrd) + avg((writetim*10)/(phyblkwrt+1))*sum(phyblkwrt) + 1)) * 1000
            avg_access_speed
  from v$datafile a,
       v$filestat b
 where a.file# = b.file#
 group by substr(name,1,instr(name,'/',-1)), substr(name,1,instr(name,'\',-1))
 order by 7 desc, 6 desc;

select t.tablespace_name,
       sum(bytes)/(1024*1024) MBytes,
       sum(phyblkrd)/1000 phyblkrd,
       sum(phyblkwrt)/1000 phyblkwrt,
       avg((readtim*10)/(phyblkrd+1)) read_time_per_block_msec,
       avg((writetim*10)/(phyblkwrt+1)) write_time_per_block_msec,
       (avg((readtim*10)/(phyblkrd+1))*sum(phyblkrd)/1000 + avg((writetim*10)/(phyblkwrt+1))*sum(phyblkwrt)/1000) /
           (sum(phyblkrd)/1000 + sum(phyblkwrt)/1000 + 1)
            avg_access_time,
       ((sum(phyblkrd) + sum(phyblkwrt)) /
           (avg((readtim*10)/(phyblkrd+1))*sum(phyblkrd) + avg((writetim*10)/(phyblkwrt+1))*sum(phyblkwrt) + 1)) * 1000
            avg_access_speed
  from dba_tablespaces t,
       v$filestat,
       dba_data_files d
 where t.tablespace_name = d.tablespace_name
   and d.file_id = file#
 group by t.tablespace_name,
       t.status
 order by 7 desc, 6 desc;

select file_name,
       bytes/(1024*1024) MBytes,
       phyblkrd/1000 phyblkrd,
       phyblkwrt/1000 phyblkwrt,
       (readtim*10)/(phyblkrd+1) read_time_per_block_msec,
       (writetim*10)/(phyblkwrt+1) write_time_per_block_msec,
       (((readtim*10)/(phyblkrd+1))*(phyblkrd) + ((writetim*10)/(phyblkwrt+1))*(phyblkwrt)) /
         (phyblkrd + phyblkwrt + 1)
          avg_access_time,
       (phyblkrd + phyblkwrt) /
         (((((readtim*10)/(phyblkrd+1))*(phyblkrd) + ((writetim*10)/(phyblkwrt+1))*(phyblkwrt)) + 1)) * 1000
          avg_access_speed
  from v$filestat,
       dba_data_files
 where file_id = file#
 order by 7 desc, 6 desc;

prompt
prompt
prompt =======================================================================================================
prompt
prompt ORACLE TRANSACTIONS (USER COMMITS + TRANSACTION ROLLBACKS) = TOTAL AVERAGES SINCE DATABASE STARTUP

SET FEEDBACK OFF;

select max(d.name) DATABASE,
       to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') DATE_OF_RUN,
       sum(s.value/(24*60*60*(sysdate-t.open_time))+0.001) tps,
       1/sum(s.value/(24*60*60*(sysdate-t.open_time))+0.001) spt
  from v$database d, v$sysstat s, v$thread t
 where s.name in ('user commits', 'transaction rollbacks');

prompt
prompt
prompt =======================================================================================================
prompt
prompt
spool off;
-------------------------------------------------------------------------------------------------------

