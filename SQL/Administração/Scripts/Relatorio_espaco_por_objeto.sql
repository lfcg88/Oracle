ttitle center "Relatório de ocupação de espaço por objeto" SKIP 2
SET LINES 80
SET PAGESIZE 65
COL "Tamanho (Mb)" FORMAT 999G999G999D99
COL "Nome do Objeto" FORMAT A30
COL "Tipo de Objeto" FORMAT A14
COL "Schema" FORMAT A10
BREAK ON "Schema" on "Tipo de Objeto"

select OWNER                "Schema"
     , SEGMENT_TYPE         "Tipo de Objeto"
     , segment_name         "Nome do Objeto"
     , sum(bytes)/1024/1024 "Tamanho (Mb)"
  from dba_segments
where OWNER NOT IN ('SYSTEM','SYS')
  AND OWNER IS NOT NULL
group  by OWNER
     , SEGMENT_TYPE
     , segment_name
/
