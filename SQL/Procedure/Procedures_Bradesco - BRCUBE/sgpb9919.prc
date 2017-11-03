CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9919 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9919
  --      DATA            : 25/07/2007
  --
  --      - PARAMETRO 722.
  --      - ATUALIZACAO O OBJETIVO DO CANAL BANCO
  --      - 2
  --      - 3
  --      - 4
  --	    - Alexandre Cysne Esteves
  -------------------------------------------------------------------------------------------------
  var_log_erro        VARCHAR2(2000);
  VAR_PARAMETRO		    NUMBER := 722;
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9919';
  ------------------------------------------------------------------------------------------------


BEGIN

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   -- INICIANDO A EXECUCAO
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   --
   COMMIT;

             BEGIN
                update parm_canal_vda_segur pcvs
                   set pcvs.vmin_prod_apurc = '0,00'
                 where pcvs.ccanal_vda_segur = 2
                   and pcvs.cinic_faixa_crrtr = 800000
                   and pcvs.cfnal_faixa_crrtr = 870000
                   and pcvs.vmin_prod_apurc = '30000,00';

             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('erro no update da tabela parm_canal_vda_segur - banco. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;
             
   --
   COMMIT;
   --
             
             BEGIN
                update parm_canal_vda_segur pcvs
                   set pcvs.vmin_prod_apurc = '0,00'
                 where pcvs.ccanal_vda_segur = 3
                   and pcvs.cinic_faixa_crrtr = 870006
                   and pcvs.cfnal_faixa_crrtr = 879999
                   and pcvs.vmin_prod_apurc = '30000,00';

             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('erro no update da tabela parm_canal_vda_segur - finasa. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;

   --
   COMMIT;
   --

   -- DWSHEDULER
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   --
END SGPB9919;
/

