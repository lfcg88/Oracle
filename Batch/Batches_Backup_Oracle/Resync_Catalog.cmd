setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

rman cmdfile=Resync_Catalog.rman
if errorlevel 1 (goto ERRRESYNC)
goto EOJ

:ERRRESYNC
NET SEND %COMPUTERNAME% Erro resync - %errorlevel%

:EOJ
endlocal