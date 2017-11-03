select n.name as "RBS Name",s.username,s.terminal as "Estação",t.used_ublk as "Blocos utilizados" from v$rollname n,v$session s,v$transaction t
where s.saddr=t.ses_addr and t.xidusn = n.usn
