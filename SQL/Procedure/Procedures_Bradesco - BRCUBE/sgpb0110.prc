CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0110
(
  ptdinic_vgcia_parm IN VARCHAR2, -- parm_canal_vda_segur.dinic_vgcia_parm %type,
  pccanal_vda_segur  IN parm_clasf_ag.ccanal_vda_segur %TYPE,
  pcclasf_ag_exgdo   IN parm_clasf_ag.cclasf_ag_exgdo %TYPE,
  ptdult_alt         IN VARCHAR2, --parm_clasf_ag.dult_alt  %type,
  pcresp_ult_alt     IN parm_clasf_ag.cresp_ult_alt %TYPE
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0110
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Insert em tabela parm_clasf_ag relativo a classe ParamClassificacaoAgenciaVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  pdinic_vgcia_parm parm_clasf_ag.dinic_vgcia_parm %TYPE;
  pdult_alt         parm_clasf_ag.dult_alt %TYPE;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdinic_vgcia_parm := To_date(ptdinic_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  --
  INSERT INTO parm_clasf_ag
    (dinic_vgcia_parm,
     ccanal_vda_segur,
     cparm,
     cclasf_ag_exgdo,
     dult_alt,
     cresp_ult_alt)
  VALUES
    (pdinic_vgcia_parm,
     pccanal_vda_segur,
     (select max(cparm)+1 from parm_clasf_ag),
     pcclasf_ag_exgdo,
     pdult_alt,
     pcresp_ult_alt);
  --
END SGPB0110;
/

