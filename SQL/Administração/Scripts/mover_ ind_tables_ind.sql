SELECT 'ALTER INDEX DBMRC.' || index_name || ' REBUILD TABLESPACE DBMRC_IND1;'
  FROM dba_indexes
  WHERE
    owner = 'DBMRC' AND     index_type != 'LOB';

SELECT 'ALTER TABLE DBMRC.' || TABLE_NAME || ' MOVE LOB( ' || COLUMN_NAME || ' ) STORE AS (TABLESPACE  DBMRC_LOB1);' FROM dba_tab_columns WHERE owner = 'DBMRC' AND data_type LIKE '%LOB';