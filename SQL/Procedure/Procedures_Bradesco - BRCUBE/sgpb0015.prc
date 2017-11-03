CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0015
( intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  intCodCanal_vda_segur  parm_canal_vda_segur.ccanal_vda_segur %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0015' )
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0015
  --      DATA            : 9/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para realizar a liberação de apurações retidas com tempo maior que o limite
  --      ALTERAÇÕES      : 07/08/2007 - Melhorias - Ass. Wassily
  --                        08/08/2007 - Rotina era diária, alterada para trimestral - Ass. Wassily
  -------------------------------------------------------------------------------------------------
 IS
  intQmes_max_rtcao      parm_canal_vda_segur.qmes_max_rtcao%TYPE;
  intProxCodigoPgtoCrrtr pgto_bonus_crrtr.cpgto_bonus%TYPE;
  intCodMaiorCrrtr       crrtr.ccrrtr%TYPE;
  intCodMaiorValorCrrtr  prod_crrtr.vprod_crrtr%TYPE;
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  Var_Irotna INT := 000;
BEGIN
  if (intCodCanal_vda_segur = PC_UTIL_01.Banco) then
     Var_Irotna := 837;
  elsif (intCodCanal_vda_segur = PC_UTIL_01.Finasa) then
    Var_Irotna := 838;
  elsif (intCodCanal_vda_segur = PC_UTIL_01.Extra_Banco) then
    Var_Irotna := 839;
  end if;
  chrLocalErro := 01;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna, 'PC');
  commit;
  chrLocalErro := 04;
  -- Zera a tabela temporária
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  chrLocalErro := 05;
  --  busca informações para o canal
  SELECT qmes_max_rtcao INTO intQmes_max_rtcao
    	FROM parm_canal_vda_segur pcvs
   		WHERE pcvs.ccanal_vda_segur = intCodCanal_vda_segur
     	AND Sgpb0016(intrCompetencia) BETWEEN pcvs.dinic_vgcia_parm AND nvl(pcvs.dfim_vgcia_parm,to_date('99991231','YYYYMMDD'));
  chrLocalErro := 06;
  --insere na temporaria todos os registros selecionados para trabalho
  UPDATE apurc_prod_crrtr
     SET cind_apurc_selec = 1
   WHERE (ccanal_vda_segur, ctpo_apurc, ccompt_apurc, cgrp_ramo_plano, ccompt_prod, ctpo_comis, ccrrtr, cund_prod
         ) IN (
          		SELECT APC3.ccanal_vda_segur, APC3.ctpo_apurc, APC3.ccompt_apurc, APC3.cgrp_ramo_plano, APC3.ccompt_prod,
                  		APC3.ctpo_comis, APC3.ccrrtr, APC3.cund_prod
            			FROM apurc_prod_crrtr apc3
           				WHERE APC3.CSIT_APURC in (/*'AP',*/'BG','LM','LP','LG')
             			AND APC3.CCANAL_VDA_SEGUR = intCodCanal_vda_segur
             			AND apc3.ccompt_apurc <= pc_util_01.SGPB0017(intrCompetencia,intQmes_max_rtcao)
             			AND NOT EXISTS (SELECT 1
                    						FROM papel_apurc_pgto PAP
                   								WHERE PAP.ccanal_vda_segur = APC3.ccanal_vda_segur
                     							AND PAP.ctpo_apurc = APC3.ctpo_apurc
                     							AND PAP.ccompt_apurc = APC3.ccompt_apurc
                     							AND PAP.cgrp_ramo_plano = APC3.cgrp_ramo_plano
                     							AND PAP.ccompt_prod = APC3.ccompt_prod
                     							AND PAP.ctpo_comis = APC3.ctpo_comis
                     							AND PAP.ccrrtr = APC3.ccrrtr
                     							AND PAP.cund_prod = APC3.cund_prod));
  chrLocalErro := 07;
  -- Pega o próximo registro a ser inserido
  SELECT nvl(MAX(cpgto_bonus),0) + 1 INTO intProxCodigoPgtoCrrtr
    		FROM pgto_bonus_crrtr;
  chrLocalErro := 08;
  -- Insere os registros na tabela de pagamento
  FOR ca IN (SELECT c.ctpo_pssoa, c.ccpf_cnpj_base,
                    SUM(CASE
                          WHEN pap.ccrrtr IS NULL THEN
                           pc.vprod_crrtr * (apc.pbonus_apurc / 100)
                          ELSE
                           0
                        END) AS total,
                    SUM(CASE
                          WHEN ((pap.ccrrtr IS NULL) AND (pc.vprod_crrtr > 0)) THEN
                           abs(pc.vprod_crrtr * (apc.pbonus_apurc / 100))
                          ELSE
                           0
                        END) AS totalModulo,/*rateio*/
                    SUM(CASE
                          WHEN ((pap.ccrrtr IS NULL) AND (pc.vprod_crrtr < 0)) THEN
                           abs(pc.vprod_crrtr * (apc.pbonus_apurc / 100))
                          ELSE
                           0
                        END) AS totalNegativo /*rateio*/
               FROM apurc_prod_crrtr apc
               JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                    AND c.cund_prod = apc.cund_prod
               JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                          AND pc.cund_prod = apc.cund_prod
                                          AND pc.ccrrtr = apc.ccrrtr
                                          AND pc.ccompt_prod = apc.ccompt_prod
                                          AND pc.ctpo_comis = apc.ctpo_comis
               LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                             AND PAP.ctpo_apurc = apc.ctpo_apurc
                                             AND PAP.ccompt_apurc = apc.ccompt_apurc
                                             AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                             AND PAP.ccompt_prod = apc.ccompt_prod
                                             AND PAP.ctpo_comis = apc.ctpo_comis
                                             AND PAP.ccrrtr = apc.ccrrtr
                                             AND PAP.cund_prod = apc.cund_prod
                                             AND pap.cindcd_papel = 0
              WHERE apc.cind_apurc_selec = 1
              GROUP BY c.ccpf_cnpj_base, c.ctpo_pssoa)
  LOOP
    chrLocalErro := 09;
    -- Inserindo os registros na tabela de pagamento
    INSERT INTO pgto_bonus_crrtr (cpgto_bonus,vpgto_tot, ctpo_pssoa, ccpf_cnpj_base, ccompt_pgto, ctpo_pgto, cind_arq_expor)
    		VALUES (intProxCodigoPgtoCrrtr,ca.total,ca.ctpo_pssoa,ca.ccpf_cnpj_base,intrCompetencia,1,0);
