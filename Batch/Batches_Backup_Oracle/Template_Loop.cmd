SETLOCAL

set /A CONTA = 0
:CLONE
set /A CONTA += 1

:ERRCLONE
echo %CONTA%
if %CONTA% LEQ 5 (
   echo Erro Clone - %errorlevel% - Nova Tentativa - %CONTA%
   goto CLONE
)

:EOJCLONE
net send %COMPUTERNAME% CLONE OK !!!
ENDLOCAL