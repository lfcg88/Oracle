create or replace procedure sgpb_proc.SGPB6022_OLD is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 13/10/2007
--  AUTOR           : JOSEVALDO / JOÃO GRIMALDE - VALUE TEAM                              
--  PROGRAMA        : SGPB6022.SQL                                                                             
--  OBJETIVO        : CARGA DE ATUALIZAÇÃO DIÁRIA DAS METAS DOS NOVOS CORRETORES - SGPB6022
--  ALTERAÇÕES      :                                                                                               
--            DATA  : -                                                                                              
--            AUTOR : -                                                                                              
--            OBS   : -                                                                                              
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO         
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             := 'SGBP'; 
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE            := 'SGPB6022';  
VAR_TABELA      			VARCHAR2(30) 			   		:= 'META_RGNAL_DSTAQ';
VAR_ERRO                    VARCHAR2(1)       := 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A'; 
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P'; 
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;           
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;     
VAR_FIM_PROCESSO_ERRO       EXCEPTION; 
--
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 752;     
VAR_DCARGA                  PARM_CARGA.DCARGA%TYPE;
VAR_DPROX_CARGA             PARM_CARGA.DPROX_CARGA%TYPE;        
VAR_DULT_APURC_DSTAQ        DATE ;                        -- DATA DA ULTIMA APURAÇÃO DESTAQUE  
VAR_VPRMIO_DSTAQ            CAMPA_DSTAQ.VPRMIO_DSTAQ%TYPE                 ; 
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_PC       			SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PC';
VAR_ROTNA_PO       			SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PO';
VAR_ROTNA_PE          		SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PE';  
--                                                                 
--          
W_HORA_PROC_INICIAL        DATE  							:= SYSDATE;
W_TEMPO_PROC               NUMBER;
--                          
-- VARIAVEIS UTILIZADAS NO PROCESSO DE CARGA DE ATUALIZAÇÃO DIÁRIA DAS METAS DOS NOVOS CORRETORES 
VAR_CCAMPA_DSTAQ            POSIC_CRRTR_DSTAQ.CCAMPA_DSTAQ%TYPE                := 1;   -- DEVE SER TROCADO VALOR DE RETORNO DA PROCEDURE
VAR_DINIC_ROTNA             DATE                            := SYSDATE;
--VAR_DAPURC_ANOMES_ANTER_DSTAQ		DATE; 
VAR_CIND_CAMPA_ATIVO        VARCHAR2(1)  := 'S' ; 
VAR_EXISTE_PROD_ATUAL       VARCHAR2(1)  := 'S'; 
--VAR_CDIR_RGNAL              POSIC_RGNAL_DSTAQ.CRGNAL%TYPE; 
--VAR_CCPF_CNPJ_BASE          POSIC_RGNAL_DSTAQ.CCPF_CNPJ_BASE%TYPE;
--VAR_CTPO_PSSOA              POSIC_RGNAL_DSTAQ.CTPO_PSSOA%TYPE;
VAR_DEMIS                   DATE;
VAR_VPROD_RGNAL_AUTO        NUMBER(15,2);
VAR_VPROD_RGNAL_RE          NUMBER(15,2);
VAR_VMETA_AUTO              NUMBER(15,2);
VAR_VMETA_RE                NUMBER(15,2);
VAR_TOT_REG_PROC           	NUMBER := 0;    
VAR_TOT_REG_CRRTR_NOVO     	NUMBER := 0;    
--
--
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

--
PROCEDURE PR_INCR_META_RGNAL_DSTAQ (
					PAR_CCAMPA_DSTAQ            IN NUMBER,
					PAR_CTPO_PSSOA              IN VARCHAR2,
					PAR_CCPF_CNPJ_BASE          IN NUMBER,
					PAR_CRGNAL                  IN NUMBER,
					PAR_DAPURC_DSTAQ            IN DATE,
					PAR_VMETA_RGNAL_AUTO        IN NUMBER,
					PAR_VMETA_RGNAL_RE          IN NUMBER,	
					PAR_DINCL_REG               IN DATE
					)IS              

