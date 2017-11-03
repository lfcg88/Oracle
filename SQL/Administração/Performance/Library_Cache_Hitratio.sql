select trunc(gethitratio*100,2) "Hit Ratio %"  -- Se > 1 aumentar Shared_Pool_Size em init.ora
from v$librarycache
where namespace = 'SQL AREA';
 