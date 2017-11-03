CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9135 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9135
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0135
  --      ALTERAÇÕES      : Wassily (17/04/2007) - Colocado parametros do dwscheduler
  --                        Wassily (11/06/2007) - alterado parametro que passa para o sgpb0135
  -------------------------------------------------------------------------------------------------
  --
  --
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;

BEGIN

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA('SGPB9135');

   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(708, VAR_DCARGA, VAR_DPROX_CARGA);

   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA('SGPB9135','INICIO DO PROCESSO DE SUMARIZACAO DIARIA. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),
                          'P', NULL, NULL);
   COMMIT;
   --
   --SGPB0135(to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM')),'SGPB9135');
   SGPB0135(VAR_DPROX_CARGA,'SGPB9135');
   --
END SGPB9135;
/

