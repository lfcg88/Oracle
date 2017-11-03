CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9170 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9170
  --      DATA            : 26/04/2007
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama SGPB0170
  --      ALTERAÇÕES      : ADICIONADOS NOVOS PARAMETROS A SEREM PASSADOS.
  --                        MWELHORIAS. ASS. WASSILY
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_CAMBTE      varchar2(100);           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
  VAR_DCARGA      date;
  VAR_DPROX_CARGA date;
  VAR_COMPT       number(6);  
  VAR_ROTINA      VARCHAR2(08) := 'SGPB9170';  
BEGIN  
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   COMMIT;   
   -- VERIFICA QUAL É O AMBIENTE
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;                       
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(852, VAR_DCARGA, VAR_DPROX_CARGA);  
   -- GRAVA LOG INICIAL DE CARGA
   -- RECUPERA A COMPETÊNCIA
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));   
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'AMBIENTE: '||VAR_CAMBTE||' COMPT_INICIAL: '||VAR_COMPT,'P', NULL, NULL);
   COMMIT;   
   SGPB0170(VAR_COMPT,VAR_ROTINA,null,null);
END SGPB9170;
/

