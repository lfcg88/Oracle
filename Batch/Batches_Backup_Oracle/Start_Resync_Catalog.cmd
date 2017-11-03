setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
call set_date_time

:STARTBACKUP
call Resync_Catalog > %BK_Batches_Logs%\Resync_Catalog_%DTH%.log

:EOJ
endlocal