set serveroutput on
accept owner prompt 'Owner da objeto ?'
accept obj prompt 'Nome do Objeto ?'
accept tipo prompt 'Tipo do Objeto ?' 

declare
    v_total_blocks number;
     v_total_bytes number;
    v_unused_blocks number;
    v_unused_bytes number;
    v_last_used_extent_file_id number;
    v_last_used_extent_block_id number;
    v_last_used_block number;
begin
   dbms_space.unused_space ('&owner','&obj','&tipo',v_total_blocks,
                             v_total_bytes, v_unused_blocks, v_unused_bytes,
                             v_last_used_extent_file_id, v_last_used_extent_block_id,
                             v_last_used_block);
   dbms_output.put_line('Objeto (bytes) = '||v_total_bytes);
   dbms_output.put_line('Blocos sem uso = '||v_unused_blocks);
   dbms_output.put_line('Bytes não utilizados = '||v_unused_bytes);
   dbms_output.put_line('Último bloco utilizado = '||v_last_used_block);
end;
/