--acysne
--    		VALUES (intProxCodigoPgtoCrrtr,ca.total,ca.ctpo_pssoa,ca.ccpf_cnpj_base,intrCompetencia,3,0);
    chrLocalErro := 10;
    -- Insere os registros na tabela de historico-distribuicao-pagamento-bonus
    FOR caInt IN (SELECT c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod,
                         SUM(CASE
                               WHEN pap.ccrrtr IS NULL THEN
                                pc.vprod_crrtr * (apc.pbonus_apurc / 100)
                               ELSE
                                0
                             END) AS total
                    FROM apurc_prod_crrtr apc
                    JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                         AND c.cund_prod = apc.cund_prod
                    JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                               AND pc.cund_prod = apc.cund_prod
                                               AND pc.ccrrtr = apc.ccrrtr
                                               AND pc.ccompt_prod = apc.ccompt_prod
                                               AND pc.ctpo_comis = apc.ctpo_comis
                    LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                                  AND PAP.ctpo_apurc = apc.ctpo_apurc
                                                  AND PAP.ccompt_apurc = apc.ccompt_apurc
                                                  AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                  AND PAP.ccompt_prod = apc.ccompt_prod
                                                  AND PAP.ctpo_comis = apc.ctpo_comis
                                                  AND PAP.ccrrtr = apc.ccrrtr
                                                  AND PAP.cund_prod = apc.cund_prod
                                                  AND pap.cindcd_papel = 0
                   WHERE apc.cind_apurc_selec = 1
                     and pc.vprod_crrtr > 0 /*rateio*/
                     AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base
                   GROUP BY c.ccpf_cnpj_base, c.ctpo_pssoa, apc.cund_prod)
    LOOP
      chrLocalErro := 14;
      -- Busca o maior CPD por sucursal
      SELECT ss.Ccrrtr, ss.total INTO intCodMaiorCrrtr, intCodMaiorValorCrrtr
        	FROM (SELECT ss.Ccrrtr, ss.total
                	FROM (SELECT c.ctpo_pssoa,
                             c.ccpf_cnpj_base,
                             apc.cund_prod,
                             apc.Ccrrtr,
                             SUM(pc.vprod_crrtr) AS total
                        	FROM apurc_prod_crrtr apc
                        	JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                             AND c.cund_prod = apc.cund_prod
                        	JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                   AND pc.cund_prod = apc.cund_prod
                                                   AND pc.ccrrtr = apc.ccrrtr
                                                   AND pc.ccompt_prod = apc.ccompt_prod
                                                   AND pc.ctpo_comis = apc.ctpo_comis
                       		WHERE apc.cind_apurc_selec = 1
                         		AND c.ctpo_pssoa = caInt.ctpo_pssoa
                         		AND c.ccpf_cnpj_base = caInt.ccpf_cnpj_base
                       		GROUP BY c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod, apc.Ccrrtr) ss
               		ORDER BY ss.total DESC) ss
        	WHERE ROWnum < 2;
      chrLocalErro := 15;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS
      INSERT INTO hist_distr_pgto (vdistr_pgto_crrtr, cpgto_bonus, ccrrtr, cund_prod)
      			VALUES (caInt.Total - ( ca.totalnegativo * (caInt.Total / ca.totalModulo) ),  /*rateio*/
                		intProxCodigoPgtoCrrtr,  intCodMaiorCrrtr, caInt.Cund_Prod);
    END LOOP;
    chrLocalErro := 13;
    -- Insere os registros na tabela de papel-apuracao-pagamento
    FOR caInt IN (SELECT apc.ccompt_apurc, apc.ccanal_vda_segur, apc.cgrp_ramo_plano, apc.ccompt_prod, apc.ctpo_comis,
                         apc.ctpo_apurc, apc.ccrrtr, apc.cund_prod, apc.pbonus_apurc
                    	FROM apurc_prod_crrtr apc
                    	JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                     AND c.cund_prod = apc.cund_prod
                   		WHERE apc.cind_apurc_selec = 1
                     		AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     		AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base)
    LOOP
      chrLocalErro := 11;
      INSERT INTO papel_apurc_pgto (cpgto_bonus, ccrrtr, cund_prod, ccanal_vda_segur, ctpo_apurc,
      								ccompt_apurc, cgrp_ramo_plano,ccompt_prod, ctpo_comis, cindcd_papel)
      VALUES (intProxCodigoPgtoCrrtr, caInt.Ccrrtr, caInt.Cund_Prod, caInt.Ccanal_Vda_Segur,
      		  caInt.Ctpo_Apurc, caInt.Ccompt_Apurc,caInt.Cgrp_Ramo_Plano, caInt.Ccompt_Prod, caInt.Ctpo_Comis, 0);
      chrLocalErro := 12;
      -- Atualiza a situacao da Apuracao para paga
      UPDATE apurc_prod_crrtr
         	SET csit_apurc = 'PR'
       WHERE ccanal_vda_segur = caInt.Ccanal_Vda_Segur
         AND ctpo_apurc = caInt.Ctpo_Apurc
         AND ccompt_apurc = caInt.Ccompt_Apurc
         AND cgrp_ramo_plano = caInt.Cgrp_Ramo_Plano
         AND ccompt_prod = caInt.Ccompt_Prod
         AND ctpo_comis = caInt.Ctpo_Comis
         AND ccrrtr = caInt.Ccrrtr
         AND cund_prod = caInt.Cund_Prod;
    END LOOP;
    chrLocalErro := 16;
    -- acrescenta um no contador
    intProxCodigoPgtoCrrtr := intProxCodigoPgtoCrrtr + 1;
  END LOOP;
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  chrLocalErro := 17;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna, 'PO');
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'TERMINO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||
                         ' COMPETENCIA: '||to_char(intrCompetencia)||' Canal: '||to_char(intCodCanal_vda_segur),'P',NULL,NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: '||chrLocalErro||' Compet: '||to_char(intrCompetencia) ||
                           ' Canal: '||to_char(intCodCanal_vda_segur)||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler, var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna, PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20212,VAR_LOG_ERRO);
END SGPB0015;
/

