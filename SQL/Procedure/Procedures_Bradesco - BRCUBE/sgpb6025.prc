create or replace procedure sgpb_proc.SGPB6025 is
------------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6021
  --      DATA            : 25/01/2008
  --      AUTOR           : wassily chuk seiblitz guanaes 
  --      OBJETIVO        : CARGA DE IMPLANTAÇÃO OU DE RE-PROCESSAMENTO DA META DA CAMPANHA DESTAQUE PRODUCAO 
  --                        (METODO IMPLANTACAO)
  ----------------------------------------------------------------------------------------------------------
begin
     --
     SGPB6027 ( 'SGPB6025', 750, 'I');
     COMMIT;
     --
end SGPB6025;
/

