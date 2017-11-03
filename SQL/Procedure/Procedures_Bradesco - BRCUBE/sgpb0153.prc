CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0153(curvrelat    OUT SYS_REFCURSOR,
                                     tipoApuracao IN tpo_apurc_canal_vda.ctpo_apurc%type,
                                     acao         IN char)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0153
  --      data            : 26/01/07 14:39:18
  --      autor           : Paulo Boccaletti - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna uma lista de ParamCanalVO->Canal - Parametrizacao Canal
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS

BEGIN
  --

  --
  IF (acao = 'E') THEN
    OPEN curvrelat FOR
      SELECT tacv.ccanal_vda_segur,
             tacv.csit_apurc_canal,
             tacv.dinic_vgcia_parm,
             tacv.dult_alt,
             tacv.cresp_ult_alt,
             cvs.icanal_vda_segur,
             cvs.RCANAL_VDA_SEGUR,
             pic.dfim_vgcia_parm,
             tpap.itpo_apurc,
             tpap.CTPO_APURC
        FROM tpo_apurc_canal_vda tacv

        join canal_vda_segur cvs
          on cvs.ccanal_vda_segur = tacv.ccanal_vda_segur

        join parm_info_campa pic
          on pic.ccanal_vda_segur = tacv.ccanal_vda_segur
         and pic.dinic_vgcia_parm = tacv.dinic_vgcia_parm
         and pic.dfim_vgcia_parm is null

        join tpo_apurc tpap
          on tacv.ctpo_apurc = tpap.ctpo_apurc

       where tacv.ctpo_apurc = tipoApuracao;

  ELSE
    IF (acao = 'S') THEN

      OPEN curvrelat FOR
      SELECT tacv.ccanal_vda_segur,
             tacv.csit_apurc_canal,
             tacv.dinic_vgcia_parm,
             tacv.dult_alt,
             tacv.cresp_ult_alt,
             cvs.icanal_vda_segur,
             cvs.RCANAL_VDA_SEGUR,
             pic.dfim_vgcia_parm,
             tpap.itpo_apurc,
             tpap.CTPO_APURC
        FROM tpo_apurc_canal_vda tacv

        join canal_vda_segur cvs
          on cvs.ccanal_vda_segur = tacv.ccanal_vda_segur

        join parm_info_campa pic
          on pic.ccanal_vda_segur = tacv.ccanal_vda_segur
         and pic.dinic_vgcia_parm = tacv.dinic_vgcia_parm
         and pic.dfim_vgcia_parm is null

        join tpo_apurc tpap
          on tacv.ctpo_apurc = tpap.ctpo_apurc

       order
          by ccanal_vda_segur, ctpo_apurc;

    END IF;
  END IF;
    --
END SGPB0153;
/

