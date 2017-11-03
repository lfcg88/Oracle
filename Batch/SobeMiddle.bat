Rem - PROCEDIMENTO PARA SUBIR TODOS OS SERVICOS E INSTANCIAS ORACLE

rem ==============================================

set ORACLE_SCRIPTS=D:\oracle\scripts
set ORACLE_SID=iasdb
REM INICIANDO MIDDLE
set ORACLE_HOME=D:\oracle\middle903
call %ORACLE_HOME%\opmn\bin\opmnctl stop
call %ORACLE_SCRIPTS%\sleep40.bat
call %ORACLE_HOME%\dcm\bin\dcmctl stop -co home -v
call %ORACLE_SCRIPTS%\sleep40.bat
call %ORACLE_HOME%\dcm\bin\dcmctl stop -co OC4J_Demos -v
call %ORACLE_SCRIPTS%\sleep40.bat
call %ORACLE_HOME%\dcm\bin\dcmctl stop -v
call %ORACLE_SCRIPTS%\sleep40.bat
call %ORACLE_HOME%\bin\webcachemon stop
call %ORACLE_SCRIPTS%\sleep40.bat
call %ORACLE_HOME%\bin\webcachectl stop
call %ORACLE_SCRIPTS%\sleep40.bat

rem ==============================================

