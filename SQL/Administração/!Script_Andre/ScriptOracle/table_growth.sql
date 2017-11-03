rem =========================================================================
rem 
rem                     table_growth.sql
rem 
rem     Copyright (C) Oriole Software, 2000
rem 
rem     Downloaded from www.oriolecorp.com
rem 
rem     This script for Oracle database administration is free software; you
rem     can redistribute it and/or modify it under the terms of the GNU General
rem     Public License as published by the Free Software Foundation; either
rem     version 2 of the License, or any later version.
rem 
rem     This script is distributed in the hope that it will be useful,
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
rem        Usage : @table_growth [schema.]tablename
rem         
column "DATE" format A10
column histo heading '' format A35
column NOW new_value TODAY noprint
set scan on
set verify off
set feedback off
set recsep off
set pause off
--
select to_char(sysdate, 'DD Month YYYY') NOW
from dual
/
ttitle LEFT ' &1 growth report' CENTER TODAY RIGHT SQL.PNO skip 2
btitle 'Copyright (c) Oriole Corporation, 2000'
--
select to_char(h.timestamp, 'MM/DD/YYYY') "DATE",
       h.table_rows "ROWS",
       h.table_blks_allocated + h.index_blks_allocated allocated,
       h.table_blks_used + h.index_blks_used used,
       rpad('x', ceil(35 * (h.table_blks_used + h.index_blks_used)
                                      / m.alloc), 'x') ||
       rpad('=', floor(35 * (h.table_blks_allocated
            + h.index_blks_allocated - h.table_blks_used - h.index_blks_used)
                    / m.alloc), '=') histo
from dba_growth_history h,
     (select owner,
             table_name,
             max(table_blks_allocated + index_blks_allocated) alloc
      from dba_growth_history
      group by owner, table_name) m
where m.owner = h.owner
  and m.table_name = h.table_name
  and h.owner = decode(instr('&1', '.'), 0, h.owner,
                     upper(substr('&1', 1, instr('&&1', '.') - 1)))
  and h.table_name = upper(substr('&1', 1 + instr('&&1', '.')))
order by h.timestamp
/
ttitle off
btitle off
