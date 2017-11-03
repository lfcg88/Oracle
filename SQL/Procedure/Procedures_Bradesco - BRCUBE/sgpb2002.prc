CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB2002 IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 24/02/2008
--      AUTOR           : FABIO GIGLIO - VALUE TEAM
--      PROGRAMA        : SGPB2002.SQL
--      OBJETIVO        : CARGA MENSAL MARGEM CONTRIBUI��O AGRUPAMENTO ECON�MICO CORRETOR
--      ALTERA��ES      : 
--                DATA  : 28/02/2007 
--                AUTOR : MONIQUE MARQUES - VALUE TEAM
--                OBS   : PARA REGISTROS JA EXISTENTES NA BASE, FAZER UPDATE
--                DATA  : 
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
--
-- VARIAVEIS DE TRABALHO         
--
VAR_ERRO 		   			VARCHAR2(1) 				   		:= 'N';
VAR_TABELA	   				VARCHAR2(30) 				   		:= 'MARGM_CONTB_AGPTO_ECONM_CRRTR';
VAR_LOG                    	LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO           	LOG_CARGA.CTPO_REG_LOG%TYPE     	:= 'P'; 
VAR_LOG_DADO               	LOG_CARGA.CTPO_REG_LOG%TYPE    		:= 'D'; 
VAR_CSIT_CTRLM         		SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_TOT_REG_LIDO  			NUMBER(9)					  		:= 0;
VAR_TOT_REG_GRAV           	NUMBER(9)					 		:= 0;
VAR_FIM_PROCESSO_ERRO      	EXCEPTION;
--
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
W_HORA_PROC_INICIAL         DATE  				   			    := SYSDATE;
W_TEMPO_PROC                NUMBER;
--    
--                        
-- VARIAVEIS PARA ABERTURA E MANIPULA��O DO ARQUIVO              
--
VAR_ARQUIVO                	UTL_FILE.FILE_TYPE;                   
VAR_REGISTRO_ARQUIVO       	VARCHAR2(500);
--                         	VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE                    
VAR_CAMBTE                 	ARQ_TRAB.CAMBTE%TYPE;
VAR_CSIST                  	ARQ_TRAB.CSIST%TYPE   	   			:= 'SGPB'; 
VAR_CROTNA                 	ARQ_TRAB.CROTNA%TYPE        	    := 'SGPB2002';
--
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE    	    := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE 	    := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
--
-- VARIAVEIS DO PARAMETRO DE CARGA
--
VAR_CPARM                  PARM_CARGA.CPARM%TYPE       		    := 735;
VAR_DCARGA                 PARM_CARGA.DCARGA%TYPE;            
VAR_DPROX_CARGA            PARM_CARGA.DPROX_CARGA%TYPE;       
VAR_DINIC_ROTNA            DATE               					:= SYSDATE;
--
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
--
VAR_ROTNA_AP		       ROTNA.CSIT_ROTNA%TYPE	   			:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	       ROTNA.CSIT_ROTNA%TYPE	 			:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		       ROTNA.CSIT_ROTNA%TYPE	 			:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	       ROTNA.CSIT_ROTNA%TYPE	  			:= 'PE'; -- PROCESSADO COM ERRO
VAR_STATUS_ROTNA	       ROTNA.CSIT_ROTNA%TYPE;
--
-- VARIAVEL REFERENTE A TABELA ALVO 
--
WROW                       MARGM_CONTB_AGPTO_ECONM_CRRTR%ROWTYPE;
--
-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - T�rmino normal, processos dependentes podem continuar.
-- 2 - T�rmino com alerta, processos dependentes podem continuar,
--      e o log dever� ser encaminhado ao analista.
-- 3 - T�rmino com alerta grave, poss�vel erro de ambiente, 
--     o processo poder� ser reiniciado.
-- 4 - T�rmino com erro, o processo n�o deve prosseguir. 
--     O analista/DBA dever� ser notificado.
-- 5 - T�rmino com erro cr�tico, o processo n�o deve prosseguir. 
--     O analista/DBA dever� ser contactado imediatamente.
-- 6 - T�rmino com erro desconhecido. O processo n�o deve continuar. 
--     O analista dever� ser contactado.
--
/* ***************************************************************** */
--      
PROCEDURE TRATA_PARAMETRO IS
--          
BEGIN
--     
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;   
--        
   IF VAR_CAMBTE NOT IN ('DESV', 'PROD') THEN
