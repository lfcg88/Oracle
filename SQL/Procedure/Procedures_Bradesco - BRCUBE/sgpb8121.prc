CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB8121 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB8121
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0121
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  --
  --
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;

BEGIN
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA('SGPB8121'); 
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA('SGPB8121','INICIO DO PROCESSO EM ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'P', NULL, NULL);
   COMMIT;
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(708, VAR_DCARGA, VAR_DPROX_CARGA);
   SGPB0121(VAR_DPROX_CARGA,pc_util_01.Finasa,'SGPB8121');
END SGPB8121;
/

