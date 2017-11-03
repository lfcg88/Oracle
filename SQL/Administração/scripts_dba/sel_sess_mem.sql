/* Lista memoria alocada na SGA para cada sessao */

select username "Usuario", 
       value    "Bytes alocados na SGA"
from   v$session t1,
       v$sesstat t2,
       v$statname t3
where t1.sid = t2.sid and
      t2.statistic# = t3.statistic# and
      t3.name = 'session memory'
/
