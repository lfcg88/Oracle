CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6024 IS
-------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                            
--  DATA            : 11/10/2007
--  AUTOR           : HUGO CARDOSO - VALUE TEAM
--  PROGRAMA        : SGPB6024_NIR.SQL                                                   
--  OBJETIVO        : ATUALIZA A DATA DA APURAÇÃO 
--  ALTERAÇÕES      : Foi alterado o  codigo da campanha para 3 "FIXO"                                                              
--            DATA  : 25/01/2008
--			 AUTOR	: Wellington P Medeiros - Value Team Ltda
--            OBS   : 
--  ALTERAÇÕES      : Alterado a condicao na Atualizacao da Data de Apuracao
--                    passou a ser testado o CIND_CAMPA_ATIVO = 'A' 
--            DATA  : 22/02/2008
--			 AUTOR	: Niria da Silva Macario
--            OBS   :  

-------------------------------------------------------------------------------------

-->> Variáveis de controle
---
VAR_CAMBTE         			ARQ_TRAB.CAMBTE%TYPE;  	                	-- parâmetro de ambiente
VAR_CSIST           			ARQ_TRAB.CSIST%TYPE   	  := 'SGPB';	    -- parâmetro de sistema
VAR_CROTNA          			ARQ_TRAB.CROTNA%TYPE  	  := 'SGPB6024';	-- parâmetro de rotina
---
-->> Variáveis para o parâmetro de carga
---
VAR_CPARM         			    PARM_CARGA.CPARM%TYPE     := 752;      -- parametro de carga para os dados da dimensão, atribuido aqui na inicialização
VAR_DCARGA        			    PARM_CARGA.DCARGA%TYPE;   		       -- data de carga
VAR_DPROX_CARGA   			    PARM_CARGA.DPROX_CARGA%TYPE; 	       -- data da próxima carga
---
-->> Variáveis para geração de Logs
---
VAR_LOG            				LOG_CARGA.RLOG%TYPE;               	    -- registro de Log
VAR_TPO_LOG_PROCESSO   		    LOG_CARGA.CTPO_REG_LOG%TYPE    := 'P';	-- Tipo de registro de log, nesse caso log de processo
VAR_TPO_LOG_DADO        		LOG_CARGA.CTPO_REG_LOG%TYPE    := 'D';  -- Tipo de registro de log, nesse caso log relativo aos dados
VAR_LOG_ERRO_ARQ        		LOG_CARGA.RLOG%TYPE;
---
-->> Variaveis para controle de tempo de processamento
---
W_HORA_PROC_INICIAL     		DATE      := SYSDATE;
W_TEMPO_PROC            		NUMBER;
---
-->> Variáveis para controle do CTRL-M
---
VAR_CSIT_CTRLM         			SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_DINIC_ROTNA        			DATE       := SYSDATE;
---
-->> Variaveis para Exceptions
---
VAR_FIM_PROCESSO_ERRO  			EXCEPTION;
VAR_FIM_PROCESSO_ERRO_CRITICO   EXCEPTION;
---
-->> Variaveis para alteracao da situacao da rotina
---
VAR_STATUS_ROTNA			    SIT_ROTNA.CSIT_ROTNA%TYPE;
VAR_ROTNA_AP				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'AP'; -- A processar
VAR_ROTNA_PC				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PC'; -- Processando
VAR_ROTNA_PO   				    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PO'; -- Processado OK
VAR_ROTNA_PE	   			    SIT_ROTNA.CSIT_ROTNA%TYPE	:= 'PE'; -- Processado com erro
---
-->> Variaveis de Trabalho
---
VAR_COUNT						NUMBER									:= 0;
VAR_QCOMMIT						NUMBER									:= 500;
VAR_DAPURC_DSTAQ				CAMPA_DSTAQ.DAPURC_DSTAQ%TYPE			:= NULL;						
VAR_CCAMPA_DSTAQ                CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE			:= 3;-- CODIGO DA CAMPANHA "FIXO"

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
   	
	--> Recupera os dados de parametro de carga (o código de parâmetro de carga foi inicializado no declare)
 	PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
  	VAR_LOG := 'PERIODO DA CARGA ATUAL: ' ||
               TO_CHAR((VAR_DCARGA+1), 'DD/MM/YYYY') || ' A ' ||
               TO_CHAR(VAR_DPROX_CARGA,  'DD/MM/YYYY');
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO , NULL, NULL);

EXCEPTION
	WHEN OTHERS THEN
    	VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: '||
     				SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END TRATA_PARAMETRO;  
---------------------------- ATUALIZA A DATA DA APURAÇÃO ----------------------
PROCEDURE ATUALIZA_DATA_APURACAO IS
BEGIN                         

     UPDATE CAMPA_DSTAQ
	    SET DAPURC_DSTAQ  = VAR_DPROX_CARGA
	  WHERE CIND_CAMPA_ATIVO = 'A';  
	 
EXCEPTION
	WHEN OTHERS THEN -- ERRO AO ATULIZAR DATA DA APURAÇÃO
    	VAR_LOG  := 'ERRO AO ATULIZAR DATA DA APURAÇÃO. ERRO ORACLE: '||
     				SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END ATUALIZA_DATA_APURACAO; 
----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN

	--> A variavel de tratamento de erro do control-m sera inicializada
	-- com o flag de termino normal com sucesso (=1)
	VAR_CSIT_CTRLM := 1;
	
	--> Limpa a tabela de log no inicio do processo
	-- (o trigger jogarah as informacoes para a tabela de historico)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA);
	
	--> Grava log inicial de carga
	VAR_LOG := 'INICIO DO PROCESSO DE ATUALIZAÇÃO DA DATA DA APURAÇÃO.';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
	--> Atualiza status da rotina, que deverá ser marcada como PC
	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
	
	--> Trata o parametro do processo.Procedure interna (sub-programa).
	TRATA_PARAMETRO;
	                       
	-- PROCEDURE INTERNA (SUB-PROGRAMA) PARA ATULIZAR DATA DA APURAÇÃO           
	ATUALIZA_DATA_APURACAO;
	
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
      	-- em caso de erro esta gravacao so sera feita na exception
      	PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                                   VAR_CROTNA     ,
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );

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

       	PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                                   VAR_CROTNA     ,
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );
                                   

	WHEN VAR_FIM_PROCESSO_ERRO THEN
    	VAR_CSIT_CTRLM := 6;

        --> Atualiza status da rotina
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
  	               'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);

       	PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                                   VAR_CROTNA     ,
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );
                                  

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

        PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                                   VAR_CROTNA     ,
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );

END SGPB6024;
/

