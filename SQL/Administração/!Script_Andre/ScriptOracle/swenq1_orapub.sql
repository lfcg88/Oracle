------------------------------------------------------------
-- file		swenq1.sql
-- desc		Session wait enqueue decode stats !! sorted by date !!
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		09-oct-98
-- lst upt	09-oct-98
-- copyright	(c)1998 OraPub, Inc.
------------------------------------------------------------

col sid   format    9999 heading "Sid"
col enq   format      a4 heading "Enq."
col edes  format     a20 heading "Enqueue Name" trunc
col md    format     a10 heading "Lock Mode" trunc
col p2    format 9999999 heading "ID 1"
col p3    format 9999999 heading "ID 2"
col cnt   format     999 heading "Cnt"

col dte      format a12       heading "Date"
col key      format 9999      heading "OSM|Key"

select chr(bitand(p1,-16777216)/16777215)||
       chr(bitand(p1, 16711680)/65535) enq,
       decode(
         chr(bitand(p1,-16777216)/16777215)||chr(bitand(p1, 16711680)/65535),
                'TX','RBS Transaction',
                'TM','DML Transaction',
                'TS','Tablespace (temp seg)',
                'TT','Temporary Table',
                'ST','Space Mgt (e.g., uet$, fet$)',
                'UL','User Defined',
         chr(bitand(p1,-16777216)/16777215)||chr(bitand(p1, 16711680)/65535))
         edes,
       decode(bitand(p1,65535),1,'Null',2,'Sub-Share',3,'Sub-Exlusive',
         4,'Share',5,'Share/Sub-Exclusive',6,'Exclusive','Other') md,
       p2,
       p3,
       a.key key,
       to_char(a.the_date,'Mon DD HH24:MI') dte,
       count(ssid) cnt
from   o$session_wait a
where  event = 'enqueue'
  and  a.client = '&client'
  and  a.key    >= &start_key
  and  a.key    <= &stop_key
group by p1, p2, p3, key, the_date
order by dte,key,edes
/


