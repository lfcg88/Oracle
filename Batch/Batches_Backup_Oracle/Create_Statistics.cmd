setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

sqlplus /nolog @Create_Statistics

endlocal