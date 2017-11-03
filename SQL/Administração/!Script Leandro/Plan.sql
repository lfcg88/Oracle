Prompt #############################################################
Prompt #                                                           #
Prompt #              Plano de execução de uma consulta            #
Prompt #           Mostra plano de execução de uma consulta.       #
Prompt #                                                           #
Prompt #############################################################

REM  Para testar a query com outras formas de otimização 
REM  utilize os hints abaixo:
REM  /*+ ALL_ROWS */ 
REM  /*+ FIRST_ROWS */ 
REM  /*+ CHOOSE */
REM  /*+ RULE */

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = 'DBA_LEANDRO'
/

EXPLAIN PLAN SET STATEMENT_ID = 'DBA_SERGIO' FOR
SELECT 1
  FROM acordo
 WHERE tp_documento = :b1 AND nu_documento = :b2 AND dt_cancelamento IS NULL
/

set lines 500
col "Plano de Acesso" format a70
col OBJECT_OWNER format a12
col OBJECT_TYPE format a12


SELECT LPAD(' ', 2* LEVEL - 2 ) || DECODE(id, 0,'',PARENT_ID||'.'||POSITION||'-')||operation || ' ' || options 
           || ' ' || object_name
           || ' ' || DECODE(id, 0, 'Otimizador por : '||OPTIMIZER) "Plano de Acesso"
     , COST
     , BYTES
     , OBJECT_OWNER
     , OBJECT_TYPE
     , CARDINALITY
  FROM plan_table
 START WITH id = 0 
   AND statement_id = 'DBA_SERGIO'
  CONNECT BY PRIOR id = parent_id 
   AND statement_id = 'DBA_SERGIO'
/

rollback;

set lines 300
clear columns
