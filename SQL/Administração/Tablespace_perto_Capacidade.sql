SELECT   *
    FROM (SELECT c.tablespace_name,
                 ROUND (A.BYTES / 1048576, 2) megs_allocacted,
                 ROUND (b.BYTES / 1048576, 2) megs_free,
                 ROUND ((A.BYTES - b.BYTES) / 1048576, 2) megs_used,
                 ROUND (b.BYTES / A.BYTES * 100, 2) pct_free,
                 ROUND ((A.BYTES - b.BYTES) / A.BYTES, 2) * 100 pct_used
            FROM (SELECT   tablespace_name, SUM (A.BYTES) BYTES,
                           MIN (A.BYTES) minbytes, MAX (A.BYTES) maxbytes
                      FROM SYS.dba_data_files A
                  GROUP BY tablespace_name) A,
                 (SELECT   A.tablespace_name, NVL (SUM (b.BYTES), 0) BYTES
                      FROM SYS.dba_data_files A, SYS.dba_free_space b
                     WHERE A.tablespace_name = b.tablespace_name(+)
                           AND A.file_id = b.file_id(+)
                  GROUP BY A.tablespace_name) b,
                 SYS.dba_tablespaces c
           WHERE A.tablespace_name = b.tablespace_name(+)
             AND A.tablespace_name = c.tablespace_name
             -- comment out next 5 lines to remove check for autoextend
             AND NOT EXISTS (
                    SELECT 'X'
                      FROM SYS.dba_data_files
                     WHERE tablespace_name = A.tablespace_name
                       AND autoextensible = 'YES')
               )
   WHERE pct_used >= 90
ORDER BY tablespace_name