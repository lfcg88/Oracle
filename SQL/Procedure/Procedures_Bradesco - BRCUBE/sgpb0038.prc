CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0038
( intrCompetencia       Prod_Crrtr.CCOMPT_PROD %TYPE,
  intCodCanal_vda_segur parm_canal_vda_segur.ccanal_vda_segur %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0038' )
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0038
  --      DATA            : 23/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para realizar a liberação de apurações liberadas pelo gestor
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
  Var_Irotna 			 INT := 000;
  var_und_prod			 number;
  VAR_ctpo_pssoa	     VARCHAR2(10);
  VAR_ccpf_cnpj_base	 NUMBER;
BEGIN
  if (intCodCanal_vda_segur = PC_UTIL_01.Banco) then
     Var_Irotna := 842;
  elsif (intCodCanal_vda_segur = PC_UTIL_01.Finasa) then
    Var_Irotna := 843;
  elsif (intCodCanal_vda_segur = PC_UTIL_01.EXTRA_BANCO) then
    Var_Irotna := 851;
  end if;
  chrLocalErro := 01;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna,'PC');
  commit;
  chrLocalErro := 02;
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
   		WHERE ( ccanal_vda_segur, ctpo_apurc, ccompt_apurc, cgrp_ramo_plano, ccompt_prod, ctpo_comis, ccrrtr, cund_prod )
         	IN ( SELECT apc3.ccanal_vda_segur, apc3.ctpo_apurc, apc3.ccompt_apurc, apc3.cgrp_ramo_plano, apc3.ccompt_prod,
                  	    apc3.ctpo_comis, apc3.ccrrtr, apc3.cund_prod
                  	    FROM apurc_prod_crrtr apc3
            			JOIN prod_crrtr pc ON pc.ccrrtr = apc3.ccrrtr
                              AND pc.cund_prod = apc3.cund_prod
                              AND pc.cgrp_ramo_plano = apc3.cgrp_ramo_plano
                              AND pc.ccompt_prod = apc3.ccompt_prod
                              AND pc.ctpo_comis = apc3.ctpo_comis
            			JOIN crrtr c ON c.ccrrtr = pc.ccrrtr
                        	  AND c.cund_prod = pc.cund_prod
           				WHERE APC3.CSIT_APURC IN ('LG','LS')   -- LIBERADO PELO GESTOR, LIBERADO PELO SISTEMA
             		          AND APC3.CCANAL_VDA_SEGUR = intCodCanal_vda_segur
             		          AND NOT EXISTS (	SELECT 1 FROM papel_apurc_pgto PAP
                   									WHERE PAP.ccanal_vda_segur = APC3.ccanal_vda_segur
                     								AND PAP.ctpo_apurc = APC3.ctpo_apurc
                     								AND PAP.ccompt_apurc = APC3.ccompt_apurc
                     								AND PAP.cgrp_ramo_plano = APC3.cgrp_ramo_plano
                     								AND PAP.ccompt_prod = APC3.ccompt_prod
                     								AND PAP.ctpo_comis = APC3.ctpo_comis
                     								AND PAP.ccrrtr = APC3.ccrrtr
                     								AND PAP.cund_prod = APC3.cund_prod)
          );
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
--acysne
--    			VALUES (intProxCodigoPgtoCrrtr, ca.total, ca.ctpo_pssoa, ca.ccpf_cnpj_base, intrCompetencia, 3, 0);
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
                     AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base
                     and pc.vprod_crrtr > 0 /*rateio*/
                   GROUP BY c.ccpf_cnpj_base, c.ctpo_pssoa, apc.cund_prod)
    LOOP
      chrLocalErro := 11;
      -- Busca o maior CPD por sucursal
      SELECT ss.Ccrrtr, ss.total
        	 INTO intCodMaiorCrrtr, intCodMaiorValorCrrtr
        	FROM (SELECT ss.Ccrrtr, ss.cund_prod, ss.total
                		FROM
                		(SELECT c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod, apc.Ccrrtr, SUM(pc.vprod_crrtr) AS total
                        	FROM apurc_prod_crrtr apc
                        	JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                         					AND c.cund_prod = apc.cund_prod
                        	JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                            AND pc.cund_prod = apc.cund_prod
                                            AND pc.ccrrtr = apc.ccrrtr
                                            AND pc.ccompt_prod = apc.ccompt_prod
                                            AND pc.ctpo_comis = apc.ctpo_comis
                       		WHERE apc.cind_apurc_selec = 1
                         	AND c.Ctpo_Pssoa = caInt.ctpo_pssoa
                         	AND c.Ccpf_Cnpj_Base = caInt.ccpf_cnpj_base
                         	and apc.cund_prod = caInt.cund_prod
                       		GROUP BY c.ctpo_pssoa, c.ccpf_cnpj_base, apc.cund_prod, apc.Ccrrtr
                  		) ss
         		ORDER BY ss.total DESC) ss
       		WHERE ROWnum < 2;
      chrLocalErro := 12;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS E PGTO
      var_und_prod := caInt.cund_prod;
      VAR_ctpo_pssoa := ca.ctpo_pssoa;
      VAR_ccpf_cnpj_base := ca.ccpf_cnpj_base;
      INSERT INTO hist_distr_pgto (vdistr_pgto_crrtr, cpgto_bonus, ccrrtr, cund_prod)
      		VALUES (caInt.Total - ( ca.totalnegativo * (caInt.Total/ca.totalModulo) ),  /*rateio*/
         			intProxCodigoPgtoCrrtr, intCodMaiorCrrtr, var_und_prod);

    END LOOP;
    chrLocalErro := 13;
    -- Insere os registros na tabela de papel-apuracao-pagamento
    FOR caInt IN (SELECT apc.ccompt_apurc, apc.ccanal_vda_segur, apc.cgrp_ramo_plano, apc.ccompt_prod,
                         apc.ctpo_comis, apc.ctpo_apurc, apc.ccrrtr, apc.cund_prod, apc.pbonus_apurc
                    	FROM apurc_prod_crrtr apc
                    	JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                         AND c.cund_prod = apc.cund_prod
                   		WHERE apc.cind_apurc_selec = 1
                     	AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     	AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base)
    LOOP
      chrLocalErro := 14;
      INSERT INTO papel_apurc_pgto
        			(cpgto_bonus, ccrrtr, cund_prod, ccanal_vda_segur, ctpo_apurc, ccompt_apurc, cgrp_ramo_plano,
         			 ccompt_prod, ctpo_comis, cindcd_papel)
      		VALUES (intProxCodigoPgtoCrrtr, caInt.Ccrrtr, caInt.Cund_Prod, caInt.Ccanal_Vda_Segur, caInt.Ctpo_Apurc,
         			caInt.Ccompt_Apurc, caInt.Cgrp_Ramo_Plano, caInt.Ccompt_Prod, caInt.Ctpo_Comis, 0);
      chrLocalErro := 15;
      -- Atualiza a situacao da Apuracao para paga
      UPDATE apurc_prod_crrtr
         SET csit_apurc = 'PL'
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
  chrLocalErro := 17;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna,'PO');
  chrLocalErro := 18;
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'TERMINO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||
                         ' COMPETENCIA: '||to_char(intrCompetencia)||' Canal: '||to_char(intCodCanal_vda_segur),'P',NULL,NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) ||
                           ' Canal: ' || to_char(intCodCanal_vda_segur) || ' Cod.Pgto: '||intProxCodigoPgtoCrrtr||
                           ' Corretor: '||intCodMaiorCrrtr||' Und.Prod: '||var_und_prod||' VAR_ctpo_pssoa: '||VAR_ctpo_pssoa||
                           ' VAR_ccpf_cnpj_base: '||VAR_ccpf_cnpj_base||' # ' || SQLERRM, 1, 500);
    -- intProxCodigoPgtoCrrtr, intCodMaiorCrrtr, caInt.Cund_Prod
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler, var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Irotna,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    RAISE_APPLICATION_ERROR(-20001,var_log_erro);
END SGPB0038;
/

