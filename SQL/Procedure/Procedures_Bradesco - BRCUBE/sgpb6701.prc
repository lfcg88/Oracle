CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6701 IS
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 22/02/2007
--  AUTOR           : MONIQUE MARQUES - VALUE TEAM                              
--  PROGRAMA        : DWCO9002.SQL                                                                             
--  OBJETIVO        : MANUTEN��ES DW
--  ALTERA��ES      :                                                                                               
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
VAR_CROTNA                 	ARQ_TRAB.CROTNA%TYPE            := 'SGPB6701';
VAR_CTPO_ACSSO             	ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB          	ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB              	ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB            	DTRIO_TRAB.IDTRIO_TRAB%TYPE;

-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                  	PARM_CARGA.CPARM%TYPE           := 670;     
VAR_DINIC_ROTNA            	DATE                            := SYSDATE;

-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_PC	   			SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC';
VAR_ROTNA_PO 			  	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO';
VAR_ROTNA_PE	   	   		SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE';

-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - Termino normal, processos dependentes podem continuar.
-- 2 - Termino com alerta, processos dependentes podem continuar, 
--     e o log dever� ser encaminhado ao analista.
-- 3 - Termino com alerta grave, poss�vel erro de ambiente, 
--     o processo poder� ser reiniciado.
-- 4 - Termino com erro, o processo n�o deve prosseguir. 
--     O analista/DBA dever� ser notificado.
-- 5 - Termino com erro cr�tico, o processo n�o deve prosseguir. 
--     O analista/DBA dever� ser contactado imediatamente.
-- 6 - Termino com erro desconhecido. O processo n�o deve continuar. 
--     Analista dever� ser contatado.
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
PROCEDURE PREENCHE_GRP_RGNAL_DSTAQ_RAMO IS
BEGIN

 -- CARGA NA TABELA - GRP_RGNAL_DSTAQ  (Campanha 200802)        
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 7106, 'A', SYSDATE, NULL);     
       
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 4103, 'A', SYSDATE, NULL);    
       
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 7103, 'B', SYSDATE, NULL);    
      
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 4105, 'B', SYSDATE, NULL);    
       
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 2101, 'C', SYSDATE, NULL);    
       
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 4106, 'C', SYSDATE, NULL);         
      
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 2102, 'D', SYSDATE, NULL);    
  
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 7201, 'D', SYSDATE, NULL);  
       
       INSERT INTO GRP_RGNAL_DSTAQ(CCAMPA_DSTAQ, CRGNAL, CGRP_RGNAL, DINCL_REG, DALT_REG)
                          VALUES(200801, 7202, 'D', SYSDATE, NULL);  

	   commit;
	                             
    -- CARGA NA TABELA - GRP_RAMO_CAMPA_DSTAQ  (Campanha 200802) 
       INSERT INTO GRP_RAMO_CAMPA_DSTAQ (CCAMPA_DSTAQ, CRAMO, CGRP_RAMO_DSTAQ, DINCL_REG, DALT_REG)
               SELECT 200801, CRAMO, CGRP_RAMO_DSTAQ, DINCL_REG, DALT_REG
                FROM GRP_RAMO_CAMPA_DSTAQ GRCD
               WHERE GRCD.CCAMPA_DSTAQ = 1;    

       	COMMIT;    

EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A PREENCHE_GRP_RGNAL_DSTAQ_RAMO : '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END PREENCHE_GRP_RGNAL_DSTAQ_RAMO;
/* ***************************************************************** */
PROCEDURE PREENCHE_PARM_HIERQ_DSTAQ IS
BEGIN


