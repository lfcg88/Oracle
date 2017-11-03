connect perfstat/perfstat;

drop table stats$vmstat;
create table stats$vmstat
(
     start_date          date,
     duration            number,
     server_name         varchar2(20),
     runque_waits        number,
     page_in             number,
     page_out            number,
     user_cpu            number,
     system_cpu          number,
     idle_cpu            number,
     wait_cpu            number
)
tablespace perfstat
storage (initial 10m
         next     1m
         pctincrease 0)
;
