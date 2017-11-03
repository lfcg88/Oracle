setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

echo spool %BK_Batches_Logs%\Status_TS.txt > Status_TS_spool.sql
copy Status_TS_spool.sql+Status_TS_Orig.sql Status_TS.sql
del Status_TS_spool.sql
endlocal