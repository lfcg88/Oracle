rem =========================================================================
rem 
rem                     monlocks.sql
rem 
rem     Copyright (C) Oriole Software, 1998
rem 
rem     This program is free software; you can redistribute it and/or modify
rem     it under the terms of the GNU General Public License as published by
rem     the Free Software Foundation; either version 2 of the License, or
rem     any later version.
rem 
rem     This program is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with this program; if not, write to the Free Software
rem     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
rem 
rem =========================================================================
rem
rem # Current DML locks (* indicates the user holds the lock)
rem
column username format A15
column "TABLE" format A12
column "MODE" format A5
column sql_text format A40 word_wrapped
column dummy noprint
break on name skip 1 on username on sql_text
select o.name "TABLE",
       s.username,
       l.type,
       l.id1 dummy,
       l.id2 dummy,
       decode(l.lmode, 0, '',
                       1, '*NULL',
                       2, '*RS',
                       3, '*RX',
                       4, '*S',
                       5, '*SRX',
                       6, '*X',
                       '*' || to_char(l.lmode)) ||
       decode(l.request, 0, '',
                         1, ' NULL',
                         2, ' RS',
                         3, ' RX',
                         4, ' S',
                         5, ' SRX',
                         6, ' X',
                         ' ' || to_char(l.request)) "MODE",
       a.sql_text   
from v$session s,
     v$sqlarea a,
     sys.obj$ o,
     v$lock l
where l.sid = s.sid
  and l.id1 = o.obj# (+)
  and s.sql_address = a.address
  and s.sql_hash_value = a.hash_value
  and s.username is not null
order by 4, 5, 2
/

