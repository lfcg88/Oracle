CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0116
(
   ptdinic_vgcia_parm        in varchar2, --parm_per_apurc_canal.dinic_vgcia_parm %type,
   ptdfim_vgcia_parm         in varchar2, --parm_per_apurc_canal.dfim_vgcia_parm %type,
   pccanal_vda_segur         in parm_per_apurc_canal.ccanal_vda_segur %type,
   pctpo_apurc               in parm_per_apurc_canal.ctpo_apurc %type,
   pqmes_anlse               in parm_per_apurc_canal.qmes_anlse %type,
   pqmes_perdc_pgto          in parm_per_apurc_canal.qmes_perdc_pgto %type,
   pqmes_perdc_apurc         in parm_per_apurc_canal.qmes_perdc_apurc %type,
   ptdult_alt                in varchar2, --parm_per_apurc_canal.dult_alt %type,
   pcresp_ult_alt            in parm_per_apurc_canal.cresp_ult_alt %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0116
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Insert em parm_per_apurc_canal relativo a classe ParamPeriodoProcessosVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
   pdinic_vgcia_parm        parm_per_apurc_canal.dinic_vgcia_parm %type;
   pdfim_vgcia_parm         parm_per_apurc_canal.dfim_vgcia_parm %type;
   pdult_alt                parm_per_apurc_canal.dult_alt %type;
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
  INSERT INTO parm_per_apurc_canal
    (dinic_vgcia_parm,
     dfim_vgcia_parm,
     ccanal_vda_segur,
     ctpo_apurc,
     qmes_anlse,
     qmes_perdc_pgto,
     qmes_perdc_apurc,
     dult_alt,
     cresp_ult_alt)
  VALUES
    (pdinic_vgcia_parm,
     pdfim_vgcia_parm,
     pccanal_vda_segur,
     pctpo_apurc,
     pqmes_anlse,
     pqmes_perdc_pgto,
     pqmes_perdc_apurc,
     pdult_alt,
     pcresp_ult_alt);
  --
END SGPB0116;
/

