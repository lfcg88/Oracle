set ORACLE_SCRIPTS=D:\oracle\scripts
set ORACLE_SID=iasdb
REM TIRANDO MIDDLE
set ORACLE_HOME=D:\oracle\middle902
call %ORACLE_HOME%\dcm\bin\dcmctl getstate -v
call %ORACLE_HOME%\dcm\bin\dcmctl stop -d -v
call %ORACLE_HOME%\bin\webcachemon stop
call %ORACLE_HOME%\bin\webcachectl stop
call %ORACLE_HOME%\opmn\bin\opmnctl stopall
REM TIRANDO INFRA
set ORACLE_HOME=D:\oracle\infra902
call %ORACLE_HOME%\dcm\bin\dcmctl getstate -v
call %ORACLE_HOME%\dcm\bin\dcmctl stop -d -v
call %ORACLE_HOME%\opmn\bin\opmnctl stopall
REM TIRANDO OID
set ORACLE_HOME=D:\oracle\infra902
call %ORACLE_SCRIPTS%\sleep40.bat
REM Tira o servico oidldap
call %ORACLE_HOME%\bin\oidctl server=oidldapd instance=1 stop
call %ORACLE_SCRIPTS%\sleep40.bat
REM Tira o servico oidmon de monitoracao
call %ORACLE_HOME%\bin\oidmon stop
call %ORACLE_SCRIPTS%\sleep40.bat
