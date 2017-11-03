select sum(waits) "Waits", sum(gets) "Gets",
trunc((sum(waits)*100/sum(gets)),2) "Ratio"
from v$rollstat;
 