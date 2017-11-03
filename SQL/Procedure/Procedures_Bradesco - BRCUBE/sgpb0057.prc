CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0057
(
  intrCompetencia       Prod_Crrtr.CCOMPT_PROD %TYPE,
  intCodCanal_vda_segur parm_canal_vda_segur.ccanal_vda_segur %TYPE
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0057
  --      DATA            : 26/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para "Liberar*" automaticamente as apurações que ultrapassem o minimo para tal - banco/finasa; *Apenas altera a situacao
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(3) := '000';
  --
  intQmes_perdc_pgto parm_per_apurc_canal.qmes_perdc_pgto%TYPE;
  intvmin_librc_pgto parm_canal_vda_segur.vmin_librc_pgto%TYPE;
  --
  intCompTemp Prod_Crrtr.CCOMPT_PROD %TYPE;
BEGIN
  --
  --
  chrLocalErro := 01;
  --  Informa ao scheduler o começo da procedure
  --PR_ATUALIZA_STATUS_ROTINA('SGPB0057',
  --                          722,
  --                          'PC');
  --
  chrLocalErro := 02;
  --  Busca a situacao do canal
  --
  chrLocalErro := 04;
  -- Zera a tabela temporária
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  --
  chrLocalErro := 05;
  --  busca de quanto em quanto tempo paga-se para o canal
  SELECT qmes_perdc_pgto
    INTO intQmes_perdc_pgto
    FROM parm_per_apurc_canal ppac
   WHERE ccanal_vda_segur = intCodCanal_vda_segur
     AND ppac.ctpo_apurc = pc_util_01.NORMAL
     AND Sgpb0016(intrCompetencia) BETWEEN ppac.dinic_vgcia_parm AND
         nvl(ppac.dfim_vgcia_parm,
             to_date('99991231',
                     'YYYYMMDD'));
  --
  chrLocalErro := 06;
  --  busca o minimo para liberar o pagamento para o canal
  SELECT pcvs.vmin_librc_pgto
    INTO intvmin_librc_pgto
    FROM parm_canal_vda_segur pcvs
   WHERE pcvs.ccanal_vda_segur = intCodCanal_vda_segur
     AND Sgpb0016(intrCompetencia) BETWEEN pcvs.dinic_vgcia_parm AND
         nvl(pcvs.dfim_vgcia_parm,
             to_date('99991231',
                     'YYYYMMDD'));
  --
  chrLocalErro := 07;
  --
  intCompTemp := PC_UTIL_01.SGPB0017(intrCompetencia,
                                     intQmes_perdc_pgto - 1); --OLHANDO PARA TRÁS
  --
  chrLocalErro := 08;
  --
  --insere na temporaria todos os registros selecionados para trabalho
  UPDATE apurc_prod_crrtr
     SET cind_apurc_selec = 1
   WHERE (ccanal_vda_segur, --
          ctpo_apurc, --
          ccompt_apurc, --
          cgrp_ramo_plano, --
          ccompt_prod, --
          ctpo_comis, --
          ccrrtr, --
          cund_prod --
         ) --
         IN --
         ( --
          SELECT apc.ccanal_vda_segur,
                  apc.ctpo_apurc,
                  apc.ccompt_apurc,
                  apc.cgrp_ramo_plano,
                  apc.ccompt_prod,
                  apc.ctpo_comis,
                  apc.ccrrtr,
                  apc.cund_prod
            FROM apurc_prod_crrtr APC
           WHERE APC.CCOMPT_APURC BETWEEN intCompTemp AND intrCompetencia
             AND APC.ccanal_vda_segur = intCodCanal_vda_segur
             AND APC.CSIT_APURC IN ('AP', 'BG', 'LM', 'LG', 'PR', 'PL')
             AND NOT EXISTS (SELECT 1
                    FROM papel_apurc_pgto PAP
                   WHERE PAP.ccanal_vda_segur = APC.ccanal_vda_segur
                     AND PAP.ctpo_apurc = APC.ctpo_apurc
                     AND PAP.ccompt_apurc = APC.ccompt_apurc
                     AND PAP.cgrp_ramo_plano = APC.cgrp_ramo_plano
                     AND PAP.ccompt_prod = APC.ccompt_prod
                     AND PAP.ctpo_comis = APC.ctpo_comis
                     AND PAP.ccrrtr = APC.ccrrtr
                     AND PAP.cund_prod = APC.cund_prod
                     AND PAP.CINDCD_PAPEL = 1 /*ELEICAO*/
                  ));
  --
  chrLocalErro := 09;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. NORMAL
  SGPB0035(pc_util_01.NORMAL,
           intQmes_perdc_pgto,
           intrCompetencia,
           pc_util_01.Banco);
  --
  chrLocalErro := 9.1;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. EXTRA
  SGPB0035(pc_util_01.EXTRA,
           intQmes_perdc_pgto,
           intrCompetencia,
           pc_util_01.Banco);
  --
  --
  chrLocalErro := 10;
  --
  FOR c IN (SELECT c.ccpf_cnpj_base,
                   c.ctpo_pssoa,
                   CASE
                     WHEN SUM(pc.vprod_crrtr * (apc.pbonus_apurc / 100)) >= intvmin_librc_pgto THEN
                      'LP' /*TRUE*/
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
    --
    --
    -- 'AP','BG','LM','LG' => vira PG se for maior que minimo
    -- 'AP' => vira LM se for menor que minimo
    chrLocalErro := 11;
    UPDATE apurc_prod_crrtr TT
       SET csit_apurc = c.novo_status
     WHERE (C.NOVO_STATUS = 'LP' OR TT.Csit_Apurc = 'AP')
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
              JOIN crrtr cc ON cc.ccrrtr = apc.ccrrtr
                           AND cc.cund_prod = apc.cund_prod
             WHERE apc.cind_apurc_selec = 1
               AND cc.Ccpf_Cnpj_Base = c.ccpf_cnpj_base
               AND cc.Ctpo_Pssoa = c.ctpo_pssoa --
            );
    --
  END LOOP;
  --
  chrLocalErro := 12;
  --
  PR_ATUALIZA_STATUS_ROTINA('SGPB0057',
                            722,
                            'PO');
  --
  chrLocalErro := 13;
  --
  -- Volta a configuração inicial
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  --
  --
  chrLocalErro := 14;
  COMMIT;
  --
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) ||
                           ' Canal: ' || to_char(intCodCanal_vda_segur) || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    --    dbms_output.put_line(var_log_erro);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0057',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0057',
                              722,
                              PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0057;
/

