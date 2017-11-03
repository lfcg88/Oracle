CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0113
(
  pccanal_vda_segur  IN parm_perc_pgto_bonif.ccanal_vda_segur %TYPE,
  pctpo_apurc        IN parm_perc_pgto_bonif.ctpo_apurc %TYPE,
  ptdinic_vgcia_parm IN VARCHAR2, -- parm_perc_pgto_bonif.dinic_vgcia_parm %type,
  ppmin_margm_contb  IN parm_perc_pgto_bonif.pmin_margm_contb %TYPE,
  ptdfim_vgcia_parm  IN VARCHAR2, -- parm_perc_pgto_bonif.dfim_vgcia_parm %type,
  ptdult_alt         IN VARCHAR2, -- parm_perc_pgto_bonif.dult_alt %TYPE,
  pcresp_ult_alt     IN parm_perc_pgto_bonif.cresp_ult_alt %TYPE,
  ppmax_margm_contb  in parm_perc_pgto_bonif.pmax_margm_contb %TYPE,
  ppbonus_apurc      in parm_perc_pgto_bonif.pbonus_apurc %TYPE,
  pperfil_crrtr      in parm_perc_pgto_bonif.ctpo_prfil_crrtr %TYPE

)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0113
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : insert em PARAMETRO-PERC-PGTO-BONIFICACAO relativo a classe ParamPercentualPagamentoVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  pdinic_vgcia_parm parm_perc_pgto_bonif.dinic_vgcia_parm %type;
  pdfim_vgcia_parm parm_perc_pgto_bonif.dfim_vgcia_parm %TYPE;
  pdult_alt        parm_perc_pgto_bonif.dult_alt %TYPE;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm := To_date(ptdfim_vgcia_parm,
                              'YYYYMMDD');
  pdult_alt        := To_date(ptdult_alt,
                              'YYYYMMDD');
  pdinic_vgcia_parm:= To_date(ptdinic_vgcia_parm,
                              'YYYYMMDD');

  --
  INSERT INTO parm_perc_pgto_bonif
    (dinic_vgcia_parm,
     ctpo_apurc,
     dfim_vgcia_parm,
     ccanal_vda_segur,
     pmax_margm_contb,
     pmin_margm_contb,
     pbonus_apurc,
     dult_alt,
     cresp_ult_alt,
     ctpo_prfil_crrtr)
  VALUES
    (pdinic_vgcia_parm,
     pctpo_apurc,
     pdfim_vgcia_parm,
     pccanal_vda_segur,
     ppmax_margm_contb,
     ppmin_margm_contb,
     ppbonus_apurc,
     pdult_alt,
     pcresp_ult_alt,
     pperfil_crrtr);
     --
     --
END SGPB0113;
/

