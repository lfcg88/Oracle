/* Lista objetos com seus nexts e blocos que poderao alocar. */
/* Executar passando como parametreo DADOS ou INDICES        */

set verify off
ttitle "NEXT EXTENTS E BLOCOS POSSIVEIS DE ALOCACAO:"

col segment_name format a20
col segment_type head "Tipo" format a5
col tablespace_name head "Tbspc" format a8
col inc format 999
col bloco head "Bloco livre"

select S.segment_name,
       S.segment_type,
       S.tablespace_name,
       S.next_extent*2048 next,
       S.pct_increase inc,
       F.bytes bloco
from sys.dba_segments S,
     sys.dba_free_space F
where S.segment_type in ('TABLE','INDEX')
  and S.owner = 'COMERCIAL'
  and S.tablespace_name = '&1'
  and S.tablespace_name = F.tablespace_name
  and (S.next_extent*2048) < F.bytes
order by F.bytes desc, 
         S.next_extent desc,
         S.segment_name
/
