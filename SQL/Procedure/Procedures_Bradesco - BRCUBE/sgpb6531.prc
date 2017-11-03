CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6531 IS
------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 06/06/2008
--      AUTOR           : MONIQUE COSTA DA ROCHA MARQUES - RELACIONAL CONSULTORIA E SISTEMAS
--      PROGRAMA        : SGPB6005.SQL
--      OBJETIVO        : calculo dos ranks e percentuais
--      ALTERAÇÕES      :
--                DATA  : 
--                AUTOR : 
--                OBS   :
------------------------------------------------------------------------------------------------------------------------

-->> Variáveis de controle
---
VAR_CAMBTE         				ARQ_TRAB.CAMBTE%TYPE;  	                	-- parâmetro de ambiente
VAR_CSIST           			ARQ_TRAB.CSIST%TYPE   	  := 'SGPB';	    -- parâmetro de sistema
VAR_CROTNA          			ARQ_TRAB.CROTNA%TYPE  	  := 'SGPB6531';	-- parâmetro de rotina
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

--VARIAVEIS USADAS PARA TODAS AS CAMPANHAS
VAR_DAPURC_DSTAQ				CAMPA_DSTAQ.DAPURC_DSTAQ%TYPE				:= NULL;						
VAR_CCAMPA_DSTAQ                CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE				:= NULL;
VAR_CPARM_HIERQ_DSTAQ			PARM_HIERQ_DSTAQ.CPARM_HIERQ_DSTAQ%TYPE		:= NULL;

VAR_SQL		 		VARCHAR2(4000)	:= NULL;

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
------------------------------------------------------------------------
PROCEDURE MONTA_SQL (PAR_CANAL CANAL_PROD.CCANAL_PROD_DW%TYPE, 
					 PAR_CPARM_HIERQ_DSTAQ PARM_HIERQ_DSTAQ.CPARM_HIERQ_DSTAQ%TYPE,
					 CIND_RGNAL	BOOLEAN DEFAULT FALSE)IS
