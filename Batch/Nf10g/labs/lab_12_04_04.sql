connect / as sysdba

SELECT file#, TRUNC(AVG(datafile_blocks)) blocks_in_file, 
TRUNC(AVG(blocks_read)) blocks_read,
TRUNC(AVG(blocks)) blocks_backed_up, 
TRUNC(AVG(blocks_read/datafile_blocks)*100) pct_read_for_backup
FROM v$backup_datafile
WHERE used_change_tracking='YES'
AND incremental_level > 0
GROUP BY file#; 

