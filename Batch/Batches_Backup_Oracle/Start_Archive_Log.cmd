setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
call set_date_time

:Start_Archive
call Archive_log > %BK_Batches_Logs%\Archive_log_%DTH%.log

:EOJ
endlocal