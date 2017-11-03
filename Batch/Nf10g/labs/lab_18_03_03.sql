
set echo on
 
select c.cust_last_name,  t.calendar_year, 
     sum(s.amount_sold)
     from   sales     s join 
            customers c using (cust_id) join 
            times t using (time_id)
     group  by c.cust_last_name, t.calendar_year 
     order  by c.cust_last_name, t.calendar_year;