--   
      VAR_CSIT_CTRLM 	:= 6;
--      
   	  VAR_LOG := 'PAR�METRO INV�LIDO. AMBIENTE INFORMADO NO PAR�METRO: ' || VAR_CAMBTE;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      RAISE VAR_FIM_PROCESSO_ERRO;
--   
   END IF;
--
   VAR_LOG := 'PAR�METRO DE AMBIENTE INFORMADO: ' || VAR_CAMBTE;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--    
EXCEPTION
   WHEN OTHERS THEN
--   
        VAR_CSIT_CTRLM 	:= 6;
--      
        VAR_LOG  := 'ERRO NO TRATA PAR�METRO. -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        RAISE VAR_FIM_PROCESSO_ERRO;
--  
END TRATA_PARAMETRO;
--   
/* ***************************************************************** */
--
PROCEDURE ABRE_ARQUIVO IS
BEGIN
--
   BEGIN
      PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                            VAR_CSIST,
                            VAR_CROTNA,
                            VAR_CTPO_ACSSO, 
                            VAR_CSEQ_ARQ_TRAB, 
                            VAR_IDTRIO_TRAB, 
                            VAR_IARQ_TRAB );
--
      VAR_LOG := 'DIRET�RIO: '  || VAR_IDTRIO_TRAB ||
                 ' -- ARQUIVO: '    || VAR_IARQ_TRAB;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      VAR_LOG := 'ABRINDO ARQUIVO DE CARGA.';
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB, VAR_CTPO_ACSSO);
--
      IF NOT UTL_FILE.IS_OPEN(VAR_ARQUIVO) THEN 
--
         VAR_CSIT_CTRLM := 6;   
--
         VAR_LOG := 'ERRO NA ABERTURA DO ARQUIVO.'||
                    ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
         --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
         UTL_FILE.FCLOSE(VAR_ARQUIVO);
         RAISE VAR_FIM_PROCESSO_ERRO;
--
      END IF;
--
   EXCEPTION
      WHEN OTHERS THEN
--
           VAR_CSIT_CTRLM := 6;
--
           VAR_LOG := 'ERRO AO TENTAR ABRIR O ARQUIVO USANDO UTL_FILE.FOPEN.'||
                      ' -- DIRETORIO: '  || VAR_IDTRIO_TRAB ||
                      ' -- ARQUIVO: '    || VAR_IARQ_TRAB||
                      ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
           --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
           RAISE VAR_FIM_PROCESSO_ERRO;
--
   END;
--
   -- RECUPERA OS DADOS DE PAR�METRO DE CARGA
   PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_LOG := 'DATA DA �LTIMA CARGA: ' || TO_CHAR(VAR_DCARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                                           
--      
   VAR_LOG := 'DATA DA PR�XIMA CARGA: ' || TO_CHAR(VAR_DPROX_CARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;   
--
EXCEPTION
   WHEN OTHERS THEN
--
        VAR_CSIT_CTRLM := 6;
        VAR_LOG  := 'ERRO NO ABRE_ARQUIVO. -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END ABRE_ARQUIVO;
--
/* ***************************************************************** */
--
PROCEDURE FECHA_ARQUIVO IS
BEGIN
--
   VAR_LOG := 'FECHANDO ARQUIVO DE CARGA.';
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255)); 
--
   UTL_FILE.FCLOSE( VAR_ARQUIVO);
--  
EXCEPTION
   WHEN OTHERS THEN
--   
        VAR_CSIT_CTRLM 	:= 6;
--      
        VAR_LOG  := 'ERRO NO FECHA_ARQUIVO. -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        UTL_FILE.FCLOSE( VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END FECHA_ARQUIVO;
--
/* ***************************************************************** */
--
PROCEDURE CARREGA_DETALHE IS
--
--   
BEGIN
--
 VAR_ERRO	:= 'N';
 --             
 WROW 		:= NULL;
--
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR	:= SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1);
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR	:= NULL;
      VAR_CSIT_CTRLM 	  				:= 5;
      VAR_ERRO 	     	  				:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CTPO_PSSOA_AGPTO_ECONM_CRRTR DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||              
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||                                                  
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR	:= NULL;
      VAR_CSIT_CTRLM 	  				:= 5;
      VAR_ERRO 	     	  				:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CCPF_CNPJ_AGPTO_ECONM_CRRTR DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN

   WROW.PMARGM_CONTB		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 11, 7))/100;
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.PMARGM_CONTB		:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CCPF_CNPJ_AGPTO_ECONM_CRRTR DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||
                 ' -- PMARGM_CONTB: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 11, 7)||                 
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--   
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CCANAL_VDA_SEGUR	:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CCANAL_VDA_SEGUR	:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	 	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR IAGPTO_ECONM_CRRTR DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||               
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CCOMPT_MARGM		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CCOMPT_MARGM		:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR RAGPTO_ECONM_CRRTR DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||             
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CRESP_ULT_ALT		:= SUBSTR(VAR_REGISTRO_ARQUIVO, 25, 50);
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CRESP_ULT_ALT	:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CRESP_ULT_ALT DO ARQUIVO.'||
                 ' -- CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 1)||
                 ' -- CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 2, 9)||
                 ' -- CCANAL_VDA_SEGUR: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 18, 1)||
                 ' -- CCOMPT_MARGM: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 19, 6)||
                 ' -- CRESP_ULT_ALT: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 25, 50)||                                  
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   SELECT DINIC_AGPTO_ECONM_CRRTR 
     INTO WROW.DINIC_AGPTO_ECONM_CRRTR
     FROM AGPTO_ECONM_CRRTR
    WHERE CTPO_PSSOA_AGPTO_ECONM_CRRTR = WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR
      AND CCPF_CNPJ_AGPTO_ECONM_CRRTR  = WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR
      AND DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL;
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
          VAR_ERRO          		   := 'S';
          WROW.DINIC_AGPTO_ECONM_CRRTR := NULL;
          VAR_CSIT_CTRLM 	  		   := 5;               
          VAR_LOG  := 'ERRO NA SELE��O DA COLUNA DINIC_AGPTO_ECONM_CRRTR NA TABELA SGPG.AGPTO_ECONM_CRRTR'||
                      ' N�O FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
                      ' - CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR||
	                  ' - CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||TO_CHAR(WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR)||
                      ' - DFIM_VGCIA_AGPTO_ECONM_CRRTR NULO.';
          PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
          --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255)); 
     WHEN TOO_MANY_ROWS THEN
          VAR_ERRO          		   := 'S';
          WROW.DINIC_AGPTO_ECONM_CRRTR := NULL;
          VAR_CSIT_CTRLM 	  		   := 5;  
          VAR_LOG  := 'ERRO NA SELE��O DA COLUNA DINIC_AGPTO_ECONM_CRRTR NA TABELA SGPG.AGPTO_ECONM_CRRTR'||
                      ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
                      ' - CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR||
		              ' - CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||TO_CHAR(WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR)||
                      ' - DFIM_VGCIA_AGPTO_ECONM_CRRTR NULO.';
          PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
          --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                      
     WHEN OTHERS THEN
          VAR_ERRO          			 := 'S';
          WROW.DINIC_AGPTO_ECONM_CRRTR := NULL;
          VAR_CSIT_CTRLM 	  			 := 5; 
          VAR_LOG  := 'ERRO NA SELE��O DA COLUNA DINIC_AGPTO_ECONM_CRRTR NA TABELA SGPG.AGPTO_ECONM_CRRTR'||
                      ' COM AS COLUNAS'||
                      ' - CTPO_PSSOA_AGPTO_ECONM_CRRTR: '||WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR||
		              ' - CCPF_CNPJ_AGPTO_ECONM_CRRTR: '||TO_CHAR(WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR)||
                      ' - DFIM_VGCIA_AGPTO_ECONM_CRRTR NULO.'||
                      ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
          PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
          --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                       
 END;
/*---------------------------------------------------------------------------------------------*/
--
 BEGIN
