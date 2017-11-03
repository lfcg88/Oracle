CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9122 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9122
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama SGPB0122
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
--  VAR_DCARGA                 	date;
--  VAR_DPROX_CARGA            	date;
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB9122';
  VAR_SISTEMA                   VARCHAR2(04) := 'SGPB';
  
BEGIN
  
   -- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   -- VAR_CSIT_CTRLM := 1;

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   COMMIT;
   
   -- VERIFICA QUAL É O AMBIENTE
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   -- RECUPERA OS DADOS DE diretorio e arquivo
   PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                         VAR_SISTEMA,
                         VAR_ROTINA,
                         'R',
                         1,
                         VAR_IDTRIO_TRAB,
                         VAR_IARQ_TRAB );
                         
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(724, VAR_DCARGA, VAR_DPROX_CARGA);
  
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA, 
                          'AMBIENTE: '||VAR_CAMBTE||' INICIO DA CARGA DO: '||VAR_IARQ_TRAB||'. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'), 
                          'P', NULL, NULL);
   COMMIT;

   SGPB0122(
      VAR_IDTRIO_TRAB,
      VAR_IARQ_TRAB,
      VAR_ROTINA
   );

END SGPB9122;
/

