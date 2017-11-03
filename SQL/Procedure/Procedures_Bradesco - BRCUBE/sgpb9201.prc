CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9201 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9201
  --      DATA            : 8/5/2007 09:38:13
  --      AUTOR           : Vinícius Faria
  --      OBJETIVO        :       
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;        
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB9201';
  VAR_COMPT                     number(6);  
BEGIN  
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(722,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   SGPB0057(VAR_COMPT,PC_UTIL_01.BANCO);
   --
END SGPB9201;
/

