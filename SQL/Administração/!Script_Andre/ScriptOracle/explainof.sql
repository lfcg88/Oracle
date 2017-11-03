
==============================
maneira legao no 9i para ciam
===============================

EXPLAIN PLAN
SET statement_id = 'JM' FOR
  SELECT INDIC_ACAO_BILHETE,       NOME_TAREFA,
    NOMEFANT_CLASS_CONTA,       '',       TO_CHAR(READY_TIME,'DD/MM/YYYY'),
    DATA_PREV_ATIV,       DATA_PREV_TERM,       JOB_NAME,       ORIGEM_TOPOL,
    COD_CONTRATO_PTA,       DESTINO_TOPOL,       COD_CONTRATO_PTA,
    CONTRATO,       TASK_ID,       JOB_ID,
    DATA_INI_TEMP,       DATA_FIM_TEMP,       IDENTIFICADOR,
    TIPO_IMPLEMENT,       SIGLA_LOCD,       DESIG_CVP,
    PROCESSO,        TO_CHAR(DATA_ATIVACAO_TEC_CVP,'DD/MM/YYYY')   ,
   ACESSO_CONFORME   ,'N' COR_VERMELHA   ,'R' FROM VW_TAREFAS_READY_DIRETA
   WHERE (POOL_ID = HEXTORAW('0200001105F5E115018E00060000091B'))  AND NOMEFANT_CLASS_CONTA like '%ECT%'
;

 set linesize 200

 set pagesize 500

 select * from table(dbms_xplan.display);



=============
modo antigo
=============

set echo off;
spool explain

rem Explain plan script for most possible statement tuning cases
rem J. Maresh  3/21/2000

rem To use this script, replace the SQL statement to be 
rem explained after the SET statement_id = ... clause.
rem Change the statement_id to your username, and the two 
rem variables below to appropriate values.  

set verify off;
set feedback off;
set timing off;
set lines 120;
ttitle off;

rem Your username
define username='JM';
rem Schema of interest
define owner = 'DW';

rem Delete old rows from plan_table
DELETE FROM plan_table 
  WHERE statement_id = '&username';
COMMIT;

rem  AND polling_interval_ts > TO_DATE('20000630','YYYYMMDD')
rem *********************************************************************
rem Insert your statement after the "SET" statement line
rem terminated by a semicolon
rem *********************************************************************
set echo on
EXPLAIN PLAN
SET statement_id = 'JM' FOR
  SELECT INDIC_ACAO_BILHETE,       NOME_TAREFA,
    NOMEFANT_CLASS_CONTA,       '',       TO_CHAR(READY_TIME,'DD/MM/YYYY'),
    DATA_PREV_ATIV,       DATA_PREV_TERM,       JOB_NAME,       ORIGEM_TOPOL,
    COD_CONTRATO_PTA,       DESTINO_TOPOL,       COD_CONTRATO_PTA,
    CONTRATO,       TASK_ID,       JOB_ID,
    DATA_INI_TEMP,       DATA_FIM_TEMP,       IDENTIFICADOR,
    TIPO_IMPLEMENT,       SIGLA_LOCD,       DESIG_CVP,
    PROCESSO,        TO_CHAR(DATA_ATIVACAO_TEC_CVP,'DD/MM/YYYY')   ,
   ACESSO_CONFORME   ,'N' COR_VERMELHA   ,'R' FROM VW_TAREFAS_READY_DIRETA
   WHERE (POOL_ID = HEXTORAW('0200001105F5E115018E00060000091B'))  AND NOMEFANT_CLASS_CONTA like '%ECT%'
;
--
set echo off
COMMIT;
rem *********************************************************************

prompt
prompt Execution Plan....................................................

rem Basic Execution plan
SELECT DECODE(id, 0,'', LPAD(' ',2*(level-1))||level||'.'||position)||' '
       ||RTRIM(operation)||' '||RTRIM(options)||
           DECODE(object_name,NULL,' ',' "'||RTRIM(object_name)||'" ')||
       RTRIM(object_type)||' '||
       DECODE(id,0,DECODE(position,NULL,NULL,'Cost = '||position))  query_plan
  FROM plan_table
  CONNECT BY PRIOR id = parent_id
    AND statement_id = '&username'
  START WITH id = 0 
    AND statement_id = '&username';

prompt
prompt Partition access information......................................

col lvl heading 'Level' format a8;
col object_name heading 'Object Name' format a30;
col part_start heading 'Part|Start' format a8;
col part_end heading 'Part|End' format a8;

rem Partition stats
SELECT level||'.'||position lvl,
    object_name,
    SUBSTR(partition_start,1,5) part_start, 
    SUBSTR(partition_stop,1,5) part_end
  FROM plan_table
  WHERE object_name IS NOT NULL
  AND partition_id IS NOT NULL
  CONNECT BY PRIOR id = parent_id
    AND statement_id = '&username'
  START WITH id = 0
    AND statement_id = '&username';

set long 8192;
col other format a90;

prompt
prompt Remote query information..........................................

col lvl heading 'Level' format a8;
col object_node heading 'DB Link Name' format a20;
col other heading 'Remote query' format a50 word_wrapped;
set long 8192;

rem Remote stats
SELECT level||'.'||position lvl,
    object_node,
    other
  FROM plan_table
  WHERE operation = 'REMOTE'
  CONNECT BY PRIOR id = parent_id
    AND statement_id = '&username'
  START WITH id = 0
    AND statement_id = '&username';

set longchunksize 30;
col object_name heading 'Object Name' format a30;
col object_node heading 'PQ Node' format a12;
col other heading 'PQ server query';
col options heading 'Access' format a12;

prompt
prompt Parallel node information.......................................

rem Parallel stats
SELECT level||'.'||position lvl,
    object_name,
    object_node,
    options,
    other
  FROM plan_table
  WHERE operation != 'REMOTE'
  AND object_node IS NOT NULL
  CONNECT BY PRIOR id = parent_id
    AND statement_id = '&username'
  START WITH id = 0
    AND statement_id = '&username';

col other_tag heading 'Parallel operation' format a30

prompt
prompt Parallel operations information.......................................
SELECT level||'.'||position lvl,
    other_tag
  FROM plan_table
  WHERE other_tag IS NOT NULL
  CONNECT BY PRIOR id = parent_id
    AND statement_id = '&username'
  START WITH id = 0
    AND statement_id = '&username';

rem Generate table stats
rem @exptab

rem Delete rows from plan_table
DELETE FROM plan_table
  WHERE statement_id = '&username';
COMMIT;

spool off;
set lines 80;
set feedback on;
set timing on;
set echo on;
