select sum(pins) "Executions", sum (reloads) "Cache Misses", trunc((sum(reloads)/sum(pins))*100,2) "%" 
from v$librarycache;
 