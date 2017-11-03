CREATE OR REPLACE PROCEDURE SGPB_PROC.insereObjetivoExtraBancoEsp
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      chrNomeRotinaScheduler VARCHAR2
    ) IS
        -------------------------------------------------------------------------------------------------
        --      BRADESCO SEGUROS S.A.
        --      PROCEDURE       : insereObjetivoExtraBanco
        --      DATA            :
        --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
        --      OBJETIVO        : insere Objetivo Extra-Banco, no segundo trimestre, usando produção do ano anterior e 
        --						  o percentual padrão de crescimento. pega quem está na tabela caracteristica corretor.
        --      ALTERAÇÕES      :
        --                DATA  : O programa sgpb0169 que chama esse passa 200706 na Intrcompetencia (segundo trimestre).
        --                AUTOR : -
        --                OBS   : -
        -------------------------------------------------------------------------------------------------

      intrMesesApurConsiderar integer;
      intComptInicial integer;
      --
      intComptInicialAnterior integer;
      IntrcompetenciaAnterior integer;
      --
      VAR_LOG_ERRO VARCHAR2(1000);
      chrLocalErro VARCHAR2(2) := '00'; 
      --  
      percentualPadrao parm_canal_vda_segur.pcrstc_prod_ano %type;

        PROCEDURE getMesesApuracaoConsiderar(intrMesesApurConsiderar OUT Parm_Per_Apurc_Canal. Qmes_Anlse %TYPE,
                         Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                         Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                         Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc %TYPE) IS
        BEGIN
        --
          SELECT ppac.qmes_perdc_apurc
            INTO intrMesesApurConsiderar
            FROM Parm_Per_Apurc_Canal ppac
           WHERE ppac.Ccanal_Vda_Segur = Intrcanal
             AND Sgpb0016(Intrvigencia) BETWEEN ppac.Dinic_Vgcia_Parm AND
                 pc_util_01.Sgpb0031(ppac.Dfim_Vgcia_Parm)
             AND ppac.Ctpo_Apurc = Intrtpapurc;
        --
        end getMesesApuracaoConsiderar;
        -- pega percentual padrao de crescimento do canal. wassily.
         procedure getPercentualPadrao
         (
            percentualPadrao out parm_canal_vda_segur.pcrstc_prod_ano %type,
            Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
            Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE
         ) IS
         begin
      
           select pcvs.pcrstc_prod_ano
             into percentualPadrao
           from parm_canal_vda_segur pcvs
           where pcvs.ccanal_vda_segur = Intrcanal
             and LAST_DAY(To_Date(Intrvigencia, 'YYYYMM')) BETWEEN
                 PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'dd/MM/yyyy'));
      
         end getPercentualPadrao;
         -- pega a producao minima do corretor para cada canal
          PROCEDURE getVlObjRe(
            vmin_prod_crrtr out PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr %type,
            Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
            chrTpPessoa     in crrtr_unfca_cnpj.ctpo_pssoa %type,
            Intrvigencia    IN Prod_Crrtr.Ccompt_Prod%TYPE
          ) IS
        
          BEGIN
            SELECT ppmc.vmin_prod_crrtr
              into vmin_prod_crrtr
              FROM PARM_PROD_MIN_CRRTR PPMC
             WHERE PPMC.CCANAL_VDA_SEGUR = Intrcanal
               AND PPMC.CGRP_RAMO_PLANO = pc_util_01.re
               AND PPMC.CTPO_PSSOA = chrTpPessoa
               AND PPMC.CTPO_PER = 'M'
               AND Last_Day(To_Date( Intrvigencia , 'YYYYMM'))
                   BETWEEN PPMC.DINIC_VGCIA_PARM
                       AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'));        
          END getVlObjRe;
         --
    begin
