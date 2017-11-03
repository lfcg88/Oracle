CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6117 IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 24/02/2008
--      AUTOR           : FABIO GIGLIO - VALUE TEAM
--      PROGRAMA        : SGPB6117.SQL
--      OBJETIVO        : CARGA DAS TABELAS HIERQ_PBLIC_ALVO E META_DSTAQ PARA
--                        CANAL DE PRODUÇÃO 4 (BANCO) SEM INFORMAÇÃO DE CAG_BCRIA E CBCO
--      ALTERAÇÕES      : 
--                DATA  : 
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
--
-- VARIAVEIS DE TRABALHO         
--
VAR_ERRO 		   			VARCHAR2(1) 				   		:= 'N';
VAR_TABELA	   				VARCHAR2(30) 				   		:= 'META_DSTAQ';
VAR_TABELA_H   				VARCHAR2(30) 				   		:= 'HIERQ_PBLIC_ALVO';
VAR_TABELA_P   				VARCHAR2(30) 				   		:= 'POSIC_DSTAQ';
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
-- VARIAVEIS PARA ABERTURA E MANIPULAÇÃO DO ARQUIVO              
--
VAR_ARQUIVO                	UTL_FILE.FILE_TYPE;                   
VAR_REGISTRO_ARQUIVO       	VARCHAR2(500);
--                         	VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE                    
VAR_CAMBTE                 	ARQ_TRAB.CAMBTE%TYPE;
VAR_CSIST                  	ARQ_TRAB.CSIST%TYPE   	   			:= 'SGPB'; 
VAR_CROTNA                 	ARQ_TRAB.CROTNA%TYPE        	    := 'SGPB6117';
--
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE    	    := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE 	    := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
--
-- VARIAVEIS DO PARAMETRO DE CARGA
--
VAR_CPARM                  PARM_CARGA.CPARM%TYPE       		    := 754;
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
WROW                       		META_DSTAQ%ROWTYPE;
--
VAR_CTPO_PSSOA		 	   		HIERQ_PBLIC_ALVO.CTPO_PSSOA%TYPE;
VAR_CCPF_CNPJ_BASE		   		HIERQ_PBLIC_ALVO.CCPF_CNPJ_BASE%TYPE;
VAR_DAPURC_DSTAQ                META_DSTAQ.DAPURC_DSTAQ%TYPE;
VAR_ERRO_CARGA                  LOG_CARGA.RLOG%TYPE;
--
--
-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - Término normal, processos dependentes podem continuar.
-- 2 - Término com alerta, processos dependentes podem continuar,
--      e o log deverá ser encaminhado ao analista.
-- 3 - Término com alerta grave, possível erro de ambiente, 
--     o processo poderá ser reiniciado.
-- 4 - Término com erro, o processo não deve prosseguir. 
--     O analista/DBA deverá ser notificado.
-- 5 - Término com erro crítico, o processo não deve prosseguir. 
--     O analista/DBA deverá ser contactado imediatamente.
-- 6 - Término com erro desconhecido. O processo não deve continuar. 
--     O analista deverá ser contactado.
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
   	  VAR_LOG := 'PARÂMETRO INVÁLIDO. AMBIENTE INFORMADO NO PARÂMETRO: ' || VAR_CAMBTE;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      RAISE VAR_FIM_PROCESSO_ERRO;
--   
   END IF;
--
   VAR_LOG := 'PARÂMETRO DE AMBIENTE INFORMADO: ' || VAR_CAMBTE;
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
        VAR_LOG  := 'ERRO NO TRATA PARÂMETRO. -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
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
      VAR_LOG := 'DIRETÓRIO: '  || VAR_IDTRIO_TRAB ||
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
   -- RECUPERA OS DADOS DE PARÂMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_LOG := 'DATA DA ÚLTIMA CARGA: ' || TO_CHAR(VAR_DCARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                                           
--      
   VAR_LOG := 'DATA DA PRÓXIMA CARGA: ' || TO_CHAR(VAR_DPROX_CARGA, 'DD/MM/YYYY');
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
   WROW.CCAMPA_DSTAQ		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CCAMPA_DSTAQ		:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CCAMPA_DSTAQ DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CPARM_HIERQ_DSTAQ		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CPARM_HIERQ_DSTAQ	:= NULL;
      VAR_CSIT_CTRLM 	  		:= 5;
      VAR_ERRO 	     	  		:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CPARM_HIERQ_DSTAQ DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   WROW.CCANAL_PROD_DW		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2));
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.CCANAL_PROD_DW	:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CCANAL_PROD_DW DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   VAR_CTPO_PSSOA	 		:= SUBSTR(VAR_REGISTRO_ARQUIVO, 11, 1);
 EXCEPTION
   WHEN OTHERS THEN
--
      VAR_CTPO_PSSOA		:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CTPO_PSSOA DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- CTPO_PSSOA: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 11, 1)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN
   VAR_CCPF_CNPJ_BASE 		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 12, 9));
 EXCEPTION
   WHEN OTHERS THEN
