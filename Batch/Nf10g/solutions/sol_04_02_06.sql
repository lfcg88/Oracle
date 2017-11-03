
connect / as sysdba

show parameter sga_

col component format a30

select component,current_size,min_size,granule_size 
from v$sga_dynamic_components
where component in ('shared pool','large pool',
                    'java pool','DEFAULT buffer cache');

col name format a30
col value format a30

SELECT name, value, isdefault 
FROM v$parameter
WHERE name in ('shared_pool_size','large_pool_size','java_pool_size',
               'db_cache_size');
