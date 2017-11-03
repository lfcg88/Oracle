-- ********************************************************
-- Report section
-- ********************************************************

set echo off;
set feedback on

set pages 999;
column nbr_FTS  format 999,999
column num_rows format 999,999,999
column blocks   format 999,999
column owner    format a14;
column name     format a25;

set heading off;
set feedback off;
select 
   'alter table '||p.owner||'.'||p.name||' storage (buffer_pool keep);'
from 
   dba_tables t,
   dba_segments s,
   sqltemp s,
  (select distinct 
     statement_id stid, 
     object_owner owner, 
     object_name name
   from 
      plan_table
   where 
      operation = 'TABLE ACCESS'
      and
      options = 'FULL') p
where 
   s.addr||':'||TO_CHAR(s.hashval) = p.stid
   and
   t.table_name = s.segment_name
   and
   t.table_name = p.name
   and
   t.owner = p.owner
   and
   t.buffer_pool <> 'KEEP'
having
   s.blocks < 50
group by 
   p.owner, p.name, t.num_rows, s.blocks
order by 
   sum(s.executions) desc;

