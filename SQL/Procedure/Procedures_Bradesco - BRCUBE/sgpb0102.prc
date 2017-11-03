CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0102
(
  curvrelat        OUT SYS_REFCURSOR,
  pData          in varchar2,
  pcanal           in canal_vda_segur.ccanal_vda_segur %TYPE
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0102
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna uma lista de ParamCanalVO->Canal do período estipulado - Parametrizacao Canal
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
	        to_date(to_char(pcvs.dfim_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dfim_vgcia_parm,
	        to_date(to_char(pcvs.dinic_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dinic_vgcia_parm,
	        pcvs.qtempo_min_rlcto,
	        pcvs.pmargm_contb_min,
	        pcvs.cinic_faixa_crrtr,
	        pcvs.cfnal_faixa_crrtr,
	        pcvs.vmin_librc_pgto,
	        pcvs.qmes_max_rtcao,
	   --     pcvs.cind_sit_sist_canal,
	        pcvs.dult_alt,
	        pcvs.cresp_ult_alt,
	        pcvs.ccta_ctbil_credr,
	        pcvs.ccta_ctbil_dvdor,
          to_char(pcvs.dinic_vgcia_parm, 'YYYYMMDD') pkInicio,
          pcvs.vmin_prod_apurc,
          pcvs.pcrstc_prod_ano,
          pcvs.cprfil_pdrao_crrtr,
          pcvs.qmes_durac_campa,
          pca.cparm,
          pca.cclasf_ag_exgdo,
          pca.dult_alt,
          pca.cresp_ult_alt

	   FROM canal_vda_segur cvs

	   JOIN parm_canal_vda_segur pcvs
	     ON pcvs.ccanal_vda_segur = cvs.ccanal_vda_segur

     left join parm_clasf_ag pca
       on pca.dinic_vgcia_parm = pcvs.dinic_vgcia_parm
      and pca.ccanal_vda_segur = pcvs.ccanal_vda_segur

	  where (
                 ((pData is null) and (pcvs.dfim_vgcia_parm is null))
              or
                 ((pData is not null) and (tmpData between pcvs.dinic_vgcia_parm and nvl(pcvs.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))))
              )

          AND ((pcanal IS NULL) OR (cvs.ccanal_vda_segur = pcanal))
    order
       by pca.cclasf_ag_exgdo;

  --
  --
END SGPB0102;
/

