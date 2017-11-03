/* orastobj.sql */
/* Lista tabelas e indices com maior numero de extents */

set echo off
set verify off
set feedb off
set pause off
set pages 1

col pula head " " fold_b 1
col segment_name head "Objeto" format a20
col segment_type head "Tipo"   format a7
col tablespace_name head "Tablespace" format a12
col extents format 9999 head "Extents"
col baites format 999999 head "Kbytes"

select 'Objetos (tabelas e indices) com maior numero de extents (>= 10):' pula
from sys.dual;

set pages 100

select segment_name,
       segment_type,
       tablespace_name,
       extents,
       bytes/1024 baites
from sys.dba_segments
where segment_type in ('TABLE','INDEX')
  and owner = 'COMERCIAL'
  and extents >= 10
order by segment_type desc, extents desc
/

exit

