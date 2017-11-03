CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0109
(
  pcparm               in parm_clasf_ag.cparm %type,
  ptdult_alt           in varchar2, --parm_clasf_ag.dult_alt  %type,
  pcresp_ult_alt       in parm_clasf_ag.cresp_ult_alt  %type

)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0109
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : update em registro da tabela parm_clasf_ag relativo a classe ParamClassificacaoAgenciaVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  pdult_alt         parm_clasf_ag.dult_alt %TYPE;

 BEGIN
--
  /*Formata a data adequadamente*/
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');
  --
  update parm_clasf_ag
     set dult_alt = pdult_alt,
         cresp_ult_alt = pcresp_ult_alt
   where cparm = pcparm;
  --
END SGPB0109;
/

