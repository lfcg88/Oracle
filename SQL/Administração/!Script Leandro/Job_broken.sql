Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #             Coloca/ Tira Job em Broken                    #
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
Accept wrk_nu_job    prompt "-- Digite o numero do Job: "
Accept wrk_hab_desab prompt "-- Digite TRUE para colocar em Broken e FALSE para tirar: "
--
Declare
  Pragma AUTONOMOUS_TRANSACTION;
Begin
  SYS.DBMS_JOB.BROKEN('&&wrk_nu_job',&&wrk_hab_desab);
  Commit;
End;
/
--
set feedback off
set heading on
col job format 9999999
col SCHEMA_USER format a12 heading "Job Owner"
col WHAT  format a60 
col broken  format a7
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
--
Select JOB "Job"
     , SCHEMA_USER
     , substr(WHAT, 1,100) "What"
     , LAST_DATE "Última Exec."
     , NEXT_DATE "Prox. Exec."
     , broken    "Broken?"
 From DBA_JOBS
where job = &&wrk_nu_job;
--
Prompt .
undefine wrk_nu_job
undefine wrk_hab_desab
set feedback on
set heading on
set verify on
set feedback oN
set heading oN
set verify oN
set lines 100
set pages 100
set linesize 150
