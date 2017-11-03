
set echo on

connect hr/hr

col first_name format a10

-- step 1:
create table names as
select first_name
from   employees
where  rownum <= 30;

update names
set    first_name = lower(first_name)
where  rownum <= 15;