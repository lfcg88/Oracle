CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0400
-----------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0400 (antigo programa sgpb0135, com adaptações)
  --      DATA            : 11/06/2007
  --      AUTOR           : Wassily Chuk - G&P
  --      OBJETIVO        : rotina eventual para sumarizar em prod_crrtr a produção de apolices do corretor
  --                        Sobrepoem os saldos existentes.
-----------------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO 				VARCHAR2(1000);
  chrLocalErro 				VARCHAR2(2) := '00';
  linhasAfetadas 			NUMBER(15);
  VAR_DCARGA                date;
  VAR_DPROX_CARGA           date;
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
    chrLocalErro := 03;
    UPDATE prod_crrtr
    	SET qtot_item_prod 	 = p_qtot_item_prod, 
           vprod_crrtr    	 = p_vprod_crrtr
     	WHERE cgrp_ramo_plano= p_cgrp_ramo_plano
       		AND cund_prod 	 = p_cund_prod
       		AND ccrrtr 		 = p_ccrrtr
       		AND ccompt_prod  = p_ccompt_prod
       		AND ctpo_comis 	 = p_ctpo_comis;
    chrLocalErro := 04;
    IF (SQL%ROWCOUNT = 0) THEN
      	chrLocalErro := 06;
      	INSERT INTO prod_crrtr (qtot_item_prod, ctpo_comis, ccrrtr, cgrp_ramo_plano, ccompt_prod,cund_prod, vprod_crrtr) 
      		VALUES (p_qtot_item_prod, p_ctpo_comis, p_ccrrtr, p_cgrp_ramo_plano, p_ccompt_prod, p_cund_prod, p_vprod_crrtr);
    END IF;
  END;
BEGIN
   chrLocalErro := 01;
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA('SGPB0400');   
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(723, VAR_DCARGA, VAR_DPROX_CARGA);   
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA('SGPB0400','INICIO DO PROCESSO DE SUMARIZACAO DO MES '||TO_CHAR(VAR_DPROX_CARGA,'YYYY/MM')||
                          ' EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   -- Avisa ao dwscheduler que está rodando
   PR_ATUALIZA_STATUS_ROTINA('SGPB0400',722,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   chrLocalErro := 02;
   --PERCORRE TODAS AS APOLICES DA COMPETENCIA INFORMADA, AGRUPANDO PELA CHAVE
   --PRIMÁRIA DE PROD_CRRTR, SOMA O VALOR DE PRODUCAO E CONTA QTD DE ITENS.
   FOR c IN (SELECT TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM')) ccompt_prod, APC.cund_prod, APC.ccrrtr, 
                    ARP.CGRP_RAMO_PLANO, APC.ctpo_comis,
                    COUNT(*) qtot_item_prod, SUM(vprmio_emtdo_apolc) vprod_crrtr
              		FROM AGPTO_RAMO_PLANO ARP
              		JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
                    WHERE APC.DEMIS_APOLC BETWEEN to_date(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM')||'01','YYYYMMDD') AND 
                    							  last_day(VAR_DPROX_CARGA)
                      	AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re, pc_util_01.ReTodos)
             		GROUP BY TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM')), APC.cund_prod, APC.ccrrtr,
             		         ARP.CGRP_RAMO_PLANO,APC.ctpo_comis) 
   LOOP
    --
    chrLocalErro := 03;
    --  CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
    insertUpdate(c.ccompt_prod,c.cund_prod,c.ccrrtr,c.cgrp_ramo_plano,c.ctpo_comis,c.qtot_item_prod,nvl(c.vprod_crrtr,0));
    --
    chrLocalErro := 04;
    -- APENAS APOLICES DO GRUPO AUTO E DO RAMO BILHETE TEM RELACIONAMENTO COM PRODUCAO
    IF (C.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re)) THEN
      --  CADA APOLICE QUE FOI AGRUPADA E INSERIDA EM UMA PRODUÇÃO RECEBE
      --  A CHAVE DA TABELA DE PRODUÇÃO(PROD_CRRTR), PARA QUE MAIS TARDE NO
      --  SISTEMA SEJA EXPORTADO QUE APOLICES PARTICIPARAM DE CADA PRODUÇÃO,
      --  E POSTERIORMENTE PARTICIPARAM DE UM PAGAMENTO
      FOR c1 IN (SELECT ccia_segdr, cramo_apolc, capolc, citem_apolc, ctpo_docto, cendss_apolc, apc.demis_apolc
                   FROM AGPTO_RAMO_PLANO ARP
                   JOIN apolc_prod_crrtr APC
                     ON APC.CRAMO_APOLC = ARP.CRAMO
                    AND APC.CUND_PROD 	= c.cund_prod
                    AND APC.CCRRTR 		= c.ccrrtr                                       
                    AND APC.DEMIS_APOLC BETWEEN to_date(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM')||'01','YYYYMMDD') AND 
                    							last_day(VAR_DPROX_CARGA)
                    AND TO_NUMBER(TO_CHAR(APC.DEMIS_APOLC,'YYYYMM')) = C.ccompt_prod
                    AND APC.CTPO_COMIS 		= C.CTPO_COMIS 
                  WHERE ARP.CGRP_RAMO_PLANO = c.cgrp_ramo_plano)
       LOOP
            chrLocalErro := 05;
        	--  RECEBEMDO A CHAVE DE PRODUCAO
        	UPDATE APOLC_PROD_CRRTR
           		SET CGRP_RAMO_PLANO 	= C.CGRP_RAMO_PLANO,
               		CCOMPT_PROD     	= C.CCOMPT_PROD
         		WHERE CUND_PROD 		= C.CUND_PROD
           		AND CCIA_SEGDR 			= C1.CCIA_SEGDR
           		AND CRAMO_APOLC 		= C1.CRAMO_APOLC
           		AND CAPOLC 				= C1.CAPOLC
           		AND CITEM_APOLC 		= C1.CITEM_APOLC
           		AND CTPO_DOCTO 			= C1.CTPO_DOCTO
           		AND CENDSS_APOLC 		= C1.CENDSS_APOLC
           		AND demis_apolc 		= C1.demis_apolc
           		and CTPO_COMIS  		= C.CTPO_COMIS
           		and CCRRTR      		= C.CCRRTR;
        	IF (SQL%ROWCOUNT = 0) THEN
        	    ROLLBACK;
           		PR_GRAVA_MSG_LOG_CARGA('SGPB0400','ERRO. O UPDATE NAO AFETOU NENHUMA LINHA.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
           		PR_ATUALIZA_STATUS_ROTINA('SGPB0400',722,PC_UTIL_01.VAR_ROTNA_PE);
           		COMMIT; 
           		Raise_Application_Error(-20210,'ERRO. UPDATE NAO AFETOU NENHUMA LINHA.');
        	END IF;
       END LOOP;
    END IF;
    chrLocalErro := 6;
  END LOOP;
  chrLocalErro := 7;
  PR_GRAVA_MSG_LOG_CARGA('SGPB0400','FIM DA SUMARIZACAO DIARIA DA PRODUCAO DO CORRETOR.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA('SGPB0400',722,'PO');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: '||chrLocalErro||' Compet: '||to_char(VAR_DPROX_CARGA,'YYYYMM')||
                           ' ERRO: '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA('SGPB0400',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL); 
    PR_ATUALIZA_STATUS_ROTINA('SGPB0400',722,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20210,var_log_erro);
END SGPB0400;
/

