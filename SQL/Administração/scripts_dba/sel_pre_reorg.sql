/* Gera estatisticas de initial de todas as tabelas do sistema financeiro */
/* Em 21/09/95                                                            */
--set pause off
--set pagesize 5000
column segment_name    format a25 heading "Tabela"
column inicial         format 9999999999999 

select segment_name,extents,initial_extent inicial ,next_extent,bytes
from sys.dba_segments 
where segment_type  in ('TABLE','INDEX')  and
owner in ('SYSTEM','SYS') 
order by segment_name;