--------------------------------------------------------------------------------    
      --
      --
      chrLocalErro := 01;
      --   
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,pc_util_01.Extra_Banco,Intrcompetencia,Pc_Util_01.Normal);
      --
      --
      chrLocalErro := 02;
      --   
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      -- volta um ano atrás. wassily
      intComptInicialAnterior := To_Number(To_Char(Add_Months(To_Date(intComptInicial, 'yyyymm'), -12), 'YYYYMM'));
      IntrcompetenciaAnterior := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'), -12), 'YYYYMM'));
      --
      --
      chrLocalErro := 03;
      --   
      getPercentualPadrao( percentualPadrao,pc_util_01.Extra_Banco,Intrcompetencia ); 
      --
      chrLocalErro := 04;
      -- tirando se o corretor já tem objetivo. wassily.                             
      DELETE FROM objtv_prod_crrtr
       WHERE ( --
              CTPO_PSSOA, CCPF_CNPJ_BASE, CANO_MES_COMPT_OBJTV, CGRP_RAMO_PLANO, CCANAL_VDA_SEGUR --
             ) --
             IN ( --
                 SELECT C.CTPO_PSSOA,
                         C.CCPF_CNPJ_BASE,
                         To_Number(To_Char(Add_Months(To_Date(pc.ccompt_prod,'yyyymm'),12),'YYYYMM')),
                         pc.cgrp_ramo_plano,
                         pc_util_01.Extra_Banco
                 --
                   FROM CRRTR C
                   JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                                     AND PC.CUND_PROD = C.CUND_PROD
                                     AND PC.CGRP_RAMO_PLANO = pc_util_01.Auto
                                     AND PC.CCOMPT_PROD BETWEEN intComptInicialAnterior AND IntrcompetenciaAnterior
                                     AND PC.CTPO_COMIS = pc_util_01.COMISSAO_NORMAL
                                     AND PC.CCRRTR BETWEEN 100000 and 200000
                 --
                   JOIN parm_info_campa pic ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
                                           AND PIC.DFIM_VGCIA_PARM IS NULL
                 --
                   JOIN crrtr_eleit_campa cec ON cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
                                             AND cec.ccanal_vda_segur = pic.ccanal_vda_segur
                                             AND cec.ccpf_cnpj_base = c.ccpf_cnpj_base
                                             AND cec.ctpo_pssoa = c.ctpo_pssoa
                 --
                   JOIN carac_crrtr_canal ccc ON ccc.ccanal_vda_segur = pic.ccanal_vda_segur
                                             AND ccc.dinic_vgcia_parm = pic.dinic_vgcia_parm
                                             AND ccc.ccpf_cnpj_base = c.ccpf_cnpj_base
                                             AND ccc.ctpo_pssoa = c.ctpo_pssoa
                                             AND ccc.cind_perc_ativo = 'S'
                                             and ccc.dult_alt > to_date(20070301,'YYYYMMDD')
                 --
                  GROUP BY C.CTPO_PSSOA,C.CCPF_CNPJ_BASE,pc.cgrp_ramo_plano,pc.ccompt_prod --
                 );
      --
      chrLocalErro := 05;
      --   
      INSERT INTO objtv_prod_crrtr
        (
           ctpo_pssoa,
           ccpf_cnpj_base,
           cgrp_ramo_plano,
           ccanal_vda_segur,
           cano_mes_compt_objtv,
           cseq_objtv_crrtr,
           vobjtv_prod_crrtr_alt,
           vobjtv_prod_crrtr_orign,
           cind_reg_ativo,
           dult_alt,
           cresp_ult_alt
        )
        SELECT C.CTPO_PSSOA,
               C.CCPF_CNPJ_BASE,
               pc.cgrp_ramo_plano,
               pc_util_01.Extra_Banco,
               To_Number(To_Char(Add_Months(To_Date(pc.ccompt_prod, 'yyyymm'), 12), 'YYYYMM')), -- somando 1 ano
               1, --sequencial burro
               SUM(PC.VPROD_CRRTR * (1+ (ccc.pcrsct_prod_alt/100) )), -- produção do ano anterior e joga o perc.cresc
               SUM(PC.VPROD_CRRTR * (1+ (ccc.pcrsct_prod_alt/100) )), -- produção do ano anterior e joga o perc.cresc
               'S',
               sysdate,
               'CARGA-ESP'
            --
          FROM CRRTR C
          JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                            AND PC.CUND_PROD = C.CUND_PROD
                            AND PC.CGRP_RAMO_PLANO = pc_util_01.Auto
                            AND PC.CCOMPT_PROD BETWEEN intComptInicialAnterior AND IntrcompetenciaAnterior -- ano passado
                            AND PC.CTPO_COMIS = pc_util_01.COMISSAO_NORMAL
                            AND PC.CCRRTR BETWEEN 100000 and 200000 -- extrabanco
            --
          JOIN parm_info_campa pic
            ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
           AND PIC.DFIM_VGCIA_PARM IS NULL
            --
          join crrtr_eleit_campa cec
            on cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
           and cec.ccanal_vda_segur = pic.ccanal_vda_segur
           and cec.ccpf_cnpj_base = c.ccpf_cnpj_base
           and cec.ctpo_pssoa = c.ctpo_pssoa
            --
          JOIN carac_crrtr_canal ccc
            ON ccc.ccanal_vda_segur = pic.ccanal_vda_segur
           and ccc.dinic_vgcia_parm = pic.dinic_vgcia_parm
           and ccc.ccpf_cnpj_base   = c.ccpf_cnpj_base
           and ccc.ctpo_pssoa       = c.ctpo_pssoa
           and ccc.cind_perc_ativo = 'S'
           and ccc.dult_alt > to_date(20070301,'YYYYMMDD')
            --
         GROUP BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE, pc.cgrp_ramo_plano, pc.ccompt_prod;
      commit;
      --
  EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(Intrcompetencia)||
                           ' Canal: ' || to_char(PC_UTIL_01.Extra_Banco) || ' # ' || SQLERRM,
                           1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169',var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0169'||' - insereObjetivoExtraBancoEsp',
                              722, PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 21 - Erro Ora: '||SUBSTR(SQLERRM,1,100));
    -- 
--------------------------------------------------------------------------------
end insereObjetivoExtraBancoEsp;
/

