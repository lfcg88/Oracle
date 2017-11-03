select /*+ CHOOSE */ a.sid, a.serial#, a.username, 
a.username "DB User", a.osuser, a.status, a.terminal, a.type ptype,   
b.owner, b.object, b.type
, a.USERNAME  "DB User" 
from v$session a, v$access b
where a.sid=b.sid
and b.type<>'NON-EXISTENT' 
and (b.owner is not null) and (b.owner<>'SYSTEM')  and (b.owner<>'SYS') 
ORDER BY 3