--
      VAR_CCPF_CNPJ_BASE	:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR CCPF_CNPJ_BASE DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- CCPF_CNPJ_BASE: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 12, 9)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN

   WROW.VMETA_AUTO		:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 21, 15))/100;
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.VMETA_AUTO		:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR VMETA_AUTO DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- VMETA_AUTO: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 21, 15)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--   
 END;
/*---------------------------------------------------------------------------------------------*/
 BEGIN

   WROW.VMETA_RE			:= TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 36, 15))/100;
 EXCEPTION
   WHEN OTHERS THEN
--
      WROW.VMETA_RE			:= NULL;
      VAR_CSIT_CTRLM 	  	:= 5;
      VAR_ERRO 	     	  	:= 'S';
--
      VAR_LOG := 'PROBLEMA AO CARREGAR VMETA_RE DO ARQUIVO.'||
                 ' -- CCAMPA_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6)||
                 ' -- CPARM_HIERQ_DSTAQ: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 2)||
                 ' -- CCANAL_PROD_DW: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 9, 2)||
                 ' -- VMETA_RE: '||SUBSTR(VAR_REGISTRO_ARQUIVO, 36, 15)||
                 ' -- ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--   
 END;
/*---------------------------------------------------------------------------------------------*/
--
  IF VAR_ERRO = 'N' THEN
  	 BEGIN
  	   SELECT DINIC_CAMPA_DSTAQ 
         INTO VAR_DAPURC_DSTAQ
         FROM CAMPA_DSTAQ
   	    WHERE CCAMPA_DSTAQ = WROW.CCAMPA_DSTAQ;
     EXCEPTION          
       WHEN NO_DATA_FOUND THEN
            VAR_DAPURC_DSTAQ := NULL;
            VAR_CSIT_CTRLM   := 5;
            VAR_ERRO 		 := 'S';
	        VAR_LOG := 'DAPURC_DSTAQ(DINIC_CAMPA_DSTAQ) NÃO RECUPERADO DA TABELA CAMPA_DSTAQ.'||
                       ' -- CCAMPA_DSTAQ: '||TO_CHAR(WROW.CCAMPA_DSTAQ)||
                       ' -- ERRO: '||VAR_ERRO_CARGA;
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                      
       WHEN TOO_MANY_ROWS THEN
            VAR_CSIT_CTRLM   := 5;
            VAR_ERRO 		 := 'S';
	        VAR_LOG := 'RECUPERADA MAIS DE UMA DAPURC_DSTAQ(DINIC_CAMPA_DSTAQ) DA TABELA CAMPA_DSTAQ.'||
                       ' -- CCAMPA_DSTAQ: '||TO_CHAR(WROW.CCAMPA_DSTAQ)||
                       ' -- ERRO: '||VAR_ERRO_CARGA;
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
       WHEN OTHERS THEN
            VAR_CSIT_CTRLM   := 5;
            VAR_ERRO 		 := 'S';
	        VAR_LOG := 'ERRO NA RECUPERAÇÃO DA DAPURC_DSTAQ(DINIC_CAMPA_DSTAQ) DA TABELA CAMPA_DSTAQ.'||
                       ' -- CCAMPA_DSTAQ: '||TO_CHAR(WROW.CCAMPA_DSTAQ)||
                       ' -- ERRO: '||VAR_ERRO_CARGA;
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
     END;
  END IF;
--              
/*---------------------------------------------------------------------------------------------*/
-- CANAL DE PRODUÇÃO 4 (BANCO) SEM INFORMAÇÃO DE CAG_BCRIA E CBCO OU CANAL DE PRODUÇÃO 8 (FINASA)
  IF VAR_ERRO = 'N' THEN
     IF WROW.CCANAL_PROD_DW IN (4, 8) THEN
        -- PROCEDURE QUE INSERE LINHA NA TABELA HIERQ_PBLIC_ALVO E RECUPERA O CONTEÚDO DA COLUNA CHIERQ_PBLIC_ALVO_DSTAQ
        PR_CARREGA_HIERQ_PBLIC_ALVO(VAR_CROTNA,
								    WROW.CCANAL_PROD_DW,
								    WROW.CCAMPA_DSTAQ,
								    WROW.CPARM_HIERQ_DSTAQ,
								    VAR_CTPO_PSSOA,
								    VAR_CCPF_CNPJ_BASE,
								    NULL,
								    NULL,
								    NULL,
								    WROW.CHIERQ_PBLIC_ALVO_DSTAQ,
								    VAR_ERRO_CARGA);
