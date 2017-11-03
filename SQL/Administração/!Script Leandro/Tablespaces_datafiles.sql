set autocommit off
set termout  on
set linesize 1000
set pagesize 60
set verify off

Accept nome_tablespace Prompt 'Digite o nome da Tablespace : '

ttitle center "Relacao de tablespaces e datafiles" skip 1
alter session set nls_numeric_characters = ',.';

column tablespace_name   heading "Tablespace"    format a25 
column tablespace_status heading "Tbs.Status"    format a10
column file_name         heading "Filename"      format a60
column datafile_status   heading "File Status"   format a10
column total_bytes_free  heading "Mb Free"       format 999G990
column pct_free          heading "% Free"        format 990D00
column next_extent       heading "Next"          format 999G990
column max_extents       heading "Tam. Max."     format 999G990
column "datafile_size"     heading "File Size(Mb)"     format 999G990

break on tablespace_name skip 1 

compute sum of datafile_size    on tablespace_name
compute sum of total_bytes_free on tablespace_name
compute sum of max_bytes_free   on tablespace_name
compute sum of max_extents      on tablespace_name


select tbl.tablespace_name, 
       dbf.file_name,
       dbf.bytes/1024/1024               datafile_size,
       tbl.MAX_EXTENTS/1024/1024         max_extents,
       tbl.status                        tablespace_status,
       dbf.status                        datafile_status 
  from dba_tablespaces   tbl, 
       dba_data_files    dbf
where dbf.tablespace_name = tbl.tablespace_name
  and dbf.tablespace_name = upper('&nome_tablespace')
group by tbl.tablespace_name, 
         dbf.bytes/1024/1024,
         tbl.status, 
         dbf.file_name,
         dbf.bytes, 
         dbf.status,
         tbl.NEXT_EXTENT    ,
         tbl.MIN_EXTENTS    ,
         tbl.MAX_EXTENTS    
/

