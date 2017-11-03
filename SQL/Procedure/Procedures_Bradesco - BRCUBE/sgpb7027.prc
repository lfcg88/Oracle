CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB7027 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB7027
  --      DATA            : 09/03/2006 09:38:13
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0027
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA       date;
  VAR_DPROX_CARGA  date;
  VAR_COMPETENCIA  number(6);

BEGIN
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(735, VAR_DCARGA, VAR_DPROX_CARGA);

   VAR_COMPETENCIA := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));

   SGPB0027(VAR_COMPETENCIA,Pc_Util_01.Extra_Banco,'SGPB7027');

END SGPB7027;
/

