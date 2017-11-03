ttitle center "Relatório de ocupação de espaço por tipo de objeto" SKIP 2
SET LINES 65
SET PAGESIZE 60
COL "Tamanho (Mb)" FORMAT 999G999G999D99
COL "Nome do Objeto" FORMAT A30
COL "Tipo de Objeto" FORMAT A14
COL "Schema" FORMAT A10
BREAK ON "Schema"

select owner "Schema"
     , SEGMENT_TYPE  "Tipo de Segmento"
     , sum(bytes)/1024/1024 "Tamanho (Mb)"
  from dba_segments
 where owner is not null
   and owner not in ('SYSTEM','SYS')
group  by owner, SEGMENT_TYPE
/
