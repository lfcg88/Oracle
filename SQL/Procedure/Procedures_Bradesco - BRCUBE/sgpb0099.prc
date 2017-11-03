CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0099(
     /*Chave primaria*/ --
     pCanal         parm_crrtr_excec.ccanal_vda_segur %TYPE,
     pCpf_cnpj_base crrtr_unfca_cnpj.ccpf_cnpj_base %TYPE,
     pTipo_pssoa    crrtr_unfca_cnpj.ctpo_pssoa %TYPE,
     pIniCompet     IN VARCHAR2,
     /*alteracoes*/ --
     dtFimCompet IN VARCHAR2,
     pUsuario    IN VARCHAR2 --
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0099
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure Update um PARM_CRRTR_EXCEC
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
BEGIN
  --
  UPDATE parm_crrtr_excec pce
  --
     SET pce.dfim_vgcia_parm = to_date(dtFimCompet, 'YYYYMMDD'),
         pce.cresp_ult_alt = pUsuario,
         pce.dult_alt = sysdate
  --
   WHERE pce.dinic_vgcia_parm = to_date(pIniCompet, 'YYYYMMDD')
     AND pce.ccanal_vda_segur = pCanal
     AND pce.ccpf_cnpj_base = pCpf_cnpj_base
     AND pce.ctpo_pssoa = pTipo_pssoa;
  --
END SGPB0099;
/

