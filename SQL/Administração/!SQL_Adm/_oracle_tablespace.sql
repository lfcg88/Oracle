## Verificando tamanho total e estaço livre das tablespaces

select df.tablespace_name "Tablespace",
 totalusedspace "Used MB",
 (df.totalspace - tu.totalusedspace) "Free MB",
 df.totalspace "Total MB",
 round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace))
 "Pct. Free"
 from
 (select tablespace_name,
 round(sum(bytes) / 1048576) TotalSpace
 from dba_data_files 
 group by tablespace_name) df,
 (select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
 from dba_segments 
 group by tablespace_name) tu
 where df.tablespace_name = tu.tablespace_name ; 



## query 2

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


## Query para checar o tamanho dos arquivos das tablespaces

select file_name, tablespace_name, (bytes / 1048576),  AUTOEXTENSIBLE from dba_data_files where tablespace_name like '%ESBIGTBL%'; 


## Acrescentando datafile em OMF setando tamanho inicial e o quanto cresce por vez e colocando também o autoextend
alter tablespace ESBIGTBL add datafile size 2G AUTOEXTEND ON next 200M;



## query para verificar quanto espaço livre tem a talbespace
select tablespace_name,  sum(bytes) from dba_free_space where tablespace_name = 'ESBIGTBL' group by tablespace_name;



## verificar tamanho de temp datafile

SELECT tablespace_name, file_name, bytes
FROM dba_temp_files WHERE tablespace_name = 'TEMP'


## verificar status da tablespace temporaria

SELECT tablespace_name,
       total_blocks,
       used_blocks,
       free_blocks,
    total_blocks*16/1024 as total_MB,
    used_blocks*16/1024 as used_MB,
    free_blocks*16/1024 as free_MB
FROM   v$sort_segment;