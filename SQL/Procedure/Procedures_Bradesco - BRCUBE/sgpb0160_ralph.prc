CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0160_RALPH(
   curvrelat              OUT SYS_REFCURSOR,
    p_ccompt_apurc_inicial apurc_prod_crrtr.ccompt_apurc %type,
    p_ccompt_apurc_final   apurc_prod_crrtr.ccompt_apurc %type,
    p_ccanal_vda_segur     apurc_prod_crrtr.ccanal_vda_segur %type,
    p_cgrp_ramo_plano      apurc_prod_crrtr.cgrp_ramo_plano %type,
    p_ctpo_apurc           apurc_prod_crrtr.ctpo_apurc %type,
    p_iatual_crrtr         crrtr_unfca_cnpj.iatual_crrtr %type,
    p_ccpf_cnpj_base       crrtr_unfca_cnpj.ccpf_cnpj_base %type,
    p_ctpo_pssoa           crrtr_unfca_cnpj.ctpo_pssoa %type
    --p_conta                p_conta_sai number
) IS
--p_conta_sai	 NUMBER := 0;
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0160
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : DAO para Relatório de bonificacao apolices - Apolices
  --      objetivo        :
  --      objetivo        :
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
BEGIN
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
           'competenciaApuracao',
           apc.ccompt_apurc,
           'percentual',
           apc.pbonus_apurc,
           --
           --
           'dataEmissao',
           aplc.demis_apolc,
           --
           --
           'apolice',
           aplc.cchave_lgado_apolc,
           'valorApolice',
           aplc.vprmio_emtdo_apolc,
           'valorBonus',
           aplc.vprmio_emtdo_apolc * (apc.pbonus_apurc /100),
           'ramo',
           aplc.cramo_apolc
           --
    --       'Contador',
    --       count(*) "p_conta"
      FROM crrtr_unfca_cnpj CUC
        --
        --
      JOIN crrtr c
        on c.ccpf_cnpj_base = cuc.ccpf_cnpj_base
       and c.ctpo_pssoa     = cuc.ctpo_pssoa
        --
        --
      join apurc_prod_crrtr apc
        on apc.ccrrtr    = c.ccrrtr
       and apc.cund_prod = c.cund_prod
       --and apc.csit_apurc in ('AP')
       and apc.csit_apurc in ('PG', 'PL', 'PM')
        --
        --
      JOIN prod_crrtr pc
        ON pc.ccrrtr          = apc.ccrrtr
       AND pc.cund_prod       = apc.cund_prod
       AND pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
       AND pc.ccompt_prod     = apc.ccompt_prod
       AND pc.ctpo_comis      = apc.ctpo_comis
        --
        --
      join canal_vda_segur cvs
        on cvs.ccanal_vda_segur = apc.ccanal_vda_segur
        --
        --
      join grp_ramo_plano grp
        on grp.cgrp_ramo_plano = pc.cgrp_ramo_plano
        --
        --
      join apolc_prod_crrtr aplc
        on aplc.ccrrtr          = pc.ccrrtr
       and aplc.cund_prod       = pc.cund_prod
       and aplc.cgrp_ramo_plano = pc.cgrp_ramo_plano
       --and aplc.cramo_apolc in (120,460,519)
       and aplc.ctpo_comis      = pc.ctpo_comis
       and aplc.demis_apolc     between to_date(pc.ccompt_prod, 'YYYYMM') and last_day(to_date(pc.ccompt_prod, 'YYYYMM'))
        --
        --
     where apc.ccompt_apurc between p_ccompt_apurc_inicial and p_ccompt_apurc_final
       and apc.ccanal_vda_segur = p_ccanal_vda_segur
       and apc.cgrp_ramo_plano = p_cgrp_ramo_plano
       and apc.ctpo_apurc = p_ctpo_apurc
       and ((p_ccpf_cnpj_base is null) or (cuc.ccpf_cnpj_base = p_ccpf_cnpj_base))
       and ((p_ctpo_pssoa is null) or (cuc.ctpo_pssoa = p_ctpo_pssoa))
       and ((p_iatual_crrtr is null) or (cuc.iatual_crrtr like '%'||p_iatual_crrtr||'%'));

  --
END SGPB0160_RALPH;
/

