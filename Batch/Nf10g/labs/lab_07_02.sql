
set echo on

connect sh/sh

SELECT time_id, prod_id, quantity_sold qs
FROM   s1
ORDER  BY prod_id, time_id;

SELECT time_id, prod_id, qs 
FROM   s1 
       MODEL 
       DIMENSION BY (prod_id, time_id) 
       MEASURES (quantity_sold qs) 
       RULES
       ( qs[13,'09-JAN-2001'] =
           sum(qs)[13,time_id between '02-JAN-2001'
                                  and '08-JAN-2001'] 
       , qs[14,'09-JAN-2001'] = qs[13,'09-JAN-2001'] * 3
       , qs[15,'09-JAN-2001'] = 42
       )
ORDER  BY prod_id, time_id;

SELECT time_id, prod_id, qs 
FROM   s1 
       MODEL
       RETURN UPDATED ROWS
       DIMENSION BY (prod_id, time_id) 
       MEASURES (quantity_sold qs) 
       RULES
       ( qs[13,'09-JAN-2001'] =
           sum(qs)[13,time_id between '02-JAN-2001'
                                  and '08-JAN-2001'] 
       , qs[14,'09-JAN-2001'] = qs[13,'09-JAN-2001'] * 3
       , qs[15,'09-JAN-2001'] = 42
       )
ORDER  BY prod_id, time_id;

rem cleanup

drop table s1;
