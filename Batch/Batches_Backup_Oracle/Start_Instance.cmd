@echo off
setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
set /A conta = 0

:start_DB
set /A CONTA += 1
if %CONTA% GTR 2 (
  net send %COMPUTERNAME% Erro - Database %1 nao fica ONLINE apos 2 tentativas - Verifique arquivo de Alerta
  goto eoj
)
if %BK_Cluster%==0 (net start OracleService%1) else (call online_resource %1)


:TESTA
call Grava_Arquivo %1

if not exist %BK_Oracle_UTL_FILE_DIR%\teste.%1.dummy (
  net stop OracleService%1
  goto start_DB
)

net send %COMPUTERNAME% Database %1 esta ONLINE

:EOJ
endlocal