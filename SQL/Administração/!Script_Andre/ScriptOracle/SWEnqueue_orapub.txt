-- ********************************************************************
-- * Copyright Notice   : (c)2001 OraPub, Inc.
-- * Filename		: swenq.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 20-nov-01
-- * Last Update	: 10-jul-00
-- * Description	: Show SW enqueue detail.
-- * Usage		: start swenqx p1 p2.sql
-- ********************************************************************

def osm_prog	= 'swenqx.sql'
def osm_title	= 'Session Wait Enqueue Detail'

def p1=&1
def p2=&2

start osmtitle

col sid   format    9999 heading "Sid"
col enq   format      a4 heading "Enq."
col edes  format     a30 heading "Enqueue Name"
col md    format     a10 heading "Lock Mode" trunc
col p2    format 9999999 heading "ID 1"
col p3    format 9999999 heading "ID 2"

select 
       chr(bitand(&p1,-16777216)/16777215)||
       chr(bitand(&p1, 16711680)/65535) enq,
       decode(
         chr(bitand(&p1,-16777216)/16777215)||chr(bitand(&p1, 16711680)/65535),
                'TX','Transaction (RBS)',
                'TM','DML Transaction',
                'TS','Tablespace and Temp Seg',
                'TT','Temporary Table',
                'ST','Space Mgt (e.g., uet$, fet$)',
                'UL','User Defined',
         chr(bitand(&p1,-16777216)/16777215)||chr(bitand(&p1, 16711680)/65535))
         edes,
       decode(bitand(&p1,65535),1,'Null',2,'Sub-Share',3,'Sub-Exlusive',
         4,'Share',5,'Share/Sub-Exclusive',6,'Exclusive','Other') md,
       &p2
from   dual
/

start osmclear

