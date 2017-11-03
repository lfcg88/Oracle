
set echo on

create table s1 as
select DISTINCT
       time_id, prod_id, quantity_sold
from   sales
where  time_id between '02-JAN-2001'
                   and '05-JAN-2001'
and    prod_id < 15;

select * from s1;

