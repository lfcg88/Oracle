CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0161(
    curvrelat              OUT SYS_REFCURSOR,
    p_data_inicial         varchar2,
    p_data_final           varchar2,
    p_ccanal_vda_segur     apurc_prod_crrtr.ccanal_vda_segur %type,
    p_cgrp_ramo_plano      apurc_prod_crrtr.cgrp_ramo_plano %type,
    p_ctpo_docto           apolc_prod_crrtr.ctpo_docto %type,
    p_iatual_crrtr         crrtr_unfca_cnpj.iatual_crrtr %type,
    p_ccpf_cnpj_base       crrtr_unfca_cnpj.ccpf_cnpj_base %type,
    p_ctpo_pssoa           crrtr_unfca_cnpj.ctpo_pssoa %type
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0161
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : DAO para Relatório de bonificacao apolices - Producao banco-Finasa
  --      objetivo        :
  --      objetivo        :
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------

  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  v_data_inicial  date := TO_DATE(P_data_inicial, 'YYYYMMDD');
  v_data_final    date := TO_DATE(p_data_final  , 'YYYYMMDD');
  v_competencia   number := TO_NUMBER(to_char(v_data_final, 'YYYYMM'));
BEGIN
  --
  Pc_Util_01.Sgpb0003(Intinicialfaixa,
                      Intfinalfaixa,
                      p_ccanal_vda_segur,
                      v_competencia);
  --
  OPEN curvrelat FOR
  --
    SELECT 'tipoPessoa',
           CUC.ctpo_pssoa,
           'cnpjBase',
           CUC.ccpf_cnpj_base,
           'nome',
           CUC.iatual_crrtr,
           --
           --
           'dataEmissao',
           aplc.demis_apolc,
           'tipoComissao',
           aplc.ctpo_comis,
           'apolice',
           aplc.cchave_lgado_apolc,
           'valorApolice',
           aplc.vprmio_emtdo_apolc,
           'ramo',
           aplc.cramo_apolc
           --
           --
      FROM crrtr_unfca_cnpj CUC
        --
        --
      JOIN mpmto_ag_crrtr mac
        on MAC.CCRRTR_ORIGN between Intinicialfaixa and Intfinalfaixa
        --
        --
      JOIN crrtr c
        on c.ccpf_cnpj_base = cuc.ccpf_cnpj_base
       and c.ctpo_pssoa     = cuc.ctpo_pssoa
       and C.CCRRTR         = mac.ccrrtr_dsmem
       and c.cund_prod      = mac.cund_prod
        --
        --
      join apolc_prod_crrtr aplc
        on aplc.ccrrtr          = c.ccrrtr
       and aplc.cund_prod       = c.cund_prod
       and aplc.demis_apolc     between v_data_inicial and v_data_final
        --
        --
      join agpto_ramo_plano arp
        on arp.cgrp_ramo_plano = p_cgrp_ramo_plano
       and arp.cramo           = aplc.cramo_apolc
        --
        --
     where aplc.demis_apolc >= MAC.DENTRD_CRRTR_AG
       AND aplc.demis_apolc < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))

       AND aplc.ctpo_docto = p_ctpo_docto
       and ((p_ccpf_cnpj_base is null) or (cuc.ccpf_cnpj_base = p_ccpf_cnpj_base))
--       and ((p_ctpo_pssoa is null) or (cuc.ctpo_pssoa = p_ctpo_pssoa))
       and cuc.ctpo_pssoa = p_ctpo_pssoa
       and ((p_iatual_crrtr is null) or (cuc.iatual_crrtr like '%'||p_iatual_crrtr||'%'));
  --
END SGPB0161;
/

