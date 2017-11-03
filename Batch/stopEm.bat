set ORACLE_SCRIPTS=D:\oracle\scripts
set ORACLE_SID=iasdb
set EM_ADMIN_PWD=pvacan00
REM INICIANDO Enterprise Web Site
call %ORACLE_SCRIPTS%\sleep40.bat
set ORACLE_HOME=D:\oracle\infra902
REM INICIA execucao
call %ORACLE_HOME%\bin\emctl stop
call %ORACLE_SCRIPTS%\sleep40.bat



