CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6004_2 IS
------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 08/10/2007
--      AUTOR           : MONIQUE COSTA DA ROCHA MARQUES - RELACIONAL CONSULTORIA E SISTEMAS
--      PROGRAMA        : SGPB6004.SQL
--      OBJETIVO        : CARGA DA TABELA ESTOQ_CUPOM_PROML_DSTAQ.
--						O ARQUIVO SÓ VEM COM AS LINHAS DE DETALHES E NÃO HÁ IDENTIFICAÇÃO DO TIPO DO REGISTRO
--      ALTERAÇÕES      :
--                DATA  :
--                AUTOR :
--                OBS   :
------------------------------------------------------------------------------------------------------------------------

-->> Variáveis de controle
VAR_CAMBTE         				ARQ_TRAB.CAMBTE%TYPE;  	                	-- parâmetro de ambiente
VAR_CSIST           			ARQ_TRAB.CSIST%TYPE   	  := 'SGPB';	    -- parâmetro de sistema
VAR_CROTNA          			ARQ_TRAB.CROTNA%TYPE  	  := 'SGPB6004';	-- parâmetro de rotina

-->> Variáveis para o parâmetro de carga
VAR_CPARM         			    PARM_CARGA.CPARM%TYPE     := 754;      -- parametro de carga para os dados da dimensão, atribuido aqui na inicialização
VAR_DCARGA        			    PARM_CARGA.DCARGA%TYPE;   		       -- data de carga
VAR_DPROX_CARGA   			    PARM_CARGA.DPROX_CARGA%TYPE; 	       -- data da próxima carga

-->> Variáveis para geração de Logs
VAR_LOG            				LOG_CARGA.RLOG%TYPE;               	    -- registro de Log
VAR_TPO_LOG_PROCESSO   		    LOG_CARGA.CTPO_REG_LOG%TYPE    := 'P';	-- Tipo de registro de log, nesse caso log de processo
VAR_TPO_LOG_DADO        		LOG_CARGA.CTPO_REG_LOG%TYPE    := 'D';  -- Tipo de registro de log, nesse caso log relativo aos dados
VAR_LOG_ERRO_ARQ        		LOG_CARGA.RLOG%TYPE;

-->> Variáveis para abertura e manipulação de arquivos
VAR_ARQUIVO             		UTL_FILE.FILE_TYPE;
VAR_REGISTRO_ARQUIVO    		VARCHAR2(500);
VAR_CTPO_ACSSO          		ARQ_TRAB.CTPO_ACSSO%TYPE       := 'R';
VAR_CSEQ_ARQ_TRAB       		ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE    := 001;
VAR_IARQ_TRAB           		ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB         		DTRIO_TRAB.IDTRIO_TRAB%TYPE;   -- diretório que está o arquivo
W_DATA_GERACAO_ARQ      		DATE;						   -- data de geração do arquivo

-->> Variaveis para controle de tempo de processamento
W_HORA_PROC_INICIAL     		DATE      := SYSDATE;
W_TEMPO_PROC            		NUMBER;

-->> Variáveis para controle do CTRL-M
VAR_CSIT_CTRLM         			NUMBER;--XYZ SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_DINIC_ROTNA        			DATE       := SYSDATE;

-->> Variaveis para Exceptions
VAR_FIM_PROCESSO_ERRO  			EXCEPTION;
VAR_FIM_PROCESSO_ERRO_CRITICO   EXCEPTION;

-->> Variaveis para alteracao da situacao da rotina
VAR_STATUS_ROTNA			    SIT_ROTNA.CSIT_ROTNA%TYPE;
VAR_ROTNA_AP				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'AP'; -- A processar
VAR_ROTNA_PC				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PC'; -- Processando
VAR_ROTNA_PO   				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PO'; -- Processado OK
VAR_ROTNA_PE	   			    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PE'; -- Processado com erro

-->> Variaveis referentes as colunas da tabela alvo (tabela definitiva pois possui todos os campos)
WROW                           ESTOQ_CUPOM_PROML_DSTAQ%ROWTYPE;

-->> Variaveis de Trabalho
VAR_ERRO						VARCHAR2(1)		:= 'N';
VAR_TOT_REG_LIDO_BODY      		NUMBER			:= 0;
VAR_TOT_REG_ALTER				NUMBER			:= 0;
VAR_TOT_REG_NOVO				NUMBER			:= 0;
VAR_TOT_REG_DESC				NUMBER			:= 0;
VAR_ACAO						NUMBER			:= NULL; -- 0 INSERE, 1 UPDATE, 2 DESCARTA
VAR_CTPO_PSSOA					ESTOQ_CUPOM_PROML_DSTAQ.CTPO_PSSOA%TYPE;
VAR_CCPF_CNPJ_BASE				ESTOQ_CUPOM_PROML_DSTAQ.CCPF_CNPJ_BASE%TYPE;
VAR_TABELA						VARCHAR2(30)	:= 'ESTOQ_CUPOM_PROML_DSTAQ';

--** Lista de situacao para tratamento de erros do control-m.
-- 1 - Término normal, processos dependentes podem continuar.
-- 2 - Término com alerta, processos dependentes podem continuar,
--     e o log deverá ser encaminhado ao analista.
-- 3 - Término com alerta grave, possível erro de ambiente,
--     o processo poderá ser reiniciado.
-- 4 - Término com erro, o processo não deve prosseguir.
--     O analista/DBA deverá ser notificado.
-- 5 - Término com erro crítico, o processo não deve prosseguir.
--     O analista/DBA deverá ser contactado imediatamente.
-- 6 - Término com erro desconhecido. O processo não deve continuar.
--     O analista deverá ser contactado.

--*****************************************************************

PROCEDURE TRATA_PARAMETRO IS
BEGIN
   --> Ambiente sendo passado por parâmetro
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   --> Caso o parâmetro seja inválido, o processo terminará com erro.
   IF VAR_CAMBTE NOT IN ('DESV','PROD') THEN
      VAR_LOG := 'PARAMETRO INVALIDO. AMBIENTE INFORMADO NO PARAMETRO: ' || VAR_CAMBTE;
      PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_TPO_LOG_PROCESSO,NULL,NULL);

      VAR_CSIT_CTRLM := 5;
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

   VAR_LOG := 'PARAMETRO DE AMBIENTE VERIFICADO: ' || VAR_CAMBTE;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

   COMMIT;

EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
   WHEN OTHERS THEN
        VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: '||
                    SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_PARAMETRO;

--**************************** TRATA HEADER ****************************
PROCEDURE TRATA_HEADER IS
BEGIN

   BEGIN
      --* Esta procedure busca o nome do diretório e nome do arquivo para o Sistema, Rotina, Acesso
      --   e ambiente em questão. As variaveis foram inicializadas no Declare.*/
      PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                            VAR_CSIST,
                            VAR_CROTNA,
                            VAR_CTPO_ACSSO,
                            VAR_CSEQ_ARQ_TRAB,
                            VAR_IDTRIO_TRAB,
                            VAR_IARQ_TRAB );


      VAR_LOG := 'ABRINDO ARQUIVO DE CARGA PARA TRATAMENTO DO HEADER. '||
                 'DIRETORIO: '  || VAR_IDTRIO_TRAB || ' --- ' ||
                 'ARQUIVO: '    || VAR_IARQ_TRAB;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
      DBMS_OUTPUT.PUT_LINE(VAR_LOG);

      --> Abrindo o arquivo através da Package Oracle UTL_FILE.FOPEN
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB, VAR_CTPO_ACSSO);

      --> Caso dê algum erro na abertura do arquivo , fecha o arquivo e finaliza o processo.
      IF NOT UTL_FILE.IS_OPEN(VAR_ARQUIVO) THEN

         VAR_CSIT_CTRLM := 6;

         VAR_LOG := 'ERRO NA ABERTURA DO ARQUIVO USANDO UTL_FILE.OPEN. ' ||
                    'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
         DBMS_OUTPUT.PUT_LINE(VAR_LOG);

         UTL_FILE.FCLOSE(VAR_ARQUIVO);
         RAISE VAR_FIM_PROCESSO_ERRO;

      END IF;

   EXCEPTION
      WHEN OTHERS THEN

           VAR_CSIT_CTRLM := 6;

           VAR_LOG := 'ERRO AO TENTAR ABRIR O ARQUIVO USANDO UTL_FILE.FOPEN. '||
                      'DIRETORIO: '  || VAR_IDTRIO_TRAB || ' -- ' ||
                      'ARQUIVO: '    || VAR_IARQ_TRAB;
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO , NULL, NULL);
           DBMS_OUTPUT.PUT_LINE(VAR_LOG);

           VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO , NULL, NULL);
           DBMS_OUTPUT.PUT_LINE(VAR_LOG);

           RAISE VAR_FIM_PROCESSO_ERRO;
   END;

EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
   WHEN OTHERS THEN

        VAR_CSIT_CTRLM := 6;

        VAR_LOG  := 'ERRO NO TRATA HEADER. ERRO ORACLE: '||
                    SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_HEADER;

--**************************** TRATA FOOTER ****************************
PROCEDURE TRATA_FOOTER IS
BEGIN

   	VAR_LOG := 'FIM DO ARQUIVO DE CARGA. TRATAMENTO DE FOOTER.';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

   	--> Informa a quantidade de registros lidos pelo processo.
   	VAR_LOG  := 'TOTAL DE REGISTROS LIDOS: '|| TO_CHAR( VAR_TOT_REG_LIDO_BODY);
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

   	VAR_LOG  := 'TOTAL DE REGISTROS INCLUIDOS: '|| TO_CHAR( VAR_TOT_REG_NOVO);
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

	VAR_LOG  := 'TOTAL DE REGISTROS ALTERADOS: '|| TO_CHAR( VAR_TOT_REG_ALTER);
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

   	VAR_LOG  := 'TOTAL DE REGISTROS DESCARTADOS: '|| TO_CHAR( VAR_TOT_REG_DESC);
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
   WHEN OTHERS THEN
        VAR_LOG  := 'ERRO NO TRATA FOOTER. ERRO ORACLE: '||
                    SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_FOOTER;
--**************************** VERIFICA_EXISTENCIA_RASPADINHA ****************************
PROCEDURE VERIFICA_ACAO_RASPADINHA IS
BEGIN

	VAR_CTPO_PSSOA		:= NULL;
	VAR_CCPF_CNPJ_BASE	:= NULL;
	VAR_ACAO			:= NULL;

	BEGIN
		SELECT NVL(CTPO_PSSOA,''), NVL(CCPF_CNPJ_BASE,0)
		INTO VAR_CTPO_PSSOA, VAR_CCPF_CNPJ_BASE
		FROM ESTOQ_CUPOM_PROML_DSTAQ
		WHERE CCAMPA_DSTAQ 			= WROW.CCAMPA_DSTAQ
		  AND CCUPOM_PROML_DSTAQ	= WROW.CCUPOM_PROML_DSTAQ;

		IF VAR_CCPF_CNPJ_BASE  = 0 THEN
			VAR_ACAO	:= 1;--UPDATE
		ELSE
		    VAR_ACAO	:= 2;--DESCARTA
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			VAR_ACAO	:= 0;--INSERE
	END;

EXCEPTION
	WHEN OTHERS THEN
        VAR_LOG  := 'ERRO AO VERIFICAR A EXISTENCIA DA RASPADINHA. ERRO ORACLE: '||
                    SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
END VERIFICA_ACAO_RASPADINHA;
--**************************** CARREGA DETALHE ****************************
PROCEDURE CARREGA_DETALHE IS
BEGIN

   	--> Inicializacao da variavel
   	WROW	  := NULL;
	----------------------------------------------------------------------------------------------------------------------
 	BEGIN
    	WROW.CCAMPA_DSTAQ			:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 3));
 	EXCEPTION
    	WHEN OTHERS THEN
	        WROW.CCAMPA_DSTAQ		:= NULL;
	        VAR_CSIT_CTRLM 		 	:= 5;

	        VAR_LOG := 'PROBLEMA AO CARREGAR O CODIGO DA CAMPANHA DESTAQUE REGISTRO:' ||
	                 SUBSTR(VAR_REGISTRO_ARQUIVO, 1,53)||
				   	   ' / ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
	        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_DADO, NULL, NULL);
	        RAISE VAR_FIM_PROCESSO_ERRO_CRITICO;
	END;
 	----------------------------------------------------------------------------------------------------------------------
 	BEGIN
   		WROW.CCUPOM_PROML_DSTAQ := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 4, 6));
	EXCEPTION
   		WHEN OTHERS THEN
      		WROW.CCUPOM_PROML_DSTAQ	:= NULL;
      		VAR_CSIT_CTRLM 		 	:= 5;

			VAR_LOG := 'PROBLEMA AO CARREGAR CODIGO CUPOM PROMOCIONAL DESTAQUE REGISTRO: ' ||
		               SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 53) ||
		               ' / ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_DADO, NULL, NULL);
		    RAISE VAR_FIM_PROCESSO_ERRO_CRITICO;
 	END;
 	----------------------------------------------------------------------------------------------------------------------
	BEGIN
		WROW.CRGNAL 		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 10,4));
	EXCEPTION
   		WHEN OTHERS THEN
        	WROW.CRGNAL		:= NULL;
        	VAR_CSIT_CTRLM	:= 5;

        	VAR_LOG := 'PROBLEMA AO CARREGAR O CODIGO DA REGIONAL REGISTRO: ' ||
            	       SUBSTR(VAR_REGISTRO_ARQUIVO, 1,53) ||
            	       ' / ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
			PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_DADO, NULL, NULL);
			RAISE VAR_FIM_PROCESSO_ERRO_CRITICO;
	END;
	----------------------------------------------------------------------------------------------------------------------
 	BEGIN
   		WROW.RCUPOM 		:= SUBSTR(VAR_REGISTRO_ARQUIVO, 14,50);
	EXCEPTION
		WHEN OTHERS THEN
			WROW.RCUPOM		    	:= NULL;
      		VAR_CSIT_CTRLM 		 	:= 5;

      		VAR_LOG := 'PROBLEMA AO CARREGAR O DESCRIÇÃO DO CUPOM REGISTRO: ' ||
                       SUBSTR(VAR_REGISTRO_ARQUIVO, 1,53) ||
                       ' / ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
      		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_DADO, NULL, NULL);
      		RAISE VAR_FIM_PROCESSO_ERRO_CRITICO;
 	END;
	----------------------------------------------------------------------------------------------------------------------
 	BEGIN

 		VERIFICA_ACAO_RASPADINHA;

 		VAR_TOT_REG_LIDO_BODY := VAR_TOT_REG_LIDO_BODY + 1;

 		IF VAR_ACAO = 0 THEN
 		BEGIN
 			INSERT INTO ESTOQ_CUPOM_PROML_DSTAQ
 				(CCAMPA_DSTAQ
 				,CCUPOM_PROML_DSTAQ
 				,CTPO_PSSOA
 				,CCPF_CNPJ_BASE
 				,CRGNAL
 				,RCUPOM
 				,DINCL_REG
 				,DALT_REG)
 			VALUES
 				(WROW.CCAMPA_DSTAQ
 				,WROW.CCUPOM_PROML_DSTAQ
 				,NULL
 				,NULL
 				,WROW.CRGNAL
 				,WROW.RCUPOM
 				,SYSDATE
 				,SYSDATE);

 				VAR_TOT_REG_NOVO := VAR_TOT_REG_NOVO + 1;

 		EXCEPTION
 			WHEN OTHERS THEN
        		VAR_LOG  := 'ERRO AO INSERIR A RASPADINHA. REGISTRO: '
        					||SUBSTR(VAR_REGISTRO_ARQUIVO, 1,53)||' ERRO ORACLE: '
        					||SUBSTR(SQLERRM(SQLCODE), 1, 200);
        		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
        		RAISE VAR_FIM_PROCESSO_ERRO;
 		END;

 		ELSIF VAR_ACAO = 1 THEN
 		BEGIN
 			UPDATE ESTOQ_CUPOM_PROML_DSTAQ SET
 				CRGNAL				=	WROW.CRGNAL
 				,RCUPOM				=	WROW.RCUPOM
 				,DALT_REG			=	SYSDATE
 			WHERE CCAMPA_DSTAQ			=	WROW.CCAMPA_DSTAQ
 			  AND CCUPOM_PROML_DSTAQ	=	WROW.CCUPOM_PROML_DSTAQ;

 			VAR_TOT_REG_ALTER := VAR_TOT_REG_ALTER + 1;
 		EXCEPTION
 			WHEN OTHERS THEN
        		VAR_LOG  := 'ERRO AO ALTERA A RASPADINHA. REGISTRO: '
        					||SUBSTR(VAR_REGISTRO_ARQUIVO, 1,53)||' ERRO ORACLE: '
        					||SUBSTR(SQLERRM(SQLCODE), 1, 200);
        		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
        		RAISE VAR_FIM_PROCESSO_ERRO;
 		END;

 		ELSIF VAR_ACAO = 2 THEN
 			VAR_LOG  := 'REGISTRO RASPADINHA '
 						||'CAMPANHA DESTAQUE '||TO_CHAR(WROW.CCAMPA_DSTAQ)
 						||', CUPOM '||TO_CHAR(WROW.CCUPOM_PROML_DSTAQ)||' - '||TO_CHAR(WROW.RCUPOM)
 						||', REGIONAL '||TO_CHAR(WROW.CRGNAL)
 						||' JÁ BAIXADO PELO CORRETOR CNPJ/CPF '||TO_CHAR(VAR_CCPF_CNPJ_BASE)
 						||' TIPO PESSOA '||VAR_CTPO_PSSOA;
        	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
        	VAR_TOT_REG_DESC := VAR_TOT_REG_DESC + 1;
 		END IF;

 		IF MOD(VAR_TOT_REG_NOVO+VAR_TOT_REG_ALTER,1000) = 0 THEN
 			COMMIT;
 		END IF;

	EXCEPTION
		WHEN VAR_FIM_PROCESSO_ERRO THEN
			RAISE VAR_FIM_PROCESSO_ERRO;
		WHEN OTHERS THEN
    		VAR_CSIT_CTRLM := 6;
	        VAR_LOG := 'ERRO AO ATUALIZAR OS DADOS DA RASPADINHA. ERRO ORACLE: '||
	                     SUBSTR(SQLERRM(SQLCODE), 1, 200);
			PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

	        VAR_LOG := 'LINHA DO REGISTRO: '|| SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 53);
		  	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
 	END;

EXCEPTION
	WHEN OTHERS THEN
    	VAR_LOG := 'ERRO NO SUB-PROGRAMA DE CARGA DOS DADOS DA TABELA '||VAR_TABELA;
  	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;

END CARREGA_DETALHE;

--**************************** TRATA BODY ****************************
PROCEDURE TRATA_BODY IS
BEGIN

	VAR_LOG := 'DADOS DO ARQUIVO DE CARGA. INICIANDO TRATAMENTO DO BODY.';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

	LOOP
    	BEGIN

    		UTL_FILE.GET_LINE( VAR_ARQUIVO, VAR_REGISTRO_ARQUIVO);

		EXCEPTION
	    	WHEN NO_DATA_FOUND THEN  -- Fim de Arquivo
	        	UTL_FILE.FCLOSE( VAR_ARQUIVO);
	        	TRATA_FOOTER;
	            EXIT;
		END;

		CARREGA_DETALHE; -- Procedure Interna (Sub-Programa)

	END LOOP;

   COMMIT;

EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
   WHEN OTHERS THEN
        VAR_LOG := 'ERRO NO TRATA BODY. REGISTRO: '||
                   SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 200);
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);
		DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_BODY;

----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN

   --> A variavel de tratamento de erro do control-m sera inicializada
   -- com o flag de termino normal com sucesso (=1)
   VAR_CSIT_CTRLM := 1;

   --> Limpa a tabela de log no inicio do processo
   -- (o trigger jogarah as informacoes para a tabela de historico)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA);

   --> Grava log inicial de carga
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DE TABELA '|| VAR_TABELA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

   --> Atualiza status da rotina, que deverá ser marcada como PC
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);

   --> Trata o parametro do processo.Procedure interna (sub-programa).
   TRATA_PARAMETRO;

   --> Verifica informacoes do header . Procedure interna (sub-programa).
   TRATA_HEADER;

   --> Processa arquivo (carrega a tabela temporaria)
   TRATA_BODY;

   --> Tempo de processamento
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||
               TO_CHAR(W_TEMPO_PROC) ;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

   IF VAR_CSIT_CTRLM = 1 THEN
      --> A situação da Rotina deverá ser marcada como 'PO'
      VAR_LOG :=  'TERMINO NORMAL DO PROCESSO (STATUS = 1). '  ||
                  'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

      --> Atualiza status da rotina
      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);

      --> Grava a situacao deste processo na tabela de controle do ctrlm

   ELSIF VAR_CSIT_CTRLM = 5 THEN
      RAISE VAR_FIM_PROCESSO_ERRO_CRITICO;
   ELSE
     RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO_CRITICO THEN

        --> Atualiza status da rotina. A situação deverá ser marcada como 'PE'.
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO CRITICO (STATUS = 5).'||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
	               'O ANALISTA/DBA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);


   WHEN VAR_FIM_PROCESSO_ERRO THEN
        VAR_CSIT_CTRLM := 6;

        --> Atualiza status da rotina
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
  	               'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);


   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;

        --> Atualiza status da rotina
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO(STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '		||
                   'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);


END SGPB6004_2;
/

