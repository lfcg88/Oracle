@echo off
setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

:mainmenu
TITLE Menu de Operacao - MIAFIS
cls
choice /c:12345F 1-Intancia MIAFIS, 2-Instancia Catalogo, 3-Backup, 4-Clone, 5-Volumes, F-Fim - 
IF errorlevel 255 goto fim
if errorlevel 6 goto eoj
if errorlevel 5 goto Mostra_volumes
if errorlevel 4 goto clonetape
if errorlevel 3 goto Backup
if errorlevel 2 goto RCVCAT
if errorlevel 1 goto MIAFIS
if errorlevel 0 goto fim

:Mostra_Volumes
Call Mostra_Volumes
pause
goto mainmenu

:clonetape
TITLE Menu de Opcoes - Clonagem de fita
cls
choice /c:12FR 1-Clone Unidade 0 para 1, 2-Clone Unidade 1 para 0, F- Fim, R-Retorna ao menu principal - 
IF errorlevel 255 goto fim
if errorlevel 4 goto mainmenu
if errorlevel 3 goto eoj
if errorlevel 2 goto Clone_1_0
if errorlevel 1 goto Clone_0_1
if errorlevel 0 goto EOJ

:Clone_0_1
Call Clone_Tape 0
pause
goto CloneTape

:Clone_1_0
Call Clone_Tape 1
pause
goto CloneTape

:MIAFIS
TITLE Menu de Opcoes - Instancia MIAFIS
cls
choice /c:12FR 1-Startup MIAFIS, 2-Shutdown MIAFIS, F- Fim, R-Retorna ao menu principal - 
IF errorlevel 255 goto fim
if errorlevel 4 goto mainmenu
if errorlevel 3 goto eoj
if errorlevel 2 goto ShutMIAFIS
if errorlevel 1 goto StartMIAFIS
if errorlevel 0 goto EOJ

:StartMIAFIS
Call Start_Instance MIAFIS
pause
goto MIAFIS

:ShutMIAFIS
Call Stop_Instance MIAFIS
pause
goto MIAFIS

:RCVCAT
TITLE Menu de Opcoes - Instancia Catalogo
cls
choice /c:12FR 1-Startup Catalogo, 2-Shutdown Catalogo, F- Fim, R-Retorna ao menu principal - 
IF errorlevel 255 goto fim
if errorlevel 4 goto mainmenu
if errorlevel 3 goto eoj
if errorlevel 2 goto ShutRCVCAT
if errorlevel 1 goto StartRCVCAT
if errorlevel 0 goto fim

:StartRCVCAT
Call Start_Instance RCVCAT
pause
goto RCVCAT

:ShutRCVCAT
Call Stop_Instance RCVCAT
pause
goto RCVCAT

:Backup
TITLE  Menu de Opcoes - Backup
cls
choice /c:12FR 1-Backup Tape, 2-Backup Disk, F-Fim, R-Retorna - 
IF errorlevel 255 goto fim
if errorlevel 4 goto mainmenu
if errorlevel 3 goto eoj
if errorlevel 2 goto Backup_Disk
if errorlevel 1 goto Backup_Tape
if errorlevel 0 goto fim

:Backup_Disk
TITLE  Menu de Opcoes - Backup Disk
cls
choice /c:12FR 1-Backup Full Disk, 2-Backup Incremental Disk, F-Fim, R-Retorna - 
IF errorlevel 255 goto fim
if errorlevel 4 goto Backup
if errorlevel 3 goto eoj
if errorlevel 2 goto BackupInc_Disk
if errorlevel 1 goto BackupFull_Disk
if errorlevel 0 goto fim

:BackupInc_Disk
Call Start_Backup I D
pause
goto Backup_Disk

:BackupFull_Disk
Call Start_Backup F D
pause
goto Backup_Disk


:Backup_Tape
TITLE  Menu de Opcoes - Backup Tape
cls
choice /c:1234FR 1-Backup Full, 2-Backup Incremental, 3-Backup FS Full, 4- Backup FS Parcial, F-Fim, R-Retorna - 
IF errorlevel 255 goto fim
if errorlevel 6 goto backup
if errorlevel 5 goto eoj
if errorlevel 4 goto BackupFSParcial
if errorlevel 3 goto BackupFSFull
if errorlevel 2 goto BackupInc_tape
if errorlevel 1 goto BackupFull_Tape
if errorlevel 0 goto fim

:BackupFSFull
Call Backup_FS_Full
pause
goto Backup_Tape

:BackupFSParcial
Call Backup_FS_Parcial
pause
goto Backup_Tape

:BackupInc_Tape
Call Start_Backup I T
pause
goto Backup_Tape

:BackupFull_Tape
Call Start_Backup F T
pause
goto Backup_Tape

:EOJ
echo Fim do menu - tecle algo para sair
pause
endlocal