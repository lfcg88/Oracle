CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0108
(
  ptdinic_vgcia_parm   IN VARCHAR2, -- parm_canal_vda_segur.dinic_vgcia_parm %type,
  pccanal_vda_segur    IN parm_canal_vda_segur.ccanal_vda_segur %TYPE
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0108
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : deleta registros em lote da tabela parm_clasf_ag relativo a classe ParamClassificacaoAgenciaVO (utilizada apenas se o inicio de vigencia for maior que hoje)
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
 BEGIN
  --
  delete parm_clasf_ag pca
   where pca.ccanal_vda_segur = pccanal_vda_segur
     and to_char(pca.dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm;
  --
END SGPB0108;
/

