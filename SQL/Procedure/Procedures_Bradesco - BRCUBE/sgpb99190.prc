CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB99190 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9900
  --      DATA            : 18/07/2007
  --
  --      - PARAMETRO 722.
  --      - ATUALIZACAO PARA CORRETORA AGIL SEGUNDO TRIMESTRE
  --      - 2
  --      - 3
  --      - 4
  --	    - Alexandre Cysne Esteves
  -------------------------------------------------------------------------------------------------
  var_log_erro        VARCHAR2(2000);
  VAR_PARAMETRO		    NUMBER := 722;
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9900';
  VAR_CONTA_TOT       NUMBER;
  ------------------------------------------------------------------------------------------------
  --PARAMETROS PARA ALTERAR
  VAR_CPF_CNPJ_BASE   NUMBER(10) := 23865611; --CNPJ BASE DO CORRETOR AGIL
  VAR_FAIXA_INI_EX    NUMBER(10) := 100000;   --FAIXA EXTRA-BANCO
  VAR_FAIXA_FIM_EX    NUMBER(10) := 199992;   --FAIXA EXTRA-BANCO
  VAR_FAIXA_INI_BC    NUMBER(10) := 800000;   --FAIXA BANCO
  VAR_FAIXA_FIM_BC    NUMBER(10) := 870000;   --FAIXA BANCO
  ------------------------------------------------------------------------------------------------
  --CURSOR
  TYPE T_CORRETOR IS REF CURSOR;
  C_CORRETOR_CCC T_CORRETOR;
  -- controle de procedure prod_crrtr chave
  int_cgrp_ramo_plano NUMBER(3) := 0;
  int_ccompt_prod     NUMBER(6) := 0;
  var_ctpo_comis      VARCHAR2(2);
  int_ccrrtr          NUMBER(6) := 0;
  int_cund_prod       NUMBER(3) := 0;
  -- controle de procedure apolc_prod_crrtr chave
  int_ccia_segdr      NUMBER(5) := 0;
  int_cramo_apolc     NUMBER(3) := 0;
  int_capolc          NUMBER(10):= 0;
  int_citem_apolc     NUMBER(10):= 0;
  var_ctpo_docto      VARCHAR2(1);
  int_cendss_apolc    NUMBER(35):= 0;
  dt_demis_apolc      DATE;
  -- controle de procedure
  int_qtot_item_prod  NUMBER(7) := 0;
  int_vprod_crrtr     NUMBER(17,2) := 0;

  --INCLUIDO PRODUCAO DO CORRETOR NA TABELA PROC_CRRTR
  PROCEDURE insertUpdate
  (
    p_ccompt_prod     prod_crrtr.ccompt_prod%TYPE,
    p_cund_prod       prod_crrtr.cund_prod%TYPE,
    p_ccrrtr          prod_crrtr.ccrrtr%TYPE,
    p_cgrp_ramo_plano prod_crrtr.cgrp_ramo_plano%TYPE,
    p_ctpo_comis      prod_crrtr.ctpo_comis%TYPE,
    p_qtot_item_prod  prod_crrtr.qtot_item_prod%TYPE,
    p_vprod_crrtr     prod_crrtr.vprod_crrtr%TYPE
  )IS
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
    --
    COMMIT;
    --
  END;
  --

