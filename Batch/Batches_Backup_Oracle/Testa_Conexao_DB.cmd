setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
set /A conta = 0

:TESTA
set /A CONTA += 1

call Grava_Arquivo %1

if not exist %BK_Oracle_UTL_FILE_DIR%\teste.%1.dummy goto start_Instance
del %BK_Oracle_UTL_FILE_DIR%\teste.%1.dummy 
rem net send %COMPUTERNAME% Database %1 esta online
goto EOJ


:start_Instance
rem para funcionar net start e stop é preciso grant de power user ou server operator no mínimo
if %CONTA% GTR 2 (
  net send %COMPUTERNAME% Erro - Database %1 não fica ONLINE - Final de backup - Verifique arquivo de Alerta
  exit
)
if %BK_Cluster% == 0 (net stop  OracleService%1) else (call offline_resource %1)
if %BK_Cluster% == 0 (net start OracleService%1) else (call online_resource %1)
goto TESTA

:EOJ
endlocal