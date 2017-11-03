rem =========================================================================
rem 
rem                     perfio.sql
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
rem # Physical I/O by filesystem and file
rem
rem ==========================================================================
rem
clear breaks
column "FILESYSTEM" format A20 print
select substr(d.name, 1, instr(d.name, '/', 2) - 1) "FILESYSTEM",
       sum(s.phyblkrd) phyblkrd, sum(s.phyblkwrt) phyblkwrt
from v$datafile d,
     v$filestat s
where s.file# = d.file#
group by substr(d.name, 1, instr(d.name, '/', 2) - 1)
/       
column file format A50
column "FILESYSTEM" noprint
column "%" format 90
clear breaks
break on "FILESYSTEM" skip 1
select substr(d.name, 1, instr(d.name, '/', 2) - 1) "FILESYSTEM",
       d.name "FILE",
       s.phyblkrd,
       round(100 * s.phyblkrd / t.tot_blkrd) "%",
       s.phyblkwrt,
       round(100 * s.phyblkwrt / t.tot_blkwrt) "%"
from v$datafile d,
     v$filestat s,
     (select sum(phyblkrd) tot_blkrd,
             sum(phyblkwrt) tot_blkwrt
      from sys.v_$filestat) t
where s.file# = d.file#
order by substr(d.name, 1, instr(d.name, '/', 2) - 1)
/       

