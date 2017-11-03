/**********************************************************************
 * File:	top_stmt4_9i.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (SageLogix, Inc.)
 * Date:	17-Mar-2004
 *
 * Description:
 *	DDL script to create the TOP_STMT4 stored procedure, which
 *	reads from STATSPACK tables instead of V$ views and which
 *	capable of calculating "delta" values using the "LAG()"
 *	analytic function...
 *
 *	This version of TOP_STMT4 is intended to used with Oracle9i,
 *	as it includes the use of the CPU_TIME and ELAPSED_TIME columns
 *	in the STATS$SQL_SUMMARY table, which do not exist in Oracle8i.
 *
 * Modifications:
 *	TGorman	17mar04	adapted from previous TOP_STMTx procedures...
 *	TGorman 02may04	corrected bug in LAG() OVER clause
 *	TGorman 10aug04	corrected bug in query on STATS$SYSSTAT and
 *			removed unnecessary PARTITION BY DBID,
 *			INSTANCE_NUMBER phrases from queries using
 *			LAG () analytic functions
 *	TGorman	17sep04	improved efficiency of cursor "get_top_stmts"
 *			by joining STATS$SQL_SUMMARY and STATS$SNAPSHOT
 *			in the inner-most in-line view subquery
 *	TGorman	21sep04	added display of EXPLAIN PLAN information from
 *			STATS$SQL_PLAN and STATS$SQL_PLAN_USAGE
 *********************************************************************/
set echo on feedback on timing on

spool top_stmt4_9i

drop table cstats$plan_table;
create global temporary table cstats$plan_table
(
	statement_id 	varchar2(30),
	timestamp    	date,
	remarks      	varchar2(80),
	operation    	varchar2(30),
	options       	varchar2(255),
	object_node  	varchar2(128),
	object_owner 	varchar2(30),
	object_name  	varchar2(30),
	object_instance numeric,
	object_type     varchar2(30),
	optimizer       varchar2(255),
	search_columns  number,
	id		numeric,
	parent_id	numeric,
	position	numeric,
	cost		numeric,
	cardinality	numeric,
	bytes		numeric,
	other_tag       varchar2(255),
	partition_start varchar2(255),
        partition_stop  varchar2(255),
        partition_id    numeric,
	other		long,
	distribution    varchar2(30),
	cpu_cost	numeric,
	io_cost		numeric,
	temp_space	numeric,
        access_predicates varchar2(4000),
        filter_predicates varchar2(4000)
) on commit delete rows;

