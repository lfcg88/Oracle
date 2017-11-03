
/* Lista objetos com menor bloco que podera' alocar          */
/* Executar passando como parametro DADOS ou INDICES         */

set verify off
ttitle "OBJETOS E BLOCO DE MENOR TAMANHO POSSIVEL DE ALOCACAO:"

col segment_name format a20
col bloco head "Menor Bloco"

select S.segment_name,
       min(F.bytes) bloco,
       S.next_extent*2048 "Next"
from sys.dba_segments S,
     sys.dba_free_space F
where S.segment_type in ('TABLE','INDEX')
  and S.owner = 'COMERCIAL'
  and S.tablespace_name = '&1'
  and S.tablespace_name = F.tablespace_name
  and (S.next_extent*2048) < F.bytes
group by S.segment_name,
         S.next_extent
order by 2 desc
/
