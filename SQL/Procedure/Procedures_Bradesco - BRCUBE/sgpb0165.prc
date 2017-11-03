CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0165
(
  p_ccanal_vda_segur parm_info_campa.ccanal_vda_segur %TYPE,
  p_dinic_vgcia_parm VARCHAR2,
  p_CTPO_APURC       TPO_APURC_CANAL_VDA.CTPO_APURC%type,
  p_CSIT_APURC_CANAL TPO_APURC_CANAL_VDA.CSIT_APURC_CANAL%type,
  p_dult_alt         VARCHAR2,
  p_cresp_ult_alt    parm_info_campa.cresp_ult_alt %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0165
  --      data            : 14/02/2007 22:52
  --      autor           : Paulo boccaletti - analise e desenvolvimento de sistemas
  --      objetivo        : CRUD para Situacaocanal
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
  v_dinic_vgcia_parm parm_info_campa.dinic_vgcia_parm %TYPE;
  v_dult_alt         parm_info_campa.dult_alt %TYPE;
BEGIN
  --
  --
  v_dinic_vgcia_parm := to_date(p_dinic_vgcia_parm, 'YYYYMMDD');
  --
  --
  v_dult_alt := to_date(p_dult_alt, 'YYYYMMDD');
  --
  --
  INSERT INTO TPO_APURC_CANAL_VDA
      (ccanal_vda_segur,
       DINIC_VGCIA_PARM,
       CTPO_APURC,
       CSIT_APURC_CANAL,
       dult_alt,
       cresp_ult_alt)
    VALUES
      (p_ccanal_vda_segur,
       v_dinic_vgcia_parm,
       p_CTPO_APURC,
       p_CSIT_APURC_CANAL,
       v_dult_alt,
       p_cresp_ult_alt);
  --
  --
END SGPB0165;
/