-- CARGA NA TABELA - PARM_HIERQ_DSTAQ  (Campanha 200802)        
       INSERT INTO PARM_HIERQ_DSTAQ(CCAMPA_DSTAQ, CPARM_HIERQ_DSTAQ, CCANAL_PROD_DW,
                   IPARM_HIERQ_DSTAQ, CIND_REG_ATIVO, DINCL_REG, DALT_REG)
                          VALUES(200801, 1, 3, 'CAMPANHA/CANAL/GRUPO REGIONAL/REGIONAL/CNPJ', 'S', SYSDATE, NULL);     
       
       INSERT INTO PARM_HIERQ_DSTAQ(CCAMPA_DSTAQ, CPARM_HIERQ_DSTAQ, CCANAL_PROD_DW,
                   IPARM_HIERQ_DSTAQ, CIND_REG_ATIVO, DINCL_REG, DALT_REG)
                          VALUES(200801, 2, 4, 'CAMPANHA/CANAL/GRUPO REGIONAL/REGIONAL/BCO/AGENCIA', 'S', SYSDATE, NULL);       
       
       INSERT INTO PARM_HIERQ_DSTAQ(CCAMPA_DSTAQ, CPARM_HIERQ_DSTAQ, CCANAL_PROD_DW,
                   IPARM_HIERQ_DSTAQ, CIND_REG_ATIVO, DINCL_REG, DALT_REG)
                          VALUES(200801, 3, 4, 'CAMPANHA/CANAL/GRUPO REGIONAL/REGIONAL/CNPJ', 'S', SYSDATE, NULL);   
       
       INSERT INTO PARM_HIERQ_DSTAQ(CCAMPA_DSTAQ, CPARM_HIERQ_DSTAQ, CCANAL_PROD_DW,
                   IPARM_HIERQ_DSTAQ, CIND_REG_ATIVO, DINCL_REG, DALT_REG)
                          VALUES(200801, 4, 8, 'CAMAPANHA/CANAL/GRUPO FINASA/CNPJ', 'S', SYSDATE, NULL);       
       
            
       COMMIT;   

EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A PREENCHE_PARM_HIERQ_DSTAQ : '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END PREENCHE_PARM_HIERQ_DSTAQ;
/* ***************************************************************** */
PROCEDURE PREENCHE_CAMPA_PCARGA_DSTAQ IS
BEGIN
	
	    -- CARGA NA TABELA - CAMPA_PARM_CARGA_DSTAQ ( campanha 200802)
       INSERT INTO CAMPA_PARM_CARGA_DSTAQ(CCAMPA_DSTAQ,CPARM_CARGA_DSTAQ,CCONTD_PARM_CARGA,IROTNA_ATULZ_PARM_CARGA,DINCL_REG,DALT_REG)
	                  VALUES(200801, 4, 30000, 'SGPB6701', SYSDATE, NULL);

       INSERT INTO CAMPA_PARM_CARGA_DSTAQ(CCAMPA_DSTAQ,CPARM_CARGA_DSTAQ,CCONTD_PARM_CARGA,IROTNA_ATULZ_PARM_CARGA,DINCL_REG,DALT_REG)
	                  VALUES(200801, 5, 9000, 'SGPB6701', SYSDATE, NULL);

        INSERT INTO CAMPA_PARM_CARGA_DSTAQ(CCAMPA_DSTAQ,CPARM_CARGA_DSTAQ,CCONTD_PARM_CARGA,IROTNA_ATULZ_PARM_CARGA,DINCL_REG,DALT_REG)
	                  VALUES(200801, 6, 20000, 'SGPB6701', SYSDATE, NULL);
        
        INSERT INTO CAMPA_PARM_CARGA_DSTAQ(CCAMPA_DSTAQ,CPARM_CARGA_DSTAQ,CCONTD_PARM_CARGA,IROTNA_ATULZ_PARM_CARGA,DINCL_REG,DALT_REG)
	                  VALUES(200801, 7, 12000, 'SGPB6701', SYSDATE, NULL);                   
			
		COMMIT;
    

EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A  PREENCHE_CAMPA_PCARGA_DSTAQ: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END PREENCHE_CAMPA_PCARGA_DSTAQ;
/* ***************************************************************** */
PROCEDURE PREENCHE_PARM_CARGA_DSTAQ IS
BEGIN

	    -- CARGA NA TABELA - PARM_CARGA_DSTAQ 
                                                      
       INSERT INTO PARM_CARGA_DSTAQ ( CPARM_CARGA_DSTAQ,IPARM_CARGA_DSTAQ,RPARM_CARGA_DSTAQ,DINCL_REG, DALT_REG)
                            VALUES(6,'Valor da Produc?o Minima do Auto - Banco',  
                                     'Valor da Produc?o Minima do Auto - Banco',SYSDATE,NULL); 

       INSERT INTO PARM_CARGA_DSTAQ ( CPARM_CARGA_DSTAQ,IPARM_CARGA_DSTAQ,RPARM_CARGA_DSTAQ,DINCL_REG, DALT_REG) 
                          VALUES(7,'Valor da Produc�o Minima do RE - Banco',  
                                   'Valor da Produc�o Minima do RE - Banco',SYSDATE,NULL); 

       INSERT INTO PARM_CARGA_DSTAQ ( CPARM_CARGA_DSTAQ,IPARM_CARGA_DSTAQ,RPARM_CARGA_DSTAQ,DINCL_REG, DALT_REG) 
                          VALUES(8,'Bloqueio CPF',  
                                   'Bloqueio CPF',SYSDATE,NULL); 
                                   
    			
	   COMMIT;                                                   
  

EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A PREENCHE_PARM_CARGA_DSTAQ : '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END PREENCHE_PARM_CARGA_DSTAQ;
/* ***************************************************************** */
PROCEDURE PREENCHE_CAMPA_DSTAQ IS
BEGIN

	   -- CARGA NA TABELA - CAMPA_DSTAQ                                           
       INSERT INTO CAMPA_DSTAQ(
       CCAMPA_DSTAQ, ICAMPA_DSTAQ, 
       CIND_DEB_CUPOM, VPRMIO_DSTAQ, 
       VPERC_PRMIO_PCIAL,CIND_CAMPA_ATIVO,
       DAPURC_DSTAQ, DINIC_CAMPA_DSTAQ, 
       DFIM_CAMPA_DSTAQ,CIND_CUPOM_PROML, 
       CIND_PRMIO_PCIAL, CIND_SITE_ATIVO,
       CFAIXA_INIC_DSMTO_CRRTR,CFAIXA_FNAL_DSMTO_CRRTR,
       VMETA_MIN_RE,VMETA_MIN_AUTO,
       DINCL_REG, DALT_REG)

       VALUES(200801,'CAMPANHA DESTAQUE DA PRODUCAO AUTO RE',
       'N',7000,
       80,'S',
       '01/01/2008','01/01/2008',
       '31/03/2008','N',
       'N','S',
       800000,879999,
       9000,30000,
       SYSDATE, NULL);
        
       COMMIT;


EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A  PREENCHE_CAMPA_DSTAQ: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END PREENCHE_CAMPA_DSTAQ;
/* ***************************************************************** */
PROCEDURE ALTERA_CAMPA_DSTAQ IS
BEGIN

	   -- CARGA NA TABELA - CAMPA_DSTAQ                                           
       UPDATE CAMPA_DSTAQ
		SET CIND_CAMPA_ATIVO = 'N'
		WHERE CCAMPA_DSTAQ = 2;
       
       COMMIT;


EXCEPTION
	WHEN OTHERS THEN
		VAR_LOG  := 'ERRO AO PREENCHER A  ALTERA_CAMPA_DSTAQ: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
		ROLLBACK;
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        VAR_CSIT_CTRLM := 2;
END ALTERA_CAMPA_DSTAQ;

/* ***************************************************************** */
PROCEDURE EXECUTA_SCRIPT IS
BEGIN

	VAR_LOG := 'INICIO DA CARGA DAS PREENCHE_CAMPA_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	 
   	PREENCHE_CAMPA_DSTAQ; 
   	
   	COMMIT;

	VAR_LOG := 'INICIO DA CARGA DAS ALTERA_CAMPA_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	   	
   	ALTERA_CAMPA_DSTAQ;
   	
   	COMMIT;
   	   	
   	VAR_LOG := 'INICIO DA CARGA DAS PREENCHE_PARM_CARGA_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	 
   	PREENCHE_PARM_CARGA_DSTAQ; 
   	
   	COMMIT;
   	
   	VAR_LOG := 'INICIO DA CARGA DAS PREENCHE_CAMPA_PARM_CARGA_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	 
   	PREENCHE_CAMPA_PCARGA_DSTAQ; 
   	
   	COMMIT;
   	
   	VAR_LOG := 'INICIO DA CARGA DAS PREENCHE_PARM_HIERQ_DSTAQ.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	 
   	PREENCHE_PARM_HIERQ_DSTAQ; 
   	
   	COMMIT;
   	
   	VAR_LOG := 'INICIO DA CARGA DAS PREENCHE_GRP_RGNAL_DSTAQ_RAMO.';
   	PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	COMMIT;
   	 
   	PREENCHE_GRP_RGNAL_DSTAQ_RAMO; 
   	
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
        
END SGPB6701;
/

