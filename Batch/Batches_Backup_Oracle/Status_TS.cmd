setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

call concat_status_TS
sqlplus /nolog @Status_TS.sql

:EOJ
endlocal