REM
REM DBAToolZ NOTE:
REM	This script was obtained from DBAToolZ.com
REM	It's configured to work with SQL Directory (SQLDIR).
REM	SQLDIR is a utility that allows easy organization and
REM	execution of SQL*Plus scripts using user-friendly menu.
REM	Visit DBAToolZ.com for more details and free SQL scripts.
REM
REM 
REM File:
REM 	s_db_checkit.sql
REM
REM <SQLDIR_GRP>MAINT TRACE</SQLDIR_GRP>
REM 
REM Author:
REM 	Oracle Corporation 
REM 
REM Purpose:
REM	<SQLDIR_TXT>
REM	This script is for the experienced dba.
REM	It gets and computes information from the DB.
REM	NOTES:
REM	-----
REM	  Must be run in SQLplus as system.
REM	  Timed_statistics must be enabled.
REM	</SQLDIR_TXT>
REM	
REM Usage:
REM	s_db_checkit.sql
REM 
REM Example:
REM	s_db_checkit.sql
REM
REM
REM History:
REM	08-01-2001	VMOGILEV	Added to DBATOOLZ library
REM
REM

rem
rem $Header: checkit.sql 99/03/XX 17:12:31 
rem
Rem  Copyright (c) 1999 by Oracle Corporation
Rem    NAME
Rem      checkit.sql - Shows database statistics.
Rem    DESCRIPTION
Rem      This script is for the experienced dba.
Rem      It gets and computes information from the DB.
Rem    RETURNS
Rem
Rem    NOTES
Rem      Must be run in SQLplus as system.
Rem      Timed_statistics must be enabled.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     ldohn      xx/02/99 - Initial collection and formatting
Rem     ldohn      22/03/99 - Added %load on file I/O stats
Rem     ldohn      06/05/99 - Removed parallel query dequeue wait pipe get and put from waitinterface
Rem     ldohn      08/06/99 - Removed slave wait / io done
Rem     jthomsen   10/12/99 - Bug: decoded fetch to :total
Rem     jmayer.cz  15/10/1999 - running time calculation changed,
Rem                             "to_date" used without format strings
Rem     jmayer.cz  15/10/1999 - updated for Oracle8
Rem     ldohn.dk   09/12/1999 - Removed dispatcher timer
Rem                             virtual circuit status
Rem                             lock manager wait for remote message
Rem     ldohn.dk   09/12/1999 - Coded to run on 7 and 8
Rem     ldohn.dk   13/12/1999 - Changed reponse to seconds for instance
Rem                             level performance and response time info
Rem     ldohn.dk   13/12/1999 - Added parse_calls info from v$sql

VARIABLE total_disk_reads  NUMBER;
VARIABLE total_buffer_gets NUMBER;
VARIABLE total_parse_calls NUMBER;
VARIABLE service_time      NUMBER;
VARIABLE wait_time         NUMBER;
VARIABLE total             NUMBER;
VARIABLE total_phyrds      NUMBER;
VARIABLE total_phywrts     NUMBER;
VARIABLE vers              VARCHAR2(80);
VARIABLE sqlstat           VARCHAR2(600);

set pagesize 24
set feedback off
set serveroutput off
set heading off

declare

cursor gettotal_disk_reads is select sum(disk_reads) from v$sql;
cursor gettotal_buffer_gets is select sum(buffer_gets) from v$sql;
cursor gettotal_parse_calls is select sum(parse_calls) from v$sql;

cursor getwait_time is select sum(time_waited) from v$system_event
where event not in ('SQL*Net message from client','SQL*Net message to client',
'rdbms ipc message','smon timer','pmon timer','Null event',
'parallel query dequeue wait','pipe get','pipe put','slave wait','io done',
'dispatcher timer','virtual circuit status','lock manager wait for remote message');

cursor getservice_time is select a.value from v$sysstat a
where a.name = 'CPU used by this session';

