CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0156
(
  ptdfim_vgcia_parm    IN VARCHAR2, -- parm_canal_vda_segur.dfim_vgcia_parm %type,
  ptdinic_vgcia_parm   IN VARCHAR2, -- parm_canal_vda_segur.dinic_vgcia_parm %type,
  pccanal_vda_segur    IN parm_canal_vda_segur.ccanal_vda_segur %TYPE,
  pqtempo_min_rlcto    IN parm_canal_vda_segur.qtempo_min_rlcto %TYPE,
  ppmargm_contb_min    IN parm_canal_vda_segur.pmargm_contb_min %TYPE,
  pcinic_faixa_crrtr   IN parm_canal_vda_segur.cinic_faixa_crrtr %TYPE,
  pcfnal_faixa_crrtr   IN parm_canal_vda_segur.cfnal_faixa_crrtr %TYPE,
  pvmin_librc_pgto     IN parm_canal_vda_segur.vmin_librc_pgto %TYPE,
  pqmes_max_rtcao      IN parm_canal_vda_segur.qmes_max_rtcao %TYPE,
  ptdult_alt           IN VARCHAR2, -- parm_canal_vda_segur.dult_alt %type,
  pcresp_ult_alt       IN parm_canal_vda_segur.cresp_ult_alt %TYPE,
  pccta_ctbil_credr    IN parm_canal_vda_segur.ccta_ctbil_credr %TYPE,
  pccta_ctbil_dvdor    IN parm_canal_vda_segur.ccta_ctbil_dvdor %TYPE,
  pvmin_prod_apurc     in parm_canal_vda_segur.vmin_prod_apurc %type,
  pcrstc_prod_ano      in parm_canal_vda_segur.pcrstc_prod_ano %type,
  pcprfil_pdrao_crrtr  in parm_canal_vda_segur.cprfil_pdrao_crrtr %type,
  pqmes_durac_campa    in parm_canal_vda_segur.qmes_durac_campa %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0156
  --      DATA            : 16/03/2006
  --      AUTOR           : Paulo Boccaletti - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : insere um novo registro na tabela PARM_CANAL_VDA_SEGUR relativo a classe ParamCanalVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  pdfim_vgcia_parm  parm_canal_vda_segur.dfim_vgcia_parm %TYPE;
  pdinic_vgcia_parm parm_canal_vda_segur.dinic_vgcia_parm %TYPE;
  pdult_alt         parm_canal_vda_segur.dult_alt %TYPE;
BEGIN
  --
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm  := To_date(ptdfim_vgcia_parm,
                               'YYYYMMDD');
  pdinic_vgcia_parm := To_date(ptdinic_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  --
  --
  --
  INSERT INTO parm_canal_vda_segur
    (dfim_vgcia_parm,
     dinic_vgcia_parm,
     ccanal_vda_segur,
     qtempo_min_rlcto,
     pmargm_contb_min,
     cinic_faixa_crrtr,
     cfnal_faixa_crrtr,
     vmin_librc_pgto,
     qmes_max_rtcao,
     dult_alt,
     cresp_ult_alt,
     ccta_ctbil_credr,
     ccta_ctbil_dvdor,
     vmin_prod_apurc,
     pcrstc_prod_ano,
     cprfil_pdrao_crrtr,
     qmes_durac_campa)
  VALUES
    (pdfim_vgcia_parm,
     pdinic_vgcia_parm,
     pccanal_vda_segur,
     pqtempo_min_rlcto,
     ppmargm_contb_min,
     pcinic_faixa_crrtr,
     pcfnal_faixa_crrtr,
     pvmin_librc_pgto,
     pqmes_max_rtcao,
     pdult_alt,
     pcresp_ult_alt,
     pccta_ctbil_credr,
     pccta_ctbil_dvdor,
     pvmin_prod_apurc,
     pcrstc_prod_ano,
     pcprfil_pdrao_crrtr,
     pqmes_durac_campa);
  --
  --
END SGPB0156;
/

