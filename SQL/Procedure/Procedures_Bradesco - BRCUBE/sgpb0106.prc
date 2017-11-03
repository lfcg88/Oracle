CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0106
(
    ptdfim_vgcia_parm       in varchar2, -- parm_canal_vda_segur.dfim_vgcia_parm %type,
    ptdinic_vgcia_parm      in varchar2, -- parm_canal_vda_segur.dinic_vgcia_parm %type,
    pccanal_vda_segur       in parm_canal_vda_segur.ccanal_vda_segur %type,
    pqtempo_min_rlcto       in parm_canal_vda_segur.qtempo_min_rlcto %type,
    ppmargm_contb_min       in parm_canal_vda_segur.pmargm_contb_min %type,
    pcinic_faixa_crrtr      in parm_canal_vda_segur.cinic_faixa_crrtr %type,
    pcfnal_faixa_crrtr      in parm_canal_vda_segur.cfnal_faixa_crrtr %type,
    pvmin_librc_pgto        in parm_canal_vda_segur.vmin_librc_pgto %type,
    pqmes_max_rtcao         in parm_canal_vda_segur.qmes_max_rtcao %type,
    ptdult_alt              in varchar2, -- parm_canal_vda_segur.dult_alt %type,
    pcresp_ult_alt          in parm_canal_vda_segur.cresp_ult_alt %type,
    pccta_ctbil_credr       in parm_canal_vda_segur.ccta_ctbil_credr %type,
    pccta_ctbil_dvdor       in parm_canal_vda_segur.ccta_ctbil_dvdor %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0106
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Atualiza a tabela PARM_CANAL_VDA_SEGUR relativo a classe ParamCanalVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
    pdfim_vgcia_parm parm_canal_vda_segur.dfim_vgcia_parm %type;
    pdinic_vgcia_parm parm_canal_vda_segur.dinic_vgcia_parm %type;
    pdult_alt parm_canal_vda_segur.dult_alt %type;
    intVerifica       INT;
BEGIN
  --
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm := To_date(ptdfim_vgcia_parm, 'YYYYMMDD');
  pdinic_vgcia_parm := To_date(ptdinic_vgcia_parm, 'YYYYMMDD');
  pdult_alt := To_date(ptdult_alt, 'YYYYMMDD');
  --
  --
  --
  --
  /*Verifica se o registro passado como parametro existe no banco*/
  BEGIN
    SELECT 1
      INTO intVerifica
      FROM parm_canal_vda_segur pcvs
     WHERE pcvs.dinic_vgcia_parm = pdinic_vgcia_parm
       AND pcvs.ccanal_vda_segur = pccanal_vda_segur;
  EXCEPTION
    WHEN no_data_found THEN
      Raise_Application_Error(-20210,
                              'REGISTRO NAO ENCONTRADO');
  END;
  --
  update parm_canal_vda_segur
     set dfim_vgcia_parm = pdfim_vgcia_parm,
         dinic_vgcia_parm = pdinic_vgcia_parm,
         ccanal_vda_segur = pccanal_vda_segur,
         qtempo_min_rlcto = pqtempo_min_rlcto,
         pmargm_contb_min = ppmargm_contb_min,
         cinic_faixa_crrtr = pcinic_faixa_crrtr,
         cfnal_faixa_crrtr = pcfnal_faixa_crrtr,
         vmin_librc_pgto = pvmin_librc_pgto,
         qmes_max_rtcao = pqmes_max_rtcao,
         dult_alt = pdult_alt,
         cresp_ult_alt = pcresp_ult_alt,
         ccta_ctbil_credr = pccta_ctbil_credr,
         ccta_ctbil_dvdor = pccta_ctbil_dvdor

   where ccanal_vda_segur = pccanal_vda_segur
     and dinic_vgcia_parm = pdinic_vgcia_parm;
  --
  --
  --
END SGPB0106;
/

