set pagesize  66
set linesize  132
set trimspool on

prompt 
prompt Monitoracao de Memoria
prompt ======================
prompt

ttitle "Library Cache" skip 1

column namespace      format a15 wrap 
column gets           format 999G999G990
column getmisses      format 999G999G990
column getmissesratio format 990D00
column reloads        format 999G999G990
column invalidation   format 999G999G990

break on report

compute sum of gets          on report
compute sum of getmisses     on report
compute sum of reloads       on report
compute sum of invalidations on report

select namespace, 
       gets, 
       gets - gethits getmisses, 
       1 - gethitratio getmissesratio,
       reloads, 
       invalidations
from v$librarycache
order by namespace;

prompt 
prompt Manter a taxa de erros (getmissesratio) total abaixo de 1%
prompt manter volume total de reloads e invalidations proximo de 0
prompt
prompt

clear columns
clear breaks
clear computes

ttitle "Dictionary Cache" skip 1
set pagesize 66

column gets          format 999G999G990
column gethits       format 999G999G990
column getmisses     format 999G999G990
column gethitratio   format 990D00

break on report

compute sum of gets          on report
compute sum of gethits       on report
compute sum of getmisses     on report

select parameter, 
       gets, 
       gets - getmisses   gethits,
       getmisses, 
       decode (gets+getmisses, 0, 0, 
                   1 - (gets/(gets+getmisses))) gethitratio
from v$rowcache
order by parameter;

prompt 
prompt Manter a taxa de erros (getmisses) total menor que 10%
prompt
prompt

clear columns
clear breaks
clear computes

ttitle "Sessoes" skip 1

column name   format a30 wrap
column total  format 999G999G990
column max    format 999G999G990

select n.name, 
       sum (s.value) total, 
       max (s.value) max
from v$sesstat s, 
     v$statname n
where s.statistic# = n.statistic#
  and n.name in ('session pga memory',
                 'session pga max memory',
                 'session uga memory',
                 'session uga max memory',
                 'session procedure space' )
group by n.name
order by n.name;

clear columns
clear breaks
clear computes

ttitle "Buffer Cache: Total Gets (= db block gets + physical gets)" skip 1

column name  format a30 wrap
column value format 999G999G990

break on report

compute sum of value on report

select name, value
from v$sysstat
where name in ( 'db block gets',
		'consistent gets' )
order by name;

clear columns
clear breaks
clear computes

ttitle "Buffer Cache" skip 1

select name, value
from v$sysstat
where name in ( 'physical reads' );

prompt 
prompt GetRatio = (1 - (physical reads/Total Gets)) > 70%
prompt 
prompt

prompt
prompt Monitoracao de I/O
prompt ==================
prompt

ttitle "Data File Contention" skip 1

column name                              format a30 wrap
column tablespace                        format a14 wrap
column filesystem                        format a20 wrap
column phyrds      heading "Phys.Reads"  format 999G999G999
column phywrts     heading "Phys.Writes" format 999G999G999
column total       heading "Total"       format 999G999G999

break on tablespace on report

compute sum of phyrds  on report
compute sum of phywrts on report
compute sum of total   on report

select dd.tablespace_name       tablespace,
       df.name,
       fs.phyrds, 
       fs.phywrts,
       fs.phyrds + fs.phywrts   total
from v$datafile df, 
     v$filestat fs, 
     dba_data_files dd
where df.file# = fs.file#
  and dd.file_name = df.name
order by 1, 2;

prompt

select dd.tablespace_name             tablespace,
       sum (fs.phyrds)                phyrds, 
       sum (fs.phywrts)               phywrts,
       sum (fs.phyrds + fs.phywrts)   total
from v$datafile df, 
     v$filestat fs, 
     dba_data_files dd
where df.file# = fs.file#
  and dd.file_name = df.name
group by tablespace_name
order by 1;

prompt \

select substr (df.name, 1, 16)      filesystem,
       sum (fs.phyrds)              phyrds,
       sum (fs.phywrts)             phywrts,
       sum (fs.phyrds + fs.phywrts) total
from v$datafile df,
     v$filestat fs
