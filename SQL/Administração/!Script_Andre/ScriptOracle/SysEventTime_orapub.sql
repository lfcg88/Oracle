------------------------------------------------------------
-- file		swpct.sql
-- desc		Session wait statitics percentage reporting.
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		14-jul-00
-- lst upt	07-oct-01 
-- copyright	(c)2000,2001 OraPub, Inc.
------------------------------------------------------------

def filter=&1

set echo off
set feedback off
set heading off
set verify off

col val1 new_val tot_time_waited noprint
col val2 new_val tot_total_waits noprint

select		sum(time_waited) val1,
		sum(total_waits) val2
from		v$system_event a
where a.event not in (	select event
			from   o$event_type
			where  type in ('bogus','idle')
		      )

set echo off
set feedback off
set heading on
set verify off

def osm_prog	= 'swpct.sql'
def osm_title	= 'System Event Activity By PERCENT'

start osmtitle

col event	format a35	heading "Wait Event" trunc
col tw	 	format 99999990	heading "Time Waited|(min)"
col time_pct 	format 990.00	heading "% Time|Waited"
col wc	 	format 99999990	heading "Waits (k)"
col cnt_pct 	format 990.00	heading "% Waits"

select 	event,
	(time_waited/100)/60 tw,
	100*(time_waited/a.tot_time_waited) time_pct,
	total_waits/1000 wc,
	100*(total_waits/a.tot_total_waits) cnt_pct
from   v$system_event,
	(
	  select	sum(time_waited) tot_time_waited,
			sum(total_waits) tot_total_waits
	  from		v$system_event a
	  where a.event not in ( select event
				 from   o$event_type
				 where  type in ('bogus','idle')
		               )
	) a
where  event like '&filter%'
  and  event not in (	select event
			from   o$event_type
			where  type in ('bogus','idle')
		      )
order by time_pct desc
/

start osmclear

