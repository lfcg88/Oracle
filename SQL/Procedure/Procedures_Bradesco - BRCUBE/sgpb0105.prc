CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0105
(
  curvrelat     OUT SYS_REFCURSOR,
  pData         IN VARCHAR2,
  pcanal        IN canal_vda_segur.ccanal_vda_segur %TYPE,
  pTipoApuracao IN parm_perc_pgto_bonif.ctpo_apurc %TYPE
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0105
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna uma lista de ParamPeriodoProcessosVO para o período estipulado - parametrizacao Periodo processos
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
  tmpData DATE;
BEGIN
  --
  IF (pData IS NOT NULL) THEN
    tmpData := to_date(pData,
                       'YYYYMMDD');
  END IF;
  --
  OPEN curvrelat FOR
  --
    SELECT cvs.ccanal_vda_segur,
           cvs.icanal_vda_segur,
           cvs.rcanal_vda_segur,
           --
           to_date(to_char(ppac.dfim_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dfim_vgcia_parm,
           to_date(to_char(ppac.dinic_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dinic_vgcia_parm,
           ppac.ctpo_apurc,
           decode(ppac.ctpo_apurc, pc_util_01.Normal, 'Normal', pc_util_01.Extra, 'Extra') itpo_apurc,
           ppac.qmes_anlse,
           ppac.qmes_perdc_pgto,
           ppac.qmes_perdc_apurc,
           ppac.dult_alt,
           ppac.cresp_ult_alt

      FROM parm_per_apurc_canal ppac
        --
      JOIN canal_vda_segur cvs ON cvs.ccanal_vda_segur = ppac.ccanal_vda_segur
        --
     WHERE ppac.ctpo_apurc = pTipoApuracao
       AND tmpData BETWEEN ppac.dinic_vgcia_parm AND nvl(ppac.dfim_vgcia_parm,
                                                       to_date(99991231,
                                                               'YYYYMMDD'))
        --
       AND cvs.ccanal_vda_segur = pcanal;
  --
END SGPB0105;
/

