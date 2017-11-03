setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
sqlplus /nolog @Archive_log.sql

:EOJ
endlocal