/**********************************************************************
 * File:        sphistory.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        15-Jul-2003
 *
 * Description:
 *	SQL*Plus script to query the "history" of a specified SQL
 *	statement, using its "hash value", in one (or more) specified
 *	database instances.  This report is useful for obtaining an
 *	hourly perspective on SQL statements seen in more aggregated
 *	reports.
 *
 * Modifications:
 *********************************************************************/
set echo off
set feedback off timing off verify off linesize 100 pagesize 100
col snap_time format a12 truncate heading "Snapshot|Time"
col execs format 999,990 heading "Execs"
col lio_per_exec format 999,999,990.00 heading "Avg LIO|Per Exec"
col pio_per_exec format 999,999,990.00 heading "Avg PIO|Per Exec"
col cpu_per_exec format 999,999,990.00 heading "Avg|CPU (secs)|Per Exec"
col ela_per_exec format 999,999,990.00 heading "Avg|Elapsed (secs)|Per Exec"
col sql_text format a64 heading "Text of SQL statement"
clear breaks computes
ttitle off
btitle off

accept V_HASH_VALUE prompt "Enter the SQL statement hash value: "
accept V_ORACLE_SID prompt "Enter the SID of the Oracle instance (wildcard chars permitted): "

spool sphistory_&&V_HASH_VALUE

select	sql_text
from	stats$sqltext
where	hash_value = &&V_HASH_VALUE
order by text_subset, piece;

select	to_char(s.snap_time, 'DD-MON HH24:MI') snap_time,
	ss.executions_inc execs,
	ss.buffer_gets_inc/decode(ss.executions_inc,0,1,ss.executions_inc) lio_per_exec,
	ss.disk_reads_inc/decode(ss.executions_inc,0,1,ss.executions_inc) pio_per_exec,
	(ss.cpu_time_inc/1000000)/decode(ss.executions_inc,0,1,ss.executions_inc) cpu_per_exec,
	(ss.elapsed_time_inc/1000000)/decode(ss.executions_inc,0,1,ss.executions_inc) ela_per_exec
from 	stats$snapshot						s,
	(select	ss2.dbid,
		ss2.snap_id,
		ss2.instance_number,
		nvl(decode(greatest(ss2.executions, nvl(lag(ss2.executions) over (order by ss2.snap_id),0)),
			   ss2.executions, ss2.executions - lag(ss2.executions) over (order by ss2.snap_id),
				ss2.executions), 0) executions_inc,
		nvl(decode(greatest(ss2.buffer_gets, nvl(lag(ss2.buffer_gets) over (order by ss2.snap_id),0)),
			   ss2.buffer_gets, ss2.buffer_gets - lag(ss2.buffer_gets) over (order by ss2.snap_id),
				ss2.buffer_gets), 0) buffer_gets_inc,
		nvl(decode(greatest(ss2.disk_reads, nvl(lag(ss2.disk_reads) over (order by ss2.snap_id),0)),
			   ss2.disk_reads, ss2.disk_reads - lag(ss2.disk_reads) over (order by ss2.snap_id),
				ss2.disk_reads), 0) disk_reads_inc,
		nvl(decode(greatest(ss2.cpu_time, nvl(lag(ss2.cpu_time) over (order by ss2.snap_id),0)),
			   ss2.cpu_time, ss2.cpu_time - lag(ss2.cpu_time) over (order by ss2.snap_id),
				ss2.cpu_time), 0) cpu_time_inc,
		nvl(decode(greatest(ss2.elapsed_time, nvl(lag(ss2.elapsed_time) over (order by ss2.snap_id),0)),
			   ss2.elapsed_time, ss2.elapsed_time - lag(ss2.elapsed_time) over (order by ss2.snap_id),
				ss2.elapsed_time), 0) elapsed_time_inc
	 from	stats$sql_summary				ss2,
		(select distinct	dbid,
					instance_number
		 from	stats$database_instance
		 where	instance_name like '&&V_ORACLE_SID')	i
	 where	ss2.hash_value = &&V_HASH_VALUE
	 and	ss2.dbid = i.dbid
	 and	ss2.instance_number = i.instance_number)	ss
where	s.snap_id = ss.snap_id
and	s.dbid = ss.dbid
and	s.instance_number = ss.instance_number
order by s.snap_time asc;

spool off
set verify on echo on feedback on
