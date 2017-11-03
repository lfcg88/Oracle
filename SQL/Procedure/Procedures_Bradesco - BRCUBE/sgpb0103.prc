CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0103
(
  curvrelat        OUT SYS_REFCURSOR,
  pData            in varchar2,
  pcanal           in canal_vda_segur.ccanal_vda_segur %TYPE,
  pGrupoRamo       in parm_prod_min_crrtr.cgrp_ramo_plano %type
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0103
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna uma lista de ParamProducaoMinimaVO para o período estipulado - parametrizacao producao minima
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
 tmpData  date;
BEGIN
  --
  if (pData is not null) then
    tmpData := to_date(pData, 'YYYYMMDD');
  end if;
  --
  OPEN curvrelat FOR
  --
SELECT cvs.ccanal_vda_segur,
	     cvs.icanal_vda_segur,
	     cvs.rcanal_vda_segur,
       --
       to_date(to_char(ppmc.dfim_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dfim_vgcia_parm,
       to_date(to_char(ppmc.dinic_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dinic_vgcia_parm,

       ppmc.ctpo_pssoa,
       decode(ppmc.ctpo_pssoa, 'J', 'Juridica', 'F', 'Fisica') itpo_pssoa,

       ppmc.cparm,
       ppmc.ctpo_per,
       ppmc.qitem_min_prod_crrtr,
       ppmc.vmin_prod_crrtr,
       ppmc.dult_alt,
       ppmc.cresp_ult_alt,
       --
       grp.cgrp_ramo_plano,
       grp.igrp_ramo_plano
       --
  FROM parm_prod_min_crrtr ppmc
    --
  join canal_vda_segur cvs
    on cvs.ccanal_vda_segur = ppmc.ccanal_vda_segur
    --
  join grp_ramo_plano grp
    on grp.cgrp_ramo_plano = ppmc.cgrp_ramo_plano

 where ppmc.cgrp_ramo_plano = pGrupoRamo
   and tmpData between ppmc.dinic_vgcia_parm and nvl(ppmc.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
   AND cvs.ccanal_vda_segur = pcanal;
  --
END SGPB0103;
/

