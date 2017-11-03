Rem ind_fix.sql - Shows the details for index stats

set pagesize 60;
set linesize 100;
set echo off;
set feedback off;
set heading off;
 
column c1 format a18;
column c2 format 9,999,999;
column c3 format 9,999,999;
column c4 format 999,999;
column c5 format 99,999;
column c6 format 9,999;

spool idx_report.lst;

prompt
prompt
prompt '                      # rep       dist.    # deleted              blk s
prompt Index                  keys        keys      leaf rows  Height      per s
prompt --------------------  ------       -----     --------   ------      -----

select distinct
  name                  c1,
  most_repeated_key     c2,
  distinct_keys         c3,
  del_lf_Rows           c4,
  height                c5,
  blks_gets_per_access  c6
from temp_stats
where
  height > 3
  or
  del_lf_rows > 10
order by name;

spool off;

spool id6.sql;

select 'alter index '||owner||'.'||name||' rebuild tablespace '||tablespace_name||';'
from temp_stats, dba_indexes
where 
  temp_stats.name = dba_indexes.index_name
  and
  (height > 3
  or
  del_lf_rows > 10);
 
select 'analyze index '||owner||'.'||name||' compute statistics;'
from temp_stats, dba_indexes
where
  temp_stats.name = dba_indexes.index_name
  and
  (height > 3
  or
  del_lf_rows > 10);

spool off;

