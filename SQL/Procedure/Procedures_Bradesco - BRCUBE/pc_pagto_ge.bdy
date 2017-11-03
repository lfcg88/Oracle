create or replace package body sgpb_proc.PC_PAGTO_GE is

    --Variaveis utilizadas na maioria dos metodos
    Intinicialfaixa Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr %TYPE;
    Intfinalfaixa   Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr %TYPE;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : removeCorretoresProducaoAbaixoPadrao
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : busca quantidade de meses para apuracao
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE getMesesApuracaoConsiderar(intrMesesApurConsiderar OUT Parm_Per_Apurc_Canal. Qmes_Anlse %TYPE,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc %TYPE) IS
    BEGIN
    --
    --
      SELECT ppac.qmes_perdc_apurc
        INTO intrMesesApurConsiderar
        FROM Parm_Per_Apurc_Canal ppac
       WHERE ppac.Ccanal_Vda_Segur = Intrcanal
         AND Sgpb0016(Intrvigencia) BETWEEN ppac.Dinic_Vgcia_Parm AND
             pc_util_01.Sgpb0031(ppac.Dfim_Vgcia_Parm)
         AND ppac.Ctpo_Apurc = Intrtpapurc;
    --
    --
    end getMesesApuracaoConsiderar;
    
   
    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : inserePubicoInicial
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere publico inicial do canal extra-banco
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicialExtraBanco
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type,
      intrIndicadorCrrtrSelecionado int
    ) IS
    begin
      --
      --
      Pc_Util_01.Sgpb0003(Intinicialfaixa,
                          Intfinalfaixa,
                          intrCanal,
                          Intrcompetencia);
      --
      --
      UPDATE Crrtr Cr
         SET Cr.Cind_Crrtr_Selec = intrIndicadorCrrtrSelecionado
       WHERE (Ccrrtr, Cund_Prod) IN
                        (
                       SELECT C.CCRRTR, C.CUND_PROD

                         FROM crrtr c

                         JOIN PARM_INFO_CAMPA PIC
                           ON PIC.CCANAL_VDA_SEGUR = intrCanal
                          AND LAST_DAY(TO_DATE(Intrcompetencia, 'YYYYMM')) BETWEEN PIC.DINIC_VGCIA_PARM AND nvl(PIC.DFIM_VGCIA_PARM, to_date(99991231, 'YYYYMMDD'))

                         JOIN CRRTR_ELEIT_CAMPA CEC
                           ON CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
                          AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                          AND CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
                          AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
                          and cec.dcrrtr_selec_campa < last_day(to_date(Intrcompetencia, 'YYYYMM'))
                   /*GE*/       
                        join agpto_econm_crrtr aec
                          on last_day(to_date(Intrcompetencia, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
                       
                        join crrtr_partc_agpto_econm cpae
                          on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                         and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                         and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr    
                         and last_day(to_date(Intrcompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                         AND cpae.CCPF_CNPJ_BASE = cec.CCPF_CNPJ_BASE
                         AND cpae.CTPO_PSSOA = cec.CTPO_PSSOA
                  /*GE*/       
                        WHERE c.ccrrtr BETWEEN Intinicialfaixa AND Intfinalfaixa
                          );
      --
      --
    end inserePubicoInicialExtraBanco;



    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : inserePubicoInicial
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Roteradora de inserir pubico inicial
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicial
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type,
      intrIndicadorCrrtrSelecionado int
    ) IS
    begin
      --
      --
      /*GE*/
      inserePubicoInicialExtraBanco( Intrcompetencia, intrCanal, intrIndicadorCrrtrSelecionado );
      /*GE*/
      --
      --
    end inserePubicoInicial;




    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca valor minimo para apuracao 30.000
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE getValorMinimoApuracao(valorMinimo OUT Parm_Canal_Vda_Segur.Vmin_Prod_Apurc%type,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    BEGIN
    --
    --
      SELECT pcvs.vmin_prod_apurc
        INTO valorMinimo
        FROM Parm_Canal_Vda_Segur pcvs
       WHERE pcvs.Ccanal_Vda_Segur = Intrcanal
         AND Sgpb0016(Intrvigencia) BETWEEN pcvs.Dinic_Vgcia_Parm AND
             pc_util_01.Sgpb0031(pcvs.Dfim_Vgcia_Parm);
    --
    --
    end getValorMinimoApuracao;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoEsperado
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n?o tem o producao minima de 30.000,00
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCrrtrProdAbxoEsperado
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    ) IS
    --
      intrMesesApurConsiderar integer;
      intComptInicial integer;
      valorMinimo Parm_Canal_Vda_Segur.Vmin_Prod_Apurc%type;
    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          Pc_Util_01.Extra_Banco,
                          Intrcompetencia,
                          Pc_Util_01.Normal);
      --
      --
      getValorMinimoApuracao(valorMinimo,
                     Intrcanal,
                     Intrcompetencia);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      --
      --
      UPDATE Crrtr Cr_ext
         SET Cr_ext.Cind_Crrtr_Selec = 0
         WHERE (Cr_ext.Ccrrtr, Cr_ext.Cund_Prod) IN
             (
              --
              SELECT Cr_int.Ccrrtr, Cr_int.Cund_Prod
                FROM Crrtr Cr_int
                where Cr_int.Cind_Crrtr_Selec = 1 --
                  and (Cr_int.Ccpf_Cnpj_Base, Cr_int.Ctpo_Pssoa) in
                      ( --
                          SELECT Cr.Ccpf_Cnpj_Base,Cr.Ctpo_Pssoa

                            FROM Crrtr Cr

                            JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
                                              AND Pc.Cund_Prod = Cr.Cund_Prod
                                              AND Pc.Ctpo_Comis = 'CN'
                                              AND Pc.Ccompt_Prod BETWEEN intComptInicial AND Intrcompetencia
                                              AND Pc.Cgrp_Ramo_Plano = Pc_Util_01.Auto

                           WHERE Cr.Cind_Crrtr_Selec = 1
                           GROUP BY Cr.Ccpf_Cnpj_Base, Cr.Ctpo_Pssoa
                          HAVING SUM(Pc.Vprod_Crrtr) < valorMinimo--
                     )
              );
      --
      --
    end delCrrtrProdAbxoEsperado;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoObjEB
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n?o tem o objetivo minimo Extra-Banco
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCrrtrProdAbxoObjEB
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type,
      intrGrupoRamoProd      grp_ramo_plano.cgrp_ramo_plano%type

      --   nao sendo mais usada pois, o resumo j? ? preenchido com o 
      -- objetivo do grupo adequado.
      -- PS.: Se a regra de apuracao alterar o resumo DEVERA OBRIGATORIAMENTE
      -- acompanhar.
      --intrGrupoRamoObj       grp_ramo_plano.cgrp_ramo_plano%type
    ) IS
    --
      intrMesesApurConsiderar integer;
      intComptInicial integer;
      valorMinimo Parm_Canal_Vda_Segur.Vmin_Prod_Apurc%type;
    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          intrCanal,
                          Intrcompetencia,
                          Pc_Util_01.Normal);
      --
      --
      getValorMinimoApuracao(valorMinimo,
                     Intrcanal,
                     Intrcompetencia);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      
      --
      --
      --#3 removendo a participacao destes cnpj da apuracao
      update crrtr c
       set c.cind_crrtr_selec = 0
       where (c.ctpo_pssoa, c.ccpf_cnpj_base) in 
       (
            --#2 todos os participante dos grupos economicos que #1 
            select cpae.ctpo_pssoa, 
                   cpae.ccpf_cnpj_base
                   --
              from crrtr_partc_agpto_econm cpae
              join (
                       --#1 grupos economicos que nao bateram a meta
                        select ctpo_pssoa_agpto_econm_crrtr,
                             ccpf_cnpj_agpto_econm_crrtr,
                             dinic_agpto_econm_crrtr
                             
                        from rsumo_objtv_agpto_econm_crrtr roaec
                        where roaec.ccompt between intComptInicial and Intrcompetencia
                          and roaec.cgrp_ramo_plano = intrGrupoRamoProd
                          and roaec.ccanal_vda_segur = 1
                       
                       group 
                          by ctpo_pssoa_agpto_econm_crrtr,
                             ccpf_cnpj_agpto_econm_crrtr,
                             dinic_agpto_econm_crrtr
                      
                      having (sum(vprod_grp_econm) - sum(vobjtv_prod_agpto_econm_alt)) < 0
                   ) aec
                on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
               and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
               and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr    
               and last_day(to_date(Intrcompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
      );

      --
      --
    end delCrrtrProdAbxoObjEB;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca a margem minima de contribuic?o
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE getMargemContribMinima(margemContribMin OUT Parm_Canal_Vda_Segur.Pmargm_Contb_Min%type,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    BEGIN
    --
    --
      SELECT pcvs.pmargm_contb_min
        INTO margemContribMin
        FROM Parm_Canal_Vda_Segur pcvs
       WHERE pcvs.Ccanal_Vda_Segur = Intrcanal
         AND Sgpb0016(Intrvigencia) BETWEEN pcvs.Dinic_Vgcia_Parm AND
             pc_util_01.Sgpb0031(pcvs.Dfim_Vgcia_Parm);
    --
    --
    end getMargemContribMinima;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoMargem
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n?o tem margem minima
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCorrtrProducaoAbaixoMargem
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    ) IS
    --
    margemContribMin Parm_Canal_Vda_Segur.Pmargm_Contb_Min%type;
    begin
      --
      --
      getMargemContribMinima(margemContribMin,
                             Intrcanal,
                             Intrcompetencia);
      --
      --
      --#3 removendo a participacao destes cnpj da apuracao
      update crrtr c
       set c.cind_crrtr_selec = 0
       where (c.ctpo_pssoa, c.ccpf_cnpj_base) in 
       (
            --#2 todos os participante dos grupos economicos que #1 
            select cpae.ctpo_pssoa, 
                   cpae.ccpf_cnpj_base
                   --
              from crrtr_partc_agpto_econm cpae
              join (
                       --#1 grupos economicos que nao bateram a meta
                        select roaec.ctpo_pssoa_agpto_econm_crrtr,
                             roaec.ccpf_cnpj_agpto_econm_crrtr,
                             roaec.dinic_agpto_econm_crrtr
                             
                        from rsumo_objtv_agpto_econm_crrtr roaec
      
                        join margm_contb_agpto_econm_crrtr mcaec
                          on mcaec.ctpo_pssoa_agpto_econm_crrtr = roaec.ctpo_pssoa_agpto_econm_crrtr
                         and mcaec.ccpf_cnpj_agpto_econm_crrtr = roaec.ccpf_cnpj_agpto_econm_crrtr
                         and mcaec.dinic_agpto_econm_crrtr = roaec.dinic_agpto_econm_crrtr    
                         and mcaec.ccompt_margm = roaec.ccompt
                         and mcaec.ccanal_vda_segur = roaec.ccanal_vda_segur
                        
                        where roaec.ccompt = Intrcompetencia
                          and roaec.cgrp_ramo_plano = 120
                          and roaec.ccanal_vda_segur = intrCanal
                          and mcaec.pmargm_contb < margemContribMin
                       
                   ) aec
                on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
               and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
               and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr    
               and last_day(to_date(Intrcompetencia, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
      );
      --
      --
    end delCorrtrProducaoAbaixoMargem;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca o perfil padr?o do corretor
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE getPerfilPadraoCorretor(perfilPadrao OUT Parm_Canal_Vda_Segur.Cprfil_Pdrao_Crrtr%type,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    BEGIN
    --
    --
      SELECT pcvs.Cprfil_Pdrao_Crrtr
        INTO perfilPadrao
        FROM Parm_Canal_Vda_Segur pcvs
       WHERE pcvs.Ccanal_Vda_Segur = Intrcanal
         AND Sgpb0016(Intrvigencia) BETWEEN pcvs.Dinic_Vgcia_Parm AND
             pc_util_01.Sgpb0031(pcvs.Dfim_Vgcia_Parm);
    --
    --
    end getPerfilPadraoCorretor;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere os corretores com flag na tabela de apuracao
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE insereTabelaApuracao(
                  intTipoApuracao in tpo_apurc.ctpo_apurc %type,
                  intComptApurc   in apurc_prod_crrtr.ccompt_apurc %type,
                  Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                  chrSituacao     in apurc_prod_crrtr.csit_apurc %type,
                  intGrupoRamo    in grp_ramo_plano.cgrp_ramo_plano %type
              ) IS
      --
      intrMesesApurConsiderar integer;
      intComptInicial integer;
      perfilPadrao Parm_Canal_Vda_Segur.Cprfil_Pdrao_Crrtr%type;
    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          intrCanal,
                          intComptApurc,
                          Pc_Util_01.Normal);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(intComptApurc, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      --
      --
      getPerfilPadraoCorretor(perfilPadrao,
                          intrCanal,
                          intComptApurc);
      --
      -- 
      --   * A apuracao de grupo economico n?o deleta a tabela de apuracao,
      -- esta tarefa ? executada na apuracao normal.
      --   * Sempre que houver um reprocessamento, as duas apuracoes deverao
      -- ser executadas, sendo primeiro a normal e depois a grupo economico
      --   * Se esta procedure gerou um pkviolation a causa disto ? que as regras
      -- acima n?o foram observadas.
      --
      -- 
      /*
        
        delete
          from apurc_prod_crrtr apc
         where apc.ccompt_apurc     = intComptApurc
           and apc.ccanal_vda_segur = Intrcanal
           and apc.cgrp_ramo_plano  = intGrupoRamo
           and apc.ctpo_apurc       = intTipoApuracao;
           
      */
      --
      --
      insert into apurc_prod_crrtr
        (
         ccanal_vda_segur,
         ctpo_apurc,
         ccompt_apurc,
         cgrp_ramo_plano,
         ccompt_prod,
         ctpo_comis,
         ccrrtr,
         cund_prod,
         csit_apurc,
         pbonus_apurc,
         cind_apurc_selec
        )
          --
      select mcaec.ccanal_vda_segur, --canal
             intTipoApuracao, --tipo apuracao
             intComptApurc, --competencia apuracao
             pc.cgrp_ramo_plano,
             pc.ccompt_prod,
             pc.ctpo_comis,
             pc.ccrrtr,
             pc.cund_prod,
             --
             chrSituacao,
             pppb.pbonus_apurc,
             0 --INDICADOR DE APURACAO SELECIONADO
             --
        from crrtr c
          --
        join prod_crrtr pc
          on pc.ccrrtr = c.ccrrtr
         and pc.cund_prod = c.cund_prod
         and pc.cgrp_ramo_plano = intGrupoRamo
         and pc.ctpo_comis = pc_util_01.COMISSAO_NORMAL
         and pc.ccompt_prod between intComptInicial AND intComptApurc--intComptInicial and Intrcompetencia
          --           
          --
        join crrtr_partc_agpto_econm cpae
          on cpae.ctpo_pssoa = c.ctpo_pssoa
         and cpae.ccpf_cnpj_base = c.ccpf_cnpj_base
         and last_day(to_date(intComptApurc, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
          --          
          --
        join margm_contb_agpto_econm_crrtr mcaec
          on mcaec.ctpo_pssoa_agpto_econm_crrtr = cpae.ctpo_pssoa_agpto_econm_crrtr
         and mcaec.ccpf_cnpj_agpto_econm_crrtr = cpae.ccpf_cnpj_agpto_econm_crrtr
         and mcaec.dinic_agpto_econm_crrtr = cpae.dinic_agpto_econm_crrtr    
         and mcaec.ccompt_margm = intComptApurc
         and mcaec.ccanal_vda_segur = Intrcanal
          --          
          --
        join parm_perc_pgto_bonif pppb
          on pppb.ccanal_vda_segur = mcaec.ccanal_vda_segur
         and pppb.ctpo_apurc = intTipoApuracao
         and last_day(to_date(intComptApurc, 'YYYYMM')) between pppb.dinic_vgcia_parm and nvl(pppb.dfim_vgcia_parm, to_date(99991231, 'YYYYMMDD'))
         and mcaec.pmargm_contb  between pppb.pmin_margm_contb and pppb.pmax_margm_contb
         and pppb.ctpo_prfil_crrtr = perfilPadrao
          --
       where c.cind_crrtr_selec = 1;
      --
      --
    end insereTabelaApuracao;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getPercentualPadrao
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : busca o percentual padr?o 20%
    --      ALTERAC?ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
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


  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : getVlObjRe
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : retorna o valor do objetivo do canal extrabanco grupo RE
  --      ALTERAC?ES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
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

end PC_PAGTO_GE;
/

