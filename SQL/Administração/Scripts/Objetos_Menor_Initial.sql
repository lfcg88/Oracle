declare 
  Cursor c_object_name is
      select owner||'.'|| segment_name objeto
           , SEGMENT_TYPE
           , tablespace_name
           , sum(Initial_Extent)/1024/1024 Init
           , sum(bytes)/1024/1024  Tamanho
        from DBA_segments
       where owner not in ('SYS','SYSTEM','OUTLN')
         And SEGMENT_type in ('TABLE','INDEX')
--         And rownum < 10 --segment_name like upper('%AU_INTEGRACAO_EMITENTE%')
      group  by SEGMENT_TYPE
           , tablespace_name
          , owner
          , segment_name
          , Initial_Extent
      ORDER BY SEGMENT_TYPE
          , Tamanho
          , owner
          , segment_name;

--  WRK_TIPO_OBJETO   VARCHAR2(100) := UPPER('Tipo_objeto');
  WRK_NOME_PARTICAO VARCHAR2(100) := null;
  TOTAL_BLOCKS number; 
  TOTAL_BYTES number; 
  UNUSED_BLOCKS number; 
  UNUSED_BYTES number; 
  USED_BYTES number;
  LAST_USED_EXTENT_FILE_ID number; 
  LAST_USED_EXTENT_BLOCK_ID number; 
  LAST_USED_BLOCK number; 
  
begin 
  DBMS_OUTPUT.ENABLE(999999999999999999);

    --  dbms_output.put_line('-----------------------------------'); 
      dbms_output.put_line(Rpad('Nome Objeto',45,' ')|| 
                                rpad('Tablespace',20,' ')||
                                rpad('INITIAL(Mb)',20,' ')||
                                rpad('USED BYTES(Mb)',20,' ')||
                                rpad('FREE BYTES(Mb)',20,' ')||
                                rpad('TOTAL BYTES(Mb)',20,' '));

  For r_object_name in c_object_name Loop
    IF WRK_NOME_PARTICAO IS NULL THEN
      dbms_space.unused_space
        ( substr(r_object_name.objeto,1,instr(r_object_name.objeto,'.',1,1)-1) 
        , substr(r_object_name.objeto,instr(r_object_name.objeto,'.',1,1)+1)
        , r_object_name.SEGMENT_TYPE
        , TOTAL_BLOCKS
        , TOTAL_BYTES
        , UNUSED_BLOCKS
        , UNUSED_BYTES
        , LAST_USED_EXTENT_FILE_ID
        , LAST_USED_EXTENT_BLOCK_ID
        , LAST_USED_BLOCK); 
      USED_BYTES    := (TOTAL_BYTES - UNUSED_BYTES)/1024/1024;
      TOTAL_BYTES   := TOTAL_BYTES/1024/1024;
      UNUSED_BYTES  := UNUSED_BYTES/1024/1024;
--
       If USED_BYTES < r_object_name.Init Then
       --  dbms_output.put_line('-----------------------------------'); 
         dbms_output.put_line(rpad(r_object_name.objeto,45,' ')|| 
                              rpad( r_object_name.tablespace_name,20,' ')||
                              rpad(TO_CHAR(r_object_name.Init,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(USED_BYTES,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(UNUSED_BYTES,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(USED_BYTES,'999G999D99'),20,' '));
       End If;
--
    ELSE
      dbms_space.unused_space
        ( substr(r_object_name.objeto,1,instr(r_object_name.objeto,'.',1,1)-1) 
        , substr(r_object_name.objeto,instr(r_object_name.objeto,'.',1,1)+1)
        , r_object_name.SEGMENT_TYPE
        , TOTAL_BLOCKS
        , TOTAL_BYTES
        , UNUSED_BLOCKS
        , UNUSED_BYTES
        , LAST_USED_EXTENT_FILE_ID
        , LAST_USED_EXTENT_BLOCK_ID
        , LAST_USED_BLOCK
        , WRK_NOME_PARTICAO); 
      USED_BYTES    := (TOTAL_BYTES - UNUSED_BYTES)/1024/1024;
      TOTAL_BYTES   := TOTAL_BYTES/1024/1024;
      UNUSED_BYTES  := UNUSED_BYTES/1024/1024;
    
       If USED_BYTES < r_object_name.Init Then
         dbms_output.put_line(rpad( r_object_name.objeto,45,' ')|| 
                              rpad( r_object_name.tablespace_name,20,' ')||
                              rpad(TO_CHAR(r_object_name.Init,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(USED_BYTES,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(UNUSED_BYTES,'999G999D99'),20,' ')||
                              rpad(TO_CHAR(USED_BYTES,'999G999D99'),20,' '));
       End If;
    END IF;
--
  End Loop;
end;
/
