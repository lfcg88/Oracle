CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB999A IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9990
  --      DATA            : 29/06/2007
  --
  --      - ESSA PROCEDURE DEVE SER COLOCADA NO PARAMETRO 722. ELA IRÁ DELETAR TODAS
  --        AS LINHAS DA TABELA PROD_CRRTR (PRODUÇÃO DO CORRETOR).
  --      - ELA DEVE SER USADA APENAS PARA IMPLANTAR O CONCEITO CORRENTISTA E O CONCEITO TELEEMPRESA.
  --      - ELA DEVE SER USADA APÓS A EXECUÇÃO DAS PROCEDURES SGPB0186 E SGPB0187.
  --      - ESSA PROCEDURE FAZ O SEGUINTE:
  --				1) DELETA A PRODUÇÃO DE ABRIL/07 EM DIANTE (SOMENTE DEIXA O PRIMEIRO TRIMESTRE)
  --				2) CARREGA O QUE FOI DELETADO COM OS NOVOS CONCEITOS
  --	  - DEPOIS DISSO OS CONCEITOS NOVOS ES~ARÃO IMPLANTADOS NO PLANO DE BONUS.
  --	  ASS. Wassily 29/06/2007
  -------------------------------------------------------------------------------------------------
  var_log_erro        VARCHAR2(2000);
  VAR_COMPETENCIA     NUMBER(6);
  VAR_PARAMETRO		    NUMBER := 722;
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9990';
  VAR_CONTA_TOT       NUMBER;
  --
  PROCEDURE insertUpdate
  (
    p_ccompt_prod     prod_crrtr.ccompt_prod%TYPE,
    p_cund_prod       prod_crrtr.cund_prod%TYPE,
    p_ccrrtr          prod_crrtr.ccrrtr%TYPE,
    p_cgrp_ramo_plano prod_crrtr.cgrp_ramo_plano%TYPE,
    p_ctpo_comis      prod_crrtr.ctpo_comis%TYPE,
    p_qtot_item_prod  prod_crrtr.qtot_item_prod%TYPE,
    p_vprod_crrtr     prod_crrtr.vprod_crrtr%TYPE
  ) IS
  BEGIN
    UPDATE prod_crrtr
    	 SET qtot_item_prod    = p_qtot_item_prod,
           vprod_crrtr    	 = p_vprod_crrtr
     WHERE cgrp_ramo_plano   = p_cgrp_ramo_plano
       AND cund_prod 	       = p_cund_prod
       AND ccrrtr 		       = p_ccrrtr
       AND ccompt_prod       = p_ccompt_prod
       AND ctpo_comis 	     = p_ctpo_comis;
    IF (SQL%ROWCOUNT = 0) THEN
      	INSERT INTO prod_crrtr (qtot_item_prod, ctpo_comis, ccrrtr, cgrp_ramo_plano, ccompt_prod,cund_prod, vprod_crrtr)
      		VALUES (p_qtot_item_prod, p_ctpo_comis, p_ccrrtr, p_cgrp_ramo_plano, p_ccompt_prod, p_cund_prod, p_vprod_crrtr);
    END IF;
  END;
  --
BEGIN

   VAR_CONTA_TOT := 0;
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   -- COMPETENCIAS ATUALIZADAS
   FOR I IN ( 	SELECT 200704 COMPETENCIA FROM DUAL
         				UNION
         				SELECT 200705 COMPETENCIA FROM DUAL
         				UNION
         				SELECT 200706 COMPETENCIA FROM DUAL
         				UNION
         				SELECT 200707 COMPETENCIA FROM DUAL
                )
   LOOP --COMPETENCIA
   --
       PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'CARREGANDO A NOVA PRODUCAO DA COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
       COMMIT;
       --
       FOR c IN (SELECT I.COMPETENCIA ccompt_prod,
                        APC.cund_prod, APC.ccrrtr,
                        ARP.CGRP_RAMO_PLANO,
                        APC.ctpo_comis,
                        COUNT(*) qtot_item_prod,
                        SUM(vprmio_emtdo_apolc) vprod_crrtr
               		 FROM AGPTO_RAMO_PLANO ARP
                   JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
                  WHERE APC.DEMIS_APOLC BETWEEN to_date(I.COMPETENCIA||'01','YYYYMMDD') AND
                                               last_day(TO_DATE(I.COMPETENCIA||'01','YYYYMMDD')) --last_day(I.COMPETENCIA||'01')
                   	AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re, pc_util_01.ReTodos)
           		 GROUP BY I.COMPETENCIA,
                        APC.cund_prod, APC.ccrrtr,
                 		    ARP.CGRP_RAMO_PLANO,APC.ctpo_comis)
        LOOP
        --CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
        insertUpdate(c.ccompt_prod,c.cund_prod,c.ccrrtr,c.cgrp_ramo_plano,c.ctpo_comis,c.qtot_item_prod,nvl(c.vprod_crrtr,0));

        VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
        IF ((VAR_CONTA_TOT mod 1000) = 0) THEN
      	   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'ATE O MOMENTO FORAM ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
     	     COMMIT;
      	END IF;
        --
       END LOOP;
   		 PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'PRODUCAO CARREGADA COM SUCESSO DA COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
  	   COMMIT;
   --
   END LOOP;
   --
END SGPB999A;
/

