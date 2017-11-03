/* Lista objetos com respectivos NEXT EXTENT em ordem desc. de tamanho */

col segment_name format a20
col segment_type format a5
col tablespace_name format a8

select segment_name,segment_type,tablespace_name,
       bytes,
       initial_extent*2048 init,
       next_extent*2048 next,
       pct_increase,
       extents,
       next_extent*(100+pct_increase)/100*2048 next_inc
from sys.dba_segments
where segment_type in ('TABLE','INDEX')
  and owner = 'COMERCIAL'
order by next_inc desc
/
