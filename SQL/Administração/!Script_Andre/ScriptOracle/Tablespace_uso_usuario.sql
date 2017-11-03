/**********************************************************************
 * File:	spc.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (SageLogix, Inc.)
 * Date:	10-Oct-97
 *
 * Description:
 *	SQL*Plus script to display database space usage.
 *
 * Modifications:
 *	TGorman	11mar02	added support for AUTOEXTENSIBLE data files
 *********************************************************************/
col tablespace format a25
col owner format a20
col type format a19
col sort1 noprint
col mb format 999,990.00

clear breaks
clear compute
break on report on tablespace on owner on type

set echo off feedback off timing off pagesize 66 verify off trimspool on

col instance new_value V_INSTANCE noprint
select instance from v$thread;

spool spc_&&V_INSTANCE

select	tablespace_name tablespace,
	owner,
	'a' sort1,
	segment_type type,
	sum(bytes)/1048576 mb
from	dba_segments
group by tablespace_name, owner, segment_type
union all
select	tablespace,
	user owner,
	'b' sort1,
	segtype type,
	sum(blocks)/128 mb
from	v$sort_usage
group by tablespace, user, segtype
union all
select	tablespace_name tablespace,
	'' owner,
	'c' sort1,
	'-------total-------' type,
	sum(bytes)/1048576 mb
from	dba_segments
group	by tablespace_name
union all
select	tablespace,
	'' owner,
	'd' sort1,
	'-------total-------' type,
	sum(blocks)/128 mb
from	v$sort_usage
group by tablespace
union all
select	tablespace_name tablespace,
	'' owner,
	'e' sort1,
	'-----allocated-----' type,
	sum(bytes)/1048576 mb
from	dba_data_files
group by tablespace_name
union all
select	tablespace_name tablespace,
	'' owner,
	'f' sort1,
	'-----allocated-----' type,
	sum(bytes)/1048576 mb
from	dba_temp_files
group by tablespace_name
union all
select	tablespace_name tablespace,
	'' owner,
	'g' sort1,
	'----allocatable----' type,
	sum(decode(autoextensible,'YES',maxbytes,bytes))/1048576 mb
from	dba_data_files
group by tablespace_name
union all
select	tablespace_name tablespace,
	'' owner,
	'h' sort1,
	'----allocatable----' type,
	sum(decode(autoextensible,'YES',maxbytes,bytes))/1048576 mb
from	dba_temp_files
group by tablespace_name
union all
select	tablespace_name tablespace,
	'' owner,
	'i' sort1,
	'' type,
	to_number('') mb
from	dba_tablespaces
union all
select	tablespace,
	owner,
	sort1,
	type,
	sum(mb)
from	(select	'' tablespace,
		'Total' owner,
		'a' sort1,
		'Used' type,
		sum(bytes)/1048576 mb
	 from	dba_segments
	 union all
	 select	'' tablespace,
		'Total' owner,
		'a' sort1,
		'Used' type,
		sum(blocks)/128 mb
	 from	v$sort_usage)
group by tablespace, owner, sort1, type
union all
select	tablespace,
	owner,
	sort1,
	type,
	sum(mb)
from	(select	'' tablespace,
		'Total' owner,
		'b' sort1,
		'Allocated' type,
		sum(bytes)/1048576 mb
	 from	dba_data_files
	 union all
 	 select	'' tablespace,
		'Total' owner,
		'b' sort1,
		'Allocated' type,
		sum(bytes)/1048576 mb
	 from	dba_temp_files)
group by tablespace, owner, sort1, type
union all
select	tablespace,
	owner,
	sort1,
	type,
	sum(mb)
from	(select	'' tablespace,
		'Total' owner,
		'c' sort1,
		'Allocatable' type,
		sum(decode(autoextensible,'YES',maxbytes,bytes))/1048576 mb
	 from	dba_data_files
	 union all
	 select	'' tablespace,
		'Total' owner,
		'c' sort1,
		'Allocatable' type,
		sum(decode(autoextensible,'YES',maxbytes,bytes))/1048576 mb
	 from	dba_temp_files)
group by tablespace, owner, sort1, type
order by 1, 2, 3, 4;

spool off
