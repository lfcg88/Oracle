create or replace package body sgpb_proc.PC_APURACAO is

    --Variáveis utilizadas na maioria dos métodos
    Intinicialfaixa Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr %TYPE;
    Intfinalfaixa   Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr %TYPE;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : removeCorretoresProducaoAbaixoPadrao
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : busca quantidade de meses para apuracao
    --      ALTERAÇÕES      :
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
    --      OBJETIVO        : insere público inicial do canal banco e finasa
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicialBancoFinasa
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    ) IS
      intrMesesApurConsiderar integer;
      intComptInicial integer;

    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          Pc_Util_01.Extra_Banco,
                          Intrcompetencia,
                          Pc_Util_01.Normal);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      --
      --
      --
      Pc_Util_01.Sgpb0003(Intinicialfaixa,
                          Intfinalfaixa,
                          intrCanal,
                          Intrcompetencia);
      --
      --
      UPDATE Crrtr Cr
         SET Cr.Cind_Crrtr_Selec = 1
       WHERE (Ccrrtr, Cund_Prod) IN
                        (
                       SELECT MAC.CCRRTR_DSMEM, MAC.CUND_PROD

                         FROM MPMTO_AG_CRRTR MAC

                         join crrtr c on c.ccrrtr = mac.ccrrtr_dsmem
                                     and c.cund_prod = mac.cund_prod

                         JOIN PARM_INFO_CAMPA PIC
                           ON PIC.CCANAL_VDA_SEGUR = intrCanal
                          AND LAST_DAY(TO_DATE(Intrcompetencia, 'YYYYMM')) BETWEEN PIC.DINIC_VGCIA_PARM AND nvl(PIC.DFIM_VGCIA_PARM, to_date(99991231, 'YYYYMMDD'))

                         JOIN CRRTR_ELEIT_CAMPA CEC
                           ON CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
                          AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                          AND CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
                          AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
                          and cec.dcrrtr_selec_campa < last_day(to_date(Intrcompetencia, 'YYYYMM'))


                        WHERE MAC.CCRRTR_ORIGN BETWEEN Intinicialfaixa AND Intfinalfaixa
                          AND last_day(TO_DATE(Intrcompetencia, 'YYYYMM')) >= MAC.DENTRD_CRRTR_AG
                          AND last_day(TO_DATE(intComptInicial, 'YYYYMM')) < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                          );
      --
      --
    end inserePubicoInicialBancoFinasa;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : inserePubicoInicial
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere público inicial do canal extra-banco
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicialExtraBanco
    (
      Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal       canal_vda_segur.ccanal_vda_segur%type
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
         SET Cr.Cind_Crrtr_Selec = 1
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
    --      OBJETIVO        : Roteradora de inserir púbico inicial
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicial
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    ) IS
    begin
      --
      --
      if (intrCanal = pc_util_01.Extra_Banco) then
        --
        --
        inserePubicoInicialExtraBanco( Intrcompetencia, intrCanal );
        --
      else
        --
        --
        inserePubicoInicialBancoFinasa( Intrcompetencia, intrCanal );
        --
      end if;
      --
      --
    end inserePubicoInicial;




    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca valor mínimo para apuracao 30.000
    --      ALTERAÇÕES      :
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
    --      OBJETIVO        : Remove quem não tem o producao mínima de 30.000,00
    --      ALTERAÇÕES      :
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
    --      PROCEDURE       : delCorrtrProducaoAbaixoObjBF
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem não tem o objetivo mínimo Banco e Finasa
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCrrtrProdAbxoObjBF
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type,
      intrGrupoRamoProd      grp_ramo_plano.cgrp_ramo_plano%type,
      intrGrupoRamoObj       grp_ramo_plano.cgrp_ramo_plano%type
    ) IS
    --
      intrMesesApurConsiderar integer;
      intComptInicial integer;
    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          intrCanal,
                          Intrcompetencia,
                          Pc_Util_01.Normal);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));
      --
      --
      UPDATE Crrtr Cr_ext
         SET Cr_ext.Cind_Crrtr_Selec = 0
         WHERE Cr_ext.Cind_Crrtr_Selec = 1
         AND (Cr_ext.Ccrrtr, Cr_ext.Cund_Prod) IN
             (
                select c.ccrrtr, c.cund_prod

                  from parm_info_campa pic
                    --
                  join crrtr_eleit_campa cec
                    on cec.ccanal_vda_segur = pic.ccanal_vda_segur
                   and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
                    --
                    --
                  join crrtr c
                    on c.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and c.ctpo_pssoa     = cec.ctpo_pssoa
                    --
                    --
                  left
                  join (
                            select c.ccpf_cnpj_base, c.ctpo_pssoa, sum(pc.vprod_crrtr) tot
                              --
                            from crrtr c
                              --
                            join prod_crrtr pc
                              on pc.ccrrtr = c.ccrrtr
                             and pc.cund_prod = c.cund_prod
                             and pc.cgrp_ramo_plano = intrGrupoRamoProd
                             and pc.ctpo_comis = pc_util_01.COMISSAO_NORMAL
                             and pc.ccompt_prod between intComptInicial and Intrcompetencia
                              --
                           where c.cind_crrtr_selec = 1
                --             and c.ccpf_cnpj_base = 2422505
                --             and c.ctpo_pssoa = 'J'
                              --
                           group
                              by c.ccpf_cnpj_base, c.ctpo_pssoa
                       ) prod
                    on prod.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and prod.ctpo_pssoa = cec.ctpo_pssoa
                    --
                    --
                  left
                  join (
                          select opc.ccpf_cnpj_base, opc.ctpo_pssoa, sum(opc.vobjtv_prod_crrtr_alt) tot
                              --
                            from objtv_prod_crrtr opc
                              --
                           where opc.cano_mes_compt_objtv between intComptInicial and Intrcompetencia
                             and opc.cgrp_ramo_plano = intrGrupoRamoObj
                             and opc.cind_reg_ativo = 'S'
                             and opc.ccanal_vda_segur = intrCanal
                --             and opc.ccpf_cnpj_base = 2422505
                --             and opc.ctpo_pssoa = 'J'
                              --
                           group
                              by opc.ccpf_cnpj_base, opc.ctpo_pssoa

                          having count(*) = intrMesesApurConsiderar

                       ) obj
                    on obj.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and obj.ctpo_pssoa = cec.ctpo_pssoa
                    --
                    --
                 where pic.ccanal_vda_segur = intrCanal
                   and pic.dfim_vgcia_parm is null
                --   and cec.ccpf_cnpj_base = 2422505
                --   and cec.ctpo_pssoa = 'J'

                   and (
                         obj.ccpf_cnpj_base is null
                       or
                         nvl(prod.tot, 0) < obj.tot
                       )
              );
      --
      --
    end delCrrtrProdAbxoObjBF;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoObjEB
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem não tem o objetivo mínimo Extra-Banco
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCrrtrProdAbxoObjEB
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type,
      intrGrupoRamoProd      grp_ramo_plano.cgrp_ramo_plano%type,
      intrGrupoRamoObj       grp_ramo_plano.cgrp_ramo_plano%type
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
      UPDATE Crrtr Cr_ext
         SET Cr_ext.Cind_Crrtr_Selec = 0
         WHERE Cr_ext.Cind_Crrtr_Selec = 1
         AND (Cr_ext.Ccrrtr, Cr_ext.Cund_Prod) IN
             (
                select c.ccrrtr, c.cund_prod

                  from parm_info_campa pic
                    --
                  join crrtr_eleit_campa cec
                    on cec.ccanal_vda_segur = pic.ccanal_vda_segur
                   and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
                    --
                    --
                  join crrtr c
                    on c.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and c.ctpo_pssoa     = cec.ctpo_pssoa
                    --
                    --
                  left
                  join (
                            select c.ccpf_cnpj_base, c.ctpo_pssoa, sum(pc.vprod_crrtr) tot
                              --
                            from crrtr c
                              --
                            join prod_crrtr pc
                              on pc.ccrrtr = c.ccrrtr
                             and pc.cund_prod = c.cund_prod
                             and pc.cgrp_ramo_plano = intrGrupoRamoProd
                             and pc.ctpo_comis = pc_util_01.COMISSAO_NORMAL
                             and pc.ccompt_prod between intComptInicial and Intrcompetencia
                              --
                           where c.cind_crrtr_selec = 1
                --             and c.ccpf_cnpj_base = 2422505
                --             and c.ctpo_pssoa = 'J'
                              --
                           group
                              by c.ccpf_cnpj_base, c.ctpo_pssoa
                       ) prod
                    on prod.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and prod.ctpo_pssoa = cec.ctpo_pssoa
                    --
                    --
                  left
                  join (
                          select opc.ccpf_cnpj_base, opc.ctpo_pssoa, sum(opc.vobjtv_prod_crrtr_alt) tot
                              --
                            from objtv_prod_crrtr opc
                              --
                           where opc.cano_mes_compt_objtv between intComptInicial and Intrcompetencia
                             and opc.cgrp_ramo_plano = intrGrupoRamoObj
                             and opc.cind_reg_ativo = 'S'
                             and opc.ccanal_vda_segur = intrCanal
                --             and opc.ccpf_cnpj_base = 2422505
                --             and opc.ctpo_pssoa = 'J'
                              --
                           group
                              by opc.ccpf_cnpj_base, opc.ctpo_pssoa

                       ) obj
                    on obj.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and obj.ctpo_pssoa = cec.ctpo_pssoa
                    --
                    --
                 where pic.ccanal_vda_segur = intrCanal
                   and pic.dfim_vgcia_parm is null
                --   and cec.ccpf_cnpj_base = 2422505
                --   and cec.ctpo_pssoa = 'J'

                   and nvl(prod.tot, 0) < nvl(obj.tot, valorMinimo)

              );
      --
      --
    end delCrrtrProdAbxoObjEB;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca a margem mínima de contribuição
    --      ALTERAÇÕES      :
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
    --      OBJETIVO        : Remove quem não tem margem mínima
    --      ALTERAÇÕES      :
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
      UPDATE Crrtr Cr_ext
         SET Cr_ext.Cind_Crrtr_Selec = 0
         WHERE Cr_ext.Cind_Crrtr_Selec = 1
         AND (Cr_ext.Ccrrtr, Cr_ext.Cund_Prod) IN
             (
                select c.ccrrtr, c.cund_prod
                    --
                  from parm_info_campa pic
                    --
                  join crrtr_eleit_campa cec
                    on cec.ccanal_vda_segur = pic.ccanal_vda_segur
                   and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
                    --
                    --
                  join crrtr c
                    on c.ccpf_cnpj_base = cec.ccpf_cnpj_base
                   and c.ctpo_pssoa     = cec.ctpo_pssoa
                    --
                    --
                  left
                  join margm_contb_crrtr mcc
                    on mcc.ccpf_cnpj_base   = cec.ccpf_cnpj_base
                   and mcc.ctpo_pssoa       = cec.ctpo_pssoa
                   and mcc.ccanal_vda_segur = intrCanal
                   and mcc.ccompt_margm     = Intrcompetencia
                    --
                    --
                 where pic.ccanal_vda_segur = intrCanal
                   and pic.dfim_vgcia_parm is null

                   and (
                         mcc.ccpf_cnpj_base is null
                       or
                         mcc.pmargm_contb < margemContribMin
                       )
              );
      --
      --
    end delCorrtrProducaoAbaixoMargem;


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Busca o perfil padrão do corretor
    --      ALTERAÇÕES      :
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
    --      ALTERAÇÕES      :
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
      delete
        from apurc_prod_crrtr apc
       where apc.ccompt_apurc     = intComptApurc
         and apc.ccanal_vda_segur = Intrcanal
         and apc.cgrp_ramo_plano  = intGrupoRamo
         and apc.ctpo_apurc       = intTipoApuracao;
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
      select mcc.ccanal_vda_segur, --canal
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
        join margm_contb_crrtr mcc
          on mcc.ccpf_cnpj_base   = c.ccpf_cnpj_base
         and mcc.ctpo_pssoa       = c.ctpo_pssoa
         and mcc.ccanal_vda_segur = Intrcanal --CANAL
         and mcc.ccompt_margm     = intComptApurc --Intrcompetencia
          --
        join parm_info_campa pic
          on pic.ccanal_vda_segur = mcc.ccanal_vda_segur
         and pic.dfim_vgcia_parm is null
          --
        left
        join carac_crrtr_canal ccc
          on ccc.ccanal_vda_segur = pic.ccanal_vda_segur
         and ccc.dinic_vgcia_parm = pic.dinic_vgcia_parm
         and ccc.ccpf_cnpj_base = c.ccpf_cnpj_base
         and ccc.ctpo_pssoa = c.ctpo_pssoa
         and ccc.cind_prfil_ativo = 'S'
          --
        join parm_perc_pgto_bonif pppb
          on pppb.ccanal_vda_segur = mcc.ccanal_vda_segur
         and pppb.ctpo_apurc = intTipoApuracao
         and last_day(to_date(intComptApurc, 'YYYYMM')) between pppb.dinic_vgcia_parm and nvl(pppb.dfim_vgcia_parm, to_date(99991231, 'YYYYMMDD'))
         and mcc.pmargm_contb between pppb.pmin_margm_contb and pppb.pmax_margm_contb
         and pppb.ctpo_prfil_crrtr = nvl(ccc.cprfil_crrtr_alt, perfilPadrao)
          --
       where c.cind_crrtr_selec = 1;
