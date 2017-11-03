SELECT t.table_name AS "Table Name", 
           t.num_rows AS "Rows", 
           t.avg_row_len AS "Avg Row Len", 
           Trunc((t.blocks * p.value)/1024) AS "Size KB", 
           t.last_analyzed AS "Last Analyzed"
FROM   dba_tables t,
           v$parameter p
WHERE t.owner = Decode(Upper('msaf_dfe'), 'ALL', t.owner, Upper('msaf_dfe'))
AND   p.name = 'db_block_size'
ORDER by t.table_name;


-- ordenado por tamanho

SELECT t.table_name AS "Table Name", 
           t.num_rows AS "Rows", 
           t.avg_row_len AS "Avg Row Len", 
           Trunc((t.blocks * p.value)/1024) AS "Size KB"--, 
          -- t.last_analyzed AS "Last Analyzed"
FROM   all_tables t,
           v$parameter p
WHERE t.owner = Decode(Upper('rm'), 'ALL', t.owner, Upper('rm'))
AND   p.name = 'db_block_size'
ORDER by Trunc((t.blocks * p.value)/1024) desc;



-- TAMANHO OCUPADO EM DISCO


SELECT SEGMENT_NAME, BYTES/1024/1024 MB
FROM dba_segments
WHERE owner = 'ECORDERS'
AND SEGMENT_TYPE = 'TABLE' -- INDEX
AND segment_name = 'SALESORDERS'


SELECT S.OWNER, S.SEGMENT_NAME, BYTES/1024/1024 MB
FROM DBA_SEGMENTS S,
     DBA_INDEXES I
WHERE i.index_name = s.segment_name
AND s.segment_type = 'INDEX'
AND i.table_name = 'SALESORDERS'
ORDER BY BYTES/1024/1024 DESC