create or replace procedure top_stmt4
(
	in_start_date in date,
	in_nbr_days in number,
	in_instance_name in varchar2,
	in_instance_number in number default 1,
	in_top_count in number default 10,
	in_max_disk_reads in number default 10000,
	in_max_buffer_gets in number default 100000
) is
	--
	cursor get_top_stmts(in_dr in number, in_bg in number,
			     in_dbid in number, in_instance_number in number,
			     in_begin_time in date, in_end_time in date)
	is
	select	 sql_text,
		 hash_value,
		 text_subset,
		 module,
		 sum(disk_reads_inc) disk_reads,
		 sum(buffer_gets_inc) buffer_gets,
		 sum(cpu_time_inc) cpu_time,
		 sum(elapsed_time_inc) elapsed_time,
		 sum(executions_inc) executions,
		 (1 - (sum(disk_reads_inc) / sum(buffer_gets_inc)))*100 bchr,
		 sum(disk_reads_inc) / sum(executions_inc) dr_per_exe,
		 sum(buffer_gets_inc) / sum(executions_inc) bg_per_exe,
		 sum(cpu_time_inc) / sum(executions_inc) cpu_per_exe,
		 sum(elapsed_time_inc) / sum(executions_inc) ela_per_exe,
		 ((sum(disk_reads_inc)*100)+sum(buffer_gets_inc))/100 factor
	from	 (select sq.sql_text,
			 sq.hash_value,
			 sq.text_subset,
			 sq.module,
			 decode(greatest(sq.disk_reads,
				nvl(lag(sq.disk_reads)
					over(partition by sq.hash_value
					     order by sq.snap_id),0)),
			        sq.disk_reads,
				sq.disk_reads-nvl(lag(sq.disk_reads)
						over(partition by sq.hash_value
						     order by sq.snap_id),0),
			        0) disk_reads_inc,
			 decode(greatest(sq.buffer_gets,
				nvl(lag(sq.buffer_gets)
					over(partition by sq.hash_value
					     order by sq.snap_id),0)),
			        sq.buffer_gets,
				sq.buffer_gets-nvl(lag(buffer_gets)
						over(partition by sq.hash_value
						     order by sq.snap_id),0),
			        0) buffer_gets_inc,
			 decode(greatest(sq.executions,
				nvl(lag(sq.executions)
					over(partition by sq.hash_value
					     order by sq.snap_id),0)),
			        sq.executions,
				sq.executions-nvl(lag(sq.executions)
						over(partition by sq.hash_value
						     order by sq.snap_id),0),
			        0) executions_inc,
			 decode(greatest(sq.cpu_time,
				nvl(lag(sq.cpu_time)
					over(partition by sq.hash_value
					     order by sq.snap_id),0)),
			        sq.cpu_time,
				sq.cpu_time-nvl(lag(sq.cpu_time)
						over(partition by sq.hash_value
						     order by sq.snap_id),0),
			        0)/1000000 cpu_time_inc,
			 decode(greatest(sq.elapsed_time,
				nvl(lag(sq.elapsed_time)
					over(partition by sq.hash_value
					     order by sq.snap_id),0)),
			        sq.elapsed_time,
				sq.elapsed_time-nvl(lag(sq.elapsed_time)
						over(partition by sq.hash_value
						     order by sq.snap_id),0),
			        0)/1000000 elapsed_time_inc
		  from	 stats$sql_summary	sq,
			 stats$snapshot		ss
		  where	 ss.dbid = in_dbid
		  and	 ss.instance_number = in_instance_number
		  and	 ss.snap_time between in_begin_time and in_end_time
		  and	 sq.dbid = ss.dbid
		  and	 sq.instance_number = ss.instance_number
		  and	 sq.snap_id = ss.snap_id
		  and	 sq.executions between 0 and 999999999999999
		  and	 sq.disk_reads between 0 and 999999999999999
		  and	 sq.buffer_gets between 0 and 999999999999999
		  and	 sq.cpu_time between 0 and 999999999999999
		  and	 sq.elapsed_time between 0 and 999999999999999)
	group by sql_text,
		 hash_value,
		 text_subset,
		 module
	having	 (sum(disk_reads_inc) > in_dr
	  or	  sum(buffer_gets_inc) > in_bg)
	and	 sum(buffer_gets_inc) > 0
	and	 sum(executions_inc) > 0
	order by factor desc;
	--
	cursor get_text (in_hash_value in number, in_text_subset in varchar2)
	is
	select	piece,
		sql_text
	from	stats$sqltext
	where	hash_value = in_hash_value
	and	text_subset = in_text_subset
	order by piece;
	--
	cursor get_plan_hash_value(in_dbid in number,
				   in_instance_number in number,
				   in_hash_value in number,
				   in_text_subset in varchar2,
				   in_begin_time in date,
				   in_end_time in date)
	is
	select	pu.plan_hash_value,
		ss.snap_time,
		ss.snap_id
	from	stats$sql_plan_usage	pu,
		stats$snapshot		ss
	where	ss.dbid = in_dbid
	and	ss.instance_number = in_instance_number
	and	ss.snap_time between in_begin_time and in_end_time
	and	pu.dbid = ss.dbid
	and	pu.instance_number = ss.instance_number
	and	pu.snap_id = ss.snap_id
	and	pu.hash_value = in_hash_value
	and	pu.text_subset = in_text_subset
	order by ss.snap_time;
	--
	cursor get_xplan(in_plan_hv in number)
	is
	select	plan_table_output
	from	table(dbms_xplan.display('CSTATS$PLAN_TABLE', trim(to_char(in_plan_hv)), 'ALL'));
	--
	v_text_lines		integer;
	v_prev_plan_hash_value	integer;
	v_length		integer;
	n			integer;
	v_tot_logr		integer;
	v_tot_phyr		integer;
	v_sql_tot_cnt		integer := 0;
	v_sql_tot_dr		integer := 0;
	v_sql_tot_bg		integer := 0;
	v_sql_tot_cpu		integer := 0;
	v_sql_tot_ela		integer := 0;
	v_plsql_tot_cnt		integer := 0;
	v_plsql_tot_dr		integer := 0;
	v_plsql_tot_bg		integer := 0;
	v_plsql_tot_cpu		integer := 0;
	v_plsql_tot_ela		integer := 0;
	v_dbid			number;
	v_begin_snapshot	date;
	v_end_snapshot		date;
	v_begin_snap_id		integer;
	v_end_snap_id		integer;
	v_nbr_snapshots		integer;
	--
	v_errcontext		varchar2(100);
	v_errmsg		varchar2(512);
	v_save_module		varchar2(48);
	v_save_action		varchar2(32);
	--
