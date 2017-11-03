
set echo on

connect hr/hr

alter session set nls_sort = binary_ci;


select * from names 
order by first_name;
