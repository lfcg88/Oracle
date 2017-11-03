setlocal
call %BK_Batches_Path%\set_date_time

set dir=%BK_Oracle_Export%\%1

set /A CONTA = 0
:LOOP_MONTA_STR
set /A CONTA += 1
IF %CONTA% GTR %BK_Export_Max_Files% GOTO EXP
if %CONTA% LSS 10 (set CONTAA=0%CONTA%) else (set CONTAA=%CONTA%)
if %CONTA%==1 (set LISTAFILE=%dir%\exp_%1_%DTH%_%CONTAA%.dmp) else (set LISTAFILE=%LISTAFILE%,%dir%\exp_%1_%DTH%_%CONTAA%.dmp)
goto LOOP_MONTA_STR

:EXP
exp backup/senhabackup@%1 full=yes file=(%LISTAFILE%) log=%dir%\exp_%1_%DTH%.log consistent=%BK_Export_Consistent% filesize=%BK_Tamanho_Arquivo_Export% statistics=none
if errorlevel 1 (
  net send %COMPUTERNAME% Erro no export de %1 - %errorlevel%
)

if %BK_Comprime_Export%==0 goto EOJEXP

set path=%path%;%BK_Winzip_Path%

set /A CONTA = 0

:LOOPZIP
set /A CONTA += 1
if %CONTA% LSS 10 (set CONTAA=0%CONTA%) else (set CONTAA=%CONTA%)
if not exist %dir%\exp_%1_%DTH%_%CONTAA%.dmp goto EOJEXP

rem Comprime e remove os arquivos .dmp e .log
wzzip -a -ex -m %dir%\exp_%1_%DTH%_%CONTAA%.ZIP %dir%\exp_%1_%DTH%_%CONTAA%.dmp %dir%\exp_%1_%DTH%.log 
if errorlevel 1 (
  net send %COMPUTERNAME% Erro no zip de %1 - %errorlevel%
)
goto LOOPZIP

:EOJEXP
endlocal