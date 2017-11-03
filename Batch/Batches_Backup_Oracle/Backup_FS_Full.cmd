setlocal
call set_date_time

set /A CONTA = 0

:BACKUP
set /A CONTA += 1

NTBACKUP.EXE backup "@%BK_Batches_Path%\Backup_Full.bks" /n "Fita_Full_%DTH%" /d "Fita_Full_%DTH%" /v:yes /r:no /rs:no /hc:on /m normal /j "Backup_Full_%DTH%" /l:f /p "%BK_Device_Backup%" /um
if errorlevel 1 (goto Errobackup)
goto EOJ

:Errobackup
if %CONTA% LSS 6 (
  net send %COMPUTERNAME% Erro Backup File System Full numero %errorlevel% - Nova Tentativa - %CONTA%
  goto BACKUP
)

:EOJ
endlocal


