connect / as sysdba

SELECT count(*) FROM v$vpd_policy;

select sql_text 
from v$sql 
where sql_id in (select sql_id from v$vpd_policy);
