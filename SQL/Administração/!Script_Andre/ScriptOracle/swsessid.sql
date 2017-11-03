-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swsessid - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 25-SEP-98
-- * Description	: Show real session waits since connection.
-- * Usage		: start swsessid.sql <sid>
-- ********************************************************************

def sid=&1

col sid	   format    9999  heading "Sess|ID"
col event  format     a35  heading "Wait Event" trunc
col tws    format 9999999  heading "Total|Waits"
col tt     format   99999  heading "Total|Timouts"
col tw     format 9999.999  heading "Time (sec)|Waited"
col avgw   format    9999  heading "Avg (sec)|Wait"

set verify off

def osm_prog="swsessid.sql"
def osm_title="Session Wait Session Event For SID &sid"
start osmtitle

select sid,
       event,
       total_waits tws,
       total_timeouts tt,
       time_waited_micro/1000 tw,
       (time_waited_micro/total_waits)/1000 avgw
from   v$session_event
where  sid = &sid
order by time_waited_micro desc,event;

undef sid
start osmclear