begin
--
dbms_application_info.read_module(v_save_module, v_save_action);
v_errcontext := 'query stats$database_instance';
dbms_application_info.set_module('TOP_STMT4', v_errcontext);
select	distinct dbid
into	v_dbid
from	stats$database_instance
where	instance_name = in_instance_name
and	instance_number = in_instance_number;
--
v_errcontext := 'query stats$snapshot';
dbms_application_info.set_action(v_errcontext);
select	min(snap_time),
	min(snap_id),
	max(snap_time),
	max(snap_id),
	count(*)
into	v_begin_snapshot,
	v_begin_snap_id,
	v_end_snapshot,
	v_end_snap_id,
	v_nbr_snapshots
from	stats$snapshot
where	snap_time between in_start_date and (in_start_date + in_nbr_days)
and	dbid = v_dbid
and	instance_number = in_instance_number;
--
v_errcontext := 'query stats$sysstat';
dbms_application_info.set_action(v_errcontext);
select	sum(cg.value_inc+dbg.value_inc),
	sum(p.value_inc)
into	v_tot_logr,
	v_tot_phyr
from	(select dbid, instance_number, snap_id,
		decode(greatest(value, nvl(lag(value) over (order by snap_id), 0)),
		       value, value - nvl(lag(value) over (order by snap_id), 0),
		       0) value_inc
	 from	stats$sysstat
	 where	dbid = v_dbid
	 and	instance_number = in_instance_number
	 and	name = 'consistent gets'
	 and	value between 0 and 999999999999999)	cg,
	(select dbid, instance_number, snap_id,
		decode(greatest(value, nvl(lag(value) over (order by snap_id), 0)),
		       value, value - nvl(lag(value) over (order by snap_id), 0),
		       0) value_inc
	 from	stats$sysstat
	 where	dbid = v_dbid
	 and	instance_number = in_instance_number
	 and	name = 'db block gets'
	 and	value between 0 and 999999999999999)	dbg,
	(select dbid, instance_number, snap_id,
		decode(greatest(value, nvl(lag(value) over (order by snap_id), 0)),
		       value, value - nvl(lag(value) over (order by snap_id), 0),
		       0) value_inc
	 from	stats$sysstat
	 where	dbid = v_dbid
	 and	instance_number = in_instance_number
	 and	name = 'physical reads'
	 and	value between 0 and 999999999999999)	p,
	stats$snapshot					s
