connect perfstat/perfstat;
set pages 9999;

set feedback off;
set verify off;

column my_date heading 'date' format a20
column c2      heading runq   format 999
column c3      heading pg_in  format 999
column c4      heading pg_ot  format 999
column c5      heading usr    format 999
column c6      heading sys    format 999
column c7      heading idl    format 999
column c8      heading wt     format 999


select
 to_char(start_date,'yyyy-mm-dd') my_date,
-- avg(runque_waits)       c2
-- avg(page_in)            c3,
-- avg(page_out)           c4,
avg(user_cpu + system_cpu)           c5,
-- avg(system_cpu)         c6,
-- avg(idle_cpu)           c7,
avg(wait_cpu)           c8
from
   stats$vmstat
group  BY
 to_char(start_date,'yyyy-mm-dd')
order by
 to_char(start_date,'yyyy-mm-dd')
;
