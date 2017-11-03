SELECT /* QueryJFV 4 */ c.country_id, c.cust_city, c.cust_last_name
FROM sh.customers c
WHERE c.country_id in (52790, 52798)
ORDER BY c.country_id, c.cust_city, c.cust_last_name;

