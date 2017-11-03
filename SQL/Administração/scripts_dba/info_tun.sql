set termout off

/*
**
** nome: info_tun.sql
**
** gera informacoes para analise e tunning de memoria e contencao
**
** autor: Celio Reis
** manut: Washington Oliveira (05/01/96):
**        Melhoria da query de estatistica de Buffer Cache
**
** data: 22/07/95
*/

set pause off
set verify off

column name format a30
column rname format a20
column osuser format a15
column time   format a30

break on report skip 0
compute sum of mem_value on report

set termout on
clear screen

accept wspool  char prompt 'ARQ. SAIDA    ==> '

set termout off
spool &wspool

/*
****************************************************************************
** IDENTIFICACAO DO DATABASE
**
**************************************************************************/

select name,
       to_char(sysdate,'DD-MON-YYYY HH24:MM') "TIME"
from v$database;

/*
****************************************************************************
** TOTAL DA SGA
**
**************************************************************************/

select name,value   
from v$sga;

/*
****************************************************************************
** DATA DICTIONARY CACHE
**
** Obs: Ratio deve ser menor que 10%.
**      Se nao for, deve-se aumentar o parametro SHARED_POOL_SIZE.
***************************************************************************/

select sum(gets) "DD GETS",
       sum(getmisses) "DD CACHE GET MISSES",
       (sum(getmisses) / sum(gets)) * 100 "% RATIO"
from v$rowcache;

/*
****************************************************************************
** LIBRARY CACHE
**
** Obs: "Cache misses while exec"  deve estar proximo de 0.
**      Ratio deve ser menor que 1%.
**      Se nao for, deve-se aumentar o parametro SHARED_POOL_SIZE.
***************************************************************************/

select sum(pins) "EXECUTIONS",
       sum(reloads) "CACHE MISSES WHILE EXEC",
       (sum(reloads) / sum(pins)) * 100 "% RATIO"
from v$librarycache;

/*
***************************************************************************
** BUFFER CACHE
**
** Obs: Hit Ratio = 1 - (physical reads / (db block gets + const. gets))
**      Deve ser maior que 65%. Quanto maior, melhor.
**      Se nao for, deve-se aumentar o parametro DB_BLOCK_BUFFERS
**      de forma incremental.
***************************************************************************/

col buf_cache_factor format 999.99 heading "% Buffer Cache"

select db.value  "DB Block Gets",
       cn.value  "Consistent Gets",
       ph.value  "Physical Reads",
       1 - (ph.value / (db.value + cn.value)) buf_cache_factor
from v$sysstat db,
     v$sysstat cn,
     v$sysstat ph
where db.name = 'db block gets'
  and cn.name = 'consistent gets'
  and ph.name = 'physical reads'
/

/*
****************************************************************************
** CONTENTION FOR ROLLBACK SEGS
**
** Obs: nenhum % HITS deve ser menor que 95%. 
**      Nenhum COUNT deve ser maior que 1% do SUM OF GETS.
**      Se for, deve-se aumentar o numero de rollback segs.
***************************************************************************/

select name, gets, waits, ((gets-waits) / gets) * 100 "% HITS"
from v$rollstat s, v$rollname n
where s.usn = n.usn;

select class, count
from v$waitstat
where class in ('system undo header','system undo block','undo header',
                'undo block');

select sum(value) "SUM OF GETS"
from v$sysstat
where name in ('db block gets','consistent gets');

  
/*
*************************************************************************
** UTILIZACAO DE ESPACO NOS ROLLBACK SEGS
**
**************************************************************************/

select name "RNAME",
       extents,
       rssize,
       writes, 
       (writes / rssize) * 100 "% USED",
       xacts
from v$rollstat a, v$rollname b
where a.usn = b.usn;        


/*
***************************************************************************
** COUNTENTION FOR REDO LOG BUFFER
**
** Obs: VALUE deve estar proximo de zero.
**      Se nao for, deve-se aumentar o tamanho do LOG_BUFFER
** Obs: (MISSES / GETS) * 100 deve ser menor que 1%
**      (IM_MISSES / (IM_GETS + IM_MISSES)) * 100 deve ser menor que 1%
**      Se nao for, deve-se diminuir o tamanho do LOG_SMALL_ENTRY_MAX_SIZE.
***************************************************************************/

select name, value
from v$sysstat 
where name = 'redo log space requests';

select n.name,
       gets,
       misses,
       immediate_gets "IM_GETS" ,
       immediate_misses "IM_MISSES"
from v$latch l, v$latchname n
where n.name in ('redo allocation','redo copy')
and n.latch# = l.latch#; 

/*
****************************************************************************
** SORT AREA 
**
** Obs: SORT(DISK) deve ser o menor possivel.
**      Se nao for deve-se aumentar o tamanho da SORT_AREA_SIZE
***************************************************************************/

select name,value
from v$sysstat 
where name in ('sorts (memory)','sorts (disk)');

/*
****************************************************************************
** FREE LIST CONTENTION
**
** Obs: Se COUNT for maior que 1% de SUM OF GETS, deve-se aumentar
**      o numero de FREE LISTS nas tabelas. Isto so' pode ser feito
**      recriando-as.            
***************************************************************************/

select class, count
from v$waitstat
where class = 'free list';

select sum(value) "SUM OF GETS"
from v$sysstat
where name in ('db block gets','consistent gets');

/*
****************************************************************************
** CURRENT USER SESSIONS
**
***************************************************************************/

select osuser,   
       block_gets "GETS",
       consistent_gets "C_GETS",
       physical_reads "PHY_READS",
       block_changes "CHANGES",
       consistent_changes "C_CHANGES"
from v$sess_io a, v$session b
where a.sid = b.sid   
and type = 'USER';

/*
****************************************************************************
** MEMORY FOR USER SESSIONS
**
***************************************************************************/

select name, sum(a.value) "MEM_VALUE"
from v$sesstat a, v$sysstat b
where a.statistic# = b.statistic#
and a.sid in ( select distinct(sid) 
               from v$session
               where type = 'USER' )
and a.statistic# in (15,20)
group by name;


/*
****************************************************************************
** DISK ACTIVITY
**
***************************************************************************/

select name,    
       phyrds "PH_READ",
       phywrts "PH_WRITE"
from v$datafile a, v$filestat b
where a.file# = b.file#;

/*
****************************************************************************
** FIM
***************************************************************************/

spool off
set termout on
set pause on
set verify on
exit

