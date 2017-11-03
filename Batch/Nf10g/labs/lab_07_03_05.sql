
set echo on

rem showing the execution plan:

explain plan for
select prod_id
,      avg(amount_sold)
from   sales
where  channel_id = 9
group  by prod_id;

select * from table(dbms_xplan.display);
