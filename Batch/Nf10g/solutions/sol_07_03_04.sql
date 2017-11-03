
select /*+ REWRITE_OR_ERROR */
       prod_id
,      avg(amount_sold)
from   sales
where  channel_id = 9
group  by prod_id;
