spool c:\verifica.log 
select * from v$sga
/
select substr(file_name,1,40), substr(tablespace_name,1,10), bytes/1024/1024
from dba_data_files
order by tablespace_name, file_name
/
select name, bytes from v$sgastat
where name = 'free memory'
/
select (1 - (sum(decode(name, 'physical reads', value, 0)) /
       (sum(decode(name, 'db block gets', value, 0)) +
       sum(decode(name, 'consistent gets', value, 0)))))
       * 100 "Hit Ratio Buffer Cache"
from   v$sysstat
/
select ((1 - (sum(getmisses) / (sum(gets) + sum(getmisses)))) * 100) "Hit Rate Dict"
from v$rowcache
where ((gets + getmisses) <> 0)
/
select sum(pins) "Hits Library",
       sum(reloads) "Misses",
       (sum(pins) / (sum(pins) + sum(reloads)) * 100) "Hit Ratio"
from v$librarycache
/
select sum(pins) "Hits Library",
       sum(Reloads) "Misses",
       ((sum(reloads) / sum(pins)) * 100) "Reloads %"
from v$librarycache
/
select a.value "Space Requests", b.value "Redo Entries",
       round(b.value / decode(a.value,0,1,a.value)) "1 para 5000"
from v$sysstat a, v$sysstat b
where a.name = 'redo log space requests'
and   b.name = 'redo entries'
/
select substr(name,1,30) "Latch",
       sum(gets) "WTW Gets",
       sum(misses) "WTW Misses",
       sum(immediate_gets) "IMM Gets",
       sum(immediate_misses) "IMM Misses"
from v$latch
where name in ('cache buffers chains','cache buffers lru chain',
               'enqueues','redo allocation','row cache objects')
group by name
/
select a.value "Disk Sorts", b.value "Memory Sorts",
       round((100 * b.value) / decode((a.value + b.value),0,1,
       (a.value + b.value)),2) "Pct Memory Sorts"
from v$sysstat a, v$sysstat b
where a.name = 'sorts (disk)'
and   b.name = 'sorts (memory)'
/
select substr(a.name,1,10), b.extents, b.rssize, b.xacts,
       b.waits, b.gets, optsize, status
from v$rollname a, v$rollstat b
where a.usn = b.usn
/
select * from v$waitstat
/
select a.class, count, sum(value) Con_Get,
       ((count /sum(value)) * 100) Pct
from v$waitstat a, v$sysstat b
where name in ('db block gets','consistent gets')
group by a.class, count
/
col value for 999,999,999,999 heading "Shared Pool Size"
col bytes for 999,999,999,999 heading "Free Bytes"
select to_number(v$parameter.value) value, v$sgastat.bytes,
       (v$sgastat.bytes/v$parameter.value) * 100 "Percent Free"
from   v$sgastat, v$parameter
where  v$sgastat.name = 'free memory'
and    v$parameter.name = 'shared_pool_size'
/
col PHYRDS   format 99,999,999
col PHYWRTS  format 99,999,999
ttitle "Disk Balancing Report"
col READTIM  format 99,999,999
col WRITETIM format 99,999,999
col name format a30
select name, phyrds, phywrts, readtim, writetim
from   v$filestat a, v$dbfile b
where a.file# = b.file#
order by readtim desc
/
spool off
