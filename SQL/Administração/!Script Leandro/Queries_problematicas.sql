set pagesize  66
set linesize  132

spool .Queries_problematicas.log

prompt
prompt Table Scans
prompt ===========
prompt

select name, value
from v$sysstat
where name like 'table%';

prompt
prompt Queries
prompt =======
prompt

column sqltext                            format a80 wrap
column version_count   heading VERSAO     format 990
column users_opening   heading USUARIOS   format 990
column executions      heading EXECUCOES  format 990
column loads           heading CARGAS     format 990
column first_load_time heading 1A_CARGA   format a20
column disk_reads                         format 999G999G990
column disk_per_exec                      format 999G999G990
column buffer_gets                        format 999G999G990
column buffer_per_exec                    format 999G999G990
column rows_processed                     format 999G999G990
column rows_per_exec                      format 999G999G990
column sorts                              format 999G999G990
column sorts_per_exec                     format 999G999G990
column optimizer_mode heading OTIMIZADOR  format a10

ttitle center 'Medias + 1 * Desvio' skip 1

select avg (disk_reads/decode(executions,0,1,executions)) + 
        stddev (disk_reads/decode(executions,0,1,executions)) disk_per_exec,
       avg (buffer_gets/decode(executions,0,1,executions)) +
        stddev (buffer_gets/decode(executions,0,1,executions)) buffer_per_exec,
       avg (rows_processed/decode(executions,0,1,executions)) + 
        stddev (rows_processed/decode(executions,0,1,executions)) rows_per_exec,
       avg (sorts/decode(executions,0,1,executions)) +
        stddev (sorts/decode(executions,0,1,executions)) sorts_per_exec
from v$sqlarea;

break on sql_text on disk_reads on executions on loads on optimizer_mode on disk_per_exec 

prompt Acesso a disco
prompt

ttitle center 'Acesso a disco' skip 1
                                                                                
select sql_text,
       disk_reads,
       executions,
       loads,
       optimizer_mode,                                                          
       disk_reads / decode (executions, 0, 1, executions) disk_per_exec,
       username,
       sid
from v$sqlarea,
     v$session
where disk_reads / decode (executions, 0, 1, executions) >
          (select avg (disk_reads / decode (executions, 0, 1, executions)) +
                  stddev (disk_reads / decode (executions, 0, 1, executions))
           from v$sqlarea)
  and sql_address    (+) = address
  and sql_hash_value (+) = hash_value
order by 6 desc;

prompt Consultas ao DB Buffer Cache
prompt

ttitle center 'Consultas ao DB Buffer Cache' skip 1

select sql_text, 
       buffer_gets,
       executions,
       loads,
       optimizer_mode,
       buffer_gets / decode (executions, 0, 1, executions) buffer_per_exec,
       username, 
       sid
from v$sqlarea,
     v$session
where buffer_gets / decode (executions, 0, 1, executions) > 
          (select avg (buffer_gets / decode (executions, 0, 1, executions)) +
                  stddev (buffer_gets / decode (executions, 0, 1, executions)) 
           from v$sqlarea)
  and sql_address    (+) = address
  and sql_hash_value (+) = hash_value
order by 6 desc;

clear columns
clear breaks
clear computes

column owner           format a25 wrap
column name            format a15 wrap
column type            format a15
column sharable_mem    format 999G990D00

prompt Utilizacao de Memoria
prompt

ttitle center 'Utilizacao de Memoria' skip 1

select o.owner,
       o.name,
       o.type,
       o.sharable_mem / 1024 sharable_mem
from v$db_object_cache o
where o.sharable_mem > 10240
  and o.type in ( 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION' )
order by o.sharable_mem desc;

prompt Reloads
prompt

ttitle center 'Reloads' skip 1

select o.owner,                                                      
       o.name,                                                       
       o.type,                                                       
       o.loads,
       o.sharable_mem / 1024 sharable_mem
from v$db_object_cache o                                             
where o.type in ( 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION' ) 
order by o.loads desc;                                        

prompt Execucoes
prompt

ttitle center 'Execucoes' skip 1

select o.owner,                                                      
       o.name,                                                       
       o.type,                                                       
       o.executions ,
       o.sharable_mem / 1024 sharable_mem
from v$db_object_cache o                                             
where o.executions > 100                                         
  and o.type in ( 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION' )
order by o.executions desc;                                        


spool off
