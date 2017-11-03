------------------------------------------------------------
-- file		swpct.sql
-- desc		Session wait statitics !! sorted by date !!
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		14-jul-00
-- lst upt	21-may-01
-- copyright	(c)2000,2001 OraPub, Inc.
------------------------------------------------------------

set feedback off head on
set echo off

def filter=&1

create or replace view o$swpct as
select  a.client,
        a.key start_key,
        b.key end_key,
        sum(b.time_waited-a.time_waited) span_time_waited,
        sum(b.total_waits-a.total_waits) span_total_waits
from    o$system_event a,
        o$system_event b
where  a.client = '&client'
  and  a.client = b.client
  and  a.key    = b.key-1
  and  a.key    >= &start_key
  and  a.key    <= &stop_key
  and  a.event  = b.event
  and  a.event  like '&filter%'
  and  a.event not like 'SQL%' 
  and  a.event not like 'KXFX%' 
  and  a.event not like 'slave wait'
  and  a.event not like 'Wait for slaves%'
  and  a.event not like 'Parallel%Qu%Idle%Sla%' 
  and  a.event not like 'refresh controfile%'
  and  a.event not in ( 
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'Null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client')
group by a.client,a.key, b.key
/


col event       format a25      heading "Wait Event" trunc
col tw          format 999990 heading "Time Waited|(sec)"
col time_pct    format 990.00   heading "% Time|Waited"
col wc          format 999990 heading "Waits (k)"
col cnt_pct     format 990.00   heading "% Waits"
col dte		 format a8		heading "Date"
col key		 format 9999		heading "OSM|Key"

select 	a.event,
	(b.time_waited-a.time_waited)/100 tw,
	100*(b.time_waited-a.time_waited)/c.span_time_waited time_pct,
	(b.total_waits-a.total_waits)/1000 wc,
	100*(b.total_waits-a.total_waits)/c.span_total_waits cnt_pct,
	b.key 					key,
	to_char(b.the_date,'DD HH24:MI') 	dte
from	o$system_event a,
	o$system_event b,
	o$swpct c
where  a.client = '&client'
  and  a.client = b.client
  and  b.client = c.client
  and  a.event  = b.event
  and  a.key    = b.key-1
  and  a.key    = c.start_key
  and  a.key    >= &start_key
  and  a.key    <= &stop_key
  and  (b.time_waited-a.time_waited) > 0
  and  a.event  like '&filter%'
  and  a.event not like 'SQL%' 
  and  a.event not like 'KXFX%' 
  and  a.event not like 'slave wait'
  and  a.event not like 'Wait for slaves%'
  and  a.event not like 'Parallel%Qu%Idle%Sla%' 
  and  a.event not like 'refresh controfile%'
  and  a.event not in ( 
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'Null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client')
order by a.the_date,a.key,2 desc
/


