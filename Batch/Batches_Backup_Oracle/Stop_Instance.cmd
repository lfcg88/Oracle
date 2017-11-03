@echo off
setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

:stop_Instance

if %BK_Cluster%==0 (net stop  OracleService%1) else (call offline_resource %1)


:TESTA
Call Grava_Arquivo %1

if exist %BK_Oracle_UTL_FILE_DIR%\teste.%1.dummy (
  net send %COMPUTERNAME% Database %1 nao pode ser parado 
  goto EOJ
)

net send %COMPUTERNAME% Database %1 esta OFFLINE

:EOJ
endlocal