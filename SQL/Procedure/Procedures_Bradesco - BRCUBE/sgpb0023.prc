CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0023 IS
-------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                            
--  DATA            : 21/02/2008
--  AUTOR           : MONIQUE COSTA DA ROCHA MARQUES - VALUE TEAM
--  PROGRAMA        : SGPB0023.SQL                                                   
--  OBJETIVO        : ELEGER TODOS OS CORRETORES DO CANAL EXTRA-BANCO, QUE PERTENCEM A GRUPOS ECONOMICOS 
--					  E QUE NÃO FORAM ELEITOS PARA A CAMPANHA ATIVA NO CANAL EXTRA-BANCO (1)
--  ALTERAÇÕES      :                                                               
--            DATA  : 
--			 AUTOR	: 
--            OBS   : 
-------------------------------------------------------------------------------------

-- VARIAVEIS DE TRABALHO    
--VAR_CHAVE_DW		   		NUMBER(10);     
VAR_CROTNA					ARQ_TRAB.CROTNA%TYPE            := 'SGPB0023';
VAR_DINIC_ROTNA         	DATE                            := SYSDATE;          
--VAR_DT_REF_INI              DATE                            := SYSDATE; 
VAR_CPARM               	PARM_CARGA.CPARM%TYPE           := 727;
--VAR_DCARGA		          	PARM_CARGA.DCARGA%TYPE;            
--VAR_DCARGA_ANT          	PARM_CARGA.DCARGA%TYPE;            
--VAR_ERRO 					VARCHAR2(1);
VAR_TABELA			VARCHAR2(30) 			   		:= 'CRRTR_ELEIT_CAMPA';
VAR_LOG                 	LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'P'; 
--VAR_LOG_DADO            	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'D'; 
VAR_LOG_ADVERTENCIA     	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'A'; 
VAR_CSIT_CTRLM          	SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
--VAR_TOT_REG_ERRO			NUMBER	   						:= 0; 
VAR_FIM_PROCESSO_ERRO   	EXCEPTION;   
--VAR_MSG_ERRO				VARCHAR2(240);                                           
--VAR_CCHAVE_ERRO	   			VARCHAR2(100);    
--VAR_TOT_REG_PROC           	NUMBER;
--VAR_CHAVE_ANT_CRRTR         NUMBER(10)  := 0;
--VAR_CHAVE_ANT_CRAMO         NUMBER(10)  := 0;
--VAR_CHAVE_ANT_VCOMIS        NUMBER(10)  := 0;
--VAR_ALT                     NUMBER(10)  := 0;
--VAR_TOT_REG_REJEITADO      	NUMBER		:= 0;

--VAR_DINIC_VGCIA             DATE;
--VAR_QTD_COMIS_ZERO          NUMBER := 0;
--VAR_CCTRL_ATULZ				NUMBER := 1;	
                                 
--VAR_ORIGEM				   	ORIGE_DADO.CORIGE_DADO%TYPE		:= 30;	

--VAR_CORIGE_RAMO             ORIGE_DADO.CORIGE_DADO%TYPE		:= 02;	
--VAR_CORIGE_CRRTR            ORIGE_DADO.CORIGE_DADO%TYPE		:= 30;

--VAR_CDMSAO_RAMO             DMSAO_DSTNO.CDMSAO_DSTNO%TYPE	:= 25;
--VAR_CDMSAO_CRRTR            DMSAO_DSTNO.CDMSAO_DSTNO%TYPE   := 47;

                                                    
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
W_HORA_PROC_INICIAL         DATE  := SYSDATE;
W_TEMPO_PROC                NUMBER;

-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_AP		     	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE'; -- PROCESSADO COM ERRO
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;     
--VAR_STATUS_ROTNA_ANT	    SIT_ROTNA.CSIT_ROTNA%TYPE;                                

-- VARIAVEL REFERENTE A TABELA ALVO 
--WROW         	            TEMPR_FATO_COMIS_CRRTR_RAMO%ROWTYPE; 
                                       
--VAR_DINIC_VGCIA_AUXIL_ALFAN	NUMBER(08);  
--VAR_DFIM_VGCIA_AUXIL		NUMBER(08); 					             
--VAR_DATULZ					DATE;
--VAR_DATIVO_REG				DATE;

--VAR_DT_REF_AUX 				NUMBER;
--VAR_DT_REF_INI_AUX          NUMBER;

--VAR_TOT_REG_COMIS_ZERO		NUMBER	:= 0;
--VAR_TOT_REG_LIDO			NUMBER	:= 0; 
--VAR_PCOMIS_CRRTR_MIN		TEMPR_FATO_COMIS_CRRTR_RAMO.PCOMIS_CRRTR%TYPE	:= 1/100;
--VAR_COUNT_COMIS_ZERO		NUMBER	:= 0;
--VAR_CHAVE_LGADO				VARCHAR2(100);

VAR_CCANAL_VDA_SEGUR		PARM_INFO_CAMPA.CCANAL_VDA_SEGUR%TYPE	:=1;
VAR_DINIC_VGCIA_PARM		PARM_INFO_CAMPA.DINIC_VGCIA_PARM%TYPE;
VAR_QTD_CRRTR_CPAC				NUMBER := 0;
--VAR_QTD_CRRTR_JA_ELEIT			NUMBER := 0;
VAR_QTD_CRRTR_ELEIT				NUMBER := 0;


-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
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

--* ***************************************************************** 
--------------------------------------------------------------------------------------
PROCEDURE RECUPERA_PARM_INFO_CAMPA IS
--RECUPERA A DATA DE INICIO DE VIGENCIA DA CAMPANHA QUE DEVE SER A MESMA DO GRUPO E DO CORRETOR ELEITO!
--COMO GRUPO ECONOMICO SO PARA O CANAL EXTRA BANCO!!! 
BEGIN

	SELECT DINIC_VGCIA_PARM
		INTO VAR_DINIC_VGCIA_PARM 
	FROM PARM_INFO_CAMPA
	WHERE DFIM_VGCIA_PARM IS NULL
	AND CCANAL_VDA_SEGUR = VAR_CCANAL_VDA_SEGUR;
	
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
    
    	VAR_CSIT_CTRLM	:= 5;
		
		VAR_LOG  := 'EXISTE MAIS DE UMA CAMPANHA ABERTA PARA O CCANAL_VDA_SEGUR: '||VAR_CCANAL_VDA_SEGUR;
  		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
  		
		RAISE VAR_FIM_PROCESSO_ERRO; 
		
	WHEN NO_DATA_FOUND THEN
    
    	VAR_CSIT_CTRLM	:= 5;
		
		VAR_LOG  := 'NÃO EXISTE CAMPANHA ABERTA PARA O CCANAL_VDA_SEGUR: '||VAR_CCANAL_VDA_SEGUR;
  		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
  		
		RAISE VAR_FIM_PROCESSO_ERRO;	
	WHEN OTHERS THEN
		VAR_CSIT_CTRLM	:= 6;
		
		VAR_LOG  := 'ERRO AO TENTAR RECUPERAR O PARAMETRO DE INFORMACAO DA CAMPANHA!';
  		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
  		
  		VAR_LOG  := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
  		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
  		
		RAISE VAR_FIM_PROCESSO_ERRO;
			
END RECUPERA_PARM_INFO_CAMPA;
--------------------------------------------------------------------------------------
PROCEDURE ELEGE_TODOS_CRRTR_PARTC_AGPTO IS 
BEGIN
  
	--CONTA TODOS OS CORRETORES DOS GRUPOS ECONOMICOS PARA A CAMPANHA VIGENTE
	SELECT COUNT(*)
		INTO VAR_QTD_CRRTR_CPAC 
	FROM CRRTR_PARTC_AGPTO_ECONM
	WHERE DINIC_VGCIA_PRTCP_AGPTO_ECONM >= VAR_DINIC_VGCIA_PARM
      AND DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL;
	  
	VAR_LOG  := 'TOTAL DE CORRETORES PARTICIPANTES EM AGRUPAMENTOS ECONOMICOS: '||VAR_QTD_CRRTR_CPAC;
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	FOR CUR_CRRTR_A_ELEGER IN (SELECT CPA.CTPO_PSSOA, CPA.CCPF_CNPJ_BASE  
								FROM CRRTR_PARTC_AGPTO_ECONM CPA
								WHERE NOT EXISTS (	SELECT * 
													FROM CRRTR_ELEIT_CAMPA CEC
													WHERE CEC.CTPO_PSSOA = CPA.CTPO_PSSOA
													AND CEC.CCPF_CNPJ_BASE = CPA.CCPF_CNPJ_BASE
													AND CEC.DINIC_VGCIA_PARM = VAR_DINIC_VGCIA_PARM
													AND CCANAL_VDA_SEGUR = VAR_CCANAL_VDA_SEGUR)
								ORDER BY CPA.CTPO_PSSOA, CPA.CCPF_CNPJ_BASE) LOOP
		BEGIN
	   											  
			INSERT INTO CRRTR_ELEIT_CAMPA (
				CCANAL_VDA_SEGUR
			  , DINIC_VGCIA_PARM
			  , CTPO_PSSOA
			  , CCPF_CNPJ_BASE
			  , DCRRTR_SELEC_CAMPA) 
			VALUES (
				VAR_CCANAL_VDA_SEGUR
			  , VAR_DINIC_VGCIA_PARM
			  , CUR_CRRTR_A_ELEGER.CTPO_PSSOA
			  , CUR_CRRTR_A_ELEGER.CCPF_CNPJ_BASE
			  , SYSDATE);
			  			  
			VAR_QTD_CRRTR_ELEIT	:=	VAR_QTD_CRRTR_ELEIT + 1;
			
			IF MOD(VAR_QTD_CRRTR_ELEIT,500) = 0 THEN
				COMMIT;
			END IF;
			
		EXCEPTION
			WHEN OTHERS THEN
				VAR_CSIT_CTRLM	:= 5;
				
				VAR_LOG  := 'ERRO AO INSERIR DADOS NA TABELA CRRTR_ELEIT_CAMPA. CANAL '||VAR_CCANAL_VDA_SEGUR||
							' DATA INIC '||VAR_DINIC_VGCIA_PARM||' TIPO '||CUR_CRRTR_A_ELEGER.CTPO_PSSOA||
							' CNPJ BASE '||CUR_CRRTR_A_ELEGER.CCPF_CNPJ_BASE;
	   			PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	   			
	   			VAR_LOG  := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
	  			PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	  		
	   			RAISE VAR_FIM_PROCESSO_ERRO;	
		END;		
	END LOOP;
	
	VAR_LOG  := 'TOTAL DE CORRETORES ELEITOS SOMENTE PARA OS AGRUPAMENTOS ECONOMICOS: '||VAR_QTD_CRRTR_ELEIT;
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		VAR_CSIT_CTRLM	:= 6;
		
		VAR_LOG  := 'ERRO NO SUBPROGRAMA ELEGE_TODOS_CRRTR_PARTC_AGPTO. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	    
	    RAISE VAR_FIM_PROCESSO_ERRO;
	    
