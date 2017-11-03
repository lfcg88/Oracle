CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0118
(
    ptdinic_vgcia_parm      in varchar2, --parm_prod_min_crrtr.dinic_vgcia_parm %type,
    ptdfim_vgcia_parm       in varchar2, --parm_prod_min_crrtr.dfim_vgcia_parm %type,
    pcparm                  in parm_prod_min_crrtr.cparm %type,
    ptdult_alt              in varchar2, --parm_prod_min_crrtr.dult_alt %type,
    pcresp_ult_alt          in parm_prod_min_crrtr.cresp_ult_alt %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0118
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : update em PARM_PROD_MIN_CRRTR relativo a classe ParamProducaoMinimaVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
    pdfim_vgcia_parm      parm_prod_min_crrtr.dfim_vgcia_parm %type;
    pdult_alt             parm_prod_min_crrtr.dult_alt %type;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm  := To_date(ptdfim_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  --
  update parm_prod_min_crrtr
     set dfim_vgcia_parm = pdfim_vgcia_parm,
         dult_alt = pdult_alt,
         cresp_ult_alt = pcresp_ult_alt
   where cparm = pcparm
     and to_char(dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm;
  --
END SGPB0118;
/

