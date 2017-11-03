SELECT /* QueryJFV 1*/
         t.calendar_month_desc,sum(s.amount_sold) AS dollars
FROM     sh.sales s
,        sh.times t
WHERE    s.time_id = t.time_id
  AND    s.time_id between TO_DATE('01-JAN-2000', 'DD-MON-YYYY')
                       AND TO_DATE('01-JUL-2000', 'DD-MON-YYYY')
GROUP BY t.calendar_month_desc;