--
  IF VAR_ERRO = 'N' THEN
  BEGIN
     INSERT INTO MARGM_CONTB_AGPTO_ECONM_CRRTR
          ( CTPO_PSSOA_AGPTO_ECONM_CRRTR,            
		    CCPF_CNPJ_AGPTO_ECONM_CRRTR,		    
		    DINIC_AGPTO_ECONM_CRRTR,
			CCANAL_VDA_SEGUR,
			CCOMPT_MARGM,
			PMARGM_CONTB,
		    CRESP_ULT_ALT,		    
            DINCL_REG,
            DALT_REG	 
          ) 
     VALUES
          ( WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
            WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
		    WROW.DINIC_AGPTO_ECONM_CRRTR,		    
		    WROW.CCANAL_VDA_SEGUR,
		    WROW.CCOMPT_MARGM,
		    WROW.PMARGM_CONTB,            
		    WROW.CRESP_ULT_ALT,
            SYSDATE,
            NULL
          );
  EXCEPTION
  	WHEN DUP_VAL_ON_INDEX THEN
  		UPDATE MARGM_CONTB_AGPTO_ECONM_CRRTR
  		SET  PMARGM_CONTB	= WROW.PMARGM_CONTB
  			,CRESP_ULT_ALT	= WROW.CRESP_ULT_ALT
  			,DALT_REG		= SYSDATE
  		WHERE CTPO_PSSOA_AGPTO_ECONM_CRRTR	= WROW.CTPO_PSSOA_AGPTO_ECONM_CRRTR
  		  AND CCPF_CNPJ_AGPTO_ECONM_CRRTR	= WROW.CCPF_CNPJ_AGPTO_ECONM_CRRTR
  		  AND DINIC_AGPTO_ECONM_CRRTR		= WROW.DINIC_AGPTO_ECONM_CRRTR
  		  AND CCANAL_VDA_SEGUR				= WROW.CCANAL_VDA_SEGUR
  		  AND CCOMPT_MARGM 	  				= WROW.CCOMPT_MARGM;
  	WHEN OTHERS THEN
  		VAR_LOG := 'ERRO NO INSERT/UPDATE DOS DADOS DA TABELA ' || VAR_TABELA ||
                    ' -- LINHA DO REGISTRO: '|| SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 74)||      	   
                    ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
	     PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);	  		  
  END;       
     VAR_TOT_REG_GRAV := VAR_TOT_REG_GRAV + 1;
--      
  END IF;
--         
 EXCEPTION
    WHEN OTHERS THEN 
         VAR_LOG := 'ERRO NO INSERT DOS DADOS DA TABELA ' || VAR_TABELA ||
                    ' -- LINHA DO REGISTRO: '|| SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 74)||      	   
                    ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
	     PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
         --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
         VAR_CSIT_CTRLM := 5;
         VAR_ERRO 	    := 'S';
--
 END;        
--
EXCEPTION
--
   WHEN OTHERS THEN     
--   
        VAR_CSIT_CTRLM 	:= 6;
--  
        VAR_LOG := 'ERRO NO SUB-PROGRAMA DE CARGA DOS DADOS DA TABELA ' ||VAR_TABELA||
                   ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END CARREGA_DETALHE;   
--
/* ***************************************************************** */
--      
PROCEDURE TRATA_BODY IS 
--
VAR_COUNT	NUMBER(10) := 0;
--   
BEGIN
--
   VAR_LOG := 'DADOS DO ARQUIVO DE CARGA. INICIANDO TRATAMENTO DO BODY.';
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--   
   VAR_TOT_REG_LIDO := 0;
   VAR_TOT_REG_GRAV := 0;
--      
   LOOP    
      BEGIN
--
         UTL_FILE.GET_LINE( VAR_ARQUIVO, VAR_REGISTRO_ARQUIVO);
--
      EXCEPTION
         WHEN NO_DATA_FOUND THEN  -- FIM DE ARQUIVO
	          IF VAR_TOT_REG_LIDO = 0 THEN
	  	         VAR_ERRO := 'S';
	          END IF;
              EXIT;
      END;
--            
      VAR_TOT_REG_LIDO := VAR_TOT_REG_LIDO + 1;
--
      CARREGA_DETALHE;
--
      IF VAR_ERRO = 'S' THEN
         EXIT;      
      END IF;         
--   
   END LOOP;
--
   IF VAR_ERRO = 'N' THEN
      COMMIT;
   ELSIF VAR_TOT_REG_LIDO <> 0 THEN
      COMMIT;
      VAR_LOG := 'ERRO NA LEITURA DO ARQUIVO N�O SER� POSSIVEL PROSSEGUIR O PROCESSAMENTO.';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      FECHA_ARQUIVO;
      RAISE VAR_FIM_PROCESSO_ERRO;
   ELSE
      VAR_LOG := 'ERRO. ARQUIVO VAZIO';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	  --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
	  COMMIT;
	  VAR_CSIT_CTRLM := 5;   
      FECHA_ARQUIVO;      
      RAISE VAR_FIM_PROCESSO_ERRO;   
   END IF;
