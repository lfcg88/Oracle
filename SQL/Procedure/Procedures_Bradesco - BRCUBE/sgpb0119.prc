CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0119
(
    ptdinic_vgcia_parm      in varchar2, --parm_prod_min_crrtr.dinic_vgcia_parm %type,
    ptdfim_vgcia_parm       in varchar2, --parm_prod_min_crrtr.dfim_vgcia_parm %type,
    pccanal_vda_segur       in parm_prod_min_crrtr.ccanal_vda_segur %type,
    pctpo_pssoa             in parm_prod_min_crrtr.ctpo_pssoa %type,
    pctpo_per               in parm_prod_min_crrtr.ctpo_per %type,
    pcgrp_ramo_plano        in parm_prod_min_crrtr.cgrp_ramo_plano %type,
    pqitem_min_prod_crrtr   in parm_prod_min_crrtr.qitem_min_prod_crrtr %type,
    pvmin_prod_crrtr        in parm_prod_min_crrtr.vmin_prod_crrtr %type,
    ptdult_alt              in varchar2, --parm_prod_min_crrtr.dult_alt %type,
    pcresp_ult_alt          in parm_prod_min_crrtr.cresp_ult_alt %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0119
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Insert em PARM_PROD_MIN_CRRTR relativo a classe ParamProducaoMinimaVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
    pdinic_vgcia_parm     parm_prod_min_crrtr.dinic_vgcia_parm %type;
    pdfim_vgcia_parm      parm_prod_min_crrtr.dfim_vgcia_parm %type;
    pdult_alt             parm_prod_min_crrtr.dult_alt %type;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm  := To_date(ptdfim_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  pdinic_vgcia_parm := To_date(ptdinic_vgcia_parm,
                               'YYYYMMDD');
  --
  INSERT INTO parm_prod_min_crrtr
    (dinic_vgcia_parm,
     dfim_vgcia_parm,
     ccanal_vda_segur,
     ctpo_pssoa,
     cparm,
     ctpo_per,
     cgrp_ramo_plano,
     qitem_min_prod_crrtr,
     vmin_prod_crrtr,
     dult_alt,
     cresp_ult_alt)
  VALUES
    (pdinic_vgcia_parm,
     pdfim_vgcia_parm,
     pccanal_vda_segur,
     pctpo_pssoa,
     (select max(cparm)+1 from parm_prod_min_crrtr),
     pctpo_per,
     pcgrp_ramo_plano,
     pqitem_min_prod_crrtr,
     pvmin_prod_crrtr,
     pdult_alt,
     pcresp_ult_alt);
  --
END SGPB0119;
/

