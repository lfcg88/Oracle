setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%

if /I %1==F (Echo RMAN Full) else (if /I %1==I (Echo RMAN Incremental) else (GOTO INVPARM))
if /I %2==T (Echo RMAN Tape) else (if /I %2==D (Echo RMAN Disk) else (GOTO INVPARM))
if /I %1==F (
  set D=D0
  set L=L0
  if /I %2==D (set msg=Backup RMAN Disk Full) else (set msg=Backup RMAN Tape Full)
            ) else (
  set D=D1
  set L=L1
  if /I %2==D (set msg=Backup RMAN Disk Incremental) else (set msg=Backup RMAN Tape Incremental)
                   )
net send %COMPUTERNAME% %msg% Iniciado

call set_date_time

:PARM
echo connect target /@%3 > backup.rman
echo connect rcvcat rman/senharman@rcvcat >> backup.rman
echo # retira archivelogs deletados do catalogo >> backup.rman
echo change archivelog all crosscheck; >> backup.rman
echo run >> backup.rman
echo { >> backup.rman
if /I %2==T goto T_Alloc
echo   allocate channel ch1 type DISK format '%BK_Oracle_Backup%\%3\%D%_%%d_%%s_%%p_%DTH%.BAK'; >> backup.rman
echo   allocate channel ch2 type DISK format '%BK_Oracle_Backup2%\%3\%D%_%%d_%%s_%%p_%DTH%.BAK'; >> backup.rman
goto Backup_DB

:T_Alloc
echo   allocate channel ch1 type 'SBT_TAPE' parms 'ENV=(NSR_GROUP=Default)'; >> backup.rman

 
:Backup_DB
echo   backup incremental >> backup.rman
if /I %1==F (echo     level 0 >> backup.rman) else (echo     level 1 >> backup.rman)
echo     cumulative >> backup.rman
if /I %1==F (echo     TAG "%DTH%" >> backup.rman) else (echo     TAG "%DTH%" >> backup.rman)
if /I %2==T (echo     (database  setsize %BK_RMAN_Setsize_Fita% include current controlfile >> backup.rman) else (echo     (database  setsize %BK_RMAN_Setsize_Disco% include current controlfile >> backup.rman)
rem echo      skip readonly >> backup.rman
if /I %2==T (echo     format 'ORA\%D%_%%d_%%s_%%p_%DTH%'>> backup.rman) 
echo     ) >> backup.rman
if /I %2==T (echo     (spfile channel ch1 >> backup.rman) else (echo     (spfile >> backup.rman)
if /I %2==T (echo     format 'ORA\SP_%%d_%%s_%%p_%DTH%'>> backup.rman) 
echo     ); >> backup.rman

echo   # arquiva log corrente >> backup.rman
echo   sql 'alter system archive log current'; >> backup.rman
if /I %2==D (
  echo   release channel ch1; >> backup.rman
  echo   release channel ch2; >> backup.rman
  echo   allocate channel ch1 type DISK format '%BK_Oracle_Backup%\%3\%L%_%%d_%%s_%%p_%DTH%.BAK'; >> backup.rman
  echo   allocate channel ch2 type DISK format '%BK_Oracle_Backup2%\%3\%L%_%%d_%%s_%%p_%DTH%.BAK'; >> backup.rman
            )
echo   backup >> backup.rman
echo     (archivelog all setsize 3145728 >> backup.rman
if /I %2==T (echo     format 'ORA\%L%_%%d_%%s_%%p_%DTH%'>> backup.rman) 
echo     ); >> backup.rman
echo   release channel ch1; >> backup.rman
if /I %2==D (
  echo   release channel ch2; >> backup.rman
	    )
echo } >> backup.rman

set /A CONTA = 0

:RMAN
set /A CONTA += 1
rem formata a fita
if /I %2==T (call format_tape)
rman cmdfile=backup.rman
if errorlevel 1 (goto ERRRMAN)
goto Zipa

:ERRRMAN
if %CONTA% LSS 6 (
  echo Erro RMAN numero %errorlevel% - Nova Tentativa - %CONTA%
  net send %COMPUTERNAME% Erro RMAN numero %errorlevel% - Nova Tentativa - %CONTA%
  goto RMAN
)
echo Erro RMAN numero %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
net send %COMPUTERNAME% Erro RMAN numero %errorlevel% - Numero maximo de tentativas esgotado (%CONTA%) - Aborta operacao
exit

:ZIPA
if %BK_RMAN_Comprime%==0 goto EOJRMAN
rem Comprime e remove os arquivos .bak
for %%f in (%BK_Oracle_Backup%\%3\*.bak) do call Zipa %%f
goto EOJRMAN

:INVPARM
echo RMAn Parametro invalido %1
net send %COMPUTERNAME% RMAN Parametro invalido - %1 %2 (validos F/I T/D)

:EOJRMAN
NET SEND %COMPUTERNAME% %msg% terminado
endlocal