CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0157(curvrelat              OUT SYS_REFCURSOR,
                                     IntrCompetenciaInicial IN Prod_Crrtr.Ccompt_Prod %TYPE,
                                     IntrCompetenciaFinal   IN Prod_Crrtr.Ccompt_Prod %TYPE,
                                     Intcodcanal_Vda_Segur  IN Parm_Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
                                     chrNomeCorretor        IN crrtr_unfca_cnpj.iatual_crrtr %TYPE,
                                     IntrCnpjRaiz           IN crrtr_unfca_cnpj.ccpf_cnpj_base %TYPE,
                                     chrTipoPessoa          IN crrtr_unfca_cnpj.ctpo_pssoa %TYPE

                                     ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0157
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna lista de CorretorUnificado->MargemContribuicao->Canal;
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
           cuc.ctpo_pssoa,
           --
           'cnpjBase',
           cuc.ccpf_cnpj_base,
           'nome',
           cuc.iatual_crrtr,
           --
           'percentual',
           mcc.pmargm_contb,
           'competencia',
           mcc.ccompt_margm,
           --
           'canalVendaVO.codigo',
           cvs.ccanal_vda_segur,
           'canalVendaVO.descricao',
           cvs.icanal_vda_segur
        --
      from crrtr_unfca_cnpj cuc
        --
      join margm_contb_crrtr mcc
        on mcc.ccpf_cnpj_base = cuc.ccpf_cnpj_base
       and mcc.ctpo_pssoa = cuc.ctpo_pssoa
        --
      join canal_vda_segur cvs
        on cvs.ccanal_vda_segur = mcc.ccanal_vda_segur
        --
     where mcc.ccanal_vda_segur = Intcodcanal_Vda_Segur
       and mcc.ccompt_margm between IntrCompetenciaInicial and IntrCompetenciaFinal
       and ((IntrCnpjRaiz is null) or (mcc.ccpf_cnpj_base = IntrCnpjRaiz))
       and ((chrTipoPessoa is null) or (mcc.ctpo_pssoa = chrTipoPessoa))
       and ((chrNomeCorretor is null) or (cuc.iatual_crrtr like '%'||chrNomeCorretor||'%'))

       order by 6,2,4,10; --nome, tipoPessoa, CnpjBase, Competencia
  --
END SGPB0157;
/

