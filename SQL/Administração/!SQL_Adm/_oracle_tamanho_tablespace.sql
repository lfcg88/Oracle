select substr(a.tablespace_name,1,20) "Tablespaces",
      ( b.BYTES/1048576 ) as "TotalMB",
      (b.BYTES/1048576)-(c.BYTES/1048576) as "UsedMB",
      (c.BYTES/1048576) as "FreeMB"
  from dba_tablespaces a,
         (select tablespace_name,sum(bytes) as "BYTES" 
                    from dba_data_files 
                   group by tablespace_name ) b,
         (select tablespace_name,sum(bytes) as "BYTES" 
                   from dba_free_space  
                   group by tablespace_name) c
   where
      a.tablespace_name = b.tablespace_name(+)
      and b.tablespace_name = c.tablespace_name(+)
      order by a.tablespace_name;



-- verificar tamanho de temp datafile

SELECT tablespace_name, file_name, bytes
FROM dba_temp_files WHERE tablespace_name = 'TEMP'


-- verificar status da tablespace temporaria

SELECT tablespace_name,
       total_blocks,
       used_blocks,
       free_blocks,
    total_blocks*16/1024 as total_MB,
    used_blocks*16/1024 as used_MB,
    free_blocks*16/1024 as free_MB
FROM   v$sort_segment;