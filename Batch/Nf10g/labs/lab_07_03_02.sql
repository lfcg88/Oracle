
set echo on

connect sh/sh

create materialized view my_mv
   build immediate
   enable query rewrite
as select prod_id
   ,      avg(amount_sold) as avg_amount
   from   sales
   where  channel_id = 9
   group  by prod_id;

rem gather statistics for the MV...

execute dbms_stats.gather_table_stats(USER,'MY_MV');

select * from my_mv;
