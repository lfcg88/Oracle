create or replace procedure sgpb_proc.SGPB0532
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0532
  --      DATA            : 15/10/07
  --      AUTOR           : Wassily chuk Seiblitz Guanaes
  --      OBJETIVO        : CONTROLE DE FIM DE FLUXO da carga do mapeamento agencia corretor - SGPB
  -------------------------------------------------------------------------------------------------
IS
begin
     PR_CONTROLE_FIM_FLUXO('SGPB0532',856);
end SGPB0532;
/

