Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #      Identifica/ Coloca/ Tira Job em Broken               #
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
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
--
select 'Prompt Job: '||job||' Owner: '||log_user||' Last_Date: '||to_char(Last_date,'dd/mm/yy hh24:mi')||chr(10)||
       'Prompt Interval: '||interval||' Total_time: '||trunc(total_time)||chr(10)||
       'BEGIN'||chr(10)||
       '  SYS.DBMS_IJOB.BROKEN('''||job||''',FALSE);'||chr(10)||
       'END;'||chr(10)||
       '/' ||chr(10)||
       'Commit;'||chr(10) "--comando"
  from dba_jobs
 where broken = 'Y'
   and last_date > sysdate - 20;
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
