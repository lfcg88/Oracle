set lines 80;
set pages 999;
set feedback off;
set verify off;

column my_date heading 'date       hour' format a20
column c2      heading runq   format 999
column c3      heading pg_in  format 999
column c4      heading pg_ot  format 999
column c5      heading usr    format 999
column c6      heading sys    format 999
column c7      heading idl    format 999
column c8      heading wt     format 999


ttitle 'run queue > 2|May indicate an overloaded CPU|When runqueue exceeds the number of CPUs| on the server, tasks are waiting for service.';


select
 server_name,
 to_char(start_date,'YY/MM/DD    HH24') my_date,
 avg(runque_waits)       c2,
 avg(page_in)            c3,
 avg(page_out)           c4,
 avg(user_cpu)           c5,
 avg(system_cpu)         c6,
 avg(idle_cpu)           c7
from
perfstat.stats$vmstat
WHERE
runque_waits > 2
and start_date > sysdate-&1
group by
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
ORDER BY
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
;

ttitle 'page_in > 1|May indicate overloaded memory|Whenever Unix performs a page-in, the RAM memory | on the server has been exhausted and swap pages are being used.';


select
 server_name,
 to_char(start_date,'YY/MM/DD    HH24') my_date,
 avg(runque_waits)       c2,
 avg(page_in)            c3,
 avg(page_out)           c4,
 avg(user_cpu)           c5,
 avg(system_cpu)         c6,
 avg(idle_cpu)           c7
from
perfstat.stats$vmstat
WHERE
page_in > 1
and start_date > sysdate-&1
group by
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
ORDER BY
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
;

ttitle 'user+system CPU > 70%|Indicates periods with a fully-loaded CPU subssystem.|Periods of 100% utilization are only a | concern when runqueue values exceeds the number of CPs on the server.';
 

select
 server_name,
 to_char(start_date,'YY/MM/DD    HH24') my_date,
 avg(runque_waits)       c2,
 avg(page_in)            c3,
 avg(page_out)           c4,
 avg(user_cpu)           c5,
 avg(system_cpu)         c6,
 avg(idle_cpu)           c7
from
perfstat.stats$vmstat
WHERE
(user_cpu + system_cpu) > 70
and start_date > sysdate-&1
group by
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
ORDER BY
 server_name,
 to_char(start_date,'YY/MM/DD    HH24')
;
