set pagesize  60
set linesize  110
set trimspool on

column object_type     heading "Object Type" format a10
column tablespace_name heading "Tablespace"  format a15
column file_name       heading "File"        format a40
column object_name     heading "Object"      format a25

break on object_type on tablespace_name on file_name

ttitle "Relacao de objetos por datafile" skip 

select o.object_type,
       f.tablespace_name,
       f.file_name,
       o.object_name
from dba_data_files f,
     dba_objects    o,
     sys.tab$       t
where f.file_id      = t.file#
  and o.object_id    = t.obj#
  and o.owner not in ( 'SYS', 'SYSTEM' )
  and f.tablespace_name = upper('&nome_tablespace')
order by o.object_type,
         f.tablespace_name,
         f.file_name,
         o.object_name;

