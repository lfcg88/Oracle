CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0027
( intrCompetencia       Prod_Crrtr.CCOMPT_PROD %TYPE,
  intCodCanal_vda_segur parm_canal_vda_segur.ccanal_vda_segur %TYPE,
  chrNomeRotinaScheduler VARCHAR2 )
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0027
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure pagamento de apuracoes liberadas; - Banco E FINASA
  --      ALTERAÇÕES      : 07/08/2007 - Melhorias - Wassily
  --                        08/08/2007 - Rotina era diária, alterada para trimestral - Ass. Wassily
  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  intProxCodigoPgtoCrrtr pgto_bonus_crrtr.cpgto_bonus%TYPE;
  intCodMaiorCrrtr crrtr.ccrrtr%TYPE;
  Var_Irotna number := 000;
BEGIN
  if (intCodCanal_vda_segur = PC_UTIL_01.Banco) then
     Var_Irotna := 840;
  elsif (intCodCanal_vda_segur = PC_UTIL_01.Finasa) then
    Var_Irotna := 841;
  end if;
  chrLocalErro := 01;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna,'PC');
  commit;
  chrLocalErro := 04;
  -- Zera a tabela temporária
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  chrLocalErro := 05;
  --insere na temporaria todos os registros selecionados para trabalho
  UPDATE apurc_prod_crrtr
     	SET cind_apurc_selec = 1
   WHERE ( ccanal_vda_segur, ctpo_apurc, ccompt_apurc, cgrp_ramo_plano, ccompt_prod, ctpo_comis, ccrrtr, cund_prod 
         ) IN (	SELECT apc.ccanal_vda_segur, apc.ctpo_apurc, apc.ccompt_apurc, apc.cgrp_ramo_plano, apc.ccompt_prod,
                 	   apc.ctpo_comis, apc.ccrrtr, apc.cund_prod
                  		FROM apurc_prod_crrtr APC
           				WHERE APC.ccanal_vda_segur = intCodCanal_vda_segur
                		AND APC.CSIT_APURC IN ('LP','BG','LM') -- CODIGOS DE APURAÇÕES
          );
  chrLocalErro := 06;
  UPDATE apurc_prod_crrtr TT
     		SET csit_apurc = 'PG'
   		WHERE TT.Csit_Apurc IN ('LP','BG','LM')
     	AND TT.ccanal_vda_segur = intCodCanal_vda_segur;
  chrLocalErro := 07;
  -- Pega o próximo registro a ser inserido
  SELECT nvl(MAX(cpgto_bonus), 0) + 1 INTO intProxCodigoPgtoCrrtr
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
    INSERT INTO pgto_bonus_crrtr (cpgto_bonus, vpgto_tot, ctpo_pssoa, ccpf_cnpj_base, ccompt_pgto, ctpo_pgto, cind_arq_expor)
    			VALUES (intProxCodigoPgtoCrrtr, ca.total, ca.ctpo_pssoa, ca.ccpf_cnpj_base, intrCompetencia, 1, 0);
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
      chrLocalErro := 11;
      -- Busca o maior CPD por sucursal
      SELECT ss.Ccrrtr INTO intCodMaiorCrrtr
        	FROM (SELECT ss.Ccrrtr, ss.total
                			FROM (SELECT c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod, apc.Ccrrtr, SUM(pc.vprod_crrtr) AS total
                        						FROM apurc_prod_crrtr apc
                        						JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                             						AND c.cund_prod = apc.cund_prod
                        						JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                   					AND pc.cund_prod = apc.cund_prod
                                                   					AND pc.ccrrtr = apc.ccrrtr
                                                   					AND pc.ccompt_prod = apc.ccompt_prod
                                                   					AND pc.ctpo_comis = apc.ctpo_comis
                       							WHERE apc.cind_apurc_selec = 1
                         								AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                         								AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base
                         								AND c.cund_prod = caInt.Cund_Prod
                       							GROUP BY c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod, apc.Ccrrtr) ss
               									ORDER BY ss.total DESC) ss
       		WHERE ROWnum < 2;
      chrLocalErro := 12;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS
      INSERT INTO hist_distr_pgto (vdistr_pgto_crrtr, cpgto_bonus, ccrrtr, cund_prod)
      		VALUES (caInt.Total - ( ca.totalnegativo * (caInt.Total/ca.totalModulo) ) ,  /*rateio*/
         			intProxCodigoPgtoCrrtr, intCodMaiorCrrtr, caInt.Cund_Prod);
    END LOOP;
    chrLocalErro := 13;
    -- Insere os registros na tabela de papel-apuracao-pagamento
    FOR caInt IN (SELECT apc.ccompt_apurc, apc.ccanal_vda_segur, apc.cgrp_ramo_plano, apc.ccompt_prod, apc.ctpo_comis,
                         apc.ctpo_apurc, apc.ccrrtr, apc.cund_prod, apc.pbonus_apurc,
                         CASE
                           WHEN pap.ccrrtr IS NULL THEN
                            		0
                           ELSE
                            		1
                         END TemPagamento
                    	FROM apurc_prod_crrtr apc
                    	JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                         AND c.cund_prod = apc.cund_prod
                    	LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur =
                                                           apc.ccanal_vda_segur
                                                       AND PAP.ctpo_apurc = apc.ctpo_apurc
                                                       AND PAP.ccompt_apurc = apc.ccompt_apurc
                                                       AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                       AND PAP.ccompt_prod = apc.ccompt_prod
                                                       AND PAP.ctpo_comis = apc.ctpo_comis
                                                       AND PAP.ccrrtr = apc.ccrrtr
                                                       AND PAP.cund_prod = apc.cund_prod
                                                       AND pap.cindcd_papel = 0
                   		WHERE APC.CIND_APURC_SELEC = 1
                     		AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     		AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base) 
    LOOP
      chrLocalErro := 14;
      -- Insere papel eleição
      INSERT INTO papel_apurc_pgto
        (cpgto_bonus, ccrrtr, cund_prod, ccanal_vda_segur, ctpo_apurc, ccompt_apurc, 
         cgrp_ramo_plano, ccompt_prod, ctpo_comis, cindcd_papel)
      VALUES
        (intProxCodigoPgtoCrrtr, caInt.Ccrrtr, caInt.Cund_Prod, caInt.Ccanal_Vda_Segur, 
         caInt.Ctpo_Apurc, caInt.Ccompt_Apurc, caInt.Cgrp_Ramo_Plano, caInt.Ccompt_Prod, caInt.Ctpo_Comis, 1);
      /* não tem pagamento*/
      IF caint.tempagamento = 0 THEN
        	chrLocalErro := 15;
        	-- Insere papel pagamento se naum tiver antes claro
        	INSERT INTO papel_apurc_pgto (cpgto_bonus, ccrrtr, cund_prod, ccanal_vda_segur, ctpo_apurc, 
        						      ccompt_apurc, cgrp_ramo_plano, ccompt_prod, ctpo_comis, cindcd_papel)
        		VALUES (intProxCodigoPgtoCrrtr, caInt.Ccrrtr, caInt.Cund_Prod, caInt.Ccanal_Vda_Segur, caInt.Ctpo_Apurc,
           				caInt.Ccompt_Apurc, caInt.Cgrp_Ramo_Plano, caInt.Ccompt_Prod, caInt.Ctpo_Comis, 0);
      END IF;
    END LOOP;
    chrLocalErro := 16;
    -- acrescenta um no contador
    intProxCodigoPgtoCrrtr := intProxCodigoPgtoCrrtr + 1;
  END LOOP;
  chrLocalErro := 17;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna, 'PO');
  chrLocalErro := 18;
  -- Volta a configuração inicial
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  chrLocalErro := 19;
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'TERMINO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||
                         ' COMPETENCIA: '||to_char(intrCompetencia)||' Canal: '||to_char(intCodCanal_vda_segur),'P',NULL,NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) ||
                           ' Canal: ' || to_char(intCodCanal_vda_segur) || ' # ' || SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler, var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna, PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20212,VAR_LOG_ERRO);
END SGPB0027;
/

