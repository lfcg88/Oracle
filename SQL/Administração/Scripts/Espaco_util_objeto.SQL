Prompt #############################################################
Prompt #                                                           #
Prompt #        Verifica o total de espaço alocado pelo Objeto,    #
Prompt #        o espaço livre  e o espaço realmente utilizado     #
Prompt #        por este objeto. Mostra ainda informações sobre    #
Prompt #        seus blocos.                                       #
Prompt #                                                           #
Prompt #############################################################

SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
set verify off

Accept wrk_nome_objeto prompt 'Digite o Owner.Nome do Objeto: '
Prompt Escolha entre os seguintes Tipos de Objetos: 
Prompt TABLE - INDEX - TABLE PARTITION - INDEX PARTITION - TABLE SUBPARTITION - INDEX SUBPARTITION
Accept Tipo_objeto prompt 'Digite o Tipo do Objeto: '
Accept Nome_partição prompt 'Digite o nome da particao, ou deixe null :'

declare 
  wrk_nome_obj        VARCHAR2(100) := UPPER('&wrk_nome_objeto');
  WRK_TIPO_OBJETO   VARCHAR2(100) := UPPER('&Tipo_objeto');
  WRK_NOME_PARTICAO VARCHAR2(100) := UPPER('&Nome_partição');
  TOTAL_BLOCKS number; 
  TOTAL_BYTES number; 
  UNUSED_BLOCKS number; 
  UNUSED_BYTES number; 
  USED_BYTES number;
  LAST_USED_EXTENT_FILE_ID number; 
  LAST_USED_EXTENT_BLOCK_ID number; 
  LAST_USED_BLOCK number; 

begin 
  IF WRK_NOME_PARTICAO IS NULL THEN
    dbms_space.unused_space
      ( substr(wrk_nome_obj,1,instr(wrk_nome_obj,'.',1,1)-1) 
      , substr(wrk_nome_obj,instr(wrk_nome_obj,'.',1,1)+1)
      , WRK_TIPO_OBJETO
      , TOTAL_BLOCKS
      , TOTAL_BYTES
      , UNUSED_BLOCKS
      , UNUSED_BYTES
      , LAST_USED_EXTENT_FILE_ID
      , LAST_USED_EXTENT_BLOCK_ID
      , LAST_USED_BLOCK); 
    dbms_output.put_line('OBJECT_NAME               = '||wrk_nome_obj); 
  ELSE
    dbms_space.unused_space
      ( substr(wrk_nome_obj,1,instr(wrk_nome_obj,'.',1,1)-1) 
      , substr(wrk_nome_obj,instr(wrk_nome_obj,'.',1,1)+1)
      , WRK_TIPO_OBJETO
      , TOTAL_BLOCKS
      , TOTAL_BYTES
      , UNUSED_BLOCKS
      , UNUSED_BYTES
      , LAST_USED_EXTENT_FILE_ID
      , LAST_USED_EXTENT_BLOCK_ID
      , LAST_USED_BLOCK
      , WRK_NOME_PARTICAO); 
    dbms_output.put_line('OBJECT_NAME               = '||wrk_nome_obj); 
  END IF;

  USED_BYTES    := (TOTAL_BYTES - UNUSED_BYTES)/1024/1024;
  TOTAL_BYTES   := TOTAL_BYTES/1024/1024;
  UNUSED_BYTES  := UNUSED_BYTES/1024/1024;

  dbms_output.put_line('-----------------------------------'); 
  dbms_output.put_line('FREE BYTES                = '||TO_CHAR(UNUSED_BYTES,'999G999D99')||' MB'); 
  dbms_output.put_line('USED BYTES                = '||TO_CHAR(USED_BYTES,'999G999D99')||' MB'); 
  dbms_output.put_line('TOTAL BYTES               = '||TO_CHAR(TOTAL_BYTES,'999G999D99')||' MB'); 
  dbms_output.put_line('TOTAL BLOCKS              = '||TO_CHAR(TOTAL_BLOCKS,'999G999G999')); 
  dbms_output.put_line('UNUSED BLOCKS             = '||TO_CHAR(UNUSED_BLOCKS,'999G999G999')); 
  dbms_output.put_line('LAST_USED_EXTENT_FILE_ID  = '||TO_CHAR(LAST_USED_EXTENT_FILE_ID,'999G999G999')); 
  dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||TO_CHAR(LAST_USED_EXTENT_BLOCK_ID,'999G999G999')); 
  dbms_output.put_line('LAST_USED_BLOCK           = '||TO_CHAR(LAST_USED_BLOCK,'999G999G999')); 
end;
/

SET FEEDBACK ON
set verify oN
