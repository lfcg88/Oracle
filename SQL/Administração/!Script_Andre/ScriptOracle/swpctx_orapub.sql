------------------------------------------------------------
-- file		swpctx.sql
-- desc		Session wait statitics CHANGE percentage reporting.
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		03-aug-00
-- lst upt	07-oct-01 
-- copyright	(c)2000,2001 OraPub, Inc.

-- It is possible to get percentages greater/lesser than 100% because there
-- is a time lag between the total calculations (which queries
-- from v$system_event) and the report query (which also queries from
-- v$system_event).
------------------------------------------------------------

set echo off
set feedback off
set heading off
set verify off

def old_tot_time_waited=&tot_time_waited noprint
def old_tot_total_waits=&tot_total_waits noprint

col val1 new_val tot_time_waited 
col val2 new_val tot_total_waits

select		sum(b.time_waited) val1,
		sum(b.total_waits) val2
from		v$system_event b
where		b.event not in ( select a.event
			         from   o$event_type a
			         where  a.type in ('bogus','idle')
		 	       )
/

set echo off
set feedback off
set heading on
set verify off

def osm_prog	= 'swpctx.sql'
def osm_title	= 'System Event CHANGE Activity By PERCENT'

start osmtitle

col event	format a35	heading "Wait Event" trunc
col tw	 	format 9990.000	heading "Time Waited|(sec)"
col time_pct 	format 990.00	heading "% Time|Waited"
col wc	 	format 9999990	heading "Waits"
col cnt_pct 	format 990.00	heading "% Waits"

select 	b.event,
	((b.time_waited-a.time_waited)/100) tw,
	100*((b.time_waited-a.time_waited)/(&tot_time_waited-&old_tot_time_waited+0.0001)) time_pct,
	(b.total_waits-a.total_waits) wc,
	100*((b.total_waits-a.total_waits)/(&tot_total_waits-&old_tot_total_waits+0.0001)) cnt_pct
from   v$system_event b,
       system_event_snap a
where  b.event = a.event
  and  b.event not in ( select x.event
		        from   o$event_type x
		        where  x.type in ('bogus','idle')
		      )
order by time_pct desc, cnt_pct desc, event asc
/

drop table system_event_snap;
create table system_event_snap as select * from v$system_event;

start osmclear

