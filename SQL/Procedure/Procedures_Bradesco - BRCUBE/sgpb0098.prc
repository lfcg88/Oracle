CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0098
(
  curvrelat        OUT SYS_REFCURSOR,
  pCanal           IN parm_crrtr_excec.ccanal_vda_segur %TYPE,
  dtCompet         IN varchar2
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0098
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure retorna lista de PARM_CRRTR_EXCEC com 1:1 CRRTR_UNFCA_CNPJ
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
BEGIN
  --
  OPEN curvrelat FOR
  --
    SELECT pce.ccpf_cnpj_base,
           pce.ccanal_vda_segur,
           pce.dinic_vgcia_parm,
           pce.dfim_vgcia_parm,
           pce.dult_alt,
           pce.cresp_ult_alt,
           pce.ctpo_pssoa,
           cuc.ccpf_cnpj_base,
           cuc.ctpo_pssoa,
           cuc.iatual_crrtr,
           cvs.ccanal_vda_segur,
           cvs.icanal_vda_segur,
	         cvs.rcanal_vda_segur

      FROM parm_crrtr_excec pce
      --
      JOIN crrtr_unfca_cnpj cuc
        on cuc.ccpf_cnpj_base = pce.ccpf_cnpj_base
       and cuc.ctpo_pssoa = pce.ctpo_pssoa
      --
      join canal_vda_segur cvs
        on cvs.ccanal_vda_segur = pce.ccanal_vda_segur
    --
    where to_date(dtCompet, 'YYYYMMDD') BETWEEN pce.dinic_vgcia_parm and nvl(pce.dfim_vgcia_parm, TO_DATE(99991231,'YYYYMMDD'))
      AND pce.ccanal_vda_segur = pCanal;
  --
END SGPB0098;
/