where df.file# = fs.file#
group by substr (df.name, 1, 16)
order by 1;

clear columns
clear breaks
clear computes

prompt
prompt Identificar e distribuir arquivos com maiores indices de acesso.
prompt
prompt

ttitle "Rollback Segment Contention" skip 1

column count format 99G999G999

break on report

compute sum of count on report

select class, count
from v$waitstat
where class in ( 'system undo header',
		 'system undo block',
		 'undo header',
		 'undo block' )
order by class;

clear columns
clear breaks
clear computes

break on tablespace_name

select rb.tablespace_name, 
       rb.segment_name, 
       rs.gets, 
       rs.waits, 
       rs.xacts
from dba_rollback_segs rb,
     v$rollstat        rs
where rb.segment_id = rs.usn (+)
order by rb.tablespace_name, 
         rb.segment_name;

prompt
prompt Razao entre as contagens acima e Total Gets deve ser menor que 1%
prompt
prompt

ttitle "Redo Log Buffer" skip 1

column values format 99G999G999

select name, value
from v$sysstat
where name like 'redo%';

clear column

prompt
prompt Numero de vezes que um processo aguardou liberacao de espaco
prompt no redo log buffer.
prompt

ttitle "Redo Log Latches" skip 1

column name             format a25
column gets             format 999G999G999
column misses           format 999G999G999
column ratio            format 0D00000
column igets            format 999G999G999
column imiss            format 999G999G999
column iratio           format 0D00000

break on report

compute sum of gets             on report
compute sum of misses           on report
compute sum of immediate_gets   on report
compute sum of immediate_misses on report

select ln.name, 
       l.gets, 
       l.misses, 
       decode (l.gets, 0, 1, l.misses/l.gets) ratio,
       l.sleeps, 
       l.immediate_gets                                                  igets, 
       l.immediate_misses                                                imiss,
       decode (l.immediate_gets,0,1,l.immediate_misses/l.immediate_gets) iratio
from v$latch l, 
     v$latchname ln
where ln.name in ( 'redo allocation', 'redo copy' )
  and ln.latch# = l.latch#
order by name;

clear columns
clear breaks
clear computes

prompt
prompt A razao MISSES/GETS e IMMEDIATE_GETS/IMMEDIATE_MISSES deve ser < 0.1%
prompt
prompt 

ttitle "Sorts" skip 1

column value format 99G999G999
break on report
compute sum of value on report

select name, value
from v$sysstat
where name like 'sort%'
order by name;

clear columns
clear breaks
clear computes

prompt
prompt Total de SORTS (order by, group by, ...) realizados apenas em 
prompt memoria ou usando area temporaria (temporary tablespace) em disco.
prompt
prompt

ttitle "Freelists" skip 1

select class, count
from v$waitstat
where class in ( 'free list' );

prompt 
prompt Razao FreeListsCount/TotalGets deve ser menor que 1%.
prompt Adicionar freelists as tabelas criticas (recreate).
prompt

prompt *******************************************************************************
prompt
prompt Relacoes completas de V$PARAMETER, V$SYSSTAT, V$SGASTAT, V$SESSTAT e V$WAITSTAT
prompt ===============================================================================
prompt
prompt

ttitle center 'Configuracao da Instance - V$PARAMETER' skip 1

clear columns
clear breaks
clear computes

column isdefault heading "Default Value" format a14
column name      heading "Parametro"     format a25 wrap
column value     heading "Value"         format a38 wrap

break on isdefault

select isdefault, name, value
from v$parameter
order by isdefault, name;

ttitle center 'Estatisticas - V$SYSSTAT' skip 1

clear columns
clear breaks
clear computes

break on class

select name, value
from v$sysstat
order by class, name;
ttitle off

ttitle center 'Estatisticas - V$SGASTAT' skip 1

clear columns
clear breaks
clear computes

select name, bytes
from v$sgastat 
order by name;

ttitle center 'Estatisticas - V$WAITSTAT' skip 1

clear columns
clear breaks
clear computes

select *
from v$waitstat;

prompt
prompt 'EOF: Oracle'
prompt
prompt


