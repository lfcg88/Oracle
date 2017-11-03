/* Reporta estatistica taxa de ocupado de dispatcher processes */

column network heading "Protocolo" format a10 
column Total format '99.99' heading "Ocupdo % (deve ser < 40)" 

select network, ( sum(busy) / ( sum(busy) + sum(idle) ) ) * 100 Total 
from v$dispatcher
group by network
/
