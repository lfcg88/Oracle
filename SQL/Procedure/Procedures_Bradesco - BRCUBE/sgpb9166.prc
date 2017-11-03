CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9166 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGP9166
  --      DATA            :
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0166
  --      ALTERAÇÕES      :
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
   PR_LE_PARAMETRO_CARGA(731, VAR_DCARGA, VAR_DPROX_CARGA);
   --
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   --
   SGPB0166(VAR_COMPT,PC_UTIL_01.Banco,'SGPB9166');
   --
END SGPB9166;
/

