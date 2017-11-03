/* Reporta estatistica na Library Cache */

column percent format '99.99' heading "Perda % (deve ser < 1)"

select sum(pins) "Execucoes",
       sum(reloads) "Caches perdidos",
       (sum(reloads) / sum(pins) * 100) percent
from v$librarycache
/
