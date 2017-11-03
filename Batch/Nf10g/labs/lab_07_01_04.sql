

set echo on

SELECT prod_id, time_id, quantity_sold
,      sum(quantity_sold) over
       ( partition by prod_id
         order by time_id
       ) as cumulative
FROM   s1
       RIGHT OUTER JOIN t1
       using (time_id)
ORDER  BY prod_id, time_id;
