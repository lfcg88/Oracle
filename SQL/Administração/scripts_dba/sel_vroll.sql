/* Lista situacao corrente dos segmentos de rollback */

select substr(name,1,8) "Rollback", 
       v$rollstat.usn "Numero",
       extents, 
       rssize, 
       writes, 
       xacts, 
       gets, 
       waits, 
       optsize, 
       status
from v$rollstat, v$rollname
where v$rollstat.usn = v$rollname.usn
/
