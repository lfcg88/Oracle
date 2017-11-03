
set echo on

connect sh/sh

alter session set nls_date_format='DD-MON-YYYY';

drop table t1;
drop table s1;

create table s1 as
select DISTINCT
       time_id, prod_id, quantity_sold
from   sales
where  time_id between '02-JAN-2001'
                   and '05-JAN-2001'
and    prod_id < 15;

create table t1 (time_id date);

begin
  for i in 0..3 loop
    insert into t1 values (to_date('02-JAN-2001') + i);
  end loop;
end;
/

commit;

break on prod_id

SELECT prod_id, time_id, quantity_sold
,      sum(quantity_sold) over
       ( partition by prod_id
         order by time_id
       ) as cumulative
FROM   s1
       PARTITION BY (prod_id)
       RIGHT OUTER JOIN t1
       using (time_id)
ORDER  BY prod_id, time_id;

rem and now without the partitioning:

SELECT prod_id, time_id, quantity_sold
,      sum(quantity_sold) over
       ( partition by prod_id
         order by time_id
       ) as cumulative
FROM   s1
       RIGHT OUTER JOIN t1
       using (time_id)
ORDER  BY prod_id, time_id;

rem cleanup

drop table t1;
clear breaks
