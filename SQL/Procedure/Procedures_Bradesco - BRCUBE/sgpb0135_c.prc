CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0135_c
(
  intrCompetencia        IN NUMBER,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0135_c'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0135_c
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : sumarizar em prod_crrtr a produção de apolices do corretor
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
    linhasAfetadas NUMBER(15);
  --
  --
  PROCEDURE insertUpdate
  (
    p_ccompt_prod     prod_crrtr.ccompt_prod %TYPE,
    p_cund_prod       prod_crrtr.cund_prod %TYPE,
    p_ccrrtr          prod_crrtr.ccrrtr %TYPE,
    p_cgrp_ramo_plano prod_crrtr.cgrp_ramo_plano %TYPE,
    p_ctpo_comis      prod_crrtr.ctpo_comis %TYPE,
    p_qtot_item_prod  prod_crrtr.qtot_item_prod %TYPE,
    p_vprod_crrtr     prod_crrtr.vprod_crrtr %TYPE
  ) IS
    linhasAfetadas NUMBER(15);
  BEGIN
    --
    -- 29 dias do mes o update será utilizado
    chrLocalErro := 03;
    UPDATE prod_crrtr
       SET qtot_item_prod = p_qtot_item_prod,
           vprod_crrtr    = p_vprod_crrtr
     WHERE cgrp_ramo_plano = p_cgrp_ramo_plano
       AND cund_prod = p_cund_prod
       AND ccrrtr = p_ccrrtr
       AND ccompt_prod = p_ccompt_prod
       AND ctpo_comis = p_ctpo_comis;
    --
    -- busca quantidade de linhas atualizadas
    chrLocalErro := 04;
    linhasAfetadas := SQL%ROWCOUNT;
    --
    --
    chrLocalErro := 05;
    -- se não afetou nenhum registro é o primeiro dia... faz insert
    IF (linhasAfetadas <= 0) THEN
      --
      chrLocalErro := 06;
      INSERT INTO prod_crrtr
        (qtot_item_prod,
         ctpo_comis,
         ccrrtr,
         cgrp_ramo_plano,
         ccompt_prod,
         cund_prod,
         vprod_crrtr --
         ) --
      VALUES --
        ( --
         p_qtot_item_prod,
         p_ctpo_comis,
         p_ccrrtr,
         p_cgrp_ramo_plano,
         p_ccompt_prod,
         p_cund_prod,
         p_vprod_crrtr --
         );
      --
    END IF;
    --
    --
  END;

BEGIN
  --
  chrLocalErro := 01;
  --  INFORMA AO SCHEDULER O COMEÇO DA PROCEDURE
  PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER,
                                 708,
                                 PC_UTIL_01.VAR_ROTNA_PC);
  
  --  PERCORRE TODAS AS APOLICES DA COMPETENCIA INFORMADA, AGRUPA PELA CHAVE
  --PRIMÁRIA DE PROD_CRRTR, SOMA O VALOR DE PRODUCAO E CONTA QTD DE ITENS.
  FOR c IN (SELECT intrCompetencia ccompt_prod,
                   APC.cund_prod,
                   APC.ccrrtr,
                   ARP.CGRP_RAMO_PLANO,
                   APC.ctpo_comis,
                   COUNT(*) qtot_item_prod,
                   SUM(vprmio_emtdo_apolc) vprod_crrtr
              FROM AGPTO_RAMO_PLANO ARP
              JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
             WHERE APC.DEMIS_APOLC BETWEEN to_date(intrCompetencia,
                                                   'YYYYMM') AND last_day(to_date(intrCompetencia,
                                                                                  'YYYYMM'))
               AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re, pc_util_01.ReTodos)
