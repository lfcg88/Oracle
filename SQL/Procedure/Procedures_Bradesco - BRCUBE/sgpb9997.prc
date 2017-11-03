CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9997 IS
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.
--  DATA            : 22/02/2008
--  AUTOR           : MONIQUE MARQUES - VALUE TEAM
--  PROGRAMA        : SGPB9997.SQL
--  OBJETIVO        : ALTERAR A DATA DE APURAÇÃO DA CAMPANHA, EM CASO DE REPROCESSAMENTO.
--  ALTERAÇÕES      :
--            DATA  : -
--            AUTOR : -
--            OBS   : -
------------------------------------------------------------------------------------------------------------------------

-- VARIAVEIS DE TRABALHO
VAR_ERRO 		   			VARCHAR2(1) 						:= 'N';
VAR_LOG                    	LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA        	LOG_CARGA.CTPO_REG_LOG%TYPE        	:= 'A';
VAR_LOG_PROCESSO           	LOG_CARGA.CTPO_REG_LOG%TYPE        	:= 'P';
VAR_CSIT_CTRLM             	SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO      	EXCEPTION;
VAR_FIM_PROCESSO_CRITICO   	EXCEPTION;



-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO
VAR_CAMBTE                 	ARQ_TRAB.CAMBTE%TYPE;           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                  	ARQ_TRAB.CSIST%TYPE             := 'SGPB';
VAR_CROTNA                 	ARQ_TRAB.CROTNA%TYPE            := 'SGPB9997';
VAR_DCARGA                  PARM_CARGA.DCARGA%TYPE;
VAR_DPROX_CARGA             PARM_CARGA.DPROX_CARGA%TYPE;
VAR_CTPO_ACSSO             	ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB          	ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB              	ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB            	DTRIO_TRAB.IDTRIO_TRAB%TYPE;

-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                  	PARM_CARGA.CPARM%TYPE           := 722;
VAR_DINIC_ROTNA            	DATE                            := SYSDATE;

-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_PC	   			SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC';
VAR_ROTNA_PO 			  	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO';
VAR_ROTNA_PE	   	   		SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE';

-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - Termino normal, processos dependentes podem continuar.
-- 2 - Termino com alerta, processos dependentes podem continuar,
--     e o log deverá ser encaminhado ao analista.
-- 3 - Termino com alerta grave, possível erro de ambiente,
--     o processo poderá ser reiniciado.
-- 4 - Termino com erro, o processo não deve prosseguir.
--     O analista/DBA deverá ser notificado.
-- 5 - Termino com erro crítico, o processo não deve prosseguir.
--     O analista/DBA deverá ser contactado imediatamente.
-- 6 - Termino com erro desconhecido. O processo não deve continuar.
--     Analista deverá ser contatado.
/* ***************************************************************** */

PROCEDURE TRATA_PARAMETRO IS
BEGIN

   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   VAR_LOG := 'PARAMETRO DE AMBIENTE VERIFICADO: ' || VAR_CAMBTE;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN

        VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_PARAMETRO;
/* ***************************************************************** */
PROCEDURE DELETA_META_DSTAQ IS
BEGIN

	DELETE FROM META_DSTAQ
	WHERE CCANAL_PROD_DW = 8
	AND CCAMPA_DSTAQ = 200801;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A  DELETA_META_DSTAQ: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END DELETA_META_DSTAQ;

/* ***************************************************************** */
PROCEDURE EXECUTA_SCRIPT IS
BEGIN
   	
   	VAR_LOG := 'INICIO DA CARGA DAS DELETA_META_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	
   	DELETA_META_DSTAQ;
   	
   	COMMIT;

EXCEPTION
   WHEN OTHERS THEN

        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END EXECUTA_SCRIPT;
----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN

   -- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA
   -- INICIALIZADA COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   VAR_CSIT_CTRLM := 1;

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
   -- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA );

   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DE TABELAS NO DW';
   PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA (O CÓDIGO DE PARâMETRO DE CARGA FOI INICIALIZADO NO DECLARE)
    PR_LE_PARAMETRO_CARGA(VAR_CPARM,VAR_DCARGA,VAR_DPROX_CARGA);

   -- ATUALIZA STATUS DA ROTINA
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);

   -- TRATA O PARAMETRO DO PROCESSO
   TRATA_PARAMETRO; 	-- PROCEDURE INTERNA (SUB-PROGRAMA)

   --EXECUTA O SCRIPT
   EXECUTA_SCRIPT;

   IF VAR_CSIT_CTRLM = 1 THEN

      VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS = 1). ' ||
                 'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	  PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

   ELSIF VAR_CSIT_CTRLM = 2 THEN

      VAR_LOG := 'TERMINO DO PROCESSO COM ADVERTENCIA (STATUS = 2). ' ||
                 ' OS PROCESSOS DEPENDENTES PODEM CONTINUAR '||
                 'E O LOG DEVE SER ENCAMINHADO AO ANALISTA RESPONSAVEL.';
	  PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

   ELSIF VAR_CSIT_CTRLM = 5 THEN
      RAISE VAR_FIM_PROCESSO_CRITICO;
   ELSE
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

   -- ATUALIZA STATUS DA ROTINA
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);

   -- GRAVA A SITUACAO DESTE PROCESSO NA TABELA DE CONTROLE DO CTRLM
   -- EM CASO DE ERRO ESTA GRAVACAO SO SERA FEITA NA EXCEPTION
   PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                              VAR_CROTNA     ,
                              SYSDATE        , -- DFIM_ROTNA
                              NULL           , -- IPROG
                              NULL           , -- CERRO
                              VAR_LOG        , -- RERRO
                              VAR_CSIT_CTRLM             );


EXCEPTION
   WHEN VAR_FIM_PROCESSO_CRITICO THEN

        -- ATUALIZA STATUS DA ROTINA
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO CRITICO (STATUS = 5).'||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
	               'O ANALISTA/DBA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

	    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
         	                       VAR_CROTNA     ,
                	               SYSDATE        , -- DFIM_ROTNA
                        	       NULL           , -- IPROG
	                               NULL           , -- CERRO
        	                       VAR_LOG        , -- RERRO
                	               VAR_CSIT_CTRLM             );

   WHEN VAR_FIM_PROCESSO_ERRO THEN

        VAR_CSIT_CTRLM := 6;

        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6).'||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
	               'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

	    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
           	                       VAR_CROTNA     ,
                	               SYSDATE        , -- DFIM_ROTNA
                        	       NULL           , -- IPROG
	                               NULL           , -- CERRO
        	                       VAR_LOG        , -- RERRO
                	               VAR_CSIT_CTRLM             );

   WHEN OTHERS THEN

        VAR_CSIT_CTRLM := 6;

        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

	   PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
          	                      VAR_CROTNA     ,
                	              SYSDATE        , -- DFIM_ROTNA
                        	      NULL           , -- IPROG
	                              NULL           , -- CERRO
        	                      VAR_LOG        , -- RERRO
                	              VAR_CSIT_CTRLM             );

END SGPB9997;
/

