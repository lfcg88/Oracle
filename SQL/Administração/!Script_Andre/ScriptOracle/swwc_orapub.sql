------------------------------------------------------------
-- file		swwc.sql
-- desc		System wait events TOTAL WAIT CHANGE report
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		26-jan-01
-- lst upt	21-may-01
-- copyright	(c)2001 OraPub, Inc.
------------------------------------------------------------

def event=&1

col eve     format a25 trunc heading "Event Name"
col rawx    format 999990    heading "Raw|Waits|(sec)"
col deltax  format 999990    heading "Delta|Waits|(sec)"
col accelx  format 999990    heading "Accel|Waits|(sec)"
col dte     format a12       heading "Date"
col key     format 9999      heading "OSM|Key"

select b.event eve,
       b.total_waits/100 rawx,
       (b.total_waits-a.total_waits)/100 deltax,
       ((b.total_waits-a.total_waits)-(a.total_waits-aa.total_waits))/100 accelx,
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


