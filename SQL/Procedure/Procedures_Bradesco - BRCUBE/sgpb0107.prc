CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0107
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
  pcind_sit_sist_canal IN varchar2
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0107
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
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
     --cind_sit_sist_canal,
     dult_alt,
     cresp_ult_alt,
     ccta_ctbil_credr,
     ccta_ctbil_dvdor)
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
--     pcind_sit_sist_canal,
     pdult_alt,
     pcresp_ult_alt,
     pccta_ctbil_credr,
     pccta_ctbil_dvdor);
  --
  --
END SGPB0107;
/

