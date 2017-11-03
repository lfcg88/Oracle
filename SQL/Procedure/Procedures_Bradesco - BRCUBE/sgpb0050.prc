CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0050 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0050
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        :
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB0050';
  VAR_COMPT                     number(6);
BEGIN
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(849,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- Vendo em que ambiente está
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;
   -- RECUPERA OS DADOS DE diretorio e arquivo
   PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,'SGPB','SGPB0050','W',1,VAR_IDTRIO_TRAB,VAR_IARQ_TRAB);
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   -- Se viver o nome do arquivo com nulo, vai colocar o nome constante
   if VAR_IARQ_TRAB is null then
      VAR_IARQ_TRAB := 'SGPB0050';
   end if;
   -- Colocando a Competencia no Arquivo (trata se o arquivo está vindo ou nao com o .dat, senao tive vai colocar)
   IF ( UPPER(substr(VAR_IARQ_TRAB,-4,4)) <> '.DAT' ) THEN
   		VAR_IARQ_TRAB := VAR_IARQ_TRAB||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   ELSE
   		VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB,1,(LENGTH(VAR_IARQ_TRAB)-4))||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   END IF;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'SERA GERADO O ARQUIVO '||VAR_IARQ_TRAB||' NO DIRETORIO '||VAR_IDTRIO_TRAB,'P',NULL,NULL);
   COMMIT;
   SGPB0037(VAR_COMPT,VAR_IDTRIO_TRAB,VAR_IARQ_TRAB,'SGPB0050');   
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSAMENTO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
END SGPB0050;
/