--   
   FECHA_ARQUIVO;
--                         
EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
   		RAISE VAR_FIM_PROCESSO_ERRO;
   WHEN OTHERS THEN
--   
        VAR_CSIT_CTRLM  := 6;
--   
        VAR_LOG := 'ERRO NO TRATA_BODY. LINHA DO REGISTRO: '||SUBSTR( VAR_REGISTRO_ARQUIVO, 1, 74)||
                   ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	    --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--    
        UTL_FILE.FCLOSE( VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;
--   
END TRATA_BODY;
--    
-----------------  PROGRAMA PRINCIPAL  -----------------------------
--
BEGIN
--     
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   -- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA);
--       
   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DA TABELA ' || VAR_TABELA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   -- A SITUACAO DA ROTINA ATUAL DEVE SER MARCADA COMO 'PC'
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
--
   VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
   VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   -- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA
   --  COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   VAR_CSIT_CTRLM := 1;
--                                
   VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '||VAR_CSIT_CTRLM;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--
   -- TRATA O PARAMETRO DO PROCESSO 
   TRATA_PARAMETRO; 	-- PROCEDURE INTERNA (SUB-PROGRAMA)  
--     
   -- VERIFICA INFORMACOES DO HEADER
   ABRE_ARQUIVO;	-- PROCEDURE INTERNA (SUB-PROGRAMA)
--     
   -- PROCESSA ARQUIVO (CARREGA A TABELA TEMPORARIA)
   TRATA_BODY;		-- PROCEDURE INTERNA (SUB-PROGRAMA)   
--
   -- TEMPO DE PROCESSAMENTO
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--                   
   IF VAR_CSIT_CTRLM = 1 THEN 

      VAR_LOG := 'TOTAL DE REGISTROS  LIDOS  DO  ARQUIVO: '||
        	      TO_CHAR(VAR_TOT_REG_LIDO);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
      VAR_LOG := 'TOTAL DE REGISTROS INSERIDOS NA TABELA: '||
                  TO_CHAR(VAR_TOT_REG_GRAV);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));             
--                                   
      -- ATUALIZA STATUS TERMINO DA ROTINA  
      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
--
      VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
      VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). '||
                 'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--      
      -- GRAVA A SITUACAO DESTE PROCESSO NA TABELA DE CONTROLE DO CTRLM   
      PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA, 
                                VAR_CROTNA     , 
                                SYSDATE        , -- DFIM_ROTNA
                                NULL           , -- IPROG
                                NULL           , -- CERRO
                                VAR_LOG        , -- RERRO
                                VAR_CSIT_CTRLM             );           
--      
   ELSE
      RAISE VAR_FIM_PROCESSO_ERRO;                
   END IF;
--           
EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
--                                       
        IF VAR_CSIT_CTRLM <> 5 THEN  
           VAR_CSIT_CTRLM := 6; 
        END IF;
--           
        VAR_LOG := 'TOTAL DE REGISTROS  LIDOS  DO  ARQUIVO: '||
        	      TO_CHAR(VAR_TOT_REG_LIDO);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        VAR_LOG := 'TOTAL DE REGISTROS INSERIDOS NA TABELA: '||
                  TO_CHAR(VAR_TOT_REG_GRAV);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));        
--
        -- ATUALIZA STATUS TERMINO DA ROTINA  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
--
        VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = ' || VAR_CSIT_CTRLM || 
                   ' ). OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
   	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   	    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                              	   VAR_CROTNA     , 
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );        
--
   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;
--        
        VAR_LOG := 'TOTAL DE REGISTROS  LIDOS  DO  ARQUIVO: '||
        	      TO_CHAR(VAR_TOT_REG_LIDO);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        VAR_LOG := 'TOTAL DE REGISTROS INSERIDOS NA TABELA: '||
                  TO_CHAR(VAR_TOT_REG_GRAV);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));        
--              
        VAR_LOG := 'EXCEPTION OTHERS -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--              
        -- ATUALIZA STATUS TERMINO DA ROTINA  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
--
        VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = 6). '|| 
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '				||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
   	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   	    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                              	   VAR_CROTNA     , 
                                   SYSDATE        , -- DFIM_ROTNA
                                   NULL           , -- IPROG
                                   NULL           , -- CERRO
                                   VAR_LOG        , -- RERRO
                                   VAR_CSIT_CTRLM             );        
--
END SGPB2002;
/

