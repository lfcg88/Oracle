SELECT t.table_name AS "Table Name",
       t.TABLESPACE_NAME AS "Table space",
       t.num_rows AS "Rows",
       t.avg_row_len AS "Avg Row Len",
       Trunc((t.blocks * p.value)/1024) AS "Size MB", -- numero de blocos X o seu tamanho em KBs
       t.last_analyzed AS "Last Analyzed"       
FROM   dba_tables t,
       v$parameter p
WHERE t.owner = 'NOME_OWNER'
AND   p.name = 'db_block_size'
ORDER BY 5 desc;

--
-- BOMM
SELECT
T.TABLE_NAME AS “TABLE NAME”,
T.NUM_ROWS AS “ROWS”,
T.AVG_ROW_LEN AS “AVG ROW LEN”,
TRUNC((T.BLOCKS * P.VALUE)/1024) AS “SIZE KB”,
T.LAST_ANALYZED AS “LAST ANALYZED”
FROM
DBA_TABLES T,
V$PARAMETER P
WHERE T.OWNER = "BDMARCASN"
AND P.NAME = ‘DB_BLOCK_SIZE’
ORDER BY T.TABLE_NAME;