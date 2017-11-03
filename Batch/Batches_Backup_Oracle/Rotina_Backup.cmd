prompt $d_$t$g
setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

if /I %1==F (Echo Backup Full) else (if /I %1==I (Echo Backup Incremental) else (goto INVPARM))
if /I %2==T (Echo RMAN Tape) else (if /I %2==D (Echo RMAN Disk) else (GOTO INVPARM))
if /I %1==F (
  if /I %2==D (set msg=Rotina de Backup Disk Full) else (set msg=Rotina de Backup Tape Full)
            ) else (
  if /I %2==D (set msg=Rotina de Backup Disk Incremental) else (set msg=Rotina de Backup Tape Incremental)
                   )
net send %COMPUTERNAME% %msg% Iniciada

:VERIF_CLUSTER
if %BK_Cluster%==1 (call MOVE_GROUP)

:TESTA_CONEXAO
call Testa_Conexao_DB RCVCAT
call Testa_Conexao_DB MIAFISDS

:REGBACK
call Backup_Registry

:DELOLD
call Delete_Old

:BACKUPCF
call backup_cf MIAFISDS

:STATUS_TS
call status_TS

:EXPORT_MIAFIS
call exp_DB MIAFISDS
call exp_DB MIAFISHM
CALL exp_DB GENERICO


:RMAN
if /I %2==T (if %BK_RMAN_Com_NTBACKUP%==1 (call Backup_rman %1 D MIAFISDS) else (call Backup_rman %1 %2 MIAFISDS)) else (call Backup_rman %1 %2 MIAFISDS)

:EXPORT_RCVCAT
call exp_DB RCVCAT

:EXPORT_MIAFISHM
rem call exp_DB MIAFISHM


:BOOTSTRAP
rem call bootstrap

:FITA
if %2==T (if %BK_RMAN_Com_NTBACKUP%==1 (goto NTBACKUP) else (goto SAVEGRP)) else (goto EOJBACKUP)

:NTBACKUP
call Backup_FS_Parcial
goto CLONE

:SAVEGRP
call savegroup %1

:CLONE
if %BK_Clone%==0 (goto ENDCLONE)
wait 45
if %BK_Clone%==1 (call clone_Tape 0)
if %BK_Clone%==2 (call clone_Tape 1)

:ENDCLONE
goto EOJBACKUP

:INVPARM
echo Parametro invalido %1
net send %COMPUTERNAME% Rotina de Backup com Parametro invalido - %1 %2 (I/F T/D)

:EOJBACKUP
net send %COMPUTERNAME% %msg% finalizada
endlocal