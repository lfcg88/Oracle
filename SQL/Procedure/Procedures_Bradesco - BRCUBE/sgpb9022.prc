CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9022 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9022
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0022
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_COMPETENCIA             number(6);
BEGIN
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA   
   PR_LIMPA_LOG_CARGA('SGPB9022');    
   PR_LE_PARAMETRO_CARGA(727, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_COMPETENCIA := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB9022', 'COMPETENCIA: '||VAR_COMPETENCIA, Pc_Util_01.Var_Log_Processo, NULL, NULL);
   COMMIT;
   SGPB0022(VAR_COMPETENCIA,pc_util_01.Banco,'SGPB9022');
END SGPB9022;
/

