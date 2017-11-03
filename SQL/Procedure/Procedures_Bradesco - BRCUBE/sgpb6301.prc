create or replace procedure sgpb_proc.SGPB6301
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6301
  --      DATA            : 22/10/2007
  --      AUTOR           : Wassily chuk Seiblitz Guanaes
  --      OBJETIVO        : CONTROLE DE FIM DE FLUXO do refresh da view VACPROD_CRRTR_DSTAQ
  -------------------------------------------------------------------------------------------------
IS
begin
     PR_CONTROLE_FIM_FLUXO('SGPB6301',857);
end SGPB6301;
/

