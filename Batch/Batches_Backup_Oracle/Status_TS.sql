spool d:\batches_Novo\logs\Status_TS.txt 
conn backup/senhabackup@miafis
TTITLE 'LISTA DE TABLESPACES E ÁREAS LIVRES'
set linesize 183
SET PAGESIZE 60
col TS for A20
col "File Name" for A60
COL "Mb Livres" for 999G999D00
COL "Max Mb Livre" for 999G999D00
col "Mb Alocados" for 999G999D00
col "% Livre" for 999D00
col "Segmento" for A30
col "Mb Auto Inc" for 999G999D000
TTITLE 'LISTA DE TABLESPACES E ÁREAS LIVRES'
SELECT fs.tablespace_name as TS, fs.MBYTES AS "Mb Livres",fs.maxbytes as "Max Mb Livres",fs.nareas as "N.áreas",
   dfs.mbytes as "Mb Alocados",fs.mbytes/dfs.mbytes*100 as "% Livre"
   from
   (select tablespace_name,sum(bytes)/1024/1024 as mbytes from dba_data_files group by tablespace_name) dfs,
   (select tablespace_name, max(bytes)/1024/1024 as maxbytes,sum(bytes)/1024/1024 as mbytes,count(*) as nareas from dba_free_space group by tablespace_name) fs
   where fs.tablespace_name = dfs.tablespace_name
   order by fs.tablespace_name;

TTITLE 'LISTA DE DATAFILES, ÁREAS LIVRES E AUTO-INCREMENTO'
SELECT df.tablespace_name as TS,
  df.file_id as "File ID",
  df.file_name as "File Name",
  fs.mbytes as "Mb Livres",
  fs.maxmbytes as "Max Mb Livre",
  fs.nareas as  "N.áreas",
  df.bytes/1024/1024 as "Mb Alocados",
  fs.mbytes/(df.bytes/1024/1024)*100 as "% Livre",
  (case when increment_by = 0 then null else
  INCREMENT_BY * (SELECT VALUE FROM V$PARAMETER WHERE NAME = 'db_block_size')/1024/1024 end) AS "Mb Auto Inc"
  from dba_data_files df,
     (select file_id, max(bytes)/1024/1024 as maxmbytes,sum(bytes)/1024/1024 as mbytes,count(*) as nareas from dba_free_space group by file_id) fs
  where fs.file_id = df.file_id
  order by df.tablespace_name,df.file_id;

TTITLE 'LISTA DE SEGMENTOS QUE NÃO PODEM CRESCER MAIS UM EXTENT'
select Segmento as "Segmento",Tipo as "Tipo",TS,Next_Extent as "Next_Extent",
  (select max(bytes) from dba_free_space where tablespace_name = All_Segments.TS) as "Maior área"
  from
  (select owner || '.' || segment_name as Segmento,
   Tablespace_Name as TS,Segment_Type as Tipo,
   nvl(next_extent,initial_extent)  as Next_Extent
   from dba_segments) All_Segments
  where not exists (select 0 from dba_free_space
                    where tablespace_name = All_Segments.TS and
                          bytes >= All_Segments.Next_Extent);

COL OWNER FOR A20
COL SEGMENT_TYPE FOR A20
COL SEGMENT_NAME FOR A30
COL "Used Kb" for 999G999G999
COL "Unused Kb" for 999G999G999
COL "Kb Initial" for 999G999G999
COL "Kb Next" for 999G999G999
col "Ext.Count" for 999G999G999
col "Max Extents" for 9G999G999G999
TTITLE 'LISTA DE SEGMENTOS, ATRIBUTOS E ALOCAÇÃO'
exec sp_pop_temp_space;
select OWNER,SEGMENT_TYPE,SEGMENT_NAME,(TOTAL_BYTES-UNUSED_BYTES)/1024 as "Used Kb",
           UNUSED_BYTES/1024 as "Unused Kb",
           INITIAL_EXTENT/1024 AS "Kb Initial",NEXT_EXTENT/1024 as "Kb Next",EXTENT_COUNT as "Ext.Count",
           MAX_EXTENTS AS "Max Extents",partition_name as "Partition"
       from TEMP_SPACE
       ORDER BY OWNER,SEGMENT_TYPE,SEGMENT_NAME;

spool off
quit;

