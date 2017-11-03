CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0229
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0229'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0229
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para pagar automaticamente as apura??es que ultrapassem o minimo para tal - extrabanco;
  --      ALTERA??ES      : 07/08/2007 - Melhorias - Wassily
  --                        08/08/2007 - Rotina era di?ria, alterada para trimestral - Ass. Wassily
  -------------------------------------------------------------------------------------------------
 IS

  -- Refactored procedure insertHistorico 

  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  intQmes_perdc_pgtoN    parm_per_apurc_canal.qmes_perdc_pgto%TYPE;
  intQmes_perdc_pgtoE    parm_per_apurc_canal.qmes_perdc_pgto%TYPE;
  intProxCodigoPgtoCrrtr pgto_bonus_crrtr.cpgto_bonus%TYPE;
  intvmin_librc_pgto     parm_canal_vda_segur.vmin_librc_pgto%TYPE;

  -- Refactored procedure getQtdMesPerdicPagto 
  function getQtdMesPerdicPagto
  (
    intrCompetencia in Prod_Crrtr.CCOMPT_PROD%type,
    intCanal        in parm_per_apurc_canal.ccanal_vda_segur%type,
    intTpoApurc     in parm_per_apurc_canal.ctpo_apurc%type
  ) return int as
    intRetorno int;
  begin
    SELECT qmes_perdc_pgto
      INTO intRetorno
      FROM parm_per_apurc_canal ppac
     WHERE ccanal_vda_segur = intCanal
       AND ppac.ctpo_apurc = intTpoApurc
       AND Sgpb0016(intrCompetencia) BETWEEN ppac.dinic_vgcia_parm AND nvl(ppac.dfim_vgcia_parm, to_date('99991231', 'YYYYMMDD'));
  
    return intRetorno;
  end getQtdMesPerdicPagto;

  -- Refactored procedure getValorMinimoLiberacaoPagamento 
  procedure getValorMinLiberacaoPagamento(intrCompetencia in Prod_Crrtr.CCOMPT_PROD%type) is
  begin
    SELECT pcvs.vmin_librc_pgto
      INTO intvmin_librc_pgto
      FROM parm_canal_vda_segur pcvs
     WHERE pcvs.ccanal_vda_segur = pc_util_01.EXTRA_BANCO
       AND Sgpb0016(intrCompetencia) BETWEEN pcvs.dinic_vgcia_parm AND nvl(pcvs.dfim_vgcia_parm, to_date('99991231', 'YYYYMMDD'));
  end getValorMinLiberacaoPagamento;

  -- Refactored procedure setFlagApuracaoZero 
  procedure setFlagApuracaoZero is
  begin
    UPDATE apurc_prod_crrtr
       SET cind_apurc_selec = 0
     WHERE cind_apurc_selec = 1;
  end setFlagApuracaoZero;

  -- Refactored procedure updateApuracao 
  procedure updateApuracao
  (
    chrLocalErro       in out VARCHAR2,
    intvmin_librc_pgto in out parm_canal_vda_segur.vmin_librc_pgto%TYPE
  ) is
  begin
    FOR c IN (SELECT cpae.ctpo_pssoa_agpto_econm_crrtr,
                     cpae.ccpf_cnpj_agpto_econm_crrtr,
                     cpae.dinic_agpto_econm_crrtr,
                     CASE
                       WHEN SUM(pc.vprod_crrtr * (apc.pbonus_apurc / 100)) >= intvmin_librc_pgto THEN
                        'PG' /*TRUE*/
                       ELSE
                        'LM' /*FALSE*/
                     END AS novo_status
              --
              --
                FROM apurc_prod_crrtr apc
              --
              --
                JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                            AND c.cund_prod = apc.cund_prod
              --
              --
                JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                  AND pc.cund_prod = apc.cund_prod
                                  AND pc.ccrrtr = apc.ccrrtr
                                  AND pc.ccompt_prod = apc.ccompt_prod
                                  AND pc.ctpo_comis = apc.ctpo_comis
              --
              --
                LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                              AND PAP.ctpo_apurc = apc.ctpo_apurc
                                              AND PAP.ccompt_apurc = apc.ccompt_apurc
                                              AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                              AND PAP.ccompt_prod = apc.ccompt_prod
                                              AND PAP.ctpo_comis = apc.ctpo_comis
                                              AND PAP.ccrrtr = apc.ccrrtr
                                              AND PAP.cund_prod = apc.cund_prod
                                              AND pap.cindcd_papel = 0
              --
              --
              /*GE*/
                join agpto_econm_crrtr aec on last_day(to_date(intrCompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and
                                              nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
              
                join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                 and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                 and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                 and last_day(to_date(intrCompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and
                                                     nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                                                 AND cpae.CCPF_CNPJ_BASE = c.CCPF_CNPJ_BASE
                                                 AND cpae.CTPO_PSSOA = c.CTPO_PSSOA
              /*GE*/
              --
              --
               WHERE APC.CIND_APURC_SELEC = 1
                 AND pap.ccrrtr IS NULL /* s? soma no total e altera situacao de quem n?o foi pago ainda*/
              --
              --
               GROUP BY cpae.ctpo_pssoa_agpto_econm_crrtr,
                        cpae.ccpf_cnpj_agpto_econm_crrtr,
                        cpae.dinic_agpto_econm_crrtr) LOOP
      --
      --
      chrLocalErro := 14;
      -- 'AP','BG','LM','LG' => vira PG se for maior que minimo
      -- 'AP' => vira LM se for menor que minimo
      chrLocalErro := 15;
      UPDATE apurc_prod_crrtr TT
         SET TT.csit_apurc       = c.novo_status,
             tt.cind_apurc_selec = case when c.novo_status = 'LM' THEN 0 ELSE 1 END
       WHERE (C.NOVO_STATUS = 'PG' OR TT.Csit_Apurc = 'AP')
         AND (ccompt_apurc, --
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
              --
              --
                JOIN crrtr cc ON cc.ccrrtr = apc.ccrrtr
                             AND cc.cund_prod = apc.cund_prod
              --
              --
              /*GE*/
                join agpto_econm_crrtr aec on last_day(to_date(intrCompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and
                                              nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
              
                join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                 and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                 and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                 and last_day(to_date(intrCompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and
                                                     nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                                                 AND cpae.CCPF_CNPJ_BASE = cc.CCPF_CNPJ_BASE
                                                 AND cpae.CTPO_PSSOA = cc.CTPO_PSSOA
              /*GE*/
              --
              --
               WHERE apc.cind_apurc_selec = 1
                 and cpae.ctpo_pssoa_agpto_econm_crrtr = c.ctpo_pssoa_agpto_econm_crrtr
                 and cpae.ccpf_cnpj_agpto_econm_crrtr = c.ccpf_cnpj_agpto_econm_crrtr
                 and cpae.dinic_agpto_econm_crrtr = c.dinic_agpto_econm_crrtr);
    END LOOP;
  end updateApuracao;

  procedure insertHistorico
  (
    intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
    chrLocalErro                  in out VARCHAR2,
    intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
    pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
    pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
    pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
    pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE,
    pTotalNegativo                in number,
    pTotalPositivo                in number
  ) is
    intCodMaiorCrrtr crrtr.ccrrtr%TYPE;
  begin
    FOR caInt IN (SELECT c.ctpo_pssoa,
                         c.ccpf_cnpj_base,
                         apc.cund_prod,
                         SUM(CASE
                               WHEN pap.ccrrtr IS NULL THEN
                                pc.vprod_crrtr * (apc.pbonus_apurc / 100)
                               ELSE
                                0
                             END) AS total
                  --
                  --
                    FROM apurc_prod_crrtr apc
                  --
                  --
                    JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                AND c.cund_prod = apc.cund_prod
                  --
                  --
                    JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                      AND pc.cund_prod = apc.cund_prod
                                      AND pc.ccrrtr = apc.ccrrtr
                                      AND pc.ccompt_prod = apc.ccompt_prod
                                      AND pc.ctpo_comis = apc.ctpo_comis
                  --
                  --
                    LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                                  AND PAP.ctpo_apurc = apc.ctpo_apurc
                                                  AND PAP.ccompt_apurc = apc.ccompt_apurc
                                                  AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                  AND PAP.ccompt_prod = apc.ccompt_prod
                                                  AND PAP.ctpo_comis = apc.ctpo_comis
                                                  AND PAP.ccrrtr = apc.ccrrtr
                                                  AND PAP.cund_prod = apc.cund_prod
                                                  AND pap.cindcd_papel = 0
                  --
                  --
                  /*GE*/
                    join agpto_econm_crrtr aec on last_day(to_date(intrCompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and
                                                  nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
                  
                    join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                     and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                     and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                     and last_day(to_date(intrCompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and
                                                         nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                                                     AND cpae.CCPF_CNPJ_BASE = c.CCPF_CNPJ_BASE
                                                     AND cpae.CTPO_PSSOA = c.CTPO_PSSOA
                  /*GE*/
                  --
                  --
                   WHERE apc.cind_apurc_selec = 1
                     and cpae.ctpo_pssoa_agpto_econm_crrtr = pCtpo_pssoa_agpto_econm_crrtr
                     and cpae.ccpf_cnpj_agpto_econm_crrtr = pCcpf_cnpj_agpto_econm_crrtr
                     and cpae.dinic_agpto_econm_crrtr = pDinic_agpto_econm_crrtr
                     and pc.vprod_crrtr > 0 /*rateio*/
                     and apc.ctpo_apurc = pCtpo_apurc
                  --
                  --
                   GROUP BY c.ccpf_cnpj_base,
                            c.ctpo_pssoa,
                            apc.cund_prod) --
     LOOP
      --
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
                      --
                      --
                        FROM apurc_prod_crrtr apc
                      --
                      --
                        JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                    AND c.cund_prod = apc.cund_prod
                      --
                      --
                        JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                          AND pc.cund_prod = apc.cund_prod
                                          AND pc.ccrrtr = apc.ccrrtr
                                          AND pc.ccompt_prod = apc.ccompt_prod
                                          AND pc.ctpo_comis = apc.ctpo_comis
                      --
                      --
                       WHERE apc.cind_apurc_selec = 1
                         AND c.Ctpo_Pssoa = caInt.ctpo_pssoa
                         AND c.Ccpf_Cnpj_Base = caInt.ccpf_cnpj_base
                         AND apc.ctpo_apurc = pCtpo_apurc
                         AND c.cund_prod = caInt.Cund_Prod
                      --
                      --
                       GROUP BY c.ctpo_pssoa,
                                c.ccpf_cnpj_base,
                                apc.cund_prod,
                                apc.Ccrrtr) ss
               ORDER BY ss.total DESC) ss
      --
      --
       WHERE ROWnum < 2;
      --
      --
      chrLocalErro := 22;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS
      INSERT INTO hist_distr_pgto
        (vdistr_pgto_crrtr,
         cpgto_bonus,
         ccrrtr,
         cund_prod)
      VALUES
        (caInt.Total - (pTotalnegativo * (caInt.Total / pTotalPositivo)),
         intProxCodigoPgtoCrrtr,
         intCodMaiorCrrtr,
         caInt.Cund_Prod);
    END LOOP;
  end insertHistorico;


  procedure insertPapel
  (
    intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
    chrLocalErro                  in out VARCHAR2,
    intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
    pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
    pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
    pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
    pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE
  ) is
  begin
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
                  --
                  --
                    FROM apurc_prod_crrtr apc
                  --
                  --
                    JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                AND c.cund_prod = apc.cund_prod
                  --
                  --
                    LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                                  AND PAP.ctpo_apurc = apc.ctpo_apurc
                                                  AND PAP.ccompt_apurc = apc.ccompt_apurc
                                                  AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                                  AND PAP.ccompt_prod = apc.ccompt_prod
                                                  AND PAP.ctpo_comis = apc.ctpo_comis
                                                  AND PAP.ccrrtr = apc.ccrrtr
                                                  AND PAP.cund_prod = apc.cund_prod
                                                  AND pap.cindcd_papel = 0
                  --
                  --
                  /*GE*/
                    join agpto_econm_crrtr aec on last_day(to_date(intrCompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and
                                                  nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
                  
                    join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                     and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                     and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                     and last_day(to_date(intrCompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and
                                                         nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                                                     AND cpae.CCPF_CNPJ_BASE = c.CCPF_CNPJ_BASE
                                                     AND cpae.CTPO_PSSOA = c.CTPO_PSSOA
                  /*GE*/
                  --
                  --
                   WHERE APC.CIND_APURC_SELEC = 1
                     and cpae.ctpo_pssoa_agpto_econm_crrtr = pCtpo_pssoa_agpto_econm_crrtr
                     and cpae.ccpf_cnpj_agpto_econm_crrtr = pCcpf_cnpj_agpto_econm_crrtr
                     and cpae.dinic_agpto_econm_crrtr = pDinic_agpto_econm_crrtr
                     and apc.ctpo_apurc = pCtpo_apurc) LOOP
      --
      --
      chrLocalErro := 24;
      -- Insere papel elei??o
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
      /* n?o tem pagamento*/
      IF caint.tempagamento = 0 THEN
        --
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
    END LOOP;
  end insertPapel;

  -- Refactored procedure insertPagamento 
  procedure insertPagamento
  (
    intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
    intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
    pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
    pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
    pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
    pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE,
    pTotalSaldo                   in number
  ) is
  begin
  
    INSERT INTO pgto_bonus_crrtr
      (cpgto_bonus,
       vpgto_tot,
       ctpo_pssoa,
       ccpf_cnpj_base,
       DINIC_AGPTO_ECONM_CRRTR,
       ccompt_pgto,
       ctpo_pgto,
       cind_arq_expor)
    VALUES
      (intProxCodigoPgtoCrrtr,
       pTotalSaldo,
       pCtpo_pssoa_agpto_econm_crrtr,
       pCcpf_cnpj_agpto_econm_crrtr,
       pDinic_agpto_econm_crrtr,
       intrCompetencia,
       pCtpo_apurc,
       0);
       
  end insertPagamento;

BEGIN
  --
  --
  chrLocalErro := 01;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, 844, 'PC');
  commit;
  --
  --
  chrLocalErro := 02;
  -- Zera a tabela tempor?ria
  setFlagApuracaoZero;
  --
  --
  chrLocalErro := 05;
  --  busca o minimo para liberar o pagamento para o canal tipo normal
  getValorMinLiberacaoPagamento(intrCompetencia);
  --
  --
  chrLocalErro := 06;
  --  busca de quanto em quanto tempo paga-se para o canal NORMAL
  intQmes_perdc_pgtoN := getQtdMesPerdicPagto(intrCompetencia, pc_util_01.EXTRA_BANCO, pc_util_01.Normal);
  --
  --
  chrLocalErro := 07;
  --  busca de quanto em quanto tempo paga-se para o canal EXTRA
  intQmes_perdc_pgtoE := getQtdMesPerdicPagto(intrCompetencia, pc_util_01.EXTRA_BANCO, pc_util_01.EXTRA);
  --
  --
  chrLocalErro := 08;
  -- insere na temporaria todos os registros selecionados para trabalho no periodo - NORMAL
  SGPB0034(pc_util_01.NORMAL, intQmes_perdc_pgtoN, intrCompetencia, pc_util_01.Extra_Banco);
  --
  --
  chrLocalErro := 09;
  -- insere na temporaria todos os registros selecionados para trabalho no periodo - EXTRA
  SGPB0034(pc_util_01.EXTRA, intQmes_perdc_pgtoE, intrCompetencia, pc_util_01.Extra_Banco);
  --
  --
  chrLocalErro := 10;
  -- insere registros que j? estejam liberados para pagamento porem abaixo do minimo. NORMAL
  SGPB0035(pc_util_01.NORMAL, intQmes_perdc_pgtoN, intrCompetencia, pc_util_01.Extra_Banco);
  --
  --
  chrLocalErro := 12;
  -- insere registros que j? estejam liberados para pagamento porem abaixo do minimo. EXTRA
  SGPB0035(pc_util_01.EXTRA, intQmes_perdc_pgtoE, intrCompetencia, pc_util_01.Extra_Banco);
  --
  --
  chrLocalErro := 13;
  -- Atualiza??o dos registros de apura??o
  -- Deleta quem ta abaixo do minimo da temp
  updateApuracao(chrLocalErro, intvmin_librc_pgto);
  --
  --
  chrLocalErro := 17;
  -- Pega o pr?ximo registro a ser inserido
  SELECT nvl(MAX(cpgto_bonus), 0) + 1
    INTO intProxCodigoPgtoCrrtr
    FROM pgto_bonus_crrtr;
  --
  --
  chrLocalErro := 18;
  -- Insere os registros na tabela de pagamento
  FOR ca IN (SELECT cpae.ctpo_pssoa_agpto_econm_crrtr,
                    cpae.ccpf_cnpj_agpto_econm_crrtr,
                    cpae.dinic_agpto_econm_crrtr,
                    apc.ctpo_apurc,
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
                        END) AS totalPositivo, /*rateio*/
                    SUM(CASE
                          WHEN ((pap.ccrrtr IS NULL) AND (pc.vprod_crrtr < 0)) THEN
                           abs(pc.vprod_crrtr * (apc.pbonus_apurc / 100))
                          ELSE
                           0
                        END) AS totalNegativo /*rateio*/
             --
             --         
               FROM apurc_prod_crrtr apc
             --
             --         
               JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                           AND c.cund_prod = apc.cund_prod
             --
             --         
               JOIN prod_crrtr pc ON pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                 AND pc.cund_prod = apc.cund_prod
                                 AND pc.ccrrtr = apc.ccrrtr
                                 AND pc.ccompt_prod = apc.ccompt_prod
                                 AND pc.ctpo_comis = apc.ctpo_comis
             --
             --         
               LEFT JOIN papel_apurc_pgto pap ON PAP.ccanal_vda_segur = apc.ccanal_vda_segur
                                             AND PAP.ctpo_apurc = apc.ctpo_apurc
                                             AND PAP.ccompt_apurc = apc.ccompt_apurc
                                             AND PAP.cgrp_ramo_plano = apc.cgrp_ramo_plano
                                             AND PAP.ccompt_prod = apc.ccompt_prod
                                             AND PAP.ctpo_comis = apc.ctpo_comis
                                             AND PAP.ccrrtr = apc.ccrrtr
                                             AND PAP.cund_prod = apc.cund_prod
                                             AND pap.cindcd_papel = 0
             --
             --         
             /*GE*/
               join agpto_econm_crrtr aec on last_day(to_date(intrCompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and
                                             nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
             
               join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                and last_day(to_date(intrCompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and
                                                    nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                                                AND cpae.CCPF_CNPJ_BASE = c.CCPF_CNPJ_BASE
                                                AND cpae.CTPO_PSSOA = c.CTPO_PSSOA
             /*GE*/
             --
             --         
              WHERE apc.cind_apurc_selec = 1
             --
             --         
              GROUP BY cpae.ctpo_pssoa_agpto_econm_crrtr,
                       cpae.ccpf_cnpj_agpto_econm_crrtr,
                       cpae.dinic_agpto_econm_crrtr,
                       apc.ctpo_apurc) --
  --
  --         
   LOOP
    --
    --
    chrLocalErro := 19;
    /*
    intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
    intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
    pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
    pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
    pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
    pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE,
    pTotalSaldo                   in number
    */
    insertPagamento(intrCompetencia, --
                    intProxCodigoPgtoCrrtr, --
                    ca.Ctpo_Pssoa_Agpto_Econm_Crrtr, --
                    ca.Ccpf_Cnpj_Agpto_Econm_Crrtr, --
                    ca.dinic_agpto_econm_crrtr, --
                    ca.ctpo_apurc,  --
                    ca.total);
    --
    --
  
    chrLocalErro := 20;  
    -- Insere os registros na tabela de historico-distribuicao-pagamento-bonus
    /*
      intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
      chrLocalErro                  in out VARCHAR2,
      intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
      pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
      pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
      pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
      pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE,
      pTotalNegativo                in number,
      pTotalPositivo                in number
    */
    insertHistorico(intrCompetencia, --
                    chrLocalErro, --
                    intProxCodigoPgtoCrrtr, --
                    ca.Ctpo_Pssoa_Agpto_Econm_Crrtr, --
                    ca.Ccpf_Cnpj_Agpto_Econm_Crrtr, --
                    ca.dinic_agpto_econm_crrtr, --
                    ca.ctpo_apurc, --
                    ca.totalnegativo, --
                    ca.totalpositivo);
    --
    --
    chrLocalErro := 23;
    -- Insere os registros na tabela de papel-apuracao-pagamento
    /*
    intrCompetencia               in Prod_Crrtr.CCOMPT_PROD%TYPE,
    chrLocalErro                  in out VARCHAR2,
    intProxCodigoPgtoCrrtr        in out pgto_bonus_crrtr.cpgto_bonus%TYPE,
    pCtpo_pssoa_agpto_econm_crrtr in agpto_econm_crrtr.ctpo_pssoa_agpto_econm_crrtr%TYPE,
    pCcpf_cnpj_agpto_econm_crrtr  in agpto_econm_crrtr.ccpf_cnpj_agpto_econm_crrtr%TYPE,
    pDinic_agpto_econm_crrtr      in agpto_econm_crrtr.dinic_agpto_econm_crrtr%TYPE,
    pCtpo_apurc                   in apurc_prod_crrtr.ctpo_apurc%TYPE
    */
    insertPapel(intrCompetencia, --
                chrLocalErro, --
                intProxCodigoPgtoCrrtr, --
                ca.Ctpo_Pssoa_Agpto_Econm_Crrtr, --
                ca.Ccpf_Cnpj_Agpto_Econm_Crrtr, --
                ca.dinic_agpto_econm_crrtr, --
                ca.ctpo_apurc --
                );
    --
    --
    chrLocalErro := 26;
    -- acrescenta um no contador
    intProxCodigoPgtoCrrtr := intProxCodigoPgtoCrrtr + 1;
  END LOOP;
  --
  --
  chrLocalErro := 27;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, 844, 'PO');
  chrLocalErro := 29;
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler, 'TERMINO DO PROCESSO. EM ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY') || ' COMPETENCIA: ' ||
                          to_char(intrCompetencia) || ' Canal: ' || to_char(pc_util_01.EXTRA_BANCO), 'P', NULL, NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) || ' Canal: ' || to_char(pc_util_01.EXTRA_BANCO) ||
                           ' # ' || SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler, var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, 844, PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20212, VAR_LOG_ERRO);
END SGPB0229;
/

