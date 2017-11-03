/* orafree3.sql */
/* Lista objetos com menor bloco que podera' alocar          */
/* Executar passando como parametro DADOS ou INDICES         */

set echo off
set verify off
set feedb off
set pause off
set pages 1

col pula head " " fold_b 1 
col tablespace_name head "Tablespace" format a10
col segment_name head "Objeto" format a20
col segment_type head "Tipo"   format a5
col bloco head "Menor Bloco"
col maiores head "Maiores blocos contiguos" new_value maior2 

set pages 100

select tablespace_name,
       bytes maiores
from sys.dba_free_space@&1 A
where tablespace_name='&2'
and   2 > (select count(*)
           from sys.dba_free_space@&1 B
           where tablespace_name = '&2'
             and B.bytes > A.bytes)
order by bytes desc;

set pages 1

select 'Maiores Next c/respectivo menor bloco p/alocacao (TbSpc &2):' pula
from sys.dual@&1;

set pages 100

select S.segment_name,
       S.segment_type,
       S.next_extent*&3 "Next Extent",
       min(F.bytes) bloco
from sys.dba_segments@&1 S,
     sys.dba_free_space@&1 F
where S.segment_type in ('TABLE','INDEX')
  and S.owner = 'COMERCIAL'
  and S.tablespace_name = '&2'
  and S.tablespace_name = F.tablespace_name
  and (S.next_extent*&3) < F.bytes
group by S.segment_name,
         S.segment_type,
         S.next_extent
having min(F.bytes) >= &maior2
order by 4 desc;

-- exit

