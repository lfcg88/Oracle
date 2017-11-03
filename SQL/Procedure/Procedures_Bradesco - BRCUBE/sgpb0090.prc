CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0090
(
  intCodCanal_vda_segur parm_canal_vda_segur.ccanal_vda_segur %TYPE,
  dtInicioVigencia      varchar2,
  chrNovaSituacao       VARCHAR2
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0090
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Altera o status do canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  intVerifica INT;
  dtTmpDtFim  DATE;
  dtAtual     DATE;
  pdtInicioVigencia Date;
  VAR_ROTINA VARCHAR2(08) := 'SGPB0090';
BEGIN
  /*Formata a data adequadamente*/
  pdtInicioVigencia := To_date(dtInicioVigencia, 'YYYYMMDD');
  /*Verifica se o registro passado como parametro existe no banco*/
  BEGIN
    SELECT 1
      INTO intVerifica
      FROM parm_canal_vda_segur pcvs
     WHERE pcvs.dinic_vgcia_parm = pdtInicioVigencia
       AND pcvs.ccanal_vda_segur = intCodCanal_vda_segur;
  EXCEPTION
    WHEN no_data_found THEN
      Raise_Application_Error(-20210,'REGISTRO NAO ENCONTRADO');
  END;
  /* pega a data atual para utilizar depois */
  dtAtual := TO_DATE(to_char(SYSDATE,'YYYYMMDD'),'YYYYMMDD');
  /*verifica se a data de vigencia do parametro é maior que hoje*/
  IF pdtInicioVigencia > dtAtual THEN
    dtTmpDtFim := pdtInicioVigencia;
  ELSE
    dtTmpDtFim := dtAtual;
  END IF;
  --
  --
  /*fecha a vigencia anterior com a data de adequada*/
  UPDATE parm_canal_vda_segur
     SET dfim_vgcia_parm = dtTmpDtFim
   WHERE dinic_vgcia_parm = pdtInicioVigencia
     AND ccanal_vda_segur = intCodCanal_vda_segur;
  --
  --
  /*insere um novo registro vigorando a partir de amanha com a nova vigencia*/
  INSERT INTO parm_canal_vda_segur
    (ccanal_vda_segur,
     dfim_vgcia_parm,
     dinic_vgcia_parm,
     qtempo_min_rlcto,
     pmargm_contb_min,
     cinic_faixa_crrtr,
     cfnal_faixa_crrtr,
     vmin_librc_pgto,
     qmes_max_rtcao,
--     cind_sit_sist_canal,
     dult_alt,
     cresp_ult_alt,
     ccta_ctbil_credr,
     ccta_ctbil_dvdor)
    SELECT pcvs.ccanal_vda_segur,
           NULL,
           dtTmpDtFim + 1, /*Ultima vigencia fechada mais um*/
           pcvs.qtempo_min_rlcto,
           pcvs.pmargm_contb_min,
           pcvs.cinic_faixa_crrtr,
           pcvs.cfnal_faixa_crrtr,
           pcvs.vmin_librc_pgto,
           pcvs.qmes_max_rtcao,
--           chrNovaSituacao,
           pcvs.dult_alt,
           pcvs.cresp_ult_alt,
           pcvs.ccta_ctbil_credr,
           pcvs.ccta_ctbil_dvdor
      FROM parm_canal_vda_segur pcvs
     WHERE pcvs.dinic_vgcia_parm = pdtInicioVigencia
       AND pcvs.ccanal_vda_segur = intCodCanal_vda_segur;
  --
  --
END SGPB0090;
/

