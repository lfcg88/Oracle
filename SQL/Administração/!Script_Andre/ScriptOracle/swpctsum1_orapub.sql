------------------------------------------------------------
-- file         swpctsum1.sql
-- desc         System wait events !! Summary !! w/percent details.
-- author       Craig A. Shallahamer (craig@orapub.com)
--              Special thanks to Andy Rivenes (arivenes@llnl.gov)
--		for the original idea and initial script!!!
-- orig         08-dec-00
-- lst upt      21-may-01
-- copyright    (c)1998,1999,2000,2001 OraPub, Inc.
------------------------------------------------------------

--- Must create the view for the PCT details first.
set feedback off head on
set echo off

create or replace view o$swpct as
select  sum(b.time_waited-a.time_waited) span_time_waited,
        sum(b.total_waits-a.total_waits) span_total_waits
from    o$system_event a,
        o$system_event b
where  a.client = '&client'
  and  a.client = b.client
  and  a.key    = &start_key
  and  b.key    = &stop_key
  and  a.event  = b.event
  and  a.event  like '&stat%'
  and  a.event NOT IN   ('client message',
                       'dispatcher timer',
                       'KXFX: execution message dequeue - Slaves',
                       'KXFX: Reply Message Dequeue - Query Coord',
                       'Null event',
                       'parallel query dequeue wait',
                       'parallel query idle wait - Slaves',
                       'pipe get',
                       'pipe put',
                       'PL/SQL lock timer',
                       'pmon timer',
                       'rdbms ipc reply',
                       'rdbms ipc message',
                       'slave wait',
                       'smon timer',
                       'SQL*Net message from client',
                       'SQL*Net message to client',
                       'SQL*Net message from dblink',
                       'SQL*Net message to dblink',
                       'io done',
                       'lock manager wait for remote message',          
                       'lock manager wait for remote message',
                       'virtual circuit status',
                       'WMON goes to sleep')
     AND a.event NOT LIKE 'PX%'                 
/

-- The main report...

col eve     format a30 trunc heading "Event Name"
col twaits  format 9999990    heading "Tot|Waits"
col cnt_pct     format 990.00   heading "% Waits"
col twaited format 99999990    heading "Time|Waited(sec)"
col time_pct    format 990.00   heading "% Time|Waited"
col ttouts  format 999990    heading "Tot|TOuts"

select a.event eve,
       (b.time_waited-a.time_waited)/100 twaited,
       100*(b.time_waited-a.time_waited)/(c.span_time_waited) time_pct,
       (b.total_waits-a.total_waits) twaits,
       100*(b.total_waits-a.total_waits)/(c.span_total_waits) cnt_pct,
       (b.total_timeouts-a.total_timeouts) ttouts
from   o$system_event a,
       o$system_event b,
       o$swpct c
where  a.client = b.client
  and  a.client = '&client'
  and  a.event  like '&stat%'
  and  a.event  = b.event
  and  a.key    = &start_key
  and  b.key    = &stop_key
  and  a.event NOT IN   ('client message',
                       'dispatcher timer',
                       'KXFX: execution message dequeue - Slaves',
                       'KXFX: Reply Message Dequeue - Query Coord',
                       'Null event',
                       'parallel query dequeue wait',
                       'parallel query idle wait - Slaves',
                       'pipe get',
                       'pipe put',
                       'PL/SQL lock timer',
                       'pmon timer',
                       'rdbms ipc reply',
                       'rdbms ipc message',
                       'slave wait',
                       'smon timer',
                       'SQL*Net message from client',
                       'SQL*Net message to client',
                       'SQL*Net message from dblink',
                       'SQL*Net message to dblink',
                       'io done',
                       'lock manager wait for remote message',
                       'virtual circuit status',
                       'WMON goes to sleep')
     AND a.event NOT LIKE 'PX%'
order by twaited desc
/


