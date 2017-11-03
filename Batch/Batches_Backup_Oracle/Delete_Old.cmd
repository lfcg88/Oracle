setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

delold %BK_Oracle_Archive1%\*.arc %BK_Dias_Manutencao_Archive%
delold %BK_Oracle_Archive2%\*.arc %BK_Dias_Manutencao_Archive%
delold %BK_Oracle_backup%\MIAFIS\*.CTL %BK_Dias_Manutencao_Backup% 
delold %BK_Oracle_backup%\MIAFIS\*.BAK %BK_Dias_Manutencao_Backup% 
delold %BK_Oracle_backup%\MIAFIS\*.ZIP %BK_Dias_Manutencao_Backup% 
delold %BK_Batches_Logs%\tapecopy*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\resync_catalog*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\backup_cf*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\BackupTape*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\BackupDisk*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\Archive_Log*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\Create_Statistics*.* %BK_Dias_Manutencao_Log%
delold %BK_Batches_Logs%\Aloca_Partic_BDI_*.* %BK_Dias_Manutencao_Log%
delold %BK_Oracle_Admin%\miafis\udump\*.trc %BK_Dias_Manutencao_Backup%
if exist %BK_Oracle_Export%\MIAFIS\*.ZIP del %BK_Oracle_Export%\MIAFIS\*.ZIP 
if exist %BK_Oracle_Export%\MIAFIS\*.DMP del %BK_Oracle_Export%\MIAFIS\*.DMP
if exist %BK_Oracle_Export%\MIAFIS\*.LOG del %BK_Oracle_Export%\MIAFIS\*.LOG
if exist %BK_Oracle_Export%\RCVCAT\*.ZIP del %BK_Oracle_Export%\RCVCAT\*.ZIP 
if exist %BK_Oracle_Export%\RCVCAT\*.DMP del %BK_Oracle_Export%\RCVCAT\*.DMP
if exist %BK_Oracle_Export%\RCVCAT\*.LOG del %BK_Oracle_Export%\RCVCAT\*.LOG  

:EOJ
endlocal