--
        IF WROW.CHIERQ_PBLIC_ALVO_DSTAQ IS NULL THEN 
	       VAR_LOG  := 'CHIERQ_PBLIC_ALVO_DSTAQ NÃO RECUPERADO.'||
                       ' -- CCANAL_PROD_DW: '||TO_CHAR(WROW.CCANAL_PROD_DW)||
                       ' -- CCAMPA_DSTAQ: '||TO_CHAR(WROW.CCAMPA_DSTAQ)||
                       ' -- CPARM_HIERQ_DSTAQ: '||TO_CHAR(WROW.CPARM_HIERQ_DSTAQ)||
                       ' -- CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                       ' -- CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE)||
                       ' -- ERRO: '||VAR_ERRO_CARGA;
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
           --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
           VAR_CSIT_CTRLM 	:= 5;
           VAR_ERRO 		:= 'S';
        END IF;
--    CANAL DE PRODUÇÃO COM ERRO   
     ELSE
	    VAR_LOG  := 'CCANAL_PROD_DW COM ERRO, DIFERENTE DE 4 E 8: '||TO_CHAR(WROW.CCANAL_PROD_DW);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--     	      
        VAR_CSIT_CTRLM    	:= 5;
        VAR_ERRO 	       	:= 'S';        
     END IF;
  END IF;           
--
/*---------------------------------------------------------------------------------------------*/
--
 BEGIN
--
  IF VAR_ERRO = 'N' THEN
--
     INSERT INTO POSIC_DSTAQ
  	     		(CCANAL_PROD_DW,
  	     		 CCAMPA_DSTAQ,
				 CPARM_HIERQ_DSTAQ,
				 CHIERQ_PBLIC_ALVO_DSTAQ,
				 DAPURC_DSTAQ,
				 NRKING_PROD_RGNAL,
                 NRKING_PERC_CRSCT_RGNAL,
				 NRKING_PROD,
				 NRKING_PERC_CRSCT,
				 VPROD_AUTO,
				 VPROD_RE,
				 VPERC_CRSCT_AUTO,
				 VPERC_CRSCT_RE,
				 VPERC_CRSCT,
				 CIND_BLOQ_CAMPA,
				 CIND_FALTA_META,
				 DINCL_REG,
				 DALT_REG
	            )
    	 VALUES
    		    (WROW.CCANAL_PROD_DW,
    		     WROW.CCAMPA_DSTAQ,
				 WROW.CPARM_HIERQ_DSTAQ,
				 WROW.CHIERQ_PBLIC_ALVO_DSTAQ,
				 VAR_DAPURC_DSTAQ,
				 NULL,
				 NULL,
				 NULL,
				 NULL,
				 0,
				 0,
				 0,
				 0,
				 0,
				 NULL,
				 NULL,
				 SYSDATE,
				 NULL
    	    	);
--      
  END IF;
--         
 EXCEPTION
    WHEN OTHERS THEN 
         VAR_LOG := 'ERRO NO INSERT DOS DADOS DA TABELA ' || VAR_TABELA_P ||
                    ' -- LINHA DO REGISTRO: '|| SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 50)||      	   
                    ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
	     PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
         --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
         VAR_CSIT_CTRLM := 5;
         VAR_ERRO 	    := 'S';
--
 END;        
--
--
 BEGIN
--
  IF VAR_ERRO = 'N' THEN
--
     INSERT INTO META_DSTAQ
          ( CCANAL_PROD_DW,
            CCAMPA_DSTAQ,
			CPARM_HIERQ_DSTAQ,
			CHIERQ_PBLIC_ALVO_DSTAQ,
			DAPURC_DSTAQ,
			VMETA_AUTO,
			VMETA_RE,
			DINCL_REG,
			DALT_REG
          ) 
     VALUES
          ( WROW.CCANAL_PROD_DW,
            WROW.CCAMPA_DSTAQ,
		    WROW.CPARM_HIERQ_DSTAQ,		    
		    WROW.CHIERQ_PBLIC_ALVO_DSTAQ,
		    VAR_DAPURC_DSTAQ,
		    WROW.VMETA_AUTO,            
		    WROW.VMETA_RE,
            SYSDATE,
            NULL
          );
--       
     VAR_TOT_REG_GRAV := VAR_TOT_REG_GRAV + 1;
--      
  END IF;
--         
 EXCEPTION
    WHEN OTHERS THEN 
         VAR_LOG := 'ERRO NO INSERT DOS DADOS DA TABELA ' || VAR_TABELA ||
                    ' -- LINHA DO REGISTRO: '|| SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 50)||      	   
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
      VAR_LOG := 'ERRO NA LEITURA DO ARQUIVO NÃO SERÁ POSSIVEL PROSSEGUIR O PROCESSAMENTO.';
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
   WHEN OTHERS THEN
--   
        VAR_CSIT_CTRLM  := 6;
--   
        VAR_LOG := 'ERRO NO TRATA_BODY. LINHA DO REGISTRO: '||SUBSTR( VAR_REGISTRO_ARQUIVO, 1, 50)||
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
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DAS TABELAS ' || VAR_TABELA_H || ' E ' || VAR_TABELA;
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
END SGPB6117;
/