BEGIN

   VAR_CONTA_TOT := 0;
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- COMPETENCIAS A SEREM REPROCESSADAS ATUALIZADAS
   FOR I IN ( 	SELECT 200704 COMPETENCIA FROM DUAL
         				UNION
         				SELECT 200705 COMPETENCIA FROM DUAL
         				UNION
         				SELECT 200706 COMPETENCIA FROM DUAL
                )
   LOOP
   --
       --DWSCHEDULER
       PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
       COMMIT;
       --

       ----------------------------------------------------
       --CURSOR PARA DELETAR APOLC_PROD_CRRTR PARA O CORRETOR X / COMPETENCIA Y
       --EXTRA-BANCO AUTO
       ----------------------------------------------------
       OPEN C_CORRETOR_CCC FOR

          --listando as apolices do corretor (competencia/cnpj_base)
          SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                 APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                 APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                 APC.CAPOLC,        --chave apolc_prod_crrtr
                 APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                 APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                 APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                 APC.DEMIS_APOLC    --chave apolc_prod_crrtr
            FROM AGPTO_RAMO_PLANO ARP
              --
            JOIN APOLC_PROD_CRRTR APC
              ON APC.CRAMO_APOLC = ARP.CRAMO
             AND APC.DEMIS_APOLC BETWEEN TO_DATE(I.COMPETENCIA,'YYYYMM') AND
                                last_day(TO_DATE(I.COMPETENCIA,'YYYYMM'))
              --
            JOIN CRRTR C
              ON C.CCRRTR = APC.CCRRTR
             AND C.CUND_PROD = APC.CUND_PROD
             AND C.Ccrrtr BETWEEN VAR_FAIXA_INI_EX and VAR_FAIXA_FIM_EX --faixa extra-banco
             AND C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE --cnpj base do corretor
              --
           WHERE ARP.CGRP_RAMO_PLANO = PC_UTIL_01.Auto; --120
       LOOP             
       FETCH C_CORRETOR_CCC INTO int_cund_prod,
                                 int_ccia_segdr,
                                 int_cramo_apolc,
                                 int_capolc,
                                 int_citem_apolc,
                                 var_ctpo_docto,
                                 int_cendss_apolc,
                                 dt_demis_apolc;
        --
        EXIT WHEN C_CORRETOR_CCC%NOTFOUND;
        --
             BEGIN
                --deletando as apolices do corretor (chave apolc_prod_crrtr)
                delete from apolc_prod_crrtr apc
                      where apc.cund_prod    = int_cund_prod
                        and apc.ccia_segdr   = int_ccia_segdr
                        and apc.cramo_apolc  = int_cramo_apolc
                        and apc.capolc       = int_capolc
                        and apc.citem_apolc  = int_citem_apolc
                        and apc.ctpo_docto   = var_ctpo_docto
                        and apc.cendss_apolc = int_cendss_apolc
                        and apc.demis_apolc  = dt_demis_apolc;

             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('ERRO NO DELETE DA APOLICE PRODUCAO. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;
        --
        END LOOP;
        --
        COMMIT;
        CLOSE C_CORRETOR_CCC;

        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'EXTRA-BANCO APOLICE PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'DELETADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --

       ----------------------------------------------------
       --CURSOR PARA DELETAR APOLC_PROD_CRRTR PARA O CORRETOR X / COMPETENCIA Y
       --BANCO AUTO
       ----------------------------------------------------
       OPEN C_CORRETOR_CCC FOR

          --listando as apolices do corretor (competencia/cnpj_base)
          SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                 APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                 APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                 APC.CAPOLC,        --chave apolc_prod_crrtr
                 APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                 APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                 APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                 APC.DEMIS_APOLC    --chave apolc_prod_crrtr
            --
            FROM AGPTO_RAMO_PLANO ARP
            --
            JOIN APOLC_PROD_CRRTR APC
              ON APC.CRAMO_APOLC = ARP.CRAMO
             AND APC.DEMIS_APOLC BETWEEN TO_DATE(I.COMPETENCIA,'YYYYMM') AND
                                last_day(TO_DATE(I.COMPETENCIA,'YYYYMM'))
            --
            JOIN CRRTR C
              ON C.CCRRTR = APC.CCRRTR
             AND C.CUND_PROD = APC.CUND_PROD
             AND C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE--cnpj base do corretor
            --
            JOIN MPMTO_AG_CRRTR MAC
              ON MAC.CUND_PROD = C.CUND_PROD
             AND MAC.CCRRTR_DSMEM = C.CCRRTR
             AND MAC.CCRRTR_ORIGN BETWEEN VAR_FAIXA_INI_BC AND VAR_FAIXA_FIM_BC --faixa banco
            --
            WHERE ARP.CGRP_RAMO_PLANO = PC_UTIL_01.Auto; --120

       LOOP             
       FETCH C_CORRETOR_CCC INTO int_cund_prod,
                                 int_ccia_segdr,
                                 int_cramo_apolc,
                                 int_capolc,
                                 int_citem_apolc,
                                 var_ctpo_docto,
                                 int_cendss_apolc,
                                 dt_demis_apolc;
        --
        EXIT WHEN C_CORRETOR_CCC%NOTFOUND;
        --
             BEGIN
                --deletando as apolices do corretor (chave apolc_prod_crrtr)
                delete from apolc_prod_crrtr apc
                      where apc.cund_prod    = int_cund_prod
                        and apc.ccia_segdr   = int_ccia_segdr
                        and apc.cramo_apolc  = int_cramo_apolc
                        and apc.capolc       = int_capolc
                        and apc.citem_apolc  = int_citem_apolc
                        and apc.ctpo_docto   = var_ctpo_docto
                        and apc.cendss_apolc = int_cendss_apolc
                        and apc.demis_apolc  = dt_demis_apolc;

             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('ERRO NO DELETE DA APOLICE PRODUCAO. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;
        --
        END LOOP;
        --
        COMMIT;
        CLOSE C_CORRETOR_CCC;

        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'BANCO APOLICE PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'DELETADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --

       ----------------------------------------------------
       --CURSOR PARA DELETAR PROD_CRRTR PARA O CORRETOR X / COMPETENCIA Y
       --EXTRA-BANCO AUTO
       ----------------------------------------------------
       OPEN C_CORRETOR_CCC FOR
          --listando a producao do corretor (competencia/cnpj_base)
          SELECT pc.cgrp_ramo_plano, --chave prod_crrtr
                 pc.ccompt_prod,     --chave prod_crrtr
                 pc.ctpo_comis,      --chave prod_crrtr
                 pc.ccrrtr,          --chave prod_crrtr
                 pc.cund_prod,       --chave prod_crrtr
                 pc.qtot_item_prod,  --
                 pc.vprod_crrtr      --
            FROM Crrtr C, crrtr_unfca_cnpj cuc, prod_crrtr pc
           WHERE pc.ccrrtr = c.ccrrtr
             and pc.cund_prod = c.cund_prod
             and pc.ccompt_prod = I.COMPETENCIA --competencia
             and CUC.ccpf_cnpj_base= c.ccpf_cnpj_base
             and (C.Ccrrtr BETWEEN VAR_FAIXA_INI_EX and VAR_FAIXA_FIM_EX) --faixa extra-banco
             and C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE --cnpj base do corretor
             and pc.cgrp_ramo_plano = PC_UTIL_01.Auto; --120
       LOOP
       FETCH C_CORRETOR_CCC INTO int_cgrp_ramo_plano,
                                 int_ccompt_prod,
                                 var_ctpo_comis,
                                 int_ccrrtr,
                                 int_cund_prod,
                                 int_qtot_item_prod,
                                 int_vprod_crrtr;
        --
        EXIT WHEN C_CORRETOR_CCC%NOTFOUND;
        --
             BEGIN
                --deletando a producao do corretor (chave prod_crrtr)
               delete from prod_crrtr pc
                where pc.cgrp_ramo_plano = int_cgrp_ramo_plano
                  and pc.ccompt_prod     = int_ccompt_prod
                  and pc.ctpo_comis      = var_ctpo_comis
                  and pc.ccrrtr          = int_ccrrtr
                  and pc.cund_prod       = int_cund_prod;
             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('ERRO NO DELETE DA PRODUCAO. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;
        --
        END LOOP;
        --
        COMMIT;
        CLOSE C_CORRETOR_CCC;

        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'EXTRA-BANCO PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'DELETADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --

       ----------------------------------------------------
       --CURSOR PARA DELETAR PROD_CRRTR PARA O CORRETOR X / COMPETENCIA Y
       --BANCO AUTO
       ----------------------------------------------------
       OPEN C_CORRETOR_CCC FOR
          --listando a producao do corretor (competencia/cnpj_base)
          SELECT pc.cgrp_ramo_plano, --chave prod_crrtr
                 pc.ccompt_prod,     --chave prod_crrtr
                 pc.ctpo_comis,      --chave prod_crrtr
                 pc.ccrrtr,          --chave prod_crrtr
                 pc.cund_prod,       --chave prod_crrtr
                 pc.qtot_item_prod,  --
                 pc.vprod_crrtr      --
            from prod_crrtr PC      
              --
            JOIN MPMTO_AG_CRRTR MAC ON MAC.CUND_PROD = PC.CUND_PROD
                                   AND MAC.CCRRTR_DSMEM = PC.CCRRTR
                                   AND MAC.CCRRTR_ORIGN BETWEEN VAR_FAIXA_INI_BC AND VAR_FAIXA_FIM_BC
            JOIN CRRTR C
              ON C.CCRRTR = PC.CCRRTR
             AND C.CUND_PROD = PC.CUND_PROD
             AND C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE
             AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto --120
             --
           WHERE PC.CCOMPT_PROD = I.COMPETENCIA; --competencia
       LOOP
       FETCH C_CORRETOR_CCC INTO int_cgrp_ramo_plano,
                                 int_ccompt_prod,
                                 var_ctpo_comis,
                                 int_ccrrtr,
                                 int_cund_prod,
                                 int_qtot_item_prod,
                                 int_vprod_crrtr;
        --
        EXIT WHEN C_CORRETOR_CCC%NOTFOUND;
        --
             BEGIN
                --deletando a producao do corretor (chave prod_crrtr)
               delete from prod_crrtr pc
                where pc.cgrp_ramo_plano = int_cgrp_ramo_plano
                  and pc.ccompt_prod     = int_ccompt_prod
                  and pc.ctpo_comis      = var_ctpo_comis
                  and pc.ccrrtr          = int_ccrrtr
                  and pc.cund_prod       = int_cund_prod;
             EXCEPTION
             WHEN OTHERS THEN
              var_log_erro := substr('ERRO NO DELETE DA PRODUCAO. ERRO: ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
              ROLLBACK;
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
              COMMIT;
              Raise_Application_Error(-20210,var_log_erro);
             END;
        --
        END LOOP;
        --
        COMMIT;
        CLOSE C_CORRETOR_CCC;

        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'BANCO PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'DELETADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --

       ----------------------------------------------------
       --CARREGANDO AS APOLICES DO CORRETOR X / COMPETENCIA Y
       --sgpb0120 - extra-banco - auto
       ----------------------------------------------------
        INSERT INTO APOLC_PROD_CRRTR
          (CUND_PROD,
           CCIA_SEGDR,
           CRAMO_APOLC,
           CAPOLC,
           CITEM_APOLC,
           CTPO_DOCTO,
           CENDSS_APOLC,
           DEMIS_APOLC,
           CTPO_COMIS,
           CCRRTR,
           DINIC_VGCIA_APOLC,
           DFIM_VGCIA_APOLC,
           VPRMIO_EMTDO_APOLC,
           CCHAVE_LGADO_APOLC,
           DINCL_LCTO_PRMIO,
           CIND_CRRTT_BCO,
           CIND_PRODT_TLEMP)
           --
          SELECT VAT.CSUCUR,
                 VAT.CCIA_SEGDR,
                 VAT.CRAMO,
                 VAT.CAPOLC,
                 VAT.CITEM_APOLC,
                 CASE
                   WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
                    PC_UTIL_01.EMISSAO
                   ELSE
                    PC_UTIL_01.ENDOSSO
                 END,
                 VAT.CNRO_ENDSS,
                 VAT.DEMIS_ENDSS,
                 CASE
                   WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
                    'CE'
                   ELSE
                    'CN'
                 END,
                 VAT.ccrrtr,
                 max(VAT.DINIC_VGCIA_ENDSS),
                 max(VAT.DFIM_VGCIA_ITEM),
                 SUM(VAT.VPRMIO_LIQ_AUTO),
                 max(VAT.CCHAVE_ORIGE_ENDSS),
                 sysdate,
                 VAT.CIND_PRODT_CRRTT_BCO,
                 VAT.CIND_PRODT_TLEMP
          --
            FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
          --
            JOIN VACOMIS_CRRTR_CALC_BONUS VCO ON VCO.CCRRTR = VAT.CCRRTR
                                             AND VCO.CUND_PROD = VAT.CSUCUR
                                             AND VCO.CRAMO = VAT.CRAMO
                                             and vat.demis_endss between vco.dinic_vgcia and nvl(vco.dfim_vgcia, TO_DATE(99991231, 'YYYYMMDD'))
          --
            JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN (PC_UTIL_01.Auto)
                                     AND ARP.CRAMO = VAT.cramo
          --
           WHERE VAT.ccrrtr BETWEEN VAR_FAIXA_INI_EX AND VAR_FAIXA_FIM_EX
             --
             --AND vat.demis_endss = intrdia
             --ALTERACAO PARA O CORRETOR
             AND vat.demis_endss BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND 
                                last_day(to_date(I.COMPETENCIA,'YYYYMM'))
             --
             AND (vat.ccrrtr, vat.csucur) in (SELECT cr.ccrrtr, cr.cund_prod 
                                                FROM crrtr cr
                                               WHERE cr.ccpf_cnpj_base = VAR_CPF_CNPJ_BASE)
             --
             AND EXISTS (SELECT 1
                    FROM CRRTR C
                   WHERE C.CCRRTR = VAT.ccrrtr
                     AND C.CUND_PROD = VAT.CSUCUR)
      	GROUP BY VAT.CSUCUR,
                 VAT.CCIA_SEGDR,
                 VAT.CRAMO,
                 VAT.CAPOLC,
                 VAT.CITEM_APOLC,
                 CASE
                   WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
                    PC_UTIL_01.EMISSAO
                   ELSE
                    PC_UTIL_01.ENDOSSO
                 END,
                 VAT.CNRO_ENDSS,
                 VAT.DEMIS_ENDSS,
                 CASE
                   WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
                    'CE'
                   ELSE
                    'CN'
                 END,
                 VAT.ccrrtr,
                 VAT.CIND_PRODT_CRRTT_BCO,
                 VAT.CIND_PRODT_TLEMP;

        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'EXTRA-BANCO APOLICE AUTO PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'CARREGADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --
                
       ----------------------------------------------------
       --CARREGANDO AS APOLICES DO CORRETOR X / COMPETENCIA Y
       --sgpb0121 - banco - auto
       ----------------------------------------------------
        INSERT INTO APOLC_PROD_CRRTR
          (CUND_PROD,
           CCIA_SEGDR,
           CRAMO_APOLC,
           CAPOLC,
           CITEM_APOLC,
           CTPO_DOCTO,
           CENDSS_APOLC,
           DEMIS_APOLC,
           CTPO_COMIS,
           CCRRTR,
           DINIC_VGCIA_APOLC,
           DFIM_VGCIA_APOLC,
           VPRMIO_EMTDO_APOLC,
           CCHAVE_LGADO_APOLC,
           DINCL_LCTO_PRMIO,
           CIND_CRRTT_BCO,
           CIND_PRODT_TLEMP)
        --
          SELECT VAT.CSUCUR,
                 VAT.CCIA_SEGDR,
                 VAT.CRAMO,
                 VAT.CAPOLC,
                 VAT.CITEM_APOLC,
                 CASE
                   WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
                    PC_UTIL_01.EMISSAO
                   ELSE
                    PC_UTIL_01.ENDOSSO
                 END,
                 VAT.CNRO_ENDSS,
                 VAT.DEMIS_ENDSS,
                 CASE
                   WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
                    'CE'
                   ELSE
                    'CN'
                 END,
                 MAC.CCRRTR_DSMEM,
                 max(VAT.DINIC_VGCIA_ENDSS),
                 max(VAT.DFIM_VGCIA_ITEM),
                 SUM(VAT.VPRMIO_LIQ_AUTO),
                 VAT.CCHAVE_ORIGE_ENDSS,
                SYSDATE,
                VAT.CIND_PRODT_CRRTT_BCO,
                VAT.CIND_PRODT_TLEMP
          --
            FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
          --
            JOIN MPMTO_AG_CRRTR MAC ON MAC.CCRRTR_ORIGN = VAT.CCRRTR
                                   AND MAC.CUND_PROD = VAT.CSUCUR
                                   --AND intrdia >= MAC.DENTRD_CRRTR_AG
                                   --AND intrdia < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
          --
            JOIN VACOMIS_CRRTR_CALC_BONUS VCO ON VCO.CCRRTR = VAT.CCRRTR
                                             AND VCO.CUND_PROD = VAT.CSUCUR
                                             AND VCO.CRAMO = VAT.CRAMO
                                             and vat.demis_endss between vco.dinic_vgcia and nvl(vco.dfim_vgcia, TO_DATE(99991231, 'YYYYMMDD'))
          
            JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN (PC_UTIL_01.Auto)
                                     AND ARP.CRAMO = VAT.cramo
          --
           WHERE VAT.ccrrtr BETWEEN VAR_FAIXA_INI_BC AND VAR_FAIXA_FIM_BC
             ----AND vat.demis_endss = intrdia
             --ALTERACAO PARA O CORRETOR
             AND vat.demis_endss BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND 
                                last_day(to_date(I.COMPETENCIA,'YYYYMM'))
             --
             AND (MAC.CCRRTR_DSMEM, vat.csucur) in (SELECT cr.ccrrtr, cr.cund_prod 
                                                      FROM crrtr cr
                                                     WHERE cr.ccpf_cnpj_base = VAR_CPF_CNPJ_BASE)
             
             --
             AND EXISTS (SELECT 1
                    FROM CRRTR C
                   WHERE C.CCRRTR = MAC.CCRRTR_DSMEM
                     AND C.CUND_PROD = VAT.CSUCUR)
           GROUP BY VAT.CSUCUR,
                 VAT.CCIA_SEGDR,
                 VAT.CRAMO,
                 VAT.CAPOLC,
                 VAT.CITEM_APOLC,
                 CASE
                   WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
                    PC_UTIL_01.EMISSAO
                   ELSE
                    PC_UTIL_01.ENDOSSO
                 END,
                 VAT.CNRO_ENDSS,
                 VAT.DEMIS_ENDSS,
                 CASE
                   WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
                    'CE'
                   ELSE
                    'CN'
                 END,
                 MAC.CCRRTR_DSMEM,
                 VAT.CCHAVE_ORIGE_ENDSS,
                 VAT.CIND_PRODT_CRRTT_BCO,
                 VAT.CIND_PRODT_TLEMP;
        
        --DWSCHEDULER
        PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'BANCO APOLICE AUTO PRODUCAO DO CORRETOR '||VAR_CPF_CNPJ_BASE||'CARREGADA - COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
        COMMIT;
        --
               
       ----------------------------------------------------
       --ATUALIZANDO PRODUCAO DO CORRETOR X / COMPETENCIA Y
       --sgpb0135 EXTRA-BANCO - AUTO
       ----------------------------------------------------
       FOR c IN (SELECT I.COMPETENCIA ccompt_prod,
                        APC.cund_prod,
                        APC.ccrrtr,
                        ARP.CGRP_RAMO_PLANO,
                        APC.ctpo_comis,
                        COUNT(*) qtot_item_prod,
                        SUM(vprmio_emtdo_apolc) vprod_crrtr
               		 FROM AGPTO_RAMO_PLANO ARP
                   JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
                     -- FILTRANDO POR CORRETOR
                   JOIN CRRTR C
                     ON C.CCRRTR = APC.CCRRTR
                    AND C.CUND_PROD = APC.CUND_PROD
                    AND C.Ccrrtr BETWEEN VAR_FAIXA_INI_EX and VAR_FAIXA_FIM_EX
                    AND C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE
                     --
                  WHERE APC.DEMIS_APOLC BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND
                                                last_day(TO_DATE(I.COMPETENCIA,'YYYYMM'))
                   	AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto) --apenas auto
           		 GROUP BY I.COMPETENCIA,
                        APC.cund_prod,
                        APC.ccrrtr,
                 		    ARP.CGRP_RAMO_PLANO,
                        APC.ctpo_comis)

        LOOP --INSERT_UPDATE
        --CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
        insertUpdate(c.ccompt_prod,c.cund_prod,c.ccrrtr,c.cgrp_ramo_plano,c.ctpo_comis,c.qtot_item_prod,nvl(c.vprod_crrtr,0));

                -- APENAS APOLICES DO GRUPO AUTO E DO RAMO BILHETE TEM RELACIONAMENTO COM PRODUCAO
      /*          IF (C.CGRP_RAMO_PLANO IN (pc_util_01.Auto)) THEN
                 FOR c1 IN (SELECT ccia_segdr, cramo_apolc, capolc, citem_apolc, ctpo_docto, cendss_apolc, apc.demis_apolc
                             FROM AGPTO_RAMO_PLANO ARP
                             JOIN apolc_prod_crrtr APC
                               ON APC.CRAMO_APOLC = ARP.CRAMO
                               --  
                             JOIN CRRTR C
                               ON C.CCRRTR = APC.CCRRTR
                              AND C.CUND_PROD = APC.CUND_PROD
                              AND C.Ccrrtr BETWEEN VAR_FAIXA_INI_EX and  VAR_FAIXA_FIM_EX --faixa extra-banco
                              AND C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE
                               --
                              AND APC.CUND_PROD 	= c.cund_prod
                              AND APC.CCRRTR 		  = c.ccrrtr
                              AND APC.DEMIS_APOLC BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND
                              							     last_day(to_date(I.COMPETENCIA,'YYYYMM'))
                              AND APC.CTPO_COMIS 		= C.CTPO_COMIS
                            WHERE ARP.CGRP_RAMO_PLANO = c.cgrp_ramo_plano)
                 LOOP
                  	--  RECEBEMDO A CHAVE DE PRODUCAO
                    --DEBUGANDO UPDATE
                     PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'-->LINHA. '||C1.CCIA_SEGDR||' '||C1.CRAMO_APOLC||' '||C1.CAPOLC||' '||C1.CITEM_APOLC||' '||C1.CTPO_DOCTO||' '||C1.CENDSS_APOLC||' '||C1.demis_apolc,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
                  	 COMMIT;
                  	UPDATE APOLC_PROD_CRRTR
                     		SET CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO,
                         		CCOMPT_PROD     = C.CCOMPT_PROD
                   		WHERE CUND_PROD 		  = C.CUND_PROD
                     		AND CCIA_SEGDR 			= C1.CCIA_SEGDR
                     		AND CRAMO_APOLC 		= C1.CRAMO_APOLC
                     		AND CAPOLC 				  = C1.CAPOLC
                     		AND CITEM_APOLC 		= C1.CITEM_APOLC
                     		AND CTPO_DOCTO 			= C1.CTPO_DOCTO
                     		AND CENDSS_APOLC 		= C1.CENDSS_APOLC
                     		AND demis_apolc 		= C1.demis_apolc
                     		and CTPO_COMIS  		= C.CTPO_COMIS
                     		and CCRRTR      		= C.CCRRTR;
                  	IF (SQL%ROWCOUNT = 0) THEN
                  	    ROLLBACK;
                     		PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'ERRO EXTRA-BANCO. O UPDATE NAO AFETOU NENHUMA LINHA.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
                     		PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
                     		COMMIT;
                     		Raise_Application_Error(-20210,'ERRO EXTRA-BANCO. UPDATE NAO AFETOU NENHUMA LINHA.');
                  	END IF;
                 END LOOP;
                 END IF;*/

        VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
        IF ((VAR_CONTA_TOT mod 250) = 0) THEN
      	   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'EXTRA-BANCO ATE O MOMENTO FORAM ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
     	     COMMIT;
      	END IF;
        --
       END LOOP; --INSERT_UPDATE
   		 PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'EXTRA-BANCO PRODUCAO CARREGADA COM SUCESSO DA COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
  	   COMMIT;
       
       ----------------------------------------------------
       --ATUALIZANDO PRODUCAO DO CORRETOR X / COMPETENCIA Y
       --sgpb0135 BANCO - AUTO
       ----------------------------------------------------
       FOR c IN (SELECT I.COMPETENCIA ccompt_prod,
                        APC.cund_prod,
                        APC.ccrrtr,
                        ARP.CGRP_RAMO_PLANO,
                        APC.ctpo_comis,
                        COUNT(*) qtot_item_prod,
                        SUM(vprmio_emtdo_apolc) vprod_crrtr
               		 FROM AGPTO_RAMO_PLANO ARP
                   JOIN apolc_prod_crrtr APC ON APC.CRAMO_APOLC = ARP.CRAMO
                     -- FILTRANDO POR CORRETOR
                   JOIN CRRTR C
                     ON C.CCRRTR = APC.CCRRTR
                    AND C.CUND_PROD = APC.CUND_PROD
                     --                    
                   JOIN MPMTO_AG_CRRTR MAC
                     ON MAC.CUND_PROD = C.CUND_PROD
                    AND MAC.CCRRTR_DSMEM = C.CCRRTR
                    AND MAC.CCRRTR_ORIGN BETWEEN VAR_FAIXA_INI_BC AND VAR_FAIXA_FIM_BC --faixa banco                  
                     --
                  WHERE C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE 
                    AND APC.DEMIS_APOLC BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND
                                                last_day(TO_DATE(I.COMPETENCIA,'YYYYMM'))
                                                                                                                                                
                   	AND ARP.CGRP_RAMO_PLANO IN (pc_util_01.Auto) 
           		 GROUP BY I.COMPETENCIA,
                        APC.cund_prod,
                        APC.ccrrtr,
                 		    ARP.CGRP_RAMO_PLANO,
                        APC.ctpo_comis)
                        

        LOOP --INSERT_UPDATE
        --CADA LINHA AGRUPA É INSERIDA NA PRODUÇÃO (PROD_CRRTR)
        insertUpdate(c.ccompt_prod,c.cund_prod,c.ccrrtr,c.cgrp_ramo_plano,c.ctpo_comis,c.qtot_item_prod,nvl(c.vprod_crrtr,0));

                -- APENAS APOLICES DO GRUPO AUTO E DO RAMO BILHETE TEM RELACIONAMENTO COM PRODUCAO
 /*               IF (C.CGRP_RAMO_PLANO IN (pc_util_01.Auto)) THEN
                 FOR c1 IN (SELECT ccia_segdr, cramo_apolc, capolc, citem_apolc, ctpo_docto, cendss_apolc, apc.demis_apolc
                             FROM AGPTO_RAMO_PLANO ARP
                             JOIN apolc_prod_crrtr APC
                               ON APC.CRAMO_APOLC = ARP.CRAMO
                               --  
                             JOIN CRRTR C
                               ON C.CCRRTR = APC.CCRRTR
                              AND C.CUND_PROD = APC.CUND_PROD
                               --
                             JOIN MPMTO_AG_CRRTR MAC
                               ON MAC.CUND_PROD = C.CUND_PROD
                              AND MAC.CCRRTR_DSMEM = C.CCRRTR
                              AND MAC.CCRRTR_ORIGN BETWEEN VAR_FAIXA_INI_BC AND VAR_FAIXA_FIM_BC --faixa banco 
                               --
                            WHERE C.CCPF_CNPJ_BASE = VAR_CPF_CNPJ_BASE 
                              AND APC.DEMIS_APOLC BETWEEN to_date(I.COMPETENCIA,'YYYYMM') AND
                                                          last_day(TO_DATE(I.COMPETENCIA,'YYYYMM'))
                               --
                              AND APC.CUND_PROD 	    = c.cund_prod
                              AND APC.CCRRTR 		      = c.ccrrtr
                              AND APC.CTPO_COMIS 		  = c.CTPO_COMIS
                              AND ARP.CGRP_RAMO_PLANO = c.cgrp_ramo_plano)
                 LOOP
                    --  RECEBEMDO A CHAVE DE PRODUCAO
                  	UPDATE APOLC_PROD_CRRTR
                     		SET CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO,
                         		CCOMPT_PROD     = C.CCOMPT_PROD
                   		WHERE CUND_PROD 		  = C.CUND_PROD
                     		AND CCIA_SEGDR 			= C1.CCIA_SEGDR
                     		AND CRAMO_APOLC 		= C1.CRAMO_APOLC
                     		AND CAPOLC 				  = C1.CAPOLC
                     		AND CITEM_APOLC 		= C1.CITEM_APOLC
                     		AND CTPO_DOCTO 			= C1.CTPO_DOCTO
                     		AND CENDSS_APOLC 		= C1.CENDSS_APOLC
                     		AND demis_apolc 		= C1.demis_apolc
                     		and CTPO_COMIS  		= C.CTPO_COMIS
                     		and CCRRTR      		= C.CCRRTR;
                  	IF (SQL%ROWCOUNT = 0) THEN
                  	    ROLLBACK;
                     		PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'ERRO BANCO. O UPDATE NAO AFETOU NENHUMA LINHA.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
                     		PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
                     		COMMIT;
                     		Raise_Application_Error(-20210,'ERRO BANCO. UPDATE NAO AFETOU NENHUMA LINHA.');
                  	END IF;
                 END LOOP;
                 END IF;*/

        VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
        IF ((VAR_CONTA_TOT mod 250) = 0) THEN
      	   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'BANCO ATE O MOMENTO FORAM ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
     	     COMMIT;
      	END IF;
        --
       END LOOP; --INSERT_UPDATE
   		 PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'BANCO PRODUCAO CARREGADA COM SUCESSO DA COMPETENCIA :'||I.COMPETENCIA,'P',NULL,NULL);
  	   COMMIT;              
   --
   END LOOP; --FIM COMPETENCIA
   --
   --ATUALIZANDO TABELA DE APOLICE PARA BANCO E EXTRA-BANCO GRUPO RAMO 120 E COMPETENCIA 200704 200705 200706
   --
    --------------EXTRABANCO 200704
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200704
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                  APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                  APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                  APC.CAPOLC,        --chave apolc_prod_crrtr
                  APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                  APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                  APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                  APC.DEMIS_APOLC
                FROM AGPTO_RAMO_PLANO ARP
                  --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200704,'YYYYMM') AND
                                    last_day(TO_DATE(200704,'YYYYMM'))
                  --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.Ccrrtr BETWEEN 100000 and 199992 --faixa extra-banco
                 AND C.CCPF_CNPJ_BASE = 23865611
                 AND ARP.CGRP_RAMO_PLANO = 120);
    --
    COMMIT;
    --
    --------------EXTRABANCO 200705
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200705
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                  APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                  APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                  APC.CAPOLC,        --chave apolc_prod_crrtr
                  APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                  APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                  APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                  APC.DEMIS_APOLC
                FROM AGPTO_RAMO_PLANO ARP
                  --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200705,'YYYYMM') AND
                                    last_day(TO_DATE(200705,'YYYYMM'))
                  --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.Ccrrtr BETWEEN 100000 and 199992 --faixa extra-banco
                 AND C.CCPF_CNPJ_BASE = 23865611
                 AND ARP.CGRP_RAMO_PLANO = 120); 
    --
    COMMIT;
    --
    --------------EXTRABANCO 200706
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200706
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                  APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                  APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                  APC.CAPOLC,        --chave apolc_prod_crrtr
                  APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                  APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                  APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                  APC.DEMIS_APOLC
                FROM AGPTO_RAMO_PLANO ARP
                  --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200706,'YYYYMM') AND
                                    last_day(TO_DATE(200706,'YYYYMM'))
                  --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.Ccrrtr BETWEEN 100000 and 199992 --faixa extra-banco
                 AND C.CCPF_CNPJ_BASE = 23865611
                 AND ARP.CGRP_RAMO_PLANO = 120);  
    --
    COMMIT;
    --
    --------------BANCO 200704
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200704
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (   SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                     APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                     APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                     APC.CAPOLC,        --chave apolc_prod_crrtr
                     APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                     APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                     APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                     APC.DEMIS_APOLC    --chave apolc_prod_crrtr
                --
                FROM AGPTO_RAMO_PLANO ARP
                --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200704,'YYYYMM') AND
                                    last_day(TO_DATE(200704,'YYYYMM'))
                --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.CCPF_CNPJ_BASE = 23865611--cnpj base do corretor
                --
                JOIN MPMTO_AG_CRRTR MAC
                  ON MAC.CUND_PROD = C.CUND_PROD
                 AND MAC.CCRRTR_DSMEM = C.CCRRTR
                 AND MAC.CCRRTR_ORIGN BETWEEN 800000 AND 870000 --faixa banco
                --
                WHERE ARP.CGRP_RAMO_PLANO = 120);
    --
    COMMIT;
    --
    --------------BANCO 200705
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200705
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (   SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                     APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                     APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                     APC.CAPOLC,        --chave apolc_prod_crrtr
                     APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                     APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                     APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                     APC.DEMIS_APOLC    --chave apolc_prod_crrtr
                --
                FROM AGPTO_RAMO_PLANO ARP
                --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200705,'YYYYMM') AND
                                    last_day(TO_DATE(200705,'YYYYMM'))
                --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.CCPF_CNPJ_BASE = 23865611--cnpj base do corretor
                --
                JOIN MPMTO_AG_CRRTR MAC
                  ON MAC.CUND_PROD = C.CUND_PROD
                 AND MAC.CCRRTR_DSMEM = C.CCRRTR
                 AND MAC.CCRRTR_ORIGN BETWEEN 800000 AND 870000 --faixa banco
                --
                WHERE ARP.CGRP_RAMO_PLANO = 120);
    --
    COMMIT;
    --
    --------------BANCO 200706
    UPDATE APOLC_PROD_CRRTR
    	 SET CGRP_RAMO_PLANO = 120,
           CCOMPT_PROD = 200706
    WHERE (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC) 
    IN    (   SELECT APC.CUND_PROD,     --chave apolc_prod_crrtr
                     APC.CCIA_SEGDR,    --chave apolc_prod_crrtr
                     APC.CRAMO_APOLC,   --chave apolc_prod_crrtr
                     APC.CAPOLC,        --chave apolc_prod_crrtr
                     APC.CITEM_APOLC,   --chave apolc_prod_crrtr
                     APC.CTPO_DOCTO,    --chave apolc_prod_crrtr
                     APC.CENDSS_APOLC,  --chave apolc_prod_crrtr
                     APC.DEMIS_APOLC    --chave apolc_prod_crrtr
                --
                FROM AGPTO_RAMO_PLANO ARP
                --
                JOIN APOLC_PROD_CRRTR APC
                  ON APC.CRAMO_APOLC = ARP.CRAMO
                 AND APC.DEMIS_APOLC BETWEEN TO_DATE(200706,'YYYYMM') AND
                                    last_day(TO_DATE(200706,'YYYYMM'))
                --
                JOIN CRRTR C
                  ON C.CCRRTR = APC.CCRRTR
                 AND C.CUND_PROD = APC.CUND_PROD
                 AND C.CCPF_CNPJ_BASE = 23865611--cnpj base do corretor
                --
                JOIN MPMTO_AG_CRRTR MAC
                  ON MAC.CUND_PROD = C.CUND_PROD
                 AND MAC.CCRRTR_DSMEM = C.CCRRTR
                 AND MAC.CCRRTR_ORIGN BETWEEN 800000 AND 870000 --faixa banco
                --
                WHERE ARP.CGRP_RAMO_PLANO = 120);
    --
    COMMIT;
    --
   --
   --FIM DA ATUALIZANDO TABELA DE APOLICE PARA BANCO E EXTRA-BANCO GRUPO RAMO 120 E COMPETENCIA 200704 200705 200706
   --         
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
   --PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TOTAL ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
   COMMIT;
   --
END SGPB9919;
/

