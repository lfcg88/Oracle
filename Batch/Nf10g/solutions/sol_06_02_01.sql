
connect / as sysdba;

alter system flush shared_pool;

-- query 1: 
SELECT /* QueryJFV 1*/
         t.calendar_month_desc,sum(s.amount_sold) AS dollars
FROM     sh.sales s
,        sh.times t
WHERE    s.time_id = t.time_id
  AND    s.time_id between TO_DATE('01-JAN-2000', 'DD-MON-YYYY')
                       AND TO_DATE('01-JUL-2000', 'DD-MON-YYYY')
GROUP BY t.calendar_month_desc;

-- query 2: star query 
SELECT /* QueryJFV 2 */
       ch.channel_class, c.cust_city, t.calendar_quarter_desc,
       SUM(s.amount_sold) sales_amount
FROM sh.sales s, sh.times t, sh.customers c, sh.channels ch
WHERE s.time_id = t.time_id
AND   s.cust_id = c.cust_id
AND   s.channel_id = ch.channel_id
AND   c.cust_state_province = 'CA'
AND   ch.channel_desc in ('Internet','Catalog')
AND   t.calendar_quarter_desc IN ('1999-01','1999-02')
GROUP BY ch.channel_class, c.cust_city, t.calendar_quarter_desc;

-- query 3: star query 
SELECT /* QueryJFV 3 */
       ch.channel_class, c.cust_city, t.calendar_quarter_desc,
       SUM(s.amount_sold) sales_amount
FROM sh.sales s, sh.times t, sh.customers c, sh.channels ch
WHERE s.time_id = t.time_id
AND   s.cust_id = c.cust_id
AND   s.channel_id = ch.channel_id
AND   c.cust_state_province = 'CA'
AND   ch.channel_desc in ('Internet','Catalog')
AND   t.calendar_quarter_desc IN ('1999-03','1999-04')
GROUP BY ch.channel_class, c.cust_city, t.calendar_quarter_desc;


-- new query 4: order by
SELECT /* QueryJFV 4 */ c.country_id, c.cust_city, c.cust_last_name
FROM sh.customers c
WHERE c.country_id in (52790, 52798)
ORDER BY c.country_id, c.cust_city, c.cust_last_name;
