/* -------------------------------------- */
/* LISTA TODOS USUARIOS PARA GERAR TRACE  */
/* -------------------------------------- */
set pagesize 0
select 'execute dbms_system.set_sql_trace_in_session('||a.sid||','||a.serial#||',TRUE); /*UNIX='||b.spid||' --> '||a.username||' */'
from v$session a,v$process b
where b.addr=a.paddr and a.username not in ('SYSTEM','SYS')
/
