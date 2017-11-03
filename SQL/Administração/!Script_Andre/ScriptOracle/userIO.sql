REM
REM DBAToolZ NOTE:
REM	This script was obtained from DBAToolZ.com
REM	It's configured to work with SQL Directory (SQLDIR).
REM	SQLDIR is a utility that allows easy organization and
REM	execution of SQL*Plus scripts using user-friendly menu.
REM	Visit DBAToolZ.com for more details and free SQL scripts.
REM
REM 
REM File:
REM 	s_user_ses_IO.sql
REM
REM <SQLDIR_GRP>USER TRACE</SQLDIR_GRP>
REM 
REM Author:
REM 	Jonathan Lewis 
REM	JLEWIS
REM	http://www.jlcomp.demon.co.uk
REM 
REM Purpose:
REM	<SQLDIR_TXT>
REM	Reports session IO with 10 sec interval
REM	</SQLDIR_TXT>
REM	
REM Usage:
REM	s_user_ses_IO.sql
REM 
REM Example:
REM	s_user_ses_IO.sql
REM
REM
REM History:
REM	??-??-????	JLEWIS		Created
REM	08-01-2001	VMOGILEV	Added to DBATOOLZ Library
REM
REM

create or replace procedure session_io ( i_period in number default 10) is
	cursor c1 is
		select 
			sid,
			block_gets,
			consistent_gets,
			physical_reads,
			block_changes,
			consistent_changes
		from 
			v$sess_io
		order by
			sid;
	r	c1%rowtype;
	type s_type is table of c1%rowtype index by binary_integer;
	s_list s_type;
begin
	
	for r in c1 loop
		s_list(r.sid).block_gets := r.block_gets;
		s_list(r.sid).consistent_gets := r.consistent_gets;
		s_list(r.sid).physical_reads := r.physical_reads;
		s_list(r.sid).block_changes := r.block_changes;
		s_list(r.sid).consistent_changes := r.consistent_changes;
	end loop;
	dbms_lock.sleep (i_period);
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Session I/O - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		'SID' ||
		lpad('Block Gets',12) ||
		lpad('Cons gets',12) ||
		lpad('Physical',12) ||
		lpad('Block chg',12) ||
		lpad('Cons Chgs',12)
	);
	dbms_output.put_line(
		'---' ||
		lpad('----------',12) ||
		lpad('----------',12) ||
		lpad('--------',12) ||
		lpad('---------',12) ||
		lpad('----------',12)
	);
	for r in c1 loop
		if (not s_list.exists(r.sid)) then
		    s_list(r.sid).block_gets := 0;
		    s_list(r.sid).consistent_gets := 0;
		    s_list(r.sid).physical_reads := 0;
		    s_list(r.sid).block_changes := 0;
		    s_list(r.sid).consistent_changes := 0;
		end if;
		if (
		       (s_list(r.sid).block_gets != r.block_gets)
		    or (s_list(r.sid).consistent_gets != r.consistent_gets)
		    or (s_list(r.sid).physical_reads != r.physical_reads)
		    or (s_list(r.sid).block_changes != r.block_changes)
		    or (s_list(r.sid).consistent_changes != r.consistent_changes)
		) then
			dbms_output.put(to_char(r.sid,'000'));
			dbms_output.put(to_char( 
				r.block_gets - s_list(r.sid).block_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.consistent_gets - s_list(r.sid).consistent_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.physical_reads - s_list(r.sid).physical_reads,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.block_changes - s_list(r.sid).block_changes,
					'999,999,990')
			);
			dbms_output.put_line(to_char( 
				r.consistent_changes - s_list(r.sid).consistent_changes,
					'999,999,990')
			);
		end if;
	end loop;
end session_io;
/


set serveroutput on
execute session_io;
