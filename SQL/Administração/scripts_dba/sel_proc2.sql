/************************************************************************/
/*  Lista os "pelas-sacos" e seus processos correntes no unix           */
/************************************************************************/

select to_char(a.sid,'999') "Sid", 
       to_char(a.serial#,'99999') "Serial", 
       to_char(b.spid,'99999') "Unix",
       a.status Status,
       substr(a.username,1,10) "Schema",
       substr(a.program,1,40) "Programa"
from v$session a,v$process b
where b.addr=a.paddr and
      b.spid=&pid
order by 5
/
