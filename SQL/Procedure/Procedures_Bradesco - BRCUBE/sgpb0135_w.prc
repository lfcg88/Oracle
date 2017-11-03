CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0135_W(intrCompetencia        IN date,
                             chrNomeRotinaScheduler VARCHAR2 := 'SGPB9135')
-----------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0135
  --      DATA            : 16/03/2006
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes- G&P
  --      OBJETIVO        : sumarizar em prod_crrtr a produção de apolices do corretor
  --      ALTERAÇÕES      :
  --                      : Wassily ( 17/04/2007 ) - Colocados parametros do dwscheduler
  --                      : Wassily ( 11/06/2007 ) - Alterado para considerar apenas o dia e nao todo o mes.
  -----------------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  linhasAfetadas NUMBER(15);
  PROCEDURE insertUpdate
  (
    p_cund_prod       prod_crrtr.cund_prod %TYPE,
    p_ccrrtr          prod_crrtr.ccrrtr %TYPE,
    p_cgrp_ramo_plano prod_crrtr.cgrp_ramo_plano %TYPE,
    p_ctpo_comis      prod_crrtr.ctpo_comis %TYPE,
    p_qtot_item_prod  prod_crrtr.qtot_item_prod %TYPE,
    p_vprod_crrtr     prod_crrtr.vprod_crrtr %TYPE
  ) IS
  BEGIN
    chrLocalErro := 7;
    UPDATE prod_crrtr
       	SET qtot_item_prod = qtot_item_prod + p_qtot_item_prod, -- soma com o que estiver lá
        	vprod_crrtr    = vprod_crrtr + p_vprod_crrtr -- soma com o que estiver lá
     	WHERE cgrp_ramo_plano= p_cgrp_ramo_plano
       		AND cund_prod = p_cund_prod
       		AND ccrrtr = p_ccrrtr
       		AND ccompt_prod = to_number(TO_CHAR(intrCompetencia,'YYYYMM')) --p_ccompt_prod
       		AND ctpo_comis = p_ctpo_comis;
    chrLocalErro := 8;
    -- se não afetou nenhum registro é o primeiro dia faz insert
    IF (SQL%ROWCOUNT = 0) THEN
      chrLocalErro := 9;
      INSERT INTO prod_crrtr (qtot_item_prod, ctpo_comis, ccrrtr, cgrp_ramo_plano, ccompt_prod,cund_prod, vprod_crrtr) 
      VALUES 
        (p_qtot_item_prod,p_ctpo_comis,p_ccrrtr,p_cgrp_ramo_plano,to_number(TO_CHAR(intrCompetencia,'YYYYMM')), --p_ccompt_prod,  
         p_cund_prod, p_vprod_crrtr);
    END IF;
  END;
  --
BEGIN
  --
  chrLocalErro := 01;
  PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER,708,PC_UTIL_01.VAR_ROTNA_PC);
  COMMIT;
  --PERCORRE TODAS AS APOLICES DA COMPETENCIA INFORMADA, AGRUPA PELA CHAVE
  --PRIMÁRIA DE PROD_CRRTR, SOMA O VALOR DE PRODUCAO E CONTA QTD DE ITENS.
  FOR c IN (SELECT APC.cund_prod, APC.ccrrtr, ARP.CGRP_RAMO_PLANO, ctpo_comis, 
                   COUNT(*) qtot_item_prod, SUM(vprmio_emtdo_apolc) vprod_crrtr
              FROM AGPTO_RAMO_PLANO ARP
              JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
             WHERE APC.DEMIS_APOLC = intrCompetencia -- vai pegar apenas o dia. ass. Wassily
                   AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re, pc_util_01.ReTodos)
             GROUP BY APC.cund_prod,APC.ccrrtr,ARP.CGRP_RAMO_PLANO,APC.ctpo_comis) 
   LOOP
    --
    chrLocalErro := 02;
    --  CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
    insertUpdate(c.cund_prod,c.ccrrtr,c.cgrp_ramo_plano,c.ctpo_comis,c.qtot_item_prod,nvl(c.vprod_crrtr,0));
    chrLocalErro := 03;
    -- APENAS APOLICES DO GRUPO AUTO E DO RAMO BILHETE TEM RELACIONAMENTO COM PRODUCAO
    IF (C.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re)) THEN
      --  CADA APOLICE QUE FOI AGRUPADA E INSERIDA EM UMA PRODUÇÃO RECEBE
      --A CHAVE DA TABELA DE PRODUÇÃO(PROD_CRRTR), PARA QUE MAIS TARDE NO
      --SISTEMA SEJA EXPORTADO QUE APOLICES PARTICIPARAM DE CADA PRODUÇÃO,
      --E POSTERIORMENTE PARTICIPARAM DE UM PAGAMENTO
      FOR c1 IN (SELECT ccia_segdr,cramo_apolc,capolc,citem_apolc,ctpo_docto,cendss_apolc
                   FROM AGPTO_RAMO_PLANO ARP
                   JOIN apolc_prod_crrtr APC
                     ON APC.CRAMO_APOLC = ARP.CRAMO
                    AND APC.CUND_PROD = c.cund_prod
                    AND APC.CCRRTR = c.ccrrtr
                    and apc.demis_apolc = intrCompetencia -- apenas o dia. ass. Wassily
                    AND APC.CTPO_COMIS = C.CTPO_COMIS 
                  WHERE ARP.CGRP_RAMO_PLANO = c.cgrp_ramo_plano)
       LOOP
        chrLocalErro := 04;
        --  RECEBEMDO A CHAVE DE PRODUCAO
        UPDATE APOLC_PROD_CRRTR
           SET CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO,
               CCOMPT_PROD     =  to_number(TO_CHAR(intrCompetencia,'YYYYMM'))
         WHERE CUND_PROD 	= C.CUND_PROD
           AND CCIA_SEGDR 	= C1.CCIA_SEGDR
           AND CRAMO_APOLC 	= C1.CRAMO_APOLC
           AND CAPOLC 		= C1.CAPOLC
           AND CITEM_APOLC 	= C1.CITEM_APOLC
           AND CTPO_DOCTO 	= C1.CTPO_DOCTO
           AND CENDSS_APOLC = C1.CENDSS_APOLC
           AND demis_apolc 	= intrCompetencia -- apenas o dia. ass. Wassily
           and CTPO_COMIS  	= C.CTPO_COMIS
           and CCRRTR      	= C.CCRRTR;
        IF (SQL%ROWCOUNT = 0) THEN
           PR_GRAVA_MSG_LOG_CARGA('SGPB9135','ERRO. O UPDATE NAO AFETOU NENHUMA LINHA.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
           PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
           COMMIT; 
           Raise_Application_Error(-20210,'ERRO. UPDATE NAO AFETOU NENHUMA LINHA.');
        END IF;
      END LOOP;
    END IF;
    chrLocalErro := 5;
  END LOOP;
  chrLocalErro := 6;
  PR_GRAVA_MSG_LOG_CARGA('SGPB9135','FIM DA SUMARIZACAO DIARIA DA PRODUCAO DO CORRETOR.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,'PO');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia)||
                           ' ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA('SGPB9135',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL); 
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20210,var_log_erro);
END SGPB0135_W;
/