cursor gettotal is select decode (sum(time_waited), 0, 1, sum(time_waited)) 
from v$system_event
where event not in ('SQL*Net message from client','SQL*Net message to client',
'rdbms ipc message','smon timer','pmon timer','Null event',
'parallel query dequeue wait','pipe get','pipe put','slave wait','io done',
'dispatcher timer','virtual circuit status','lock manager wait for remote message');

cursor gettotal_phyrds is select sum(phyrds) from v$filestat;
cursor gettotal_phywrts is select sum(phywrts) from v$filestat;

begin
  open gettotal_disk_reads;
  open gettotal_buffer_gets;
  open gettotal_parse_calls;
  fetch gettotal_disk_reads into :total_disk_reads;
  fetch gettotal_buffer_gets into :total_buffer_gets;
  fetch gettotal_parse_calls into :total_parse_calls;
  close gettotal_disk_reads;
  close gettotal_buffer_gets;
  close gettotal_parse_calls;
  open gettotal;
  open getwait_time;
  open getservice_time;
  fetch gettotal into :total;
  fetch getwait_time into :wait_time;
  fetch getservice_time into :service_time;
  close gettotal;
  close getwait_time;
  close getservice_time;
  open gettotal_phyrds;
  open gettotal_phywrts;
  fetch gettotal_phyrds into :total_phyrds;
  fetch gettotal_phywrts into :total_phywrts;
  close gettotal_phyrds;
  close gettotal_phywrts;
end;
/
declare
 n1 number;
