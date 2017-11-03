CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0160_ACYSNE(
    curvrelat              OUT SYS_REFCURSOR,
    p_ccompt_apurc_inicial apurc_prod_crrtr.ccompt_apurc %type,
    p_ccompt_apurc_final   apurc_prod_crrtr.ccompt_apurc %type,
    p_ccanal_vda_segur     apurc_prod_crrtr.ccanal_vda_segur %type,
    p_cgrp_ramo_plano      apurc_prod_crrtr.cgrp_ramo_plano %type,
    p_ctpo_apurc           apurc_prod_crrtr.ctpo_apurc %type,
    p_iatual_crrtr         crrtr_unfca_cnpj.iatual_crrtr %type,
    p_ccpf_cnpj_base       crrtr_unfca_cnpj.ccpf_cnpj_base %type,
    p_ctpo_pssoa           crrtr_unfca_cnpj.ctpo_pssoa %type
) IS
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
  --                autor : - Alexandre Cysne/Marcelo Barbosa
  --                obs   : - Procedure em desenvolvimento de melhoria de performance
  -------------------------------------------------------------------------------------------------

  --criando o cursor T_CORRETOR
  TYPE T_APOLICE IS REF CURSOR;
  --variavel C_CORRETOR_CCC do tipo cursor
  C_APOLICE T_APOLICE;
  
  -- controle de procedure chave
  var_ctpo_pssoa VARCHAR2(1);
  num_ccpf_cnpj_base NUMBER(22) := 0;
  var_iatual_crrtr VARCHAR2(80);
  num_ccompt_apurc NUMBER(22) := 0;
  num_pbonus_apurc NUMBER(22) := 0;
  num_ccrrtr       NUMBER(22) := 0;
  num_cund_prod    NUMBER(22) := 0;


BEGIN
  --
  
  OPEN C_APOLICE FOR
  --
  SELECT 'tipoPessoa',
          CUC.ctpo_pssoa,
          'cnpjBase',
          CUC.ccpf_cnpj_base,
          'nome',
          CUC.iatual_crrtr,
          'competenciaApuracao',
          apc.ccompt_apurc,
          'percentual',
          apc.pbonus_apurc,
          --
          -- Incluido pelo DBA
          pc.ccrrtr         ,
          pc.cund_prod      ,
          pc.cgrp_ramo_plano,
          pc.ctpo_comis     ,
          pc.ccompt_prod    
     FROM cpvo.crrtr_unfca_cnpj CUC,
          cpvo.crrtr            c,
          sgpb.apurc_prod_crrtr apc,
          sgpb.prod_crrtr       pc,
          sgpb.canal_vda_segur  cvs,
          sgpb.grp_ramo_plano   grp
    where c.ccpf_cnpj_base = cuc.ccpf_cnpj_base
      and c.ctpo_pssoa     = cuc.ctpo_pssoa
      and apc.ccrrtr    = c.ccrrtr
      and apc.cund_prod = c.cund_prod
      and apc.csit_apurc in ('PG', 'PL', 'PM')
      and pc.ccrrtr          = apc.ccrrtr
      and pc.cund_prod       = apc.cund_prod
      and pc.cgrp_ramo_plano = apc.cgrp_ramo_plano
      and pc.ccompt_prod     = apc.ccompt_prod
      and pc.ctpo_comis      = apc.ctpo_comis
      and cvs.ccanal_vda_segur = apc.ccanal_vda_segur
      and grp.cgrp_ramo_plano = pc.cgrp_ramo_plano
      and apc.ccompt_apurc between p_ccompt_apurc_inicial and p_ccompt_apurc_final  --obrigatorio
      and apc.ccanal_vda_segur = p_ccanal_vda_segur                                 --obrigatorio
      and apc.cgrp_ramo_plano = p_cgrp_ramo_plano                                   --obrigatorio
      and apc.ctpo_apurc = p_ctpo_apurc;                                             --obrigatorio
  --
  LOOP
  FETCH C_APOLICE INTO var_ctpo_pssoa,
                       num_ccpf_cnpj_base,
                       var_iatual_crrtr,
                       num_ccompt_apurc,
                       num_pbonus_apurc,
                       num_ccrrtr,
                       num_cund_prod;
  --
  EXIT WHEN C_APOLICE%NOTFOUND;
  
  BEGIN
      --
      OPEN curvrelat FOR
      --
      select 'dataEmissao',
             aplc.demis_apolc,
             'apolice',
             aplc.cchave_lgado_apolc,
             'valorApolice',
             aplc.vprmio_emtdo_apolc,
             'valorBonus',
             aplc.vprmio_emtdo_apolc * (num_pbonus_apurc /100),
             'ramo',
             aplc.cramo_apolc
        from sgpb.apolc_prod_crrtr aplc
       where aplc.ccrrtr          = num_ccrrtr
         and aplc.cund_prod       = num_cund_prod;
--         and aplc.cgrp_ramo_plano = reg.cgrp_ramo_plano;
--         and aplc.ctpo_comis      = reg.ctpo_comis;
        -- and aplc.demis_apolc     between to_date(reg.ccompt_prod, 'YYYYMM') 
          --                            and last_day(to_date(reg.ccompt_prod, 'YYYYMM'));
     
      EXCEPTION
       WHEN OTHERS THEN
         --???????????????????????????????????????????????
         COMMIT;
  END;
  
  END LOOP;
  --
  CLOSE C_APOLICE; 
  
  
-----------------------------  
/*
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
           --
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
  */
END SGPB0160_ACYSNE;
/

