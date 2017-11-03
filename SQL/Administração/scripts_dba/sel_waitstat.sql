/* Mostra estatistica de waits por segmentos de rollback */
/* em comparacao com total de requisicoes (gets).        */

/* ATENCAO !!! Para funcionar, tem que por o parametro   */
/* timed_statistics=true no init.ora                     */

set pause off

select sum(value) "Total de Gets"
from v$sysstat
where name in ('db block gets','consistent gets')
/
select class, count
from v$waitstat
where class in ('system undo header','system undo block',
                'undo header','undo block')
/
-----------------------------------------------------------
/* Mostra estatistica de waits por segmentos de rollback */
/* em comparacao com total de requisicoes (gets).        */

set pause off
set feed off

col tot_gets  head "Total de Gets"
col tot_gets  new_value tot_gets
col sys_u_hea new_value sys_u_hea
col sys_u_blk new_value sys_u_blk
col u_hea     new_value u_hea
col u_blk     new_value u_blk
col perc_1    head "Percentual system undo header" format '99.99'
col perc_2    head "Percentual system undo block"  format '99.99'
col perc_3    head "Percentual undo header"        format '99.99'
col perc_4    head "Percentual undo block"         format '99.99'

select sum(value) tot_gets
from v$sysstat
where name in ('db block gets','consistent gets')
/
select class, count sys_u_hea
from v$waitstat
where class in ('system undo header')
/
set head off

select class, count sys_u_blk
from v$waitstat
where class in ('system undo block')
/
select class, count u_hea
from v$waitstat
where class in ('undo header')
/
select class, count u_blk
from v$waitstat
where class in ('undo block')
/
set head on

select (&sys_u_hea / &tot_gets) perc_1
from dual
/
select (&sys_u_blk / &tot_gets) perc_2
from dual
/
select (&u_hea / &tot_gets) perc_3
from dual
/
select (&u_blk / &tot_gets) perc_4
from dual
/
