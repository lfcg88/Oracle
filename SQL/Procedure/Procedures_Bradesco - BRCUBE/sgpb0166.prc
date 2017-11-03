CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0166
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  intrCanal              Parm_Canal_Vda_Segur.Ccanal_Vda_Segur %type,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0166'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0166
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para pagar automaticamente as apurações que ultrapassem o minimo para tal - extrabanco;
  --      ALTERAÇÕES      : OBSOLETA. ASS. WASSILY (NÃO ESTÁ NEM EM PRODUCAO)
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  intQmes_perdc_pgtoN    parm_per_apurc_canal.qmes_perdc_pgto%TYPE;
  intQmes_perdc_pgtoE    parm_per_apurc_canal.qmes_perdc_pgto%TYPE;
  intProxCodigoPgtoCrrtr pgto_bonus_crrtr.cpgto_bonus%TYPE;
  intvmin_librc_pgto     parm_canal_vda_segur.vmin_librc_pgto%TYPE;
  intCodMaiorCrrtr crrtr.ccrrtr%TYPE;
BEGIN
  chrLocalErro := 01;
  --  Informa ao scheduler o começo da procedure
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, 708,
                                 'PC');
  --
  chrLocalErro := 02;
  -- Zera a tabela temporária
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  --
  chrLocalErro := 05;
  --  busca o minimo para liberar o pagamento para o canal tipo normal
  SELECT pcvs.vmin_librc_pgto
    INTO intvmin_librc_pgto
    FROM parm_canal_vda_segur pcvs
   WHERE pcvs.ccanal_vda_segur = intrCanal
     AND Sgpb0016(intrCompetencia) BETWEEN pcvs.dinic_vgcia_parm AND
         nvl(pcvs.dfim_vgcia_parm,
             to_date('99991231',
                     'YYYYMMDD'));
  --
  chrLocalErro := 06;
  --  busca de quanto em quanto tempo paga-se para o canal NORMAL
  SELECT qmes_perdc_pgto
    INTO intQmes_perdc_pgtoN
    FROM parm_per_apurc_canal ppac
   WHERE ccanal_vda_segur = intrCanal
     AND ppac.ctpo_apurc = pc_util_01.NORMAL
     AND Sgpb0016(intrCompetencia) BETWEEN ppac.dinic_vgcia_parm AND
         nvl(ppac.dfim_vgcia_parm,
             to_date('99991231',
                     'YYYYMMDD'));
  --
  --
  --
  chrLocalErro := 07;
  --  busca de quanto em quanto tempo paga-se para o canal EXTRA
  SELECT qmes_perdc_pgto
    INTO intQmes_perdc_pgtoE
    FROM parm_per_apurc_canal ppac
   WHERE ccanal_vda_segur = intrCanal
     AND ppac.ctpo_apurc = pc_util_01.EXTRA
     AND Sgpb0016(intrCompetencia) BETWEEN ppac.dinic_vgcia_parm AND
         nvl(ppac.dfim_vgcia_parm,
             to_date('99991231',
                     'YYYYMMDD'));
  --
  --
  chrLocalErro := 08;
  -- insere na temporaria todos os registros selecionados para trabalho no periodo - NORMAL
  SGPB0034(pc_util_01.NORMAL,
           intQmes_perdc_pgtoN,
           intrCompetencia,
           intrCanal);
  Commit;
  --
  --
  chrLocalErro := 09;
  -- insere na temporaria todos os registros selecionados para trabalho no periodo - EXTRA
  SGPB0083(pc_util_01.EXTRA,
           intQmes_perdc_pgtoE,
           intrCompetencia,
           intrCanal);
  Commit;
  --
  --
  chrLocalErro := 10;
  --
  chrLocalErro := 11;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. NORMAL
  SGPB0035(pc_util_01.NORMAL,
           intQmes_perdc_pgtoN,
           intrCompetencia,
           intrCanal);
  Commit;
  --
  chrLocalErro := 12;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. EXTRA
  SGPB0035(pc_util_01.EXTRA,
           intQmes_perdc_pgtoE,
           intrCompetencia,
           intrCanal);          
  Commit;
  --
  --
  chrLocalErro := 13;
  --
  FOR c IN (SELECT c.ccpf_cnpj_base,
                   c.ctpo_pssoa,
                   CASE
                     WHEN SUM(pc.vprod_crrtr * (apc.pbonus_apurc / 100)) >= intvmin_librc_pgto THEN
                      'PG' /*TRUE*/
                     ELSE
                      'LM' /*FALSE*/
                   END AS novo_status
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
             WHERE APC.CIND_APURC_SELEC = 1
               AND pap.ccrrtr IS NULL /* só soma no total e altera situacao de quem não foi pago ainda*/
             GROUP BY c.ccpf_cnpj_base,
                      c.ctpo_pssoa) LOOP
    --
    chrLocalErro := 14;
    --
    -- 'AP','BG','LM','LG' => vira PG se for maior que minimo
    -- 'AP' => vira LM se for menor que minimo
    chrLocalErro := 15;
    UPDATE apurc_prod_crrtr TT
       SET csit_apurc = c.novo_status
     WHERE (C.NOVO_STATUS = 'PG' OR TT.Csit_Apurc = 'AP')
       AND ( --
            ccompt_apurc, --
            ccanal_vda_segur, --
            cgrp_ramo_plano, --
            ccompt_prod, --
            ctpo_comis, --
            ctpo_apurc, --
            ccrrtr, --
            cund_prod --
           ) --
           IN --
           ( --
            SELECT apc.ccompt_apurc,
                    apc.ccanal_vda_segur,
                    apc.cgrp_ramo_plano,
                    apc.ccompt_prod,
                    apc.ctpo_comis,
                    apc.ctpo_apurc,
                    apc.ccrrtr,
                    apc.cund_prod
              FROM apurc_prod_crrtr apc
              JOIN crrtr cc ON cc.ccrrtr = apc.ccrrtr
                           AND cc.cund_prod = apc.cund_prod
             WHERE apc.cind_apurc_selec = 1
               AND cc.Ctpo_Pssoa = c.ctpo_pssoa
               AND cc.Ccpf_Cnpj_Base = c.ccpf_cnpj_base --
            );
    --
  END LOOP;
  --
  chrLocalErro := 16;
  -- Deleta quem ta abaixo do minimo da temp
  UPDATE apurc_prod_crrtr
     SET cind_apurc_selec = 0
   WHERE cind_apurc_selec = 1
     AND ( --
          ccrrtr, --
          cund_prod --
         ) --
         IN --
         ( --
          SELECT apc.ccrrtr,
                  apc.cund_prod
            FROM apurc_prod_crrtr apc
            JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                        AND c.cund_prod = apc.cund_prod
           WHERE apc.cind_apurc_selec = 1
             AND ( --
                  c.ccpf_cnpj_base, --
                  c.ctpo_pssoa --
                 ) --
                 IN (SELECT c.ccpf_cnpj_base,
                            c.ctpo_pssoa
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
                      WHERE pap.ccrrtr IS NULL /* só soma no total e altera situacao de quem não foi pago ainda*/
                        AND apc.cind_apurc_selec = 1
                      GROUP BY c.ccpf_cnpj_base,
                               c.ctpo_pssoa
                     HAVING SUM(pc.vprod_crrtr * (apc.pbonus_apurc / 100)) < intvmin_librc_pgto) --
          );
  --
  --
  chrLocalErro := 17;
  -- Pega o próximo registro a ser inserido
  SELECT nvl(MAX(cpgto_bonus),
             0) + 1
    INTO intProxCodigoPgtoCrrtr
    FROM pgto_bonus_crrtr;
  --
  --
  chrLocalErro := 18;
  -- Insere os registros na tabela de pagamento
  FOR ca IN (SELECT c.ccpf_cnpj_base,
                    c.ctpo_pssoa,
                    apc.ctpo_apurc,
                    /*I04/04*/
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
             /*F04/04*/
               FROM apurc_prod_crrtr apc
               JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                           AND c.cund_prod = apc.cund_prod
               JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                 AND pc.cund_prod = apc.cund_prod
                                 AND pc.ccrrtr = apc.ccrrtr
                                 AND pc.ccompt_prod = apc.ccompt_prod
                                 AND pc.ctpo_comis = apc.ctpo_comis
             /*I04/04*/
               LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                             AND PAP.ctpo_apurc = apc.ctpo_apurc
                                             AND PAP.ccompt_apurc = apc.ccompt_apurc
                                             AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                             AND PAP.ccompt_prod = apc.ccompt_prod
                                             AND PAP.ctpo_comis = apc.ctpo_comis
                                             AND PAP.ccrrtr = apc.ccrrtr
                                             AND PAP.cund_prod = apc.cund_prod
                                             AND pap.cindcd_papel = 0
             /*F04/04*/
              WHERE apc.cind_apurc_selec = 1
              GROUP BY c.ccpf_cnpj_base,
                       c.ctpo_pssoa,
                       apc.ctpo_apurc) LOOP
    --
    chrLocalErro := 19;
    --
    INSERT INTO pgto_bonus_crrtr
      (cpgto_bonus,
       vpgto_tot,
       ctpo_pssoa,
       ccpf_cnpj_base,
       ccompt_pgto,
       ctpo_pgto,
       cind_arq_expor)
    VALUES
      (intProxCodigoPgtoCrrtr,
       ca.total,
       ca.ctpo_pssoa,
       ca.ccpf_cnpj_base,
       intrCompetencia,
       ca.ctpo_apurc,
       0);
    --
    chrLocalErro := 20;
    -- Insere os registros na tabela de historico-distribuicao-pagamento-bonus
    FOR caInt IN (SELECT c.ctpo_pssoa,
                         c.ccpf_cnpj_base,
                         apc.cund_prod,
                         /*I04/04*/
                         SUM(CASE
                               WHEN pap.ccrrtr IS NULL THEN
                                pc.vprod_crrtr * (apc.pbonus_apurc / 100)
                               ELSE
                                0
                             END) AS total
                  /*F04/04*/
                    FROM apurc_prod_crrtr apc
                    JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                AND c.cund_prod = apc.cund_prod
                    JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                      AND pc.cund_prod = apc.cund_prod
                                      AND pc.ccrrtr = apc.ccrrtr
                                      AND pc.ccompt_prod = apc.ccompt_prod
                                      AND pc.ctpo_comis = apc.ctpo_comis
                  /*I04/04*/
                    LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                                  AND PAP.ctpo_apurc = apc.ctpo_apurc
                                                  AND PAP.ccompt_apurc = apc.ccompt_apurc
                                                  AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                  AND PAP.ccompt_prod = apc.ccompt_prod
                                                  AND PAP.ctpo_comis = apc.ctpo_comis
                                                  AND PAP.ccrrtr = apc.ccrrtr
                                                  AND PAP.cund_prod = apc.cund_prod
                                                  AND pap.cindcd_papel = 0
                  /*F04/04*/
                   WHERE apc.cind_apurc_selec = 1
                     AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                     AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base
                     and pc.vprod_crrtr > 0 /*rateio*/
                   GROUP BY c.ccpf_cnpj_base,
                            c.ctpo_pssoa,
                            apc.cund_prod) LOOP
      --
      chrLocalErro := 21;
      -- Busca o maior CPD por sucursal
      SELECT ss.Ccrrtr
        INTO intCodMaiorCrrtr
        FROM (SELECT ss.Ccrrtr,
                     ss.total
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
                         AND c.Ctpo_Pssoa = ca.ctpo_pssoa
                         AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base
                         AND apc.ctpo_apurc = ca.ctpo_apurc
                         AND c.cund_prod = caInt.Cund_Prod
                       GROUP BY c.ctpo_pssoa,
                                c.ccpf_cnpj_base,
                                apc.cund_prod,
                                apc.Ccrrtr) ss
               ORDER BY ss.total DESC) ss
       WHERE ROWnum < 2;
      --
      chrLocalErro := 22;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS
      INSERT INTO hist_distr_pgto
        (vdistr_pgto_crrtr,
         cpgto_bonus,
         ccrrtr,
         cund_prod)
      VALUES
         (caInt.Total - ( ca.totalnegativo * (caInt.Total/ca.totalModulo) ) ,  /*rateio*/
         intProxCodigoPgtoCrrtr,
         intCodMaiorCrrtr,
         caInt.Cund_Prod);
      --
    --
    END LOOP;
    --
    chrLocalErro := 23;
    --
    -- Insere os registros na tabela de papel-apuracao-pagamento
    FOR caInt IN (SELECT apc.ccompt_apurc,
                         apc.ccanal_vda_segur,
                         apc.cgrp_ramo_plano,
                         apc.ccompt_prod,
                         apc.ctpo_comis,
                         apc.ctpo_apurc,
                         apc.ccrrtr,
                         apc.cund_prod,
                         apc.pbonus_apurc,
                         CASE
                           WHEN pap.ccrrtr IS NULL THEN
                            0
                           ELSE
                            1
                         END TemPagamento
                    FROM apurc_prod_crrtr apc
                    JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                AND c.cund_prod = apc.cund_prod
                    LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
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
                     AND c.Ccpf_Cnpj_Base = ca.ccpf_cnpj_base) LOOP
      --
      chrLocalErro := 24;
      --
      -- Insere papel eleição
      INSERT INTO papel_apurc_pgto
        (cpgto_bonus,
         ccrrtr,
         cund_prod,
         ccanal_vda_segur,
         ctpo_apurc,
         ccompt_apurc,
         cgrp_ramo_plano,
         ccompt_prod,
         ctpo_comis,
         cindcd_papel)
      VALUES
        (intProxCodigoPgtoCrrtr,
         caInt.Ccrrtr,
         caInt.Cund_Prod,
         caInt.Ccanal_Vda_Segur,
         caInt.Ctpo_Apurc,
         caInt.Ccompt_Apurc,
         caInt.Cgrp_Ramo_Plano,
         caInt.Ccompt_Prod,
         caInt.Ctpo_Comis,
         1);
      --
      --
      /* não tem pagamento*/
      IF caint.tempagamento = 0 THEN
        --
        chrLocalErro := 25;
        -- Insere papel pagamento se naum tiver antes claro
        INSERT INTO papel_apurc_pgto
          (cpgto_bonus,
           ccrrtr,
           cund_prod,
           ccanal_vda_segur,
           ctpo_apurc,
           ccompt_apurc,
           cgrp_ramo_plano,
           ccompt_prod,
           ctpo_comis,
           cindcd_papel)
        VALUES
          (intProxCodigoPgtoCrrtr,
           caInt.Ccrrtr,
           caInt.Cund_Prod,
           caInt.Ccanal_Vda_Segur,
           caInt.Ctpo_Apurc,
           caInt.Ccompt_Apurc,
           caInt.Cgrp_Ramo_Plano,
           caInt.Ccompt_Prod,
           caInt.Ctpo_Comis,
           0);
      END IF;
      --
    END LOOP;
    chrLocalErro := 26;
    -- acrescenta um no contador
    intProxCodigoPgtoCrrtr := intProxCodigoPgtoCrrtr + 1;
    --
  END LOOP;
  --
  chrLocalErro := 27;
  --
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                 708,
                                 'PO');
  --
  --
  chrLocalErro := 28;
  --
  -- Volta a configuração inicial
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  --
  --
  chrLocalErro := 29;
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) || ' Canal: ' ||
                           to_char(intrCanal) || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    --    dbms_output.put_line(var_log_erro);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0166',
                                var_log_erro,
                                pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                   708,
                                   PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0166;
/

