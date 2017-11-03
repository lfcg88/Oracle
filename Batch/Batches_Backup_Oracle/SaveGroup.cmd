setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
if /I %1==F (goto FULL) else (if /I %1==I (goto INCR) else (GOTO INVPARM))

set /A CONTA = 0

:FULL
net send %COMPUTERNAME% Backup de Filesystem Full Iniciado
goto SAVEGRP

:INCR
net send %COMPUTERNAME% Backup de Filesystem Incremental Iniciado

:SAVEGRP
set /A CONTA += 1
if /I %1==I goto SAVEGRPINC

:SAVEGRPFULL
savegrp -l full -G Default
rem savegrp -l full -v -G Default
goto SAVEGRPTESTA

:SAVEGRPINC
savegrp -l 1 -G Default
rem savegrp -l 1 -N 1 -G Default

:SAVEGRPTESTA
if errorlevel 1 (goto ERRSAVEGRP)
Echo Backup de Filesystem Terminado
net send %COMPUTERNAME% Backup de Filesystem Terminado
goto EOJSAVEGRP

:ERRSAVEGRP
if %CONTA% LSS 6 (
  echo Erro Backup de Filesystem - numero %errorlevel% - Nova Tentativa - %CONTA%
  net send %COMPUTERNAME% Erro Backup de Filesystem - numero %errorlevel% - Nova Tentativa - %CONTA%
  goto SAVEGRP
)

echo Erro Backup de Filesystem numero %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
net send %COMPUTERNAME% Erro Backup de Filesystem numero %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
exit

:INVPARM
Echo Backup de Filesystem parametro invalido %1
net send %COMPUTERNAME% Backup de Filesystem parametro invalido %1

:EOJSAVEGRP
call Unmount_volume
endlocal