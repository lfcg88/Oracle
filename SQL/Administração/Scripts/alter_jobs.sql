SET FEEDBACK OFF
SET ECHO OFF
SET VERIFY OFF
SET HEAD OFF

ACCEPT BD CHAR PROMPT 'Digite o BANCO: '
@entra &BD manager
@./man/lista_jobs

ACCEPT 1 CHAR PROMPT 'Digite o n�mero do JOB a ser alterado: '
ACCEPT 2 CHAR PROMPT 'Digite o NOVO NEXT : '

spool priv_user.sql
SET FEEDBACK OFF
SET ECHO OFF
SET VERIFY OFF
SET HEAD OFF

SELECT 'SET HEAD OFF'||CHR(10)||'SET VERIFY OFF'||CHR(10)||'SET FEEDBACK OFF'||CHR(10)||'SET ECHO OFF'
FROM DUAL;

SELECT '@ENTRA '||'&BD '||PRIV_USER FROM DBA_JOBS WHERE JOB = &1;
SELECT 'SET ECHO ON' FROM DUAL;
SELECT 'EXEC DBMS_JOB.NEXT_DATE('||'&1'||','||'&2'||')' FROM DUAL;
SELECT 'SET ECHO OFF' FROM DUAL;
SELECT '@./man/LISTA_JOBS1.SQL '||'&1' FROM DUAL; 

spool off

@priv_user.sql


