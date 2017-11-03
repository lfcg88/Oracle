CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB8127 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB8127
  --      DATA            :
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0127
  --      ALTERAÇÕES      : Obsoleta (nao tem nem em producao). Ass. Wassily 07/08/2007
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  --
  --
  VAR_COMPT       number(6);
  VAR_DCARGA      date;
  VAR_DPROX_CARGA date;

BEGIN
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(729, VAR_DCARGA, VAR_DPROX_CARGA);
   --
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   --
   SGPB0127(VAR_COMPT,PC_UTIL_01.Finasa,'SGPB8127');
   --
END SGPB8127;
/

