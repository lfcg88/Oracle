setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
call set_date_time

:STARTBACKUP
if /I %2==T (set Logfile=%BK_Batches_Logs%\BackupTape_%DTH%.log) else (set Logfile=%BK_Batches_Logs%\BackupDisk_%DTH%.log)

call Rotina_Backup %1 %2 > %Logfile%
          									    )
:EOJ
endlocal