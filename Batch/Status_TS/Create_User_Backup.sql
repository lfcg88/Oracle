create user backup identified by senhabackup
default tablespace users
temporary tablespace temp;

grant create session to backup;
grant exp_full_database to backup;
-- analize any é necessário para executar dbms_space.unused_space
grant analyze any to backup;


create global temporary TABLE backup.TEMP_SPACE (
  OWNER varchar2(30),
  SEGMENT_TYPE VARCHAR2(30),
  SEGMENT_NAME varchar2(30),
  UNUSED_BYTES NUMBER,
  TOTAL_BYTES NUMBER,
  INITIAL_EXTENT NUMBER,
  NEXT_EXTENT NUMBER,
  MAX_EXTENTS NUMBER,
  EXTENT_COUNT NUMBER,
  PARTITION_NAME VARCHAR2(30))
  on commit preserve rows;

CREATE OR REPLACE PROCEDURE BACKUP.SP_POP_TEMP_SPACE IS

   v_total_blocks number;
   v_total_bytes number;
   v_unused_blocks number;
   v_unused_bytes number;
   v_last_used_extent_file_id number;
   v_last_used_extent_block_id number;
   v_last_used_block number;
   v_owner varchar2(30);
   v_segment_name varchar2(30);
   v_segment_type varchar2(30);
   v_segment_type_w varchar2(30);
   v_initial_extent binary_integer;
   v_next_extent binary_integer;
   V_max_extents binary_integer;
   V_extent_count binary_integer;
   v_partition_name varchar2(30);
   cursor cs_segs is
           select  s.owner,s.segment_name,s.segment_type,s.initial_extent,nvl(s.next_extent,s.initial_extent) as next_extent,ext.extent_count as Extent_Count,s.max_extents,s.partition_name
                   from dba_segments s,(select owner,segment_name,count(*) as extent_count
                        from dba_extents
          group by owner,segment_name) ext
                   where s.owner not in ('SYS','SYSTEM') and
                         s.segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION','INDEX','INDEX PARTITION','CLUSTER','LOBSEGMENT') and
                         s.owner = ext.owner and
                         s.segment_name = ext.segment_name
                   order by s.owner,s.segment_type,s.segment_name;
begin
  open cs_segs;
  loop
    fetch cs_segs into v_owner,v_segment_name,v_segment_type,v_initial_extent,v_next_extent,v_extent_count,v_max_extents,v_partition_name;
    exit when cs_segs%NOTFOUND;
	select DECODE(v_segment_type,'LOBSEGMENT','LOB',v_segment_type) into v_segment_type_w from dual;
    dbms_space.unused_space (v_owner,v_segment_name,v_segment_type_w,v_total_blocks,
                             v_total_bytes, v_unused_blocks, v_unused_bytes,
                             v_last_used_extent_file_id, v_last_used_extent_block_id,
                             v_last_used_block,v_partition_name);

   INSERT INTO TEMP_SPACE
          (OWNER,SEGMENT_TYPE,SEGMENT_NAME,UNUSED_BYTES,TOTAL_BYTES,
           INITIAL_EXTENT,NEXT_EXTENT,EXTENT_COUNT,MAX_EXTENTS,PARTITION_NAME)
   VALUES (V_OWNER, V_SEGMENT_TYPE, V_SEGMENT_NAME,v_unused_bytes,v_total_bytes,
           v_initial_extent,v_next_extent,v_extent_count,V_MAX_EXTENTS,V_PARTITION_NAME);
  end loop;
  close cs_segs;
  commit;
EXCEPTION
WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE ('Processando segmento ' || V_OWNER || '.' || V_SEGMENT_NAME || '(' || V_SEGMENT_TYPE_W || ')');
   DBMS_OUTPUT.PUT_LINE (SQLCODE || ' --- ' || SQLERRM);
   RAISE;
end SP_POP_TEMP_SPACE;
/

connect sys@miafis
grant select on dba_free_space to backup;
grant select on dba_data_files to backup;
grant select on dba_segments to backup;
grant select on dba_extents to backup;

