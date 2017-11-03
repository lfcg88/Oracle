CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9137 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9137
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0137
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
   PR_LIMPA_LOG_CARGA('SGPB9137'); 
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA('SGPB9137','INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(708, VAR_DCARGA, VAR_DPROX_CARGA);
   --
   SGPB0137(VAR_DPROX_CARGA, pc_util_01.Banco,'SGPB9137');
   --SGPB0137(TO_DATE('20070102','YYYYMMDD'), pc_util_01.Banco,'SGPB9137');
   --
END SGPB9137;
/

