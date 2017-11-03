/* Lista tablespaces existentes c/alocacao de espaco para cada uma. */
select substr(tablespace_name,1,10) "TABLESPACE",
       initial_extent "INIT_EXT",
       next_extent "NEXT_EXT",
       min_extents "MIN_EXT",
       max_extents "MAX_EXT",
       pct_increase,
       status
from sys.dba_tablespaces
/
