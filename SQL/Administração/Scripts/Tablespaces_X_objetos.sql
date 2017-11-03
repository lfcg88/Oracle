set verify off
ACCEPT Tablespace_name Prompt 'Digite o nome da Tablespace: '
alter session set nls_numeric_characters = ',.';
alter session set nls_date_format = 'DD/MM/YYYY';

set linesize 180
set pagesize 66
set echo off

column Objeto          heading "Objeto"     format a36 wrap
column pct_free        heading "PCTfree"    format 990
column pct_used        heading "PCTused"    format 990
column num_rows        heading "# rows"     format 9G999G990
column chain_cnt       heading "Chain #"    format 9G999G990
column avg_row_len     heading "Avg.row."   format 99G990
column extents         heading "Extents"    format 990
column initial         heading "Initial"    format 999G999G990
column next            heading "Next"       format 999G999G990
column kbytes          heading "Mbytes"     format 999G999G990
column segment_type    heading "Tipo"       format a8
column tablespace_name heading "Nome da Tablespace"     format a30

clear breaks
clear computes
break on tablespace_name skip 1 on owner

select t.tablespace_name, 
       t.owner||'.'||t.table_name Objeto, 
       s.segment_type      segment_type,
       s.bytes/1024/1024   kbytes,
       s.initial_extent/1024/1024    "initial",
       s.next_extent/1024/1024       "next",
       t.pct_free,
       t.pct_used,
       t.num_rows,
       t.chain_cnt,
       t.avg_row_len,
       s.extents
from dba_tables   t,
     dba_segments s
where t.table_name   = s.segment_name
  and t.owner        = s.owner
  and t.tablespace_name like upper('%&Tablespace_name%')
order by t.tablespace_name, t.owner, t.table_name;


clear computes 
clear breaks
clear columns
ttitle off
btitle off

