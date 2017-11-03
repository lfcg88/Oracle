/* orafree1.sql */
/* Lista espaco em tablespaces e high-water mark do segm. rollback */

set echo off
set verify off
set feedb off
set head off
set pause off
set pages 0

col total format "99,999" head "Total"
col livre format "99,999" head "Livre"
col hwmsize format "999"
col rbsize format "999"
break on tbspc nodup

select substr(tablespace_name,1,10) tbspc,
       trunc(sum(bytes)/1024/1024) total,
       ' Mb total'
from sys.dba_data_files
group by tablespace_name
having (tablespace_name <> 'TEMP') and (tablespace_name not like 'ROLL%')
union all
select substr(tablespace_name,1,10) tbspc,
       trunc(sum(bytes)/1024/1024) livre,
       ' Mb livres'
from sys.dba_free_space
group by tablespace_name
having (tablespace_name <> 'TEMP') and (tablespace_name not like 'ROLL%')
order by 1,2 desc;

select ' ' from sys.dual;

select 'Rollback',
       substr(R.segment_name,1,4), 
       'atingiu marca de',
       trunc(S.hwmsize/1024/1024) hwmsize,
       'Mb ',
       '(TbSpc ' || substr(R.tablespace_name,1,10) || ' tem', 
       trunc(sum(T.bytes)/1024/1024) rbsize,
       'Mb)'
from sys.dba_rollback_segs R,
     v$rollstat S,
     sys.dba_data_files T
where R.status = 'ONLINE' 
  and R.segment_id = S.usn
  and S.usn <> 0
  and R.tablespace_name = T.tablespace_name
group by R.segment_name, R.tablespace_name, S.hwmsize;

-- exit
