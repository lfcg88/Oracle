/* orafree2.sql */
/* Lista objetos que next extent e' maior que bloco contiguo disponivel */
/* Executar passando como parametreo DADOS ou INDICES                   */

set echo off
set verify off
set feedb off
set pause off
set pages 1

col pula head " " fold_b 1 
col segment_name head "Objeto" format a30
col segment_type head "Tipo"   format a5
col tablespace_name head "Tablespace" format a10
col pct_increase head "Pct Inc" 


select 'Next extents que NAO poderao ser alocados (TbSpc &3):' pula
from sys.dual;


set pages 100

select segment_name,
       segment_type,
       tablespace_name,
       next_extent next,
       pct_increase
from sys.dba_segments
where segment_type in ('TABLE','INDEX')
  and owner = 'PANNET'
  and tablespace_name = '&&3'
  and (next_extent)    >   (select max(bytes)
                            from sys.dba_free_space
                            where tablespace_name = '&&3')
order by next_extent desc;

-- exit

