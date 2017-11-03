------------------------------------------------------------
-- file		swc1.sql
-- desc		Session wait statitics w/COUNTS !! sorted by date !!
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		19-nov-98
-- lst upt	19-nov-98
-- copyright	(c)1998 OraPub, Inc.
------------------------------------------------------------

def input=&1

set feedback off head on
set echo off

col event    format a40       heading "Session Wait Event" trunc
col cnt      format 9999      heading "Ocurrs"
col sec      format 999,999,990      heading "Secs In|Wait (sec)"
col dte      format a8          heading "Date"
col key      format 9999         heading "OSM|Key"

select event,
       a.key key,
       to_char(a.the_date,'DD HH24:MI') dte,
       sum(seconds_in_wait) sec,
       count(ssid) cnt
from   o$session_wait a
where  a.client = '&client'
  and  a.key    >= &start_key
  and  a.key    <= &stop_key
  and  a.event  like '&input%'
  and  a.state  = 'WAITING'
group by  event, key, the_date
order by dte,key,cnt desc, sec desc,event
/