begin
 select count(*) into n1 from v$version
  where banner like 'Oracle7%';
 if n1>0 then
   select name ||' has been running for ' ||
   trunc(sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS')) || ' days, ' || 
   trunc(24*((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS')) - 
   trunc((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS'))))) || ' hours and ' ||
   trunc(60*((24*((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS')) -
   trunc((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS'))))) -
   (trunc(24*((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS')) -
   trunc((sysdate-to_date(open_time,'MM/DD/YY HH24:MI:SS')))))))) || ' minutes' " "
   into :vers
   from v$thread,v$database;
 else
   select name ||' has been running for ' ||
   trunc(sysdate-open_time) || ' days, ' ||
   trunc(24*((sysdate-open_time)
      - trunc(sysdate-open_time))) || ' hours and ' ||
   trunc(60*((24*((sysdate-open_time) 
         - trunc(sysdate-open_time)))
      - trunc(24*((sysdate-open_time) 
         - trunc(sysdate-open_time))))) || ' minutes' " "
   into :vers
   from v$thread,v$database;
 end if;
end;
/

declare
 n1 number;
begin
 select count(*) into n1 from v$version
  where banner like 'Oracle7%';
 if n1>0 then
  :sqlstat := 'select substr(n.name,1,20) "rollname", ' ||
  'round(24*(sysdate-to_date(i1.value||'' ''||i2.value,''j SSSSS'')) ' ||
  '/(s.writes/s.rssize),1) "rolltime" ' ||
  'from v$instance i1, v$instance i2, v$rollname n, v$rollstat s ' ||
  'where i1.key = ''STARTUP TIME - JULIAN'' '||
  'and i2.key = ''STARTUP TIME - SECONDS'' '||
  'and n.usn = s.usn and s.status = ''ONLINE'' ';
 else
  :sqlstat := 'select substr(n.name,1,20) rollname,' ||
      'round(24*(sysdate-i.startup_time)/(s.writes/s.rssize),1) rolltime '||
      'from v$instance i, v$rollname n, v$rollstat s '||
      'where i.instance_number = 1 '||
      'and n.usn = s.usn and s.status = ''ONLINE''';
  end if;
end;
/
set lines 100
spool checkit
select 'Statistics gathered from ' || dn.name || ' the ' || sysdate " "
from v$database dn;
print vers 
set heading on

set serveroutput on size 40000
declare
 n1 number;
begin
  select count(*) into n1 from v$parameter 
  where upper(name) = 'TIMED_STATISTICS' and value = 'TRUE' ;
 if n1=0 then
 dbms_output.put_line('*************************************************************************');
 dbms_output.put_line('Timed Statistics is FALSE !!!');
 dbms_output.put_line('Timed Statistics must be true to get valid information !!!');
 dbms_output.put_line('*************************************************************************');
 end if;
end;
/
set serveroutput off
prompt *************************************************************************
prompt
prompt                   Rollback wrap time
prompt
prompt Rollback segment     Turn around Hours
prompt -------------------- ------------------

set serveroutput on size 40000
declare
  rollname varchar2(32);
  rolltime varchar2(32);
  cursor_handle     INTEGER;
  rows_processed    INTEGER;
begin
  cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(cursor_handle,:sqlstat,dbms_sql.v7);
  rows_processed := dbms_sql.execute(cursor_handle);
  dbms_sql.define_column(cursor_handle,1,rollname,32);
  dbms_sql.define_column(cursor_handle,2,rolltime,32);

  rows_processed := dbms_sql.fetch_rows(cursor_handle);
  while rows_processed = 1 loop
     dbms_sql.column_value (cursor_handle, 1, rollname);
     dbms_sql.column_value (cursor_handle, 2, rolltime);
     dbms_output.put_line(rpad(rollname,21,' ')|| lpad(rolltime,17,' '));
     rows_processed := dbms_sql.fetch_rows(cursor_handle);
  end loop;
end;
/
set serveroutput off
prompt
prompt Should be > 24 hours. If not: Increase size of RBS
prompt *************************************************************************
set feedback on
prompt
prompt Buffer Contention statistic information
select round(100*s1.count/(s2.value+s3.value)) "% Contension"
from v$waitstat s1, v$sysstat s2, v$sysstat s3 
where s1.class = 'buffer busy waits' and s2.name = 'consistent gets'
and s3.name = 'db block gets' and s2.value + s3.value > 1000;
prompt % Contention should be < 5
prompt Buffer Contention : If no rows then perfect
prompt *************************************************************************
prompt
set feedback off
prompt V$LIBRARYCACHE statistic information
select sum(pins) "Total pins", sum(reloads) "Total reloads",round(sum(reloads)/(sum(pins)/100),2) "% Reloads" from v$librarycache;
prompt
prompt % Reloads must be < 1 % else increase shared_pool_size
prompt *                            Consider increasing OPEN_CURSORS
prompt *                            Write identical SQL statements
prompt *                            Consider setting CURSOR_SPACE_FOR_TIME
prompt *************************************************************************
prompt
prompt V$ROWCACHE statistic information
select sum(gets) "Total gets", sum(getmisses) "Total misses",round(sum(getmisses)/(sum(gets)/100),2) "% Misses"
from v$rowcache;
prompt
prompt % Misses must be < 5 % else increase shared_pool_size
prompt *************************************************************************
prompt
set feedback on
prompt Redo log space requests
select round(100*s1.value/s2.value) "% Redo log space requests"
from v$sysstat s1, v$sysstat s2
where s1.name = 'redo log space requests'
      and s2.name = 'redo entries' and s2.value > 1000;
prompt
prompt *   Should be < 5% If not: Check that DBWR has completed checkpointing.
prompt *                          Check that ARCH can archive in time.
prompt *                          Increase LOG_BUFFER.
prompt *************************************************************************
prompt
prompt Redo buffer allocation retries
select round(100*s1.value/s2.value) "%Redo buffer alloc retries"
from v$sysstat s1, v$sysstat s2
where s1.name = 'redo buffer allocation retries'
      and s2.name = 'redo entries'
      and s2.value > 1000;
prompt
prompt *   Should be < 5% If not: Check that DBWR has completed checkpointing.
prompt *                          Check that ARCH can archive in time.
prompt *                          Increase LOG_BUFFER.
prompt *************************************************************************
prompt
prompt Chained Rows 
select substr(owner || '.' || table_name,1,40) "Table",chain_cnt from sys.dba_tables where chain_cnt > 0 order by chain_cnt,owner,table_name;
REM select substr(owner_name || '.' || table_name,1,20) "Table" ,count(*) "Antal" from chained_rows group by owner_name,table_name;
prompt
prompt Chained rows increases I/O operations
prompt *************************************************************************
prompt
prompt Next extent to large in tablespace
select tablespace_name TABLESPACE,  
       table_name      TABLE_NAME, 
       next_extent     NEXT  
from   user_tables     OUTER  
where not exists (select 'X' from sys.dba_free_space INNER  
where  OUTER.tablespace_name = INNER.tablespace_name and bytes >= next_extent); 
prompt *************************************************************************
set feedback off
prompt
prompt Oracle file I/O statistic information per file basis
column "NAME" format a35
column "% Load" format a7
select substr(name,1,35) "NAME", 
phyrds, to_char(phyrds/(:total_phyrds/100),'999.99') "% Load",
phywrts, to_char(phywrts/((:total_phywrts+1)/100),'999.99') "% Load"
from v$datafile df, v$filestat
fs where df.file# = fs.file#;
prompt
prompt File I/O should be equally distributed on each datafile
prompt *************************************************************************
prompt
prompt Oracle file I/O cost information per file basis
column "NAME" format a35
column "Readtime" format a10
column "Writetime" format a10
column "Read cost ms" format a12
column "Write cost ms" format a13
select substr(name,1,35) "Name",
readtim "   Readtime",
writetim " Writetime",
to_char((readtim/(phyblkrd+1))*10,'99999999.99') "Read cost ms",
to_char((writetim/(phyblkwrt+1))*10,'999999999.99') "Write cost ms"
from v$datafile df, v$filestat fs
where df.file# = fs.file#;
prompt
prompt Reads should be under 20 ms, writes under 100 ms depending on HW.....
prompt *************************************************************************
prompt
prompt Rollback Segment Contention 
select sum(waits)/sum(gets)*100 "% Wait to get" from v$rollstat,v$rollname where v$rollstat.usn = v$rollname.usn;
prompt
prompt % Wait to get must be < 1 % else add rollback segments
prompt *************************************************************************
prompt
prompt Memory/disk sorts
select substr(name,1,16) "Sort type" ,value from v$sysstat where name in ('sorts (memory)', 'sorts (disk)');
prompt
prompt Sorts on disk are very I/O intensive. 
prompt If problem then increase sort_area_size, but beware of mem swapping
prompt *************************************************************************
prompt
prompt DBWR
select substr(name,1,25) "Dirty Buffers", value from v$sysstat where name = 'dirty buffers inspected';
prompt
prompt Must be close to 0, if not DBWR cannot keep up with foreground
prompt Add db_writers to system
prompt *************************************************************************
prompt
prompt Information from v$sql / disk reads (impact > 3%)
column "SQL text" format a40
column "Execs" format a8
column "Rows proc" format a9
column "   Disk rds" format a11
column "% impact" format a8
set lines 140
select substr(sql_text,1,40) "SQL text",
to_char(executions,'9999999') "   Execs",
to_char(rows_processed,'99999999') "Rows proc",
to_char(disk_reads,'9999999999') "   Disk rds",
to_char(disk_reads/(:total_disk_reads/100),'9999.99') "% impact"
from v$sql where disk_reads > :total_disk_reads/33
order by disk_reads;
prompt
prompt Warning, if DB has been running for a long time,
prompt the above may be extreme misleading...
prompt *************************************************************************
prompt Information from v$sql / buffer gets (impact > 3%)
column "SQL text" format a40
column "Execs" format a8
column "Rows proc" format a9
column "Buffer gets" format a11
column "% impact" format a8
select substr(sql_text,1,40) "SQL text",
to_char(executions,'99999999') "Execs",
to_char(rows_processed,'9999999999') "Rows proc",
to_char(buffer_gets,'99999999999') "Buffer gets",
to_char(buffer_gets/(:total_buffer_gets/100),'9999.99') "% impact"
from v$sql where buffer_gets > :total_buffer_gets/33
order by buffer_gets;
prompt
prompt Warning, if DB has been running for a long time,
prompt the above may be extreme misleading...
prompt *************************************************************************
prompt
prompt Information from v$sql / Parse calls (impact > 3%)
column "SQL text" format a40
column "Execs" format a8
column "Rows proc" format a9
column "Parse calls" format a11
column "% impact" format a8
select substr(sql_text,1,40) "SQL text",
to_char(executions,'9999999') "Execs",
to_char(rows_processed,'9999999999') "Rows proc",
to_char(parse_calls,'99999999999') "Parse calls",
to_char(parse_calls/(:total_parse_calls/100),'9999.99') "% impact"
from v$sql where parse_calls > :total_parse_calls/33
order by parse_calls;
prompt
prompt Warning, if DB has been running for a long time,
prompt the above may be extreme misleading...
prompt *************************************************************************
prompt
column "Event" format a30
column "A wait ms" format a10
column "% impact" format a8
column "T waited" format 9999999999
prompt Information from the Wait Interface 

select substr(event,1,30) "Event",
time_waited "T waited",
to_char(average_wait*10,'999999.99') "A wait ms",
to_char(time_waited/(:total/100),'9999.99') "% impact"
from v$system_event
where event not in ( 'SQL*Net message from client','SQL*Net message to client',
'rdbms ipc message', 'smon timer','pmon timer','Null event',
'parallel query dequeue wait','pipe get','pipe put','slave wait','io done',
'dispatcher timer','virtual circuit status','lock manager wait for remote message')
order by time_waited;
prompt
prompt General information from the wait interface.
prompt For reference use "Description of Oracle7 Wait Events by Anjo Kolk"
prompt *************************************************************************
prompt
prompt Response time information (in seconds)
column "Response Time" format a13
column "      Service Time" format a18
column "       Wait Time" format a16
column "=" format a1
column '+' format a1
select to_char((:service_time + :wait_time)/100,'999999999999') "Response Time"
, '=' "=",
substr(to_char((:service_time)/100,'99999999999') || ' (' ||
round((:service_time/(:service_time + :wait_time))*100) || '%)',
1,18) "      Service Time", '+' "+",
substr(to_char((:wait_time)/100,'999999999') || ' (' ||
round((:wait_time/(:service_time + :wait_time))*100) || '%)',
1,16) "       Wait Time"
from dual;
prompt
prompt Ideal scenery is Wait Time < Service Time 
prompt *************************************************************************
prompt
prompt Instance level performance (in seconds)
select a.value/100 "Total CPU", b.value/100 "Parse CPU", 
c.value/100 "Recursive CPU",
(a.value - b.value - c.value)/100 "Other"
from v$sysstat a, v$sysstat b, v$sysstat c
where a.name = 'CPU used by this session'
and   b.name = 'parse time cpu'
and   c.name = 'recursive cpu usage';
prompt
prompt *************************************************************************
prompt
prompt Indexes with critical blevel
column "Index" format a50
select substr(owner||'.'||index_name,1,50) "Index", blevel "Blevel", leaf_blocks "Leaf blocks"
from sys.dba_indexes
where blevel > 1
order by owner, index_name;
prompt
prompt If no rows, perfect.
prompt blevel = 2 : Consider to reorg index
prompt blevel = 3 : Reorg index
prompt blevel > 3 : Reorg index asap
prompt *************************************************************************
prompt
prompt Invalid objects
column "Object" format a40 
select substr(owner||'.'||object_name,1,40) "Object",
object_type "Type", status "Status"
from sys.dba_objects
where status = 'INVALID'
order by owner,object_name;
prompt
prompt If no rows, perfect.
prompt else recompile invalid objects.
prompt *************************************************************************
spool off
