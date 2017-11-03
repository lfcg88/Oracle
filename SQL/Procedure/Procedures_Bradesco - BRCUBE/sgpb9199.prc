CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9199 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9199
  --      DATA            : 20/05/2007
  --      AUTOR           : Vinícius Faria
  --      OBJETIVO        : GERA ARQUIVO COM TODOS OS CORRETORES ELEITOS, LISTA TODOS MESMO QUE AINDA NÃO EXISTA APURAÇÃO DO BONUS.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_COMPT						OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%type;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB9199';
BEGIN
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(723,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   -- Vendo em que ambiente está
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;
   -- RECUPERA OS DADOS DE diretorio e arquivo
   PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,'SGPB','SGPB9199','W',1,VAR_IDTRIO_TRAB,VAR_IARQ_TRAB);
   -- Se viver o nome do arquivo com nulo, vai colocar o nome constante
   if VAR_IARQ_TRAB is null then
      VAR_IARQ_TRAB := 'SGPB9199';
   end if;
   -- Colocando a Competencia no Arquivo (trata se o arquivo está vindo ou nao com o .dat, senao tive vai colocar)
   IF ( UPPER(substr(VAR_IARQ_TRAB,-4,4)) <> '.DAT' ) THEN
   		VAR_IARQ_TRAB := VAR_IARQ_TRAB||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   ELSE
   		VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB,1,(LENGTH(VAR_IARQ_TRAB)-4))||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   END IF;  
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'SERA GERADO O ARQUIVO '||VAR_IARQ_TRAB||' NO DIRETORIO '||VAR_IDTRIO_TRAB,'P',NULL,NULL);
   COMMIT;
   VAR_COMPT := TO_number(to_char(VAR_DPROX_CARGA,'YYYYMM'));
   SGPB0199(VAR_IDTRIO_TRAB,VAR_IARQ_TRAB,VAR_COMPT,'SGPB9199');
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSAMENTO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
END SGPB9199;
/

