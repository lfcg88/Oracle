/* Reporta estatistica tempo de espera de dispatcher processes */
/* atender uma fila.                                           */

column network heading "Protocolo" format a10 
column Total heading "Media tempo/espera por resposta" format a38

select network, decode (sum(totalq), 0, 'Nao Reponde',
               round(sum(wait)/sum(totalq),4) || ' Centesimos de segundo') Total
from v$queue q, v$dispatcher d
where q.type = 'DISPATCHER'
  and q.paddr = d.paddr
group by network
/