--               AND APC.CTPO_COMIS = pc_util_01.COMISSAO_NORMAL
             GROUP BY intrCompetencia,
                      APC.cund_prod,
                      APC.ccrrtr,
                      ARP.CGRP_RAMO_PLANO,
                      APC.ctpo_comis) --
   LOOP
    --
    --
    chrLocalErro := 07;
    --  CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
    insertUpdate(
      c.ccompt_prod,
      c.cund_prod,
      c.ccrrtr,
      c.cgrp_ramo_plano,
      c.ctpo_comis,
      c.qtot_item_prod,
      nvl(c.vprod_crrtr,0)
    );
    --
    --
    chrLocalErro := 08;
    --
    -- APENAS APOLICES DO GRUPO AUTO E DO RAMO BILHETE TEM RELACIONAMENTO COM PRODUCAO
    IF (C.CGRP_RAMO_PLANO IN (pc_util_01.Auto, pc_util_01.Re)) THEN
      --  FAZ O INVERSO DO PRIMEIRO FOR.
      --  CADA APOLICE QUE FOI AGRUPADA E INSERIDA EM UMA PRODUÇÃO RECEBE
      --A CHAVE DA TABELA DE PRODUÇÃO(PROD_CRRTR), PARA QUE MAIS TARDE NO
      --SISTEMA SEJA EXPORTADO QUE APOLICES PARTICIPARAM DE CADA PRODUÇÃO,
      --E POSTERIORMENTE PARTICIPARAM DE UM PAGAMENTO
      FOR c1 IN (SELECT cund_prod,
                        ccia_segdr,
                        cramo_apolc,
                        capolc,
                        citem_apolc,
                        ctpo_docto,
                        cendss_apolc,
                        apc.demis_apolc
                        --
                   FROM AGPTO_RAMO_PLANO ARP
                   --
                   JOIN apolc_prod_crrtr APC
                     ON APC.CRAMO_APOLC = ARP.CRAMO
                    AND APC.CUND_PROD = c.cund_prod
                    AND APC.CCRRTR = c.ccrrtr
                    AND APC.DEMIS_APOLC BETWEEN to_date(C.ccompt_prod, 'YYYYMM') AND
                                                last_day(to_date(C.ccompt_prod, 'YYYYMM'))
                    AND APC.CTPO_COMIS = C.CTPO_COMIS
                   --
                   --
                  WHERE ARP.CGRP_RAMO_PLANO = c.cgrp_ramo_plano)
       LOOP
        --
        --
        chrLocalErro := 09;
        --  RECEBEMDO A CHAVE DE PRODUCAO
        UPDATE APOLC_PROD_CRRTR
        --
           SET CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO,
               CCOMPT_PROD     = C.CCOMPT_PROD
        --
         WHERE CUND_PROD = C1.CUND_PROD
           AND CCIA_SEGDR = C1.CCIA_SEGDR
           AND CRAMO_APOLC = C1.CRAMO_APOLC
           AND CAPOLC = C1.CAPOLC
           AND CITEM_APOLC = C1.CITEM_APOLC
           AND CTPO_DOCTO = C1.CTPO_DOCTO
           AND CENDSS_APOLC = C1.CENDSS_APOLC
           AND demis_apolc = C1.demis_apolc
           and CTPO_COMIS  = C.CTPO_COMIS
           and CCRRTR      = C.CCRRTR;
        --
        linhasAfetadas := SQL%ROWCOUNT;
      IF (linhasAfetadas <= 0) THEN
        Raise_Application_Error(-20210,'UPDATE AFETOU NENHUMA LINHA');
      END IF;
      --
      END LOOP;
    END IF;
    --
    chrLocalErro := 10;
    --
  --
  END LOOP;
  --
  chrLocalErro := 11;
  --
  --
  PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER,
                               708,
                               PC_UTIL_01.VAR_ROTNA_PO);
  --
  chrLocalErro := 12;
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    commit;
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) || ' Canal: ' ||
                           to_char(pc_util_01.EXTRA_BANCO) || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    --    dbms_output.put_line(var_log_erro);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0135_c',
                                var_log_erro,
                                pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER,
                                   708,
                                   PC_UTIL_01.VAR_ROTNA_PE);
    --
    RAISE;
END SGPB0135_c;
/

