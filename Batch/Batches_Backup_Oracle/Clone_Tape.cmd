SETLOCAL
if %1==0 (net send %COMPUTERNAME% Inciando CLONE 0 para 1) else (if %1==1 (net send %COMPUTERNAME% Inciando CLONE 1 para 0) else (goto INVPARM))

%BK_Batches_Drive%
cd %BK_Batches_Dir%
PATH=%PATH%;%BK_Tapecopy_Path%
set /A conta = 0

:CLONE
set /A CONTA += 1

if %1==0 (tcpro clone_0_1.cpy) else (tcpro clone_1_0.cpy)
if errorlevel 1 goto ERRCLONE
goto EOJCLONE


:ERRCLONE
if %CONTA% LSS 6 (
  echo Erro Clone - Erro numero %errorlevel% - Nova Tentativa - %CONTA%
  net send %COMPUTERNAME% Erro Clone - Erro numero %errorlevel% - Nova Tentativa - %CONTA%
  goto CLONE
)

echo Erro Clone - %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
net send %COMPUTERNAME% Erro Clone - %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
exit 

:INVPARM
net send %COMPUTERNAME% Erro Clone - Parametro Invalido - %1 - requerido 0 ou 1
exit

:EOJCLONE
net send %COMPUTERNAME% CLONE Terminado
ENDLOCAL