CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0115
(
   ptdinic_vgcia_parm        in varchar2, --parm_per_apurc_canal.dinic_vgcia_parm %type,
   ptdfim_vgcia_parm         in varchar2, --parm_per_apurc_canal.dfim_vgcia_parm %type,
   pccanal_vda_segur         in parm_per_apurc_canal.ccanal_vda_segur %type,
   pctpo_apurc               in parm_per_apurc_canal.ctpo_apurc %type,
   ptdult_alt                in varchar2, --parm_per_apurc_canal.dult_alt %type,
   pcresp_ult_alt            in parm_per_apurc_canal.cresp_ult_alt %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0115
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : update em parm_per_apurc_canal relativo a classe ParamPeriodoProcessosVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
   pdfim_vgcia_parm         parm_per_apurc_canal.dfim_vgcia_parm %type;
   pdult_alt                parm_per_apurc_canal.dult_alt %type;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm  := To_date(ptdfim_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  --
update parm_per_apurc_canal
   set dfim_vgcia_parm = pdfim_vgcia_parm,
       dult_alt = pdult_alt,
       cresp_ult_alt = pcresp_ult_alt

 where ccanal_vda_segur = pccanal_vda_segur
   and ctpo_apurc = pctpo_apurc
   and to_char(dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm;
  --
END SGPB0115;
/

