select n.name,s.extents,s.rssize/1024 as Kbytes,s.optsize/1024 as "KB Otimo",s.xacts as "Trans.",s.status as Status,s.writes,s.extends,s.waits as "Header waits" from v$rollname n,v$rollstat s
where n.usn=s.usn 