END ELEGE_TODOS_CRRTR_PARTC_AGPTO; 
------------------------------------  PROGRAMA PRINCIPAL  ------------------------------------
BEGIN
         
	-- A variável de tratamento de erro do control-m sera inicializada 
   	-- com o flag de termino normal com sucesso (=1)
   	VAR_CSIT_CTRLM := 1;

	--> Limpa a tabela de log no inicio do processo 
	-- (o trigger jogarah as informacoes para a tabela de historico)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA); 
	
	--> Grava log inicial de carga
	VAR_LOG := 'INICIO DO PROCESSO DE ELEICAO DO GRUPO ECONOMICO '||VAR_TABELA;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		
	--> Grava log inicial de carga
	VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '||VAR_CSIT_CTRLM;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	--> Atualiza status da rotina atual      
   	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);

	-->SUB PROGRAMA QUE BUSCA OS DADOS DA CAMPANHA ATIVA E ARMAZENA EM VARIAVEIS GLOBAIS
   	RECUPERA_PARM_INFO_CAMPA;
   	
   	-->SUB PROGRAMA QUE ELEGE TODOS OS CORRETORES DO GRUPO ECONOMICO
   	ELEGE_TODOS_CRRTR_PARTC_AGPTO;    

    --> Tempo de processamento
    W_TEMPO_PROC :=  ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
    VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||W_TEMPO_PROC;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);	
	
	IF VAR_CSIT_CTRLM = 1 THEN
                       
		--> Atualiza status termino da rotina  
		PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
		VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PO; 
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

		VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). ' ||
                   'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      
		--> Grava a situacao deste processo na tabela de controle do ctrlm   
		PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA, 
                                  VAR_CROTNA     , 
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );           
	ELSE 
	
		RAISE VAR_FIM_PROCESSO_ERRO;

	END IF;
    	
EXCEPTION
	WHEN VAR_FIM_PROCESSO_ERRO THEN      
        
        --> Atualiza status termino da rotina  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = ' || VAR_CSIT_CTRLM || 
                   ' ). OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

   	    PR_GRAVA_LOG_EXCUC_CTRLM(VAR_DINIC_ROTNA, 
                              	 VAR_CROTNA     , 
                                 SYSDATE        , -- DFIM_ROTNA
                                 NULL           , -- IPROG
                                 NULL           , -- CERRO
                                 VAR_LOG        , -- RERRO
                                 VAR_CSIT_CTRLM             );

	WHEN OTHERS THEN   
    	                                              
        VAR_CSIT_CTRLM := 6;                         

        --> Atualiza status termino da rotina  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
                
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = 6). ' || 
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '				 ||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        
   	    PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA, 
                              	  VAR_CROTNA     , 
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );

 END;
/

