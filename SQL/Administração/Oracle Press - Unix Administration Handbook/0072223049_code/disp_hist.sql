column table_name format a20;
column column_name format a25;

select
   table_name,
   column_name,
   endpoint_number,
   endpoint_value
from
   dba_histograms
where
   table_name = 'SUBSCRIPTION'
order by
   column_name
;
