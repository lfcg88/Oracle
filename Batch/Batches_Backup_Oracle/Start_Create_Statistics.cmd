setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
call set_date_time

:STARTBACKUP
call Create_STatistics > %BK_Batches_Logs%\Create_Statistics_%DTH%.log

:EOJ
endlocal