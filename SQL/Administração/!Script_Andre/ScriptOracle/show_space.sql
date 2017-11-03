/**********************************************************************
 * File:        show_space.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        01-Feb-02
 *
 * Description:
 *      SQL*Plus script to display space utilization by a single
 *	table, index, cluster, or partition.  The SHOW_SPACE stored
 *	procedure is an encapsulation of the DBMS_SPACE packaged
 *	procedures.
 *
 * Modifications:
 *********************************************************************/
set echo on feedback on timing on

spool show_space

create or replace procedure show_space (p_segname in varchar2,
					p_owner in varchar2 default USER,
					p_type in varchar2 default 'TABLE',
					p_partition in varchar2 default NULL)
as
	--
	l_free_blocks		number;
	l_total_blocks		number;
	l_total_bytes		number;
	l_unused_bytes		number;
	l_unused_blocks		number;
	l_LastusedExtFileId	number;
	l_LastUsedExtBlockId	number;
	l_last_used_block	number;
	--
	l_segname		varchar2(30);
	l_owner			varchar2(30);
	l_type			varchar2(20);
	l_partition		varchar2(30);
	--
	procedure p(p_label in varchar2, p_num in number )
	is
	begin
		dbms_output.put_line(rpad(p_label,40,'.')||p_num);
	end;
	--
	procedure p(p_label in varchar2, p_num in varchar2 )
	is
	begin
		dbms_output.put_line(rpad(p_label,40,'.')||p_num);
	end;
	--
begin
	--
	l_segname := upper(p_segname);
	l_owner := upper(p_owner);
	l_type := upper(p_type);
	l_partition := upper(p_partition);
	--
	dbms_space.free_blocks (
		segment_owner			=> l_owner
		, segment_name			=> l_segname
		, segment_type			=> l_type
		, partition_name		=> l_partition
		, freelist_group_id		=> 0
		, free_blks			=> l_free_blocks
	);
	--
	dbms_space.unused_space (
		segment_owner			=> l_owner
		, segment_name			=> l_segname
		, segment_type			=> l_type
		, partition_name		=> l_partition
		, total_blocks			=> l_total_blocks
		, total_bytes			=> l_total_bytes
		, unused_blocks			=> l_unused_blocks
		, unused_bytes			=> l_unused_bytes
		, last_used_block		=> l_last_used_block
		, last_used_extent_file_id	=> l_LastusedExtFileId
		, last_used_extent_block_id	=> l_LastUsedExtBlockId
	);
	--
	p('Free Blocks', l_free_blocks);
	p('Total Blocks', l_total_blocks);
	p('Total Bytes', l_total_bytes);
	p('Unused Blocks', l_unused_blocks);
	p('Unused Bytes', l_unused_bytes);
	p('Last Used Ext FileId', l_LastusedExtFileId);
	p('Last Used Ext BlockId', l_LastUsedExtBlockId);
	p('Last Used Block', l_last_used_block);
	p('********** Summary Percentages *********','');
	p('% Bytes Unused', trim(to_char((l_unused_bytes/l_total_bytes)*100,'990.00'))||'%');
	p('% Blocks Unused', trim(to_char((l_unused_blocks/l_total_blocks)*100,'990.00'))||'%');
	p('% Blocks Free', trim(to_char((l_free_blocks/l_total_blocks)*100,'990.00'))||'%');
	p('% Blocks Used', trim(to_char((1-((l_free_blocks+l_unused_blocks)/l_total_blocks))*100,'990.00'))||'%');
	--
end;
/
show error

spool off
