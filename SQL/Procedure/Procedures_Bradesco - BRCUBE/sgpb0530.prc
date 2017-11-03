create or replace procedure sgpb_proc.SGPB0530
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0528
  --      DATA            : 25/06/2007
  --      AUTOR           : Wassily chuk Seiblitz Guanaes
  --      OBJETIVO        : CONTROLE DE FIM DE FLUXO - SGPB - 25/06/2007
  -- 						OBS: AINDA NÃO FOI PARA A PRODUÇÃO. SE FOR TEM QUE IR COM A SGPB0188
  -------------------------------------------------------------------------------------------------
IS
begin
     PR_CONTROLE_FIM_FLUXO('SGPB0530',854);
end SGPB0530;
/

