/************************************************************************/
/*  Lista os "pelas-sacos" e seus processos correntes no unix           */
/************************************************************************/

select to_char(a.sid,'999') "Sid", 
       to_char(a.serial#,'99999') "Serial", 
       to_char(b.spid,'9999999') "Unix",
       a.status Status,
       substr(a.username,1,10) "Schema",
       substr(a.program,1,30) "Programa",
       substr(a.osuser,1,10) "OS_USER"
from v$session a,v$process b
where b.addr=a.paddr
order by 5
/
