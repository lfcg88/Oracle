--Versão 1
-- Somente Usuários ATIVOS
SELECT s.username,
     s.osuser,
     s.sid,
     s.serial#,
     p.spid,
     s.status,
     s.machine,
     s.program,
     TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
   FROM v$session s
  inner join v$process p
     on s.paddr = p.addr
  WHERE s.status = 'ACTIVE'
    and s.type <> 'BACKGROUND';
	
--Versão 2
-- Usuários ATIVOS e INATIVOS

SELECT s.username,
     s.osuser,
     s.sid,
     s.serial#,
     p.spid,
     s.status,
     s.machine,
     s.program,
     s.type,
     TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
   FROM v$session s
  inner join v$process p
     on s.paddr = p.addr
  WHERE s.status IN ('ACTIVE', 'INACTIVE')
      and s.type <> 'BACKGROUND' 
      --and s.sid = '251';
	  
-- Matando as sessões
ALTER SYSTEM KILL SESSION '259, 137';