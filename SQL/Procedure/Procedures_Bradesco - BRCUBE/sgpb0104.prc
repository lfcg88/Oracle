CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0104
(
  curvrelat     OUT SYS_REFCURSOR,
  pData         IN VARCHAR2,
  pcanal        IN canal_vda_segur.ccanal_vda_segur %TYPE,
  pTipoApuracao IN parm_perc_pgto_bonif.ctpo_apurc %TYPE
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0104
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna uma lista de ParamPercentualPagamentoVO para o
  --                        período estipulado - parametrizacao Percentual de pagamento
  --      alterações      : Passa a filtrar por perfil corretor. Filtro diferente entre o canal Banco
  --                        e os demais canais.
  --                data  : 06/02/2007
  --                autor : Paulo Boccaletti
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

    --Se NÂO for canal Banco, busca os corretores sem perfil
    IF (pcanal IS NOT NULL and pcanal != 2) THEN
      --
      OPEN curvrelat FOR
      --
        SELECT cvs.ccanal_vda_segur,
               cvs.icanal_vda_segur,
               cvs.rcanal_vda_segur,
               --
               to_date(to_char(pppb.dfim_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dfim_vgcia_parm,
               to_date(to_char(pppb.dinic_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dinic_vgcia_parm,
               pppb.ctpo_apurc,
               decode(pppb.ctpo_apurc, pc_util_01.Normal, 'Normal', pc_util_01.Extra, 'Extra') itpo_apurc,
               pppb.pmax_margm_contb,
               pppb.pmin_margm_contb,
               pppb.pbonus_apurc,
               pppb.dult_alt,
               pppb.cresp_ult_alt,
               pppb.ctpo_prfil_crrtr

          FROM parm_perc_pgto_bonif pppb
      --
          JOIN canal_vda_segur cvs ON cvs.ccanal_vda_segur = pppb.ccanal_vda_segur
      --
         WHERE pppb.ctpo_apurc = pTipoApuracao
           AND tmpData BETWEEN pppb.dinic_vgcia_parm AND nvl(pppb.dfim_vgcia_parm,
                                                           to_date(99991231,
                                                                   'YYYYMMDD'))
           AND cvs.ccanal_vda_segur = pcanal
           AND pppb.ctpo_prfil_crrtr = 'N';
    ELSE
      --
      OPEN curvrelat FOR
      --
        SELECT cvs.ccanal_vda_segur,
               cvs.icanal_vda_segur,
               cvs.rcanal_vda_segur,
               --
               to_date(to_char(pppb.dfim_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dfim_vgcia_parm,
               to_date(to_char(pppb.dinic_vgcia_parm, 'YYYYMMDD'), 'YYYYMMDD') dinic_vgcia_parm,
               pppb.ctpo_apurc,
               decode(pppb.ctpo_apurc, pc_util_01.Normal, 'Normal', pc_util_01.Extra, 'Extra') itpo_apurc,
               pppb.pmax_margm_contb,
               pppb.pmin_margm_contb,
               pppb.pbonus_apurc,
               pppb.dult_alt,
               pppb.cresp_ult_alt,
               pppb.ctpo_prfil_crrtr

          FROM parm_perc_pgto_bonif pppb
      --
          JOIN canal_vda_segur cvs ON cvs.ccanal_vda_segur = pppb.ccanal_vda_segur
      --
         WHERE pppb.ctpo_apurc = pTipoApuracao
           AND tmpData BETWEEN pppb.dinic_vgcia_parm AND nvl(pppb.dfim_vgcia_parm,to_date(99991231,'YYYYMMDD'))
           AND cvs.ccanal_vda_segur = pcanal
           AND pppb.ctpo_prfil_crrtr != 'N'
     GROUP BY ctpo_prfil_crrtr, CVS.ccanal_vda_segur, icanal_vda_segur, rcanal_vda_segur, dfim_vgcia_parm,
              dinic_vgcia_parm, ctpo_apurc,
              pmax_margm_contb, pmin_margm_contb, pbonus_apurc,
              dult_alt, cresp_ult_alt
     ORDER BY ctpo_prfil_crrtr;

     END IF;
  --

END SGPB0104;
/

