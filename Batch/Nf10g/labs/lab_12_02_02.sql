connect / as sysdba
/

SELECT filename, status, bytes
FROM  v$block_change_tracking
/
