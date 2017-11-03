-- ********************************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename		: swsid 
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 07-oct-01
-- * Description	: Show real time session wait for a given sess.
-- * Usage		: start swsid.sql <sid>
-- ********************************************************************

set verify off

def sid=&1

col event  format     a30  heading "Wait Event" trunc
col siw    format   99999  heading "Waited|So|Far (secs)"
col wt     format   99999  heading "Time|Waited|(secs)"
col p1     format   99999  heading "P1"
col p2     format   99999  heading "P2"
col p3     format   99999  heading "P3" 
col state  format      a4  heading "Wait|State"

def osm_prog="swsid.sql"
def osm_title="Real Time Session Wait For SID=&sid"
start osmtitle

select event,
       seconds_in_wait siw,
       wait_time wt,
       decode(state,'WAITING','WG','WAITING UNKNOWN','W UN',
                    'WAITED KNOWN TIME','W KN','WAITED SHORT TIME','W SH',
                    'WAITED','WD','*') state,
       p1,
       p2,
       p3
from   v$session_wait
where  sid = &sid
order by event;


start osmclear


