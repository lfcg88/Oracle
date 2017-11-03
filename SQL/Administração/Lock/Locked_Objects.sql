/*Se v$locked_object.XIDUSN =0, a sess�o est� esperando pelo lock que est�
  sendo bloqueado por outra sess�o, no mesmo objeto */

select lo.xidusn,s.sid,s.username,s.terminal,o.owner,o.object_name,o.object_type,lo.locked_mode
from dba_objects o,v$locked_object lo,v$session s
where o.object_id = lo.object_id and
      s.sid = lo.session_id
order by o.owner,o.object_name

