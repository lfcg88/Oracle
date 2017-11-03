select s.sid,s.username,s.terminal,owner,object_id,object_name,object_type,l.type,sql.sql_text
from dba_objects o,v$lock l,v$session s,v$sql sql
where object_id = l.id1 and
      s.sid = l.sid and 
      s.sql_address = sql.address
