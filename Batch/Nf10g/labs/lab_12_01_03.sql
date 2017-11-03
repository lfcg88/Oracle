connect / as sysdba

SELECT name, space_limit AS quota,
space_used        AS used,
space_reclaimable AS reclaimable,
number_of_files   AS files
FROM  v$recovery_file_dest 
/
