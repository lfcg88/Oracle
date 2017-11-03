/* Reporta estatistica no Dictionary Cache */

column percent format '99.99' heading "Perda % (deve ser < 13)"

select sum(gets) "Dictionary Gets",
       sum(getmisses) "Dictionary Get Misses",
       (sum(getmisses) / sum(gets) * 100) percent
from v$rowcache
/
