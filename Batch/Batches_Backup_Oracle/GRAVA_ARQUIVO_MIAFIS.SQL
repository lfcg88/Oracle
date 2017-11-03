conn /@MIAFIS as sysoper 
declare 
  saida utl_file.file_type; 
  linha  varchar(50); 
begin 
  saida:= UTL_FILE.FOPEN ('d:\oracle\file','Teste.MIAFIS.DUMMY','W'); 
  UTL_FILE.PUT_LINE (SAIDA,'Teste Gravação'); 
  UTL_FILE.FFLUSH(SAIDA); 
  UTL_FILE.FCLOSE(SAIDA); 
EXCEPTION 
  when UTL_FILE.INVALID_PATH THEN 
    RAISE_APPLICATION_ERROR (-20000,'Caminho Invalido'); 
  when UTL_FILE.INVALID_MODE THEN 
    RAISE_APPLICATION_ERROR (-20001,'Modo de uso invalido'); 
  when UTL_FILE.INVALID_OPERATION THEN 
    RAISE_APPLICATION_ERROR (-20002,'Operacao incompátivel'); 
END; 
/ 
quit; 
