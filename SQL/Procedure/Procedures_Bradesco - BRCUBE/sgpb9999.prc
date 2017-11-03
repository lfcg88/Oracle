create or replace procedure sgpb_proc.SGPB9999 is
------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : sgpb9999
  --      DATA            : 26/12/2006
  --      AUTOR           : wassily chuk seiblitz guanaes - 29/03/2007
  --      OBJETIVO        : CONTROLE DE FIM DE FLUXO DO PARAMETRO 722 (ROTINA EVENTUAL)
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
begin
     PR_CONTROLE_FIM_FLUXO('SGPB9999',722);
end SGPB9999;
/

