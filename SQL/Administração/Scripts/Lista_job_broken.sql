Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #             Verifica Jobs em Broken                       #
Prompt -- #                                                           #
Prompt -- #############################################################
--
set trimspool on
set verify off
set lines 200
set feed off
set pages 100
set heading oN
col job format 9999999
col SCHEMA_USER format a12 heading "Job Owner"
col WHAT  format a60 
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
--
Select JOB "Job"
     , SCHEMA_USER
     , substr(WHAT, 1,100) "What"
     , LAST_DATE "Última Exec."
     , NEXT_DATE "Prox. Exec."
 From DBA_JOBS
where broken = 'Y';
--
Prompt .
set feedback on
set heading on
set verify on
set feedback oN
set heading oN
set verify oN
set lines 100
set pages 100
set linesize 150
