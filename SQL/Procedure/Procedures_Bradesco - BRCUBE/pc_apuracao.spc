create or replace package sgpb_proc.PC_APURACAO is


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : inserePubicoInicial
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Roteradora de inserir p�bico inicial
    --      ALTERA��ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE inserePubicoInicial
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal  canal_vda_segur.ccanal_vda_segur%type
    );

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoEsperado
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n�o tem o producao m�nima de 30.000,00
    --      ALTERA��ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCrrtrProdAbxoEsperado
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    );

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoObjBF
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n�o tem o objetivo m�nimo Banco e Finasa
    --      ALTERA��ES      :
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
    );


    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoObjEB
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n�o tem o objetivo m�nimo Extra-Banco
    --      ALTERA��ES      :
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
    );

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : delCorrtrProducaoAbaixoMargem
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Remove quem n�o tem margem m�nima
    --      ALTERA��ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE delCorrtrProducaoAbaixoMargem
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      intrCanal              canal_vda_segur.ccanal_vda_segur%type
    );

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : getMargemContribMinima
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere os corretores com flag na tabela de apuracao
    --      ALTERA��ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE insereTabelaApuracao
    (
        intTipoApuracao in tpo_apurc.ctpo_apurc %type,
        intComptApurc   in apurc_prod_crrtr.ccompt_apurc %type,
        Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
        chrSituacao     in apurc_prod_crrtr.csit_apurc %type,
        intGrupoRamo    in grp_ramo_plano.cgrp_ramo_plano %type
    );

    -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : insereObjetivoExtraBanco
    --      DATA            :
    --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : insere Objetivo Extra-Banco
    --      ALTERA��ES      :
    --                DATA  : -
    --                AUTOR : -
    --                OBS   : -
    -------------------------------------------------------------------------------------------------
    PROCEDURE insereObjetivoExtraBanco
    (
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE
    );

end PC_APURACAO;
/

