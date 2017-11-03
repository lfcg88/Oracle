set ORACLE_SCRIPTS=D:\oracle\scripts
set ORACLE_SID=iasdb
REM INICIANDO OID
set ORACLE_HOME=D:\oracle\infra902
REM INICIA o servico oidmon de monitoracao
call %ORACLE_HOME%\bin\oidmon start
call %ORACLE_SCRIPTS%\sleep40.bat
REM INICIA o servico oidldap
call %ORACLE_HOME%\bin\oidctl server=oidldapd instance=1 start
call %ORACLE_SCRIPTS%\sleep40.bat
REM INICIANDO INFRA
set ORACLE_HOME=D:\oracle\infra902
call %ORACLE_HOME%\opmn\bin\opmnctl start
call %ORACLE_HOME%\dcm\bin\dcmctl start -d -v
REM call %ORACLE_HOME%\dcm\bin\dcmctl getstate -v
REM INICIANDO MIDDLE
set ORACLE_HOME=D:\oracle\middle902
call %ORACLE_HOME%\opmn\bin\opmnctl start
call %ORACLE_HOME%\dcm\bin\dcmctl start -d -v
REM call %ORACLE_HOME%\dcm\bin\dcmctl getstate -v
call %ORACLE_HOME%\bin\webcachemon start
call %ORACLE_HOME%\bin\webcachectl start
call %ORACLE_SCRIPTS%\sleep40.bat


