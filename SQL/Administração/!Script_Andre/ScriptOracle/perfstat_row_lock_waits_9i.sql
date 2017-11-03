/**********************************************************************
 * File:        sp_row_lock_waits.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (SageLogix, Inc.)
 * Date:        15-Sep-03
 *
 * Description:
 *      SQL*Plus script to display two reports from the STATSPACK
 *      repository of segment wait information captured by the Oracle9i
 *      (and higher) versions of the product.
 *
 *      The first report displays the 10 segments (tables, indexes, etc)
 *      with the most "row lock waits" for each day.
 *
 *      The second report displays the 3 segments (tables, indexes, etc)
 *      with the most "row lock waits" for each hour of each day.
 *
 *      The report will prompt the user for the number of days of
 *      STATSPACK data to examine.     
 *
 * Modifications:
 *	TGorman	02may04	corrected bug in LAG() OVER clause
 *********************************************************************/
set echo off feedback off timing off pagesize 200 lines 130 trimout on trimspool on verify off
col sort0 noprint
col sort1 noprint
col day heading "Day"
col hr heading "Hour"
col object_type heading "Object|Type"
col owner format a15 heading "Owner"
col object_name format a30 heading "Object|Name"
col row_lock_waits format 999,999,999,990 heading "Row Lock|Waits"

accept V_NBR_DAYS prompt "How many days of data to examine? "

spool sp_row_lock_waits
clear breaks computes
break on day skip 1 on object_type on report
select	yyyymmdd sort0,
	daily_ranking sort1,
	day,
	object_type,
	owner,
	object_name,
	row_lock_waits
from	(select	to_char(ss.snap_time, 'YYYYMMDD') yyyymmdd,
		to_char(ss.snap_time, 'DD-MON') day,
		o.object_type,
		o.owner,
		o.object_name,
		sum(s.row_lock_waits) row_lock_waits,
		rank () over (partition by to_char(ss.snap_time, 'YYYYMMDD') order by sum(s.row_lock_waits) desc) daily_ranking
	 from	(select	dbid,
			instance_number,
			dataobj#,
			obj#,
			snap_id,
			nvl(decode(greatest(row_lock_waits,
					    nvl(lag(row_lock_waits) over (partition by dbid, instance_number, dataobj#, obj# order by snap_id),0)),
				   row_lock_waits,
				   row_lock_waits - lag(row_lock_waits) over (partition by dbid, instance_number, dataobj#, obj# order by snap_id),
					row_lock_waits), 0) row_lock_waits
		 from	stats$seg_stat)		s,
		stats$seg_stat_obj		o,
		stats$snapshot			ss
	 where	s.row_lock_waits > 0
	 and	o.dataobj# = s.dataobj#
	 and	o.obj# = s.obj#
	 and	o.dbid = s.dbid
	 and	ss.snap_id = s.snap_id
	 and	ss.dbid = s.dbid
	 and	ss.instance_number = s.instance_number
	 and	ss.snap_time between (sysdate - &&V_NBR_DAYS) and sysdate
	 group by to_char(ss.snap_time, 'YYYYMMDD'),
		  to_char(ss.snap_time, 'DD-MON'),
		  o.object_type,
		  o.owner,
		  o.object_name
	 order by yyyymmdd, row_lock_waits)
where	daily_ranking <= 10
order by sort0, sort1;

clear breaks computes
break on day on hr skip 1 on object_type on report
select	yyyymmddhh24 sort0,
	hourly_ranking sort1,
	day,
	hr,
	object_type,
	owner,
	object_name,
	row_lock_waits
from	(select	to_char(ss.snap_time, 'YYYYMMDDHH24') yyyymmddhh24,
		to_char(ss.snap_time, 'DD-MON') day,
		to_char(ss.snap_time, 'HH24')||':00' hr,
		o.object_type,
		o.owner,
		o.object_name,
		sum(s.row_lock_waits) row_lock_waits,
		rank () over (partition by to_char(ss.snap_time, 'YYYYMMDDHH24') order by sum(s.row_lock_waits) desc) hourly_ranking
	 from	(select	dbid,
			instance_number,
			dataobj#,
			obj#,
			snap_id,
			nvl(decode(greatest(row_lock_waits,
					    nvl(lag(row_lock_waits) over (partition by dbid, instance_number, dataobj#, obj# order by snap_id),0)),
				   row_lock_waits,
				   row_lock_waits - lag(row_lock_waits) over (partition by dbid, instance_number, dataobj#, obj# order by snap_id),
					row_lock_waits), 0) row_lock_waits
		 from	stats$seg_stat)		s,
		stats$seg_stat_obj		o,
		stats$snapshot			ss
	 where	s.row_lock_waits > 0
	 and	o.dataobj# = s.dataobj#
	 and	o.obj# = s.obj#
	 and	o.dbid = s.dbid
	 and	ss.snap_id = s.snap_id
	 and	ss.dbid = s.dbid
	 and	ss.instance_number = s.instance_number
	 and	ss.snap_time between (sysdate - &&V_NBR_DAYS) and sysdate
	 group by to_char(ss.snap_time, 'YYYYMMDDHH24'),
		  to_char(ss.snap_time, 'DD-MON'),
		  to_char(ss.snap_time, 'HH24')||':00',
		  o.object_type,
		  o.owner,
		  o.object_name
	 order by yyyymmddhh24, row_lock_waits)
where	hourly_ranking <= 3
order by sort0, sort1;
spool off
set verify on