BEGIN 
   BEGIN  
   --          
	  BEGIN
          -- Cadastra Produção do Corretor na tabela POSIC_CRRTR_DSTAQ
             INSERT INTO META_RGNAL_DSTAQ
             ( CCAMPA_DSTAQ,
		       CTPO_PSSOA,
		       CCPF_CNPJ_BASE,
		       CRGNAL,
		       DAPURC_DSTAQ,
		       VMETA_AUTO,
		       VMETA_RE, 
		       DINCL_REG,
		       DALT_REG)
             VALUES
             ( PAR_CCAMPA_DSTAQ,
		       PAR_CTPO_PSSOA,
		       PAR_CCPF_CNPJ_BASE, 
		       PAR_CRGNAL,
		       PAR_DAPURC_DSTAQ,      -- DATA DA APURAÇÃO ATUAL
		       PAR_VMETA_RGNAL_AUTO,
		       PAR_VMETA_RGNAL_RE,
		       PAR_DINCL_REG,    
		       NULL );            -- DALT_REG
          --       
          
		    VAR_TOT_REG_PROC :=VAR_TOT_REG_PROC +1;
		      
	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'META JÁ CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(PAR_CCAMPA_DSTAQ)||
           	           ' REGIONAL: '        || TO_CHAR(PAR_CRGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(PAR_CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(PAR_DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
            --
    	WHEN OTHERS THEN    
    	    --			
			VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	  END;  
   --       
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;  
   END;
END;
--
--
PROCEDURE PR_RECUPERA_PARM_APURACAO IS  
BEGIN 
  
      --> RECUPERA OS DADOS DE PARAMETRO DE CARGA (O CÓDIGO DE PARâMETRO DE CARGA FOI INICIALIZADO NO DECLARE)
      PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
    
   --       
END;
-- 
--
PROCEDURE PR_META_DIA_NOVO_CRRTR IS  -- POSICAO DIARIA PRODUÇÃO DA SUPEX
BEGIN 
    --
   	VAR_LOG  := '------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECUÇÃO CURSOR DE APURAÇÃO DA META DOS CORRETORES NOVOS   ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 3, NULL);
    VAR_LOG  := '-------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);   	
   	-- 
	FOR REG IN(	
				SELECT CPD.CCAMPA_DSTAQ,
				       PRD.CRGNAL        CDIR_RGNAL,
				       PRD.CCPF_CNPJ_BASE,
				       PRD.CTPO_PSSOA,
				       CPD.DAPURC_DSTAQ,
				       CPD.VMETA_MIN_RE,
				       CPD.VMETA_MIN_AUTO
				  from CAMPA_DSTAQ       CPD,
				       POSIC_RGNAL_DSTAQ PRD
				    where CPD.CCAMPA_DSTAQ      = VAR_CCAMPA_DSTAQ
				      AND CPD.CIND_CAMPA_ATIVO  = VAR_CIND_CAMPA_ATIVO
				      AND PRD.DAPURC_DSTAQ      = VAR_DPROX_CARGA
				      AND PRD.CCAMPA_DSTAQ      = CPD.CCAMPA_DSTAQ
				      AND NOT EXISTS (SELECT 1
				                    FROM META_RGNAL_DSTAQ
				                   WHERE CCAMPA_DSTAQ        = CPD.CCAMPA_DSTAQ
				                     AND CTPO_PSSOA          = PRD.CTPO_PSSOA
				                     AND CCPF_CNPJ_BASE      = PRD.CCPF_CNPJ_BASE
				                     AND CRGNAL              = PRD.CRGNAL
				                     AND ( TRUNC(DAPURC_DSTAQ) >= TRUNC(DINIC_CAMPA_DSTAQ) AND
				                           TRUNC(DAPURC_DSTAQ) <= TRUNC(DFIM_CAMPA_DSTAQ )) 
				                          )
               ) 
    LOOP
   	-- 
		    
	  BEGIN
          -- Cadastra Produção do Corretor na tabela POSIC_CRRTR_DSTAQ
             INSERT INTO META_RGNAL_DSTAQ
             ( CCAMPA_DSTAQ,
		       CTPO_PSSOA,
		       CCPF_CNPJ_BASE,
		       CRGNAL,
		       DAPURC_DSTAQ,
		       VMETA_AUTO,
		       VMETA_RE, 
		       DINCL_REG,
		       DALT_REG)
             VALUES
             ( REG.CCAMPA_DSTAQ,
		       REG.CTPO_PSSOA,
		       REG.CCPF_CNPJ_BASE, 
		       REG.CDIR_RGNAL,
		       VAR_DPROX_CARGA,      -- DATA DA APURAÇÃO ATUAL
		       REG.VMETA_MIN_AUTO,
		       REG.VMETA_MIN_RE,
		       SYSDATE,    
		       NULL );            -- DALT_REG
          --       
          
		    VAR_TOT_REG_PROC :=VAR_TOT_REG_PROC +1;
		      
	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'META JÁ CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           ' REGIONAL: '        || TO_CHAR(REG.CDIR_RGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(REG.CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(REG.DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
            --
    	WHEN OTHERS THEN    
    	    --			
			VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	  END;  
		    		    
     IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
        COMMIT;
     END IF;  						
 
--
END LOOP;
--
COMMIT;
--  
EXCEPTION
	WHEN OTHERS THEN    
        --
    	VAR_CSIT_CTRLM := 6;   
        --
         VAR_LOG := 'ERRO NO SUB-PROGRAMA que CARREGA OS DADOS PARA TABELA ' || VAR_TABELA;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 6, NULL); 

        VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 7, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
      
END;   

--
----------------------------- PROGRAMA PRINCIPAL  -----------------------------  
BEGIN
	-- A VARIáVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA 
   	-- COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   	VAR_CSIT_CTRLM := 1;

	--> LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
	-- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA); 
	
	--> GRAVA LOG INICIAL DE CARGA
	VAR_LOG := 'INICIO DO PROCESSO CARGA DA TABELA '||VAR_TABELA;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);   

   -- TEMPO DE PROCESSAMENTO
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	
	
	--> Grava log inicial de carga
	VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '|| VAR_CSIT_CTRLM;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	
   	--> Verifica status da rotina antes de iniciar o processamento 
  	VAR_LOG := 'VERIFICANDO STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.';
  	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
 	VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
 	VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	--> Atualiza status da rotina atual      
 	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);   
      
    --> RECUPERA PARÂMETROS DA CAMPANHA DESTAQUE
    PR_RECUPERA_PARM_APURACAO;
    VAR_LOG  := 'DATA DE APURAÇÃO: ' || TO_CHAR(VAR_DPROX_CARGA,'DD/MM/YYYY') ||
                ' -- ULTIMA DATA DE APURAÇÃO: ' || TO_CHAR(VAR_DULT_APURC_DSTAQ,'DD/MM/YYYY');
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    VAR_LOG  := 'PRÊMIO DESTAQUE: ' || TO_CHAR(VAR_VPRMIO_DSTAQ) ;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 	
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
	-- 
    VAR_LOG  := 'INICIANDO PROCESSO DE APURAÇÃO DA META DA REGIONAL    ';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
	--
    PR_META_DIA_NOVO_CRRTR;
    --
    VAR_LOG  := 'TOTAL DE REGISTROS INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_PROC);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    --
    VAR_LOG  := 'TOTAL DE REGISTROS META CORRETOR NOVO INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_CRRTR_NOVO);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    --
    
    --> Tempo de processamento
    --W_TEMPO_PROC :=  ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
    --VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||  TO_CHAR(W_TEMPO_PROC) ;
	--PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);	
	
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

