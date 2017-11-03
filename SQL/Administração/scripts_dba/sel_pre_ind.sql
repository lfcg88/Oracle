/* Gera estatisticas de initial de todas as indices do sistema financeiro */
/* Em 21/09/95                                                            */
set pause off
set pagesize 5000
column segment_name    format a25 heading "Indice"
column inicial         format 9999999999 

/* select segment_name,pct_increase, extents,(initial_extent * 2048) inicial ,bytes */
select segment_name,pct_increase, extents,initial_extent inicial ,bytes
from sys.dba_segments 
where segment_type  = 'INDEX' and
owner in ('COMERCIAL')  and
tablespace_name in ('INDICES_LIR','DADOS_LIR')
order by segment_name
/