where	s.snap_id between v_begin_snap_id and v_end_snap_id
and	s.dbid = v_dbid
and	s.instance_number = in_instance_number
and	cg.snap_id = s.snap_id
and	cg.dbid = s.dbid
and	cg.instance_number = s.instance_number
and	dbg.snap_id = s.snap_id
and	dbg.dbid = s.dbid
and	dbg.instance_number = s.instance_number
and	p.snap_id = s.snap_id
and	p.dbid = s.dbid
and	p.instance_number = s.instance_number;
--
v_errcontext := 'open/fetch get_top_stmts';
dbms_application_info.set_action(v_errcontext);
for a in get_top_stmts(in_max_disk_reads, in_max_buffer_gets,
		       v_dbid, in_instance_number, v_begin_snapshot, v_end_snapshot) loop
	--
	if get_top_stmts%rowcount > in_top_count then
		--
		exit;
		--
	end if;
	--
	v_errcontext := 'put_line formfeed';
	dbms_application_info.set_action(v_errcontext);
	if get_top_stmts%rowcount > 1 then
		--
		dbms_output.put_line(chr(12));
		--
	end if;
	--
	v_errcontext := 'put_line statement header';
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line(rpad('Beginning Snap Time: ',30) ||
			to_char(v_begin_snapshot, 'MM/DD/YY HH24:MI:SS') ||
			lpad('Page ' ||
			     to_char(get_top_stmts%rowcount,'990'),52));
	dbms_output.put_line(rpad('Ending Snap Time : ',30) ||
			to_char(v_end_snapshot, 'MM/DD/YY HH24:MI:SS') ||
			lpad('Nbr of Snapshots: ' ||
			     to_char(v_nbr_snapshots,'990'),52));
	dbms_output.put_line(rpad('Date of Report : ',30) ||
			to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
	dbms_output.put_line(rpad('Total Logical Reads: ', 23) ||
			to_char(v_tot_logr,'999,999,999,999,999,990') ||
			lpad('Total Physical Reads: ' ||
			to_char(v_tot_phyr,'999,999,999,999,999,990'), 52));
	dbms_output.put_line('.');
	--
	if a.module is not null then
		v_errcontext := 'display module';
		dbms_output.put_line('Module: "' || a.module || '"');
		dbms_output.put_line('.');
	end if;
	--
	dbms_output.put_line('SQL Statement Text (Hash Value=' || a.hash_value || ')');
	dbms_output.put_line('-------------------------------' || rpad('-', length(trim(to_char(a.hash_value))), '-') || '-');
	--
	v_text_lines := 0;
	v_errcontext := 'open/fetch get_text';
	dbms_application_info.set_action(v_errcontext);
	for s in get_text(a.hash_value, a.text_subset) loop
		--
		dbms_output.put_line(rpad(to_char(s.piece),6) || s.sql_text);
		--
		v_text_lines := v_text_lines + 1;
		--
		v_errcontext := 'fetch/close get_text';
		--
	end loop;
	--
	v_errcontext := 'put_line NULL statement text';
	dbms_application_info.set_action(v_errcontext);
	if v_text_lines = 0 then
		--
		v_text_lines := 0;
		v_length := length(a.sql_text);
		n := 1;
		loop
			--
			dbms_output.put_line(rpad(v_text_lines,6) ||
				substr(a.sql_text,n,64));
			--
			v_text_lines := v_text_lines + 1;
			n := n + 64;
			exit when n >= v_length;
			--
		end loop;
		--
	end if;
	--
	v_errcontext := 'put_line statement totals';
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('.');
	dbms_output.put_line(':' ||
				lpad('Disk ',16) ||
				lpad('Buffer',16) ||
				lpad('Cache Hit',10) ||
				lpad(' ',11) ||
				lpad('DR Per',12) ||
				lpad('BG Per',12) ||
				lpad('CPU Per',11) ||
				lpad('Ela Per',11));
	dbms_output.put_line(':' ||
				lpad('Reads',16) ||
				lpad('Gets',16) ||
				lpad('Ratio',10) ||
				lpad('Runs',11) ||
				lpad('Run',12) ||
				lpad('Run',12) ||
				lpad('Run',11) ||
				lpad('Run',11));
	dbms_output.put_line(':' ||
				lpad('-----',16) ||
				lpad('------',16) ||
				lpad('---------',10) ||
				lpad('----',11) ||
				lpad('------',12) ||
				lpad('------',12) ||
				lpad('------',11) ||
				lpad('------',11));
	dbms_output.put_line(':' ||
		lpad(ltrim(to_char(a.disk_reads,'999,999,999,990')),16) ||
		lpad(ltrim(to_char(a.buffer_gets,'999,999,999,990')),16) ||
		lpad(ltrim(to_char(a.bchr,'990.00')||'%'),10) ||
		lpad(ltrim(to_char(a.executions,'99,999,990')),11) ||
		lpad(ltrim(to_char(a.dr_per_exe,'999,999,990')),12) ||
		lpad(ltrim(to_char(a.bg_per_exe,'999,999,990')),12) ||
		lpad(ltrim(to_char(a.cpu_per_exe,'999,990.00')),11) ||
		lpad(ltrim(to_char(a.ela_per_exe,'999,990.00')),11));
	dbms_output.put_line(':' ||
		lpad('('||ltrim(to_char(round((a.disk_reads/v_tot_phyr)*100,3),
				   '990.000'))||'%)',16) ||
		lpad('('||ltrim(to_char(round((a.buffer_gets/v_tot_logr)*100,3),
				   '990.000'))||'%)',16));
	--
	v_prev_plan_hash_value := -1;
	v_errcontext := 'open/fetch get_plan_hash_value';
	dbms_application_info.set_action(v_errcontext);
	for phv in get_plan_hash_value(v_dbid, in_instance_number,
				       a.hash_value, a.text_subset,
				       v_begin_snapshot, v_end_snapshot) loop
		--
		if v_prev_plan_hash_value <> phv.plan_hash_value then
			--
			v_prev_plan_hash_value := phv.plan_hash_value;
			--
			v_errcontext := 'insert into CSTATS$PLAN_TABLE';
			insert into cstats$plan_table
			(	STATEMENT_ID,
				TIMESTAMP,
				REMARKS,
				OPERATION,
				OPTIONS,
				OBJECT_NODE,
				OBJECT_OWNER,
				OBJECT_NAME,
				OBJECT_INSTANCE,
				OBJECT_TYPE,
				OPTIMIZER,
				SEARCH_COLUMNS,
				ID,
				PARENT_ID,
				POSITION,
				COST,
				CARDINALITY,
				BYTES,
				OTHER_TAG,
				PARTITION_START,
				PARTITION_STOP,
				PARTITION_ID,
				OTHER,
				DISTRIBUTION,
				CPU_COST,
				IO_COST,
				TEMP_SPACE,
				ACCESS_PREDICATES,
				FILTER_PREDICATES)
			select	trim(to_char(p.PLAN_HASH_VALUE)),
				SYSDATE,
				'hash_value = '''||p.PLAN_HASH_VALUE||''' from STATS$SQL_PLAN',
				p.OPERATION,
				p.OPTIONS,
				p.OBJECT_NODE,
				p.OBJECT_OWNER,
				p.OBJECT_NAME,
				p.OBJECT#,
				o.OBJECT_TYPE,
				p.OPTIMIZER,
				p.SEARCH_COLUMNS,
				p.ID,
				p.PARENT_ID,
				p.POSITION,
				p.COST,
				p.CARDINALITY,
				p.BYTES,
				p.OTHER_TAG,
				p.PARTITION_START,
				p.PARTITION_STOP,
				p.PARTITION_ID,
				p.OTHER,
				p.DISTRIBUTION,
				p.CPU_COST,
				p.IO_COST,
				p.TEMP_SPACE,
				p.ACCESS_PREDICATES,
				p.FILTER_PREDICATES
			from	stats$sql_plan		p,
				stats$seg_stat_obj	o
			where	p.plan_hash_value = phv.plan_hash_value
			and	o.obj# (+) = p.object#;
			--
			v_text_lines := 0;
			v_errcontext := 'open/fetch get_xplan';
			dbms_application_info.set_action(v_errcontext);
			for s in get_xplan(phv.plan_hash_value) loop
				--
				if s.plan_table_output like 'Predicate Information %' then
					exit;
				end if;
				--
				if v_text_lines = 0 then
					dbms_output.put_line('.');
					dbms_output.put_line('.  SQL execution plan from "'||
						to_char(phv.snap_time,'MM/DD/YY HH24:MI:SS') ||
						'" (snap #'||phv.snap_id||')');
				end if;
				--
				dbms_output.put_line(s.plan_table_output);
				v_text_lines := v_text_lines + 1;
				--
			end loop;
			--
			v_errcontext := 'delete from cstats$plan_table';
			delete
			from	cstats$plan_table
			where	statement_id = trim(to_char(phv.plan_hash_value));
			--
			v_errcontext := 'fetch/close get_plan_hash_value';
			--
		end if;
		--
	end loop;
	--
	if upper(substr(ltrim(a.text_subset),1,6)) in ('DECLAR','BEGIN ') then
		--
		v_plsql_tot_cnt := v_plsql_tot_cnt + 1;
		v_plsql_tot_dr := v_plsql_tot_dr + a.disk_reads;
		v_plsql_tot_bg := v_plsql_tot_bg + a.buffer_gets;
		v_plsql_tot_cpu := v_plsql_tot_cpu + a.cpu_time;
		v_plsql_tot_ela := v_plsql_tot_ela + a.elapsed_time;
		--
	else
		--
		v_sql_tot_cnt := v_sql_tot_cnt + 1;
		v_sql_tot_dr := v_sql_tot_dr + a.disk_reads;
		v_sql_tot_bg := v_sql_tot_bg + a.buffer_gets;
		v_sql_tot_cpu := v_sql_tot_cpu + a.cpu_time;
		v_sql_tot_ela := v_sql_tot_ela + a.elapsed_time;
		--
	end if;
	--
	v_errcontext := 'fetch/close get_top_stmt';
	dbms_application_info.set_action(v_errcontext);
	--
end loop;
--
if v_sql_tot_cnt > 0 then
	--
	v_errcontext := 'put_line SQL cumulative totals';
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('.');
	dbms_output.put_line('.');
	dbms_output.put_line(': =============================================================================');
	dbms_output.put_line(':');
	dbms_output.put_line(': >>> CUMULATIVE TOTALS FOR '||v_sql_tot_cnt||' "TOP ' || in_top_count || '" SQL STATEMENTS <<<');
	dbms_output.put_line(':');
	dbms_output.put_line(':' ||
		lpad('Disk ',16) ||
		lpad('Buffer',20) ||
		lpad('Cache Hit',10) ||
		lpad('CPU',20) ||
		lpad('Elapsed',20));
	dbms_output.put_line(':' ||
		lpad('Reads',16) ||
		lpad('Gets',20) ||
		lpad('Ratio',10) ||
		lpad('Time',20) ||
		lpad('Time',20));
	dbms_output.put_line(':' ||
		lpad('-----',16) ||
		lpad('------',20) ||
		lpad('---------',10) ||
		lpad('---------',20) ||
		lpad('---------',20));
	dbms_output.put_line(':' ||
		lpad(ltrim(to_char(v_sql_tot_dr,'999,999,999,990')),16) ||
		lpad(ltrim(to_char(v_sql_tot_bg,'999,999,999,999,990')),20) ||
		lpad(ltrim(to_char((1 - (v_sql_tot_dr/v_sql_tot_bg))*100,'990.00')||'%'),10) ||
		lpad(ltrim(to_char(v_sql_tot_cpu,'999,999,999,999,990')),20) ||
		lpad(ltrim(to_char(v_sql_tot_ela,'999,999,999,999,990')),20));
	dbms_output.put_line(':' ||
		lpad('('||ltrim(to_char(round((v_sql_tot_dr/v_tot_phyr)*100,3),
			   	'990.000'))||'%)',16) ||
		lpad('('||ltrim(to_char(round((v_sql_tot_bg/v_tot_logr)*100,3),
			   	'990.000'))||'%)',20));
	--
end if;
--
if v_plsql_tot_cnt > 0 then
	--
	v_errcontext := 'put_line PLSQL cumulative totals';
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('.');
	dbms_output.put_line('.');
	dbms_output.put_line(': =============================================================================');
	dbms_output.put_line(':');
	dbms_output.put_line(': >>> CUMULATIVE TOTALS FOR '||v_plsql_tot_cnt||' "TOP '||in_top_count||'" PL/SQL STATEMENTS <<<');
	dbms_output.put_line(':');
	dbms_output.put_line(':' ||
		lpad('Disk ',20) ||
		lpad('Buffer',20) ||
		lpad('Cache Hit',10) ||
		lpad('CPU',20) ||
		lpad('Elapsed',20));
	dbms_output.put_line(':' ||
		lpad('Reads',16) ||
		lpad('Gets',20) ||
		lpad('Ratio',10) ||
		lpad('Time',20) ||
		lpad('Time',20));
	dbms_output.put_line(':' ||
		lpad('-----',20) ||
		lpad('------',20) ||
		lpad('---------',10) ||
		lpad('---------',20) ||
		lpad('---------',20));
	dbms_output.put_line(':' ||
		lpad(ltrim(to_char(v_plsql_tot_dr,'999,999,999,999,990')),20) ||
		lpad(ltrim(to_char(v_plsql_tot_bg,'999,999,999,999,990')),20) ||
		lpad(ltrim(to_char((1 - (v_plsql_tot_dr/v_plsql_tot_bg))*100,'990.00')||'%'),10) ||
		lpad(ltrim(to_char(v_plsql_tot_cpu,'999,999,999,999,990')),20) ||
		lpad(ltrim(to_char(v_plsql_tot_ela,'999,999,999,999,990')),20));
	dbms_output.put_line(':' ||
		lpad('('||ltrim(to_char(round((v_plsql_tot_dr/v_tot_phyr)*100,3),
			   	'990.000'))||'%)',20) ||
		lpad('('||ltrim(to_char(round((v_plsql_tot_bg/v_tot_logr)*100,3),
			   	'990.000'))||'%)',20));
	--
end if;
--
rollback;
--
dbms_application_info.set_module(v_save_module, v_save_action);
--
exception
	when others then
		v_errmsg := sqlerrm;
		dbms_application_info.set_module(v_save_module, v_save_action);
		rollback;
		raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end top_stmt4;
/
show errors

set serveroutput on size 1000000

execute top_stmt4 (trunc(sysdate),1,'bmpa');



spool off
