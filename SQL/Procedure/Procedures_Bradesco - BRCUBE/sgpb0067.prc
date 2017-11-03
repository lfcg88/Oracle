CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0067 is
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0067
  --      DATA            :
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0038
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  --
  --
  VAR_DCARGA      date;
  VAR_DPROX_CARGA date;     
  VAR_ROTINA      VARCHAR2(08) := 'SGPB0067';
  VAR_COMPT       number(6);  

BEGIN
    -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(851,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));   
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||' COMPT: '||VAR_COMPT,'P',NULL,NULL);
   COMMIT;
   SGPB0038(VAR_COMPT,PC_UTIL_01.Extra_Banco,'SGPB0067');
END SGPB0067;
/

