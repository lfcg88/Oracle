
set echo on

rem try the MV with an intended typo in the query:

select /*+ REWRITE_OR_ERROR */
       prod_id
,      avg(quantity_sold)
from   sales
where  channel_id = 9
group  by prod_id;