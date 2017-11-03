select trunc((1 - phy.value / (cur.value + con.value))*100 ,2)
"CACHE HIT RATIO %"
from v$sysstat cur, v$sysstat con, v$sysstat phy
where cur.name = 'db block gets'
and con.name = 'consistent gets'
and phy.name = 'physical reads';
 