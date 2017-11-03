
/***************************************/
/* Reporta estatistica de Buffer Cache */
/***************************************/

set space 4 
--TTITLE 'Estatistica de calculos sobre Buffer Cache' 
column buffer_cache_factor format 999.99 heading "% Buffer Cache|{1-[Ph/(DB+Con)]} > 0.65"

select db.value        "DB Block Gets",
       cn.value        "Consistent Gets",
       ph.value        "Physical Reads",
       1 - (ph.value / (db.value + cn.value)) buffer_cache_factor 
  from v$sysstat db,
       v$sysstat cn,
       v$sysstat ph
       where db.name = 'db block gets'   and
             cn.name = 'consistent gets' and
             ph.name = 'physical reads'
/
set space 1
