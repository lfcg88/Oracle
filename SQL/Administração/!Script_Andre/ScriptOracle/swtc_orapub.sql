------------------------------------------------------------
-- file		swtc.sql
-- desc		System wait events TIME CHANGE report
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		26-jan-01
-- lst upt	21-may-01
-- copyright	(c)2001 OraPub, Inc.
------------------------------------------------------------

def event=&1

col eve     format a25 trunc heading "Event Name"
col rawx    format 999990    heading "Raw|Time Waited|(sec)"
col deltax  format 999990    heading "Delta|Time Waited|(sec)"
col accelx  format 999990    heading "Accel|Time Waited|(sec)"
col dte     format a12       heading "Date"
col key     format 9999      heading "OSM|Key"

select b.event eve,
       b.time_waited/100 rawx,
       (b.time_waited-a.time_waited)/100 deltax,
       ((b.time_waited-a.time_waited)-(a.time_waited-aa.time_waited))/100 accelx,
       b.key key,
       to_char(b.the_date,'Mon DD HH24:MI') dte
from   o$system_event aa,
       o$system_event a,
       o$system_event b
where  b.client = a.client
  and  b.client = aa.client
  and  b.client = '&client'
  and  b.event  like '&event%'
  and  b.event  = a.event
  and  b.event  = aa.event
  and  b.key    = a.key+1
  and  b.key    = aa.key+2
  and  b.key   >= &start_key
  and  b.key   <= &stop_key
order by dte,key,eve
/