--         and c.ccpf_cnpj_base = 2422505
--         and c.ctpo_pssoa = 'J'

      --
      --
    end insereTabelaApuracao;

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getPercentualPadrao
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : busca o percentual padrão 20%
    --      ALTERAÇÕES      :
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
  --      ALTERAÇÕES      :
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

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : insereObjetivoExtraBanco
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere Objetivo Extra-Banco
    --      ALTERAÇÕES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE insereObjetivoExtraBanco
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE
    ) IS
      intrMesesApurConsiderar integer;
      intComptInicial integer;
      --
      intComptInicialAnterior integer;
      IntrcompetenciaAnterior integer;
      --
      percentualPadrao parm_canal_vda_segur.pcrstc_prod_ano %type;
      vmin_prod_crrtr_J PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr %type;
      vmin_prod_crrtr_F PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr %type;
    begin
      --
      --
      getMesesApuracaoConsiderar(intrMesesApurConsiderar,
                          pc_util_01.Extra_Banco,
                          Intrcompetencia,
                          Pc_Util_01.Normal);
      --
      --
      intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((intrMesesApurConsiderar -1) * -1)), 'YYYYMM'));

      intComptInicialAnterior := To_Number(To_Char(Add_Months(To_Date(intComptInicial, 'yyyymm'), -12), 'YYYYMM'));
      IntrcompetenciaAnterior := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'), -12), 'YYYYMM'));
      --
      --
      getPercentualPadrao( percentualPadrao,
                           pc_util_01.Extra_Banco,
                           Intrcompetencia );
      --
      --
      delete objtv_prod_crrtr opc
       where opc.ccanal_vda_segur = pc_util_01.Extra_Banco;
      commit;
      --
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
               To_Number(To_Char(Add_Months(To_Date(pc.ccompt_prod, 'yyyymm'), 12), 'YYYYMM')),
               1, --sequencial burro
               SUM(PC.VPROD_CRRTR * (1+ (nvl(ccc.pcrsct_prod_alt, percentualPadrao)/100) )),
               SUM(PC.VPROD_CRRTR * (1+ (nvl(ccc.pcrsct_prod_alt, percentualPadrao)/100) )),
               'S',
               sysdate,
               'CARGA'
            --
          FROM CRRTR C
          JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                            AND PC.CUND_PROD = C.CUND_PROD
                            AND PC.CGRP_RAMO_PLANO = pc_util_01.Auto
                            AND PC.CCOMPT_PROD BETWEEN intComptInicialAnterior AND IntrcompetenciaAnterior
                            AND PC.CTPO_COMIS = pc_util_01.COMISSAO_NORMAL
            --
          JOIN parm_info_campa pic
            ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
           AND PIC.DFIM_VGCIA_PARM IS NULL
            --
          left
          JOIN carac_crrtr_canal ccc
            ON ccc.ccanal_vda_segur = pic.ccanal_vda_segur
           and ccc.dinic_vgcia_parm = pic.dinic_vgcia_parm
           and ccc.ccpf_cnpj_base   = c.ccpf_cnpj_base
           and ccc.ctpo_pssoa       = c.ctpo_pssoa
           and ccc.cind_perc_ativo = 'S'
            --
         WHERE c.cind_crrtr_selec = 1
            --
         GROUP BY C.CTPO_PSSOA,
               C.CCPF_CNPJ_BASE,
               pc.cgrp_ramo_plano,
               pc.ccompt_prod;
      commit;
      --
      --
      getVlObjRe(
        vmin_prod_crrtr_j,
        pc_util_01.Extra_Banco,
        'J',
        Intrcompetencia);
      --
      --
      getVlObjRe(
        vmin_prod_crrtr_f,
        pc_util_01.Extra_Banco,
        'F',
        Intrcompetencia);
      --
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
               pc_util_01.re,
               pc_util_01.Extra_Banco,
               intComptInicial,
               1, --sequencial burro
               decode(c.ctpo_pssoa,'J',vmin_prod_crrtr_j, vmin_prod_crrtr_f) * intrMesesApurConsiderar,
               decode(c.ctpo_pssoa,'J',vmin_prod_crrtr_j, vmin_prod_crrtr_f) * intrMesesApurConsiderar,
               'S',
               sysdate,
               'CARGA'
            --
          FROM CRRTR C
            --
         WHERE c.cind_crrtr_selec = 1
            --
         GROUP BY C.CTPO_PSSOA,
               C.CCPF_CNPJ_BASE;
      commit;
      --
      --
    end insereObjetivoExtraBanco;


end PC_APURACAO;
/

