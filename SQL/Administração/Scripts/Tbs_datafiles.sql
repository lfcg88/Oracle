set autocommit off
set termout  on
set linesize 1000
set pagesize 60
set verify off

Accept nome_tablespace Prompt 'Digite o nome da Tablespace : '

ttitle center "Relacao de tablespaces e datafiles" skip 1
alter session set nls_numeric_characters = ',.';

column tablespace_name   heading "Tablespace"    format a30 
column tablespace_status heading "Tbs.Status"    format a10
column file_name         heading "Filename"      format a80
column datafile_status   heading "File Status"   format a10
column total_bytes_free  heading "Mb Free"       format 99G999G990
column pct_free          heading "% Free"        format 990D00
column next_extent       heading "Next"          format 99G999G990
column max_extents       heading "Tam. Max."     format 99G999G990
column "datafile_size"     heading "File Size(Mb)"     format 99G999G990

break on tablespace_name skip 1 

compute sum of datafile_size    on tablespace_name
compute sum of total_bytes_free on tablespace_name
compute sum of max_bytes_free   on tablespace_name
compute sum of max_extents      on tablespace_name


select tbl.tablespace_name, 
       tbl.status                        tablespace_status,
       dbf.status                        datafile_status, 
       dbf.bytes/1024/1024               datafile_size,
       sum (spc.bytes)/1024/1024         total_bytes_free,
       (100*sum (spc.bytes))/dbf.bytes   pct_free,
       tbl.NEXT_EXTENT/1024/1024         next_extent,
       tbl.MAX_EXTENTS/1024/1024         max_extents,
       dbf.file_name
  from dba_tablespaces   tbl, 
       dba_data_files  dbf, 
       dba_free_space  spc
where spc.tablespace_name = tbl.tablespace_name
  and spc.file_id         = dbf.file_id
  and dbf.tablespace_name = tbl.tablespace_name
  and dbf.tablespace_name like upper('%&nome_tablespace%')
group by tbl.tablespace_name, 
         tbl.status, 
         dbf.file_name,
         dbf.bytes, 
         dbf.status,
         tbl.NEXT_EXTENT    ,
         tbl.MIN_EXTENTS    ,
         tbl.MAX_EXTENTS    
/

