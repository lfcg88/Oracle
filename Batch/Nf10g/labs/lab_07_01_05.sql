
set echo on

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
