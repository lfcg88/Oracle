setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

If exist %BK_Oracle_UTL_FILE_DIR%\Teste.%1.DUMMY del %BK_Oracle_UTL_FILE_DIR%\Teste.%1.DUMMY

echo conn /@%1 as sysoper > grava_arquivo_%1.sql
echo declare >> grava_arquivo_%1.sql
echo   saida utl_file.file_type; >> grava_arquivo_%1.sql
echo   linha  varchar(50); >> grava_arquivo_%1.sql
echo begin >> grava_arquivo_%1.sql
echo   saida:= UTL_FILE.FOPEN ('%BK_Oracle_UTL_FILE_DIR%','Teste.%1.DUMMY','W'); >> grava_arquivo_%1.sql
echo   UTL_FILE.PUT_LINE (SAIDA,'Teste Gravação'); >> grava_arquivo_%1.sql
echo   UTL_FILE.FFLUSH(SAIDA); >> grava_arquivo_%1.sql
echo   UTL_FILE.FCLOSE(SAIDA); >> grava_arquivo_%1.sql
echo EXCEPTION >> grava_arquivo_%1.sql
echo   when UTL_FILE.INVALID_PATH THEN >> grava_arquivo_%1.sql
echo     RAISE_APPLICATION_ERROR (-20000,'Caminho Invalido'); >> grava_arquivo_%1.sql
echo   when UTL_FILE.INVALID_MODE THEN >> grava_arquivo_%1.sql
echo     RAISE_APPLICATION_ERROR (-20001,'Modo de uso invalido'); >> grava_arquivo_%1.sql
echo   when UTL_FILE.INVALID_OPERATION THEN >> grava_arquivo_%1.sql
echo     RAISE_APPLICATION_ERROR (-20002,'Operacao incompátivel'); >> grava_arquivo_%1.sql
echo END; >> grava_arquivo_%1.sql
echo / >> grava_arquivo_%1.sql
echo quit; >> grava_arquivo_%1.sql

sqlplus /nolog @grava_arquivo_%1.sql
endlocal