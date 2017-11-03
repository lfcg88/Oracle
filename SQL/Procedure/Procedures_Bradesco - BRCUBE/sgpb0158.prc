CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0158(curvrelat              OUT SYS_REFCURSOR) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0158
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : DAO para Reinício de campanha
  --      objetivo        : Retorna lista de ParamInfoCampanhaVO->CanalVendaVO
  --      objetivo        :                  ParamInfoCampanhaVO->SituacaoCanalVO->TipoApuracaoVO
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
BEGIN

  --
  OPEN curvrelat FOR
  --
      SELECT 'dataInicioVigencia',
             pic.dinic_vgcia_parm,
             'usuario',
             pic.cresp_ult_alt,
             'dataFimVigencia',
             pic.dfim_vgcia_parm,
             'ultimaAlteracao',
             pic.dult_alt,

             'canalVendaVO.codigo',
             cvs.ccanal_vda_segur,
             'canalVendaVO.nome',
             cvs.icanal_vda_segur,
             'canalVendaVO.descricao',
             cvs.RCANAL_VDA_SEGUR,

             'situacaoCanalVO.situacao',
             tacv.csit_apurc_canal,
             'situacaoCanalVO.ultimaAlteracao',
             tacv.dult_alt,
             'situacaoCanalVO.usuario',
             tacv.cresp_ult_alt,

             'situacaoCanalVO.tipoApuracaoVO.codigo',
             tpap.ctpo_apurc,
             'situacaoCanalVO.tipoApuracaoVO.descricao',
             tpap.itpo_apurc

        FROM tpo_apurc_canal_vda tacv
          --
        join canal_vda_segur cvs
          on cvs.ccanal_vda_segur =  tacv.ccanal_vda_segur
          --
        join parm_info_campa pic
          on pic.ccanal_vda_segur = tacv.ccanal_vda_segur
         and pic.dinic_vgcia_parm  = tacv.dinic_vgcia_parm
          --
        join tpo_apurc tpap
          on tacv.ctpo_apurc = tpap.ctpo_apurc
          --
       where tacv.ctpo_apurc = 1
         and pic.dinic_vgcia_parm = (select max(pic_int.dinic_vgcia_parm)
                                     from parm_info_campa pic_int
                                    where pic_int.ccanal_vda_segur = pic.ccanal_vda_segur);
  --
END SGPB0158;
/

