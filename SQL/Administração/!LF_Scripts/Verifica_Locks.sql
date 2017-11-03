set feed off
set linesize 100
set pagesize 300
column blocker format a20
column blockee format a20
select /*+ ordered */     c.username||'('||c.sid||')' blocker,
d.username||'('||d.sid||')' blockee
from v$lock a, v$lock b,v$session c,v$session d
where a.block = 1
       and b.request > 0
       and a.id1 = b.id1
       and a.id2 = b.id2
       and a.sid = c.sid
       and b.sid = d.sid; 
	   
	  