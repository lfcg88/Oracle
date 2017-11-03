rem $DBA/analinds.sql
rem
rem Determines the appropriateness of all indexes on all non-SYS/SYSTEM-owned
rem tables.
rem
rem Creates an analysis report (analinds.lis) of all tables and indexes.
rem
rem ***** Notes: *****
rem    1) This may take many hours when analyzing large tables!
rem    2) Uses DBMS_SQL package.
rem
rem Last Change 05/23/97 
rem
set echo off
set feedback off
set heading off
set pagesize 0
set serveroutput on size 1000000
set termout off
set verify off
drop table analinds_temp;
set termout on
whenever sqlerror exit failure
create table analinds_temp (lineno number, text varchar2(80));
declare
	cursor time_cursor is select
		to_char(sysdate, 'HH:MI:SS')
		from dual;

	cursor tab_cursor is select
		owner,
		table_name
		from sys.dba_tables
		where owner != 'SYS' and owner != 'SYSTEM'
		and table_name != 'ANALINDS_TEMP'
		order by owner, table_name;

	cursor ind_cursor (c_own VARCHAR2, c_tab VARCHAR2) is select
		to_char(sysdate, 'HH:MI:SS'),
		index_name,
		decode(uniqueness,
			'NONUNIQUE','Non-Unique',
			'UNIQUE','    Unique',
			'BITMAP','    Bitmap', uniqueness)
		from sys.dba_indexes
		where owner = c_own and table_name = c_tab
		order by index_name;

	cursor col_cursor (c_own varchar2, c_ind varchar2) is select
		decode(column_position, 1, column_name, ', ' || column_name)
		from sys.dba_ind_columns
		where index_owner = c_own and index_name = c_ind
		order by column_position;

	cursor col2_cursor (c_own varchar2, c_ind varchar2) is select
		decode(column_position, 1, column_name, '||' || column_name)
		from sys.dba_ind_columns
		where index_owner = c_own and index_name = c_ind
		order by column_position;

	lv_owner		sys.dba_tables.owner%TYPE;
	lv_table_name		sys.dba_tables.table_name%TYPE;
	lv_num_rows		number;
	lv_index_name		sys.dba_indexes.index_name%TYPE;
	lv_distinct_keys	number;
	lv_column_name		sys.dba_ind_columns.column_name%TYPE;
	lv_uniqueness		char(10);
	now			varchar2(8);
	the_cols		varchar2(1000);
	dbms_sql_cursor		number;
	dummy			number;
	numrows			number;
	lineno			number;
	recno			number;
	n			number;
	a_lin			varchar2(80);
	x			varchar2(80);
	pct_dist_keys		char(9);
	cardinality		char(11);

	function vwri(x_lin in varchar2, x_str in varchar2,
		x_force in number) return varchar2 is
	begin
		if length(x_lin) + length(x_str) > 80
		then
			lineno := lineno + 1;
			insert into analinds_temp values (lineno, x_lin);
			if x_force = 0
			then
				return '                              ' ||
					x_str;
			else
				lineno := lineno + 1;
				insert into analinds_temp values
					(lineno, x_str);
				return '';
			end if;
		else
			if x_force = 0
			then
				return x_lin||x_str;
			else
				lineno := lineno + 1;
				insert into analinds_temp values (
					lineno, x_lin||x_str);
				return '';
			end if;
		end if;
	end vwri;

	function format_owner_table (the_owner in varchar2,
		the_table in varchar2) return varchar2 is
	begin
		n := length(the_owner) + length(the_table);
		if n < 40 then
			return rpad(the_owner || '.' || the_table, 40);
		else
			return '..' || substr(the_owner || '.' || the_table,
				n-36, 38);
		end if;
	end format_owner_table;

	function get_row_count (the_owner in varchar2,
		the_table in varchar2) return number is
	begin
		dbms_sql_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(dbms_sql_cursor,
			'select count(*) from ' || the_owner || '.' ||
			the_table, dbms_sql.v7);
		dbms_sql.define_column(dbms_sql_cursor, 1, numrows);
		dummy := dbms_sql.execute(dbms_sql_cursor);
		dummy := dbms_sql.fetch_rows(dbms_sql_cursor);
		dbms_sql.column_value(dbms_sql_cursor, 1, numrows);
		dbms_sql.close_cursor(dbms_sql_cursor);
		return numrows;
	end get_row_count;

	function get_distinct (the_owner in varchar2,
		the_table in varchar2, the_index in varchar2) return number is
	begin
		the_cols := '';
		open col2_cursor(the_owner, the_index);
		loop
			fetch col2_cursor into lv_column_name;
			exit when col2_cursor%notfound;
			the_cols := the_cols || lv_column_name;
		end loop;
		close col2_cursor;
		dbms_sql_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(dbms_sql_cursor,
			'select count(distinct ' || the_cols || ') from ' ||
			the_owner || '.' || the_table, dbms_sql.v7);
		dbms_sql.define_column(dbms_sql_cursor, 1, numrows);
		dummy := dbms_sql.execute(dbms_sql_cursor);
		dummy := dbms_sql.fetch_rows(dbms_sql_cursor);
		dbms_sql.column_value(dbms_sql_cursor, 1, numrows);
		dbms_sql.close_cursor(dbms_sql_cursor);
		return numrows;
	end get_distinct;

	procedure wri (my_txt in varchar2) is
	begin
		lineno := lineno + 1;
		insert into analinds_temp values (lineno, my_txt);
	end wri;

begin
	lineno := 0;
	recno := 0;

	wri('                                                    Distinct' ||
		' %Distinct');
	wri('Object Owner / Name                       Num Rows    Keys  ' ||
		'   Keys  Cardinality');
	wri('---------------------------------------- --------- ---------' ||
		' ------- -----------');

	/* Process all of the desired tables and indexes */
	open tab_cursor;
	loop
		open time_cursor;
		fetch time_cursor into now;
		close time_cursor;
		fetch tab_cursor into
			lv_owner,
			lv_table_name;
		exit when tab_cursor%notfound;

		dbms_output.put_line('Starting analysis of ' ||
			format_owner_table(lv_owner, lv_table_name) ||
			' at ' || now);

		/* Count the number of rows in each table */
		lv_num_rows := get_row_count(lv_owner, lv_table_name);

		recno := recno + 1;
		if recno > 1 then
			wri(' ');
		end if;

		wri(format_owner_table(lv_owner, lv_table_name) ||
			to_char(lv_num_rows, '999999999'));

		open ind_cursor(lv_owner, lv_table_name);
		loop
			fetch ind_cursor into
				now,
				lv_index_name,
				lv_uniqueness;
			exit when ind_cursor%notfound;

			dbms_output.put_line('Starting analysis of ' ||
				rpad(lv_index_name, 40) || ' at ' || now);

			/* Count the number of distinct keys for this index */
			lv_distinct_keys :=
				get_distinct(lv_owner, lv_table_name,
				lv_index_name);

			if lv_num_rows <> 0 then
				pct_dist_keys := to_char(100 *
					lv_distinct_keys / lv_num_rows,
					'999.999') || '%';
			else
				pct_dist_keys := ' ';
			end if;

			if lv_distinct_keys <> 0 then
				cardinality := to_char(100 / lv_distinct_keys,
					'999.99999') || '%';
			else
				cardinality := ' ';
			end if;

			wri(rpad('  ' || lv_uniqueness || ' ' || lv_index_name,
				40) || '          ' ||
				to_char(lv_distinct_keys, '999999999') ||
				pct_dist_keys || cardinality);

			a_lin := '             Indexed columns: ';
			open col_cursor(lv_owner, lv_index_name);
			loop
				fetch col_cursor into lv_column_name;
				exit when col_cursor%notfound;
				a_lin := vwri(a_lin, lv_column_name, 0);
			end loop;
			close col_cursor;
			a_lin := vwri(a_lin, '', 1);

			/* Analyze for proper index type */
			if lv_uniqueness = 'Non-Unique' then
				if lv_distinct_keys > 0 and
					lv_distinct_keys < 21
				then
					wri('');
					wri('  *************************' ||
						'**************************' ||
						'***************************');
					wri('  ** The above non-unique index' ||
						' might not be appropriate,' ||
						' since non-unique    **');
					wri('  ** indexes should be created' ||
						' on columns which return' ||
						' no more than 2-4% of   **');
					wri('  ** the total number of rows' ||
						' in the table - Assuming' ||
						' an average distribution **');
					x := to_char(trunc(100 /
						lv_distinct_keys));
					wri('  ** of values, this index will' ||
						' return ' || x ||
						'% of the rows' || substr(
						'                         ',
						1, 26 - length(x)) || '**');
					wri('  *************************' ||
						'**************************' ||
						'***************************');
					wri('');
				end if;
			elsif lv_uniqueness = '    Bitmap' then
				if lv_distinct_keys > 0 and lv_num_rows > 0 then
				    if lv_num_rows / lv_distinct_keys < 1000
				    then
					wri('');
					wri('  *************************' ||
						'**************************' ||
						'***************************');
					wri('  ** The above bitmap index' ||
						' might not be appropriate,' ||
						' since bitmap indexes    **');
					wri('  ** should be created on' ||
						' columns having no more' ||
						' than 1 unique value' ||
						' per      **');
					x := to_char(trunc(lv_num_rows /
						lv_distinct_keys));
					wri('  ** 1000 rows - This index' ||
						' currently has 1 unique' ||
						' value per ' || x || ' rows' ||
						substr('           ',
						1, 12 - length(x)) || '**');
					wri('  *************************' ||
						'**************************' ||
						'***************************');
					wri('');
				    end if;
				end if;
			end if;

		end loop;
		close ind_cursor;
	end loop;
	close tab_cursor;

	dbms_output.put_line('Done with analysis at ' || now);

	commit;
exception
        when others then
                rollback;
		if dbms_sql.is_open(dbms_sql_cursor) then
			dbms_sql.close_cursor(dbms_sql_cursor);
		end if;
                raise_application_error(-20000,
                        'Unexpected error on ' || lv_owner || '.' ||
			lv_table_name || ': ' || to_char(SQLCODE) || chr(10) ||
			sqlerrm || chr(10) || 'Aborting...');
end;
/

set termout off
spool analinds.lis
select text from analinds_temp order by lineno;
spool off
drop table analinds_temp;
set termout on
select 'Created analinds.lis report for your viewing pleasure...' from dual;
exit
