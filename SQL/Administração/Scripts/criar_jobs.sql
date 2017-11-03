Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #                        Cria Job	                      #
Prompt -- #                                                           #
Prompt -- #############################################################
--
set trimspool on
--set feedback off
set heading off
set verify off
set lines 32767
set pages 100
--
Accept BD 	prompt "-- Digite o BANCO : "
Accept 1 	prompt "-- Digite o owner do job : "
Accept 2 	prompt "-- Digite o nome do objeto chamado pelo job : "
Accept 3 	prompt "-- Digite o a data de inicio do job (ex: sysdate): "
Accept 4 	prompt "-- Digite o next do job (ex: trunc(sysdate+1)+08/24 ): "
--

SPOOL CRIANDO_JOB.SQL


SELECT 
'VARIABLE jobno number; 	'||CHR(10)||
'BEGIN				'||CHR(10)||
'   DBMS_JOB.SUBMIT		'||CHR(10)||
' (:jobno, 			'||CHR(10)||
'        ''&&1'||'.'||'&&2;'',	'||CHR(10)||
'  	 &&3, 			'||CHR(10)||
' 	''&&4'');		'||CHR(10)||
'   commit;			'||CHR(10)||
'END;				'||CHR(10)||
'/				'||CHR(10)
FROM DUAL;

--

SELECT
'set feedback off						'||CHR(10)||
'set verify OFF							'||CHR(10)||
'set ECHO OFF							'||CHR(10)||
'set heading on							'||CHR(10)||
'col job format 9999999						'||CHR(10)||	
'col SCHEMA_USER format a12 heading "Job Owner"			'||CHR(10)||
'col WHAT  format a60 						'||CHR(10)||
'col broken  format a7						'||CHR(10)||
'alter session set nls_date_format=''dd/mm/yyyy hh24:mi:ss'';	'||CHR(10)||
'--								'||CHR(10)||
'Select JOB "Job"						'||CHR(10)||
'     , SCHEMA_USER						'||CHR(10)||
'     , substr(WHAT, 1,100) "What"				'||CHR(10)||
'     , LAST_DATE "Última Exec."				'||CHR(10)||
'     , NEXT_DATE "Prox. Exec."					'||CHR(10)||
'     , broken    "Broken?"					'||CHR(10)||
' From DBA_JOBS							'||CHR(10)||
'where upper(what) like upper(''%&&2%'');			'||CHR(10)
from dual;


SPOOL OFF

@entra2 &BD &1
@CRIANDO_JOB.SQL
