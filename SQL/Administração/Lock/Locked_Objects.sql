/*Se v$locked_object.XIDUSN =0, a sessão está esperando pelo lock que está
  sendo bloqueado por outra sessão, no mesmo objeto */

select lo.xidusn,s.sid,s.username,s.terminal,o.owner,o.object_name,o.object_type,lo.locked_mode
from dba_objects o,v$locked_object lo,v$session s
where o.object_id = lo.object_id and
      s.sid = lo.session_id
order by o.owner,o.object_name

