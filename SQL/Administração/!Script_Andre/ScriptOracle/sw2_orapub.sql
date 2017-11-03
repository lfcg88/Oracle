------------------------------------------------------------
-- file		sw2.sql
-- desc		Session wait statitics !! sorted by event !!
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		09-oct-98
-- lst upt	05-nov-98
-- copyright	(c)1998 OraPub, Inc.
------------------------------------------------------------

def input=&1

set feedback off head on
set echo off

col event    format a25       heading "Session Wait Event" trunc
col cnt      format 9999      heading "Ocurrs"
col p1       format 999999999999 heading "P1"
col p2       format 99999999 heading "P2"
col p3       format 99999 heading "P3"
col dte      format a8          heading "Date"
col key      format 9999         heading "OSM|Key"

select event,
       p1,
       p2,
       p3,
       a.key key,
       to_char(a.the_date,'DD HH24:MI') dte,
       count(ssid) cnt
from   o$session_wait a
where  a.client = '&client'
  and  a.key    >= &start_key
  and  a.key    <= &stop_key
  and  a.event  like '&input%'
group by  event, p1, p2, p3, key, the_date
order by event,dte,key
/


