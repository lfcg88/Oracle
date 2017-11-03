CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0159
(
  p_ccanal_vda_segur parm_info_campa.ccanal_vda_segur %TYPE,
  p_dinic_vgcia_parm VARCHAR2,
  p_dfim_vgcia_parm  VARCHAR2,
  p_dult_alt         VARCHAR2,
  p_cresp_ult_alt    parm_info_campa.cresp_ult_alt %TYPE,
  p_operacao         VARCHAR
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0159
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : CRUD para PARAMINFOCAMPA
  --      objetivo        : atualiza o objeto paraminfocampanha
  --      objetivo        :
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
  v_dinic_vgcia_parm parm_info_campa.dinic_vgcia_parm %TYPE;
  v_dfim_vgcia_parm  parm_info_campa.dfim_vgcia_parm %TYPE;
  v_dult_alt         parm_info_campa.dult_alt %TYPE;
BEGIN
  --
  --
  v_dinic_vgcia_parm := to_date(p_dinic_vgcia_parm, 'YYYYMMDD');
  --
  --
  v_dfim_vgcia_parm := to_date(p_dfim_vgcia_parm, 'YYYYMMDD');
  --
  --
  v_dult_alt := to_date(p_dult_alt, 'YYYYMMDD');
  --
  --
  IF p_operacao = 'U' THEN
    UPDATE parm_info_campa
       SET dfim_vgcia_parm = v_dfim_vgcia_parm,
           dult_alt        = v_dult_alt,
           cresp_ult_alt   = p_cresp_ult_alt
     WHERE ccanal_vda_segur = p_ccanal_vda_segur
       AND dinic_vgcia_parm = v_dinic_vgcia_parm;
  END IF;
  --
  --
  IF p_operacao = 'D' THEN

    DELETE CRRTR_ELEIT_CAMPA
    WHERE ccanal_vda_segur = p_ccanal_vda_segur
      AND dinic_vgcia_parm = v_dinic_vgcia_parm;

    DELETE TPO_APURC_CANAL_VDA
    WHERE ccanal_vda_segur = p_ccanal_vda_segur
      AND dinic_vgcia_parm = v_dinic_vgcia_parm;

    DELETE CARAC_CRRTR_CANAL
    WHERE ccanal_vda_segur = p_ccanal_vda_segur
      AND dinic_vgcia_parm = v_dinic_vgcia_parm;

    DELETE CRRTR_EXCEC_CAMPA
    WHERE ccanal_vda_segur = p_ccanal_vda_segur
      AND dinic_vgcia_parm = v_dinic_vgcia_parm;

    DELETE parm_info_campa
     WHERE ccanal_vda_segur = p_ccanal_vda_segur
       AND dinic_vgcia_parm = v_dinic_vgcia_parm;
  END IF;
  --
  --
  IF p_operacao = 'C' THEN
    INSERT INTO parm_info_campa
      (ccanal_vda_segur,
       dinic_vgcia_parm,
       dfim_vgcia_parm,
       dult_alt,
       cresp_ult_alt)
    VALUES
      (p_ccanal_vda_segur,
       v_dinic_vgcia_parm,
       v_dfim_vgcia_parm,
       v_dult_alt,
       p_cresp_ult_alt);
  END IF;
  --
  --
END SGPB0159;
/

