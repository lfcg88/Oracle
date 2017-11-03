
connect / as sysdba

select /*+ PARALLEL */ count(*) 
from (select /*+ parallel(s 12) */ * from sgalab s group by a);
