CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0117
(
    ptdinic_vgcia_parm in varchar2, --parm_prod_min_crrtr.dinic_vgcia_parm %type,
    pcparm in parm_prod_min_crrtr.cparm %type

)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0117
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : delete em PARM_PROD_MIN_CRRTR relativo a classe ParamProducaoMinimaVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
BEGIN
  --
  /*Formata a data adequadamente*/
  --
  delete parm_prod_min_crrtr
   where cparm = pcparm
     and to_char(dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm;
  --
END SGPB0117;
/

