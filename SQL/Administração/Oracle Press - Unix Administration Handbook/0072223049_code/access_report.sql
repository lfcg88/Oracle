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
column name     format a24;
column ch       format a1;
column K        format a1;

--spool access.lst;

set heading off;
set feedback off;
ttitle 'Total SQL found in library cache'
select count(distinct statement_id) from plan_table; 

ttitle 'Total SQL that could not be explained'
select count(distinct statement_id) from plan_table where remarks is not null;

set heading on;
set feedback on;
ttitle 'full table scans and counts|  |Note that "?" indicates in the table is cached.'
select 
   p.owner, 
   p.name, 
   t.num_rows,
   ltrim(t.cache) ch,
   decode(t.buffer_pool,'KEEP','K','DEFAULT',' ') K,
   s.blocks blocks,
   sum(s.executions) nbr_FTS
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
   t.owner = s.owner
   and
   t.table_name = s.segment_name
   and
   t.table_name = p.name
   and
   t.owner = p.owner
having
   sum(s.executions) > 9
group by 
   p.owner, p.name, t.num_rows, t.cache, t.buffer_pool, s.blocks
order by 
   sum(s.executions) desc;

column nbr_RID  format 999,999,999
column num_rows format 999,999,999
column owner    format a15;
column name     format a25;

ttitle 'Table access by ROWID and counts'
select 
   p.owner, 
   p.name, 
   t.num_rows,
   sum(s.executions) nbr_RID
from 
   dba_tables t,
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
      options = 'BY ROWID') p
where 
   s.addr||':'||TO_CHAR(s.hashval) = p.stid
   and
   t.table_name = p.name
   and
   t.owner = p.owner
having
   sum(s.executions) > 9
group by 
   p.owner, p.name, t.num_rows
order by 
   sum(s.executions) desc;

--*************************************************
--  Index Report Section
--*************************************************

column nbr_scans  format 999,999,999
column num_rows   format 999,999,999
column tbl_blocks format 999,999,999
column owner      format a9;
column table_name format a20;
column index_name format a20;

ttitle 'Index full scans and counts'
select
   p.owner,
   d.table_name,
   p.name index_name,
   seg.blocks tbl_blocks,
   sum(s.executions) nbr_scans
from
   dba_segments seg,
   sqltemp s,
   dba_indexes d,
  (select distinct
     statement_id stid,
     object_owner owner,
     object_name name
   from
      plan_table
   where
      operation = 'INDEX'
      and
      options = 'FULL SCAN') p
where
   d.index_name = p.name
   and
   s.addr||':'||TO_CHAR(s.hashval) = p.stid
   and
   d.table_name = seg.segment_name
   and
   seg.owner = p.owner
having
   sum(s.executions) > 9
group by
   p.owner, d.table_name, p.name, seg.blocks
order by
   sum(s.executions) desc;


ttitle 'Index range scans and counts'
select
   p.owner,
   d.table_name,
   p.name index_name,
   seg.blocks tbl_blocks,
   sum(s.executions) nbr_scans
from
   dba_segments seg,
   sqltemp s,
   dba_indexes d,
  (select distinct
     statement_id stid,
     object_owner owner,
     object_name name
   from
      plan_table
   where
      operation = 'INDEX'
      and
      options = 'RANGE SCAN') p
where
   d.index_name = p.name
   and
   s.addr||':'||TO_CHAR(s.hashval) = p.stid
   and
   d.table_name = seg.segment_name
   and
   seg.owner = p.owner
having
   sum(s.executions) > 9
group by
   p.owner, d.table_name, p.name, seg.blocks
order by
   sum(s.executions) desc;


ttitle 'Index unique scans and counts'
select 
   p.owner, 
   d.table_name, 
   p.name index_name, 
   sum(s.executions) nbr_scans
from 
   sqltemp s,
   dba_indexes d,
  (select distinct 
     statement_id stid, 
     object_owner owner, 
     object_name name
   from 
      plan_table
   where 
      operation = 'INDEX'
      and
      options = 'UNIQUE SCAN') p
where 
   d.index_name = p.name
   and
   s.addr||':'||TO_CHAR(s.hashval) = p.stid
having
   sum(s.executions) > 9
group by 
   p.owner, d.table_name, p.name
order by 
   sum(s.executions) desc;