--XYZ APOS TESTE INICIAL UNITARIO COLOCAR OS RANKS DOS PERCENTUAIS
BEGIN	
	VAR_SQL	:= 'SELECT PRD.ROWID
		     , (VPROD_AUTO + VPROD_RE) VPROD_CRRTR 
		     , RANK() OVER (PARTITION BY ';
				     
	IF PAR_CANAL IN (3,5) THEN --EXTRA BANCO
		IF CIND_RGNAL THEN
			VAR_SQL := VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_EXTRA_BCO_RGNAL(VAR_CCAMPA_DSTAQ);
			VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD_RGNAL ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT
		ELSE
			VAR_SQL := VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_EXTRA_BCO(VAR_CCAMPA_DSTAQ);
			VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT			
		END IF;
	
	ELSIF PAR_CANAL IN (4) THEN --BANCO
	
		IF PAR_CPARM_HIERQ_DSTAQ = 1 THEN --XYZ VER NUMERO QUE REPRESENTA CNPJ			
			VAR_SQL	:= VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_BCO_CNPJ(VAR_CCAMPA_DSTAQ);
			VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT			
		ELSIF PAR_CPARM_HIERQ_DSTAQ = 1 THEN --XYZ VER NUMERO QUE REPRESENTA AG
			IF CIND_RGNAL THEN
				VAR_SQL	:= VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_BCO_AG(VAR_CCAMPA_DSTAQ);
				VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD_RGNAL ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT				
			ELSE
				VAR_SQL	:= VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_BCO_AG(VAR_CCAMPA_DSTAQ);
				VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT				
			END IF;
		END IF;
	
	ELSIF PAR_CANAL IN (8) THEN --FINASA
	
		VAR_SQL := VAR_SQL + PC_PARAMETROS_DESTAQUE.FC_RCUPD_HIERQ_FNASA(VAR_CCAMPA_DSTAQ);
		VAR_SQL	:= '  ORDER BY (VPROD_AUTO + VPROD_RE) DESC) NRKING_PROD ';
--			, RANK() OVER (PARTITION BY HIERARQUIA ORDER BY VPERC_CRSCT DESC) NRKING_PERC_CRSCT		
	
	END IF;
        
	VAR_SQL	:= VAR_SQL + ' FROM POSIC_DSTAQ PRD
			 , HIERQ_PBLIC_ALVO HPA
			 WHERE PRD.DAPURC_DSTAQ = '|| VAR_DPROX_CARGA||
			 ' AND PRD.CCAMPA_DSTAQ = '||VAR_CCAMPA_DSTAQ||
			 ' AND PRD.CCANAL_PROD_DW = '||PAR_CANAL||
			 ' AND PRD.CPARM_HIERQ_DSTAQ = '||PAR_CPARM_HIERQ_DSTAQ||
			 ' AND PRD.CCAMPA_DSTAQ				= HPA.CCAMPA_DSTAQ
			   AND PRD.CPARM_HIERQ_DSTAQ			= HPA.CPARM_HIERQ_DSTAQ
			   AND PRD.CHIERQ_PBLIC_ALVO_DSTAQ	= HPA.CHIERQ_PBLIC_ALVO_DSTAQ
			   AND PRD.CCANAL_PROD_DW			= HPA.CCANAL_PROD_DW
			 ORDER BY VPROD_CRRTR DESC';
			 
VAR_LOG  := '------O SELECT SERA:------'||VAR_SQL;
PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
END MONTA_SQL;
-------------------------------------------------------------------------
PROCEDURE GRAVA_RANK IS
VAR_ROWID			ROWID;
VAR_VPROD_CRRTR		POSIC_DSTAQ.VPROD_AUTO%TYPE;
VAR_NRKING_PROD		POSIC_DSTAQ.NRKING_PROD%TYPE;
TYPE TP_CURSOR		IS REF CURSOR;
CUR_RANK			TP_CURSOR;
BEGIN
	OPEN CUR_RANK FOR VAR_SQL;
		
	LOOP
		FETCH CUR_RANK INTO VAR_ROWID, VAR_NRKING_PROD;
			
		UPDATE POSIC_DSTAQ
		SET NRKING_PROD 		= VAR_NRKING_PROD 
	 	WHERE ROWID = VAR_ROWID;
		
		VAR_COUNT	:= VAR_COUNT + 1;
		
		IF MOD(VAR_COUNT,VAR_QCOMMIT) = 0 THEN
			COMMIT;
		END IF;
		
		EXIT WHEN CUR_RANK%NOTFOUND;
		
	END LOOP;
	
	COMMIT;
	
	CLOSE CUR_RANK;
	
	VAR_LOG  := '---------------------TOTAL DE REGISTROS CLASSIFICADOS: '|| TO_CHAR(VAR_COUNT);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
	VAR_COUNT	:= 0;

END GRAVA_RANK;
-------------------------------------------------------------------------
PROCEDURE GRAVA_RANK_RGNAL IS
VAR_ROWID				ROWID;
VAR_VPROD_CRRTR			POSIC_DSTAQ.VPROD_AUTO%TYPE;
VAR_NRKING_PROD_RGNAL	POSIC_DSTAQ.NRKING_PROD%TYPE;
TYPE TP_CURSOR			IS REF CURSOR;
CUR_RANK				TP_CURSOR;
BEGIN
	OPEN CUR_RANK FOR VAR_SQL;
		
	LOOP
		FETCH CUR_RANK INTO VAR_ROWID, VAR_NRKING_PROD_RGNAL;
			
		UPDATE POSIC_DSTAQ
		SET NRKING_PROD_RGNAL 		= VAR_NRKING_PROD_RGNAL 
	 	WHERE ROWID = VAR_ROWID;
		
		VAR_COUNT	:= VAR_COUNT + 1;
		
		IF MOD(VAR_COUNT,VAR_QCOMMIT) = 0 THEN
			COMMIT;
		END IF;
		
		EXIT WHEN CUR_RANK%NOTFOUND;
		
	END LOOP;
	
	COMMIT;
	
	CLOSE CUR_RANK;
	
	VAR_LOG  := '---------------------TOTAL DE REGISTROS CLASSIFICADOS: '|| TO_CHAR(VAR_COUNT);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
	VAR_COUNT	:= 0;

END GRAVA_RANK_RGNAL;

----------------------------- CARREGA_RANK  -----------------------------
PROCEDURE CARREGA_RANK IS
BEGIN
 	
	VAR_COUNT := 0;
					
	FOR REG_PHD	IN (SELECT CPARM_HIERQ_DSTAQ,CCANAL_PROD_DW, IPARM_HIERQ_DSTAQ
				 FROM PARM_HIERQ_DSTAQ PHD
				 WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
				 ORDER BY CCANAL_PROD_DW) LOOP
				 
		VAR_LOG  := '------INICIA A CLASSIFICACAO DOS CORRETORES DA CAMPANHA - '||VAR_CCAMPA_DSTAQ
				  ||' CANAL DW - '||REG_PHD.CCANAL_PROD_DW||' HIERARQUIA - '||REG_PHD.IPARM_HIERQ_DSTAQ;
 		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
	 	COMMIT;
	 	
	 	IF	((REG_PHD.CCANAL_PROD_DW = 4) AND (REG_PHD.CPARM_HIERQ_DSTAQ = 1)) OR --CANAL BANCO --XYZ HIERARQUIA QUE REPRESENTA AGENCIA
	 		(REG_PHD.CCANAL_PROD_DW IN(5,3)) THEN --OU SE CANAL EXTRA BANCO
	 		--PARA ESSAS COMBINAÇÕES DE CANAL E HIERARQUIA EXISTE AGRUPAMENTO POR REGIONAL E GRUPO DE REGIONAL
	 		
	 		MONTA_SQL (REG_PHD.CCANAL_PROD_DW, REG_PHD.CPARM_HIERQ_DSTAQ,TRUE);
	 		GRAVA_RANK;
	 		MONTA_SQL (REG_PHD.CCANAL_PROD_DW, REG_PHD.CPARM_HIERQ_DSTAQ,FALSE);
	 		GRAVA_RANK_RGNAL;	 	
	 	ELSE
 			MONTA_SQL (REG_PHD.CCANAL_PROD_DW, REG_PHD.CPARM_HIERQ_DSTAQ);
 			GRAVA_RANK;
		END IF;
				
	END LOOP;--LOOP DE HIERARQUIA	
	
	COMMIT;
		
EXCEPTION
	WHEN OTHERS THEN
    	VAR_LOG  := 'ERRO AO CARREGA RANK DE PRODUÇÃO DA REGIONAL <HIERQ 4>. ERRO ORACLE: '||
     				SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
END CARREGA_RANK;
----------------------------- CARREGA_RANK6  -----------------------------
----------------------------- CARREGA_RANK8  -----------------------------
----------------------------- CARREGA_%  -----------------------------
PROCEDURE CARREGA_PARCENTUAL IS
BEGIN

	VAR_LOG  := 'INICIA O CALCULO DO PERCENTUAL DE CRESCIMENTO. PARA A CAMPANHA - '||VAR_CCAMPA_DSTAQ||
				' APURAÇÃO - '||TO_CHAR(VAR_DAPURC_DSTAQ,'DD/MM/YYYY');
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
 	COMMIT;
 	
	VAR_COUNT := 0;
	
	FOR REG IN (SELECT PRD.ROWID
				     , ((VPROD_AUTO + VPROD_RE)/(VMETA_AUTO + VMETA_RE)) * 100 VPERC_CRSCT
				     , (VPROD_AUTO / VMETA_AUTO) * 100 VPERC_CRSCT_AUTO
				     , (VPROD_RE / VMETA_RE) * 100 VPERC_CRSCT_RE
				FROM POSIC_DSTAQ	PRD
				   , META_DSTAQ	MRD
				WHERE MRD.CCAMPA_DSTAQ				= PRD.CCAMPA_DSTAQ
				  AND MRD.CHIERQ_PBLIC_ALVO_DSTAQ	= PRD.CHIERQ_PBLIC_ALVO_DSTAQ
				  AND MRD.CPARM_HIERQ_DSTAQ			= PRD.CPARM_HIERQ_DSTAQ
				  AND MRD.CCANAL_PROD_DW			= MRD.CCANAL_PROD_DW
				  AND PRD.DAPURC_DSTAQ				= VAR_DPROX_CARGA --A DT DEVE SER A DATA CADASTRADA NA CAMPANHA
				  AND PRD.CCAMPA_DSTAQ				= VAR_CCAMPA_DSTAQ) LOOP
				
		UPDATE POSIC_DSTAQ
		SET VPERC_CRSCT			=	REG.VPERC_CRSCT
		  , VPERC_CRSCT_AUTO	=	REG.VPERC_CRSCT_AUTO
		  , VPERC_CRSCT_RE		=	REG.VPERC_CRSCT_RE
		WHERE ROWID = REG.ROWID;
					
		VAR_COUNT	:= VAR_COUNT + 1;
		
		IF MOD(VAR_COUNT,VAR_QCOMMIT) = 0 THEN
			COMMIT;
		END IF;
		
	END LOOP;
	
	VAR_LOG  := 'TOTAL DE REGISTROS COM PERCENTUAL DE CRESCIMENTO CALCULADOS: '|| TO_CHAR(VAR_COUNT)||
				' . PARA A CAMPANHA - '||VAR_CCAMPA_DSTAQ ||' APURAÇÃO - '||TO_CHAR(VAR_DAPURC_DSTAQ,'DD/MM/YYYY');
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
    	VAR_LOG  := 'ERRO AO CALCULAR O PERCENTUAL DE CRESCIMENTO. PARA A CAMPANHA - '||VAR_CCAMPA_DSTAQ ||
    				' APURAÇÃO - '||TO_CHAR(VAR_DAPURC_DSTAQ,'DD/MM/YYYY')||' . ERRO ORACLE: '||
     				SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
END CARREGA_PARCENTUAL;
----------------------------- CARREGA_RANK  -----------------------------
PROCEDURE ATUALIZA_POSIC IS
VCCAMPA_DSTAQ_PERC_OK	NUMBER := 0;	
BEGIN

	FOR REG_CD IN ( SELECT CD.CCAMPA_DSTAQ
						 , CD.ICAMPA_DSTAQ
						 , CD.DAPURC_DSTAQ
					FROM CAMPA_DSTAQ CD
					WHERE CD.CIND_CAMPA_ATIVO	= 'S'
					ORDER BY CCAMPA_DSTAQ) LOOP
					
		VAR_LOG  := '--------------------------------------------------------------------------------------------------------------';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
        
		VAR_DAPURC_DSTAQ		:=	REG_CD.DAPURC_DSTAQ;
		VAR_CCAMPA_DSTAQ		:=	REG_CD.CCAMPA_DSTAQ;
		VAR_DPROX_CARGA			:=  NULL; --XYZ RECUPERAR A PROXIMA CARGA DO SCHEDULER
		
		--SO IRA CARREGAR O PERCENTUAL UMA VEZ POR CAMPANHA!
		IF VCCAMPA_DSTAQ_PERC_OK <> VAR_CCAMPA_DSTAQ THEN
			CARREGA_PARCENTUAL;
			VCCAMPA_DSTAQ_PERC_OK	:= VAR_CCAMPA_DSTAQ;	
		END IF;

		CARREGA_RANK;
		
		VAR_LOG  := '--------------------------------------------------------------------------------------------------------------';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);
		
	END LOOP;	
			
	
EXCEPTION
	WHEN OTHERS THEN
    	VAR_LOG  := 'ERRO NO PROGRAMA ATUALIZA_POSIC. ERRO ORACLE: '||
     				SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_TPO_LOG_PROCESSO, NULL, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
END ATUALIZA_POSIC;
----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN

	--> A variavel de tratamento de erro do control-m sera inicializada
	-- com o flag de termino normal com sucesso (=1)
	VAR_CSIT_CTRLM := 1;
	
	--> Limpa a tabela de log no inicio do processo
	-- (o trigger jogarah as informacoes para a tabela de historico)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA);
	
	--> Grava log inicial de carga
	VAR_LOG := 'INICIO DO PROCESSO DE RANK DO CORRETOR.';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_TPO_LOG_PROCESSO, NULL, NULL);
	
	--> Atualiza status da rotina, que deverá ser marcada como PC
	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
	
	--> Trata o parametro do processo.Procedure interna (sub-programa).
	TRATA_PARAMETRO;
	
	-- PROCEDURE INTERNA (SUB-PROGRAMA) PARA CARREGAR O RANK
	ATUALIZA_POSIC;
		
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
 

END SGPB6531;
/

