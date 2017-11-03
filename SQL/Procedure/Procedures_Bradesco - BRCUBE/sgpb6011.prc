create or replace procedure sgpb_proc.SGPB6011 is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 11/10/2007
--  AUTOR           : ANDRE GUIMARÃES - VALUE TEAM                              
--  PROGRAMA        : SGPB6011.SQL                                                                             
--  OBJETIVO        : MANUTENÇÕES DW -- INSERE NAS TABELAS DE CAMPA_PARM_CARGA_DSTAQ
--  ALTERAÇÕES      : Acertos para campanha 3 , foi alterado VARIAVEIS DO PARAMETRO DE CARGA para 752  , realizado insert na tabela CAMPA_PARM_CARGA_DSTAQ                                                                                       
--            DATA  : 24/01/2008                                                                                             
--            AUTOR : - wellington P Medeirois - Valueteam                                                                                             
--            OBS   : -                                                                                                 
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO         
VAR_ERRO                    VARCHAR2(1)       := 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A'; 
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P'; 
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_FIM_PROCESSO_CRITICO    EXCEPTION;
--VAR_ORIGEM_GEN_CORP         ORIGE_DADO.CORIGE_DADO%TYPE  := 1; -- ORIGEM GENERICA DO SISTEMA CORPORATIVO
-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO              
VAR_CAMBTE                  ARQ_TRAB.CAMBTE%TYPE;           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             := 'SGPB'; 
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE            := 'SGPB6011';
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 752;     
VAR_DINIC_ROTNA             DATE                            := SYSDATE;
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_PC       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PC';
VAR_ROTNA_PO       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PO';
VAR_ROTNA_PE       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PE';
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
PROCEDURE EXECUTA_SCRIPT_CAMPA IS
BEGIN
    VAR_LOG := 'INSERE CAMPA_DSTAQ';
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    COMMIT;
    
    		INSERT INTO CAMPA_PARM_CARGA_DSTAQ (
    		SELECT 3 , CPARM_CARGA_DSTAQ, CCONTD_PARM_CARGA, IROTNA_ATULZ_PARM_CARGA, DINCL_REG, DALT_REG
    		FROM CAMPA_PARM_CARGA_DSTAQ 
    		WHERE CCAMPA_DSTAQ = 2);

    		INSERT INTO CAMPA_PARM_CARGA_DSTAQ
    					(CCAMPA_DSTAQ,
    					CPARM_CARGA_DSTAQ,
    					CCONTD_PARM_CARGA,
    					IROTNA_ATULZ_PARM_CARGA,
    					DINCL_REG,
    					DALT_REG)
    		VALUES		 (3,
    					 1,
    		  			 2170592,
    		   			 'SGPB6011',
    		   			 SYSDATE,
    		    		 NULL);

    		INSERT INTO CAMPA_PARM_CARGA_DSTAQ
    					(CCAMPA_DSTAQ,
    					CPARM_CARGA_DSTAQ,
    					CCONTD_PARM_CARGA,
    					IROTNA_ATULZ_PARM_CARGA,
    					DINCL_REG,
    					DALT_REG)
    		VALUES		(3,
    		 			4,
    		  			30000,
    		   			'SGPB6011',
    		    		SYSDATE,
    		     		NULL);

    		INSERT INTO CAMPA_PARM_CARGA_DSTAQ
    					(CCAMPA_DSTAQ,
    					CPARM_CARGA_DSTAQ,
    					CCONTD_PARM_CARGA,
    					IROTNA_ATULZ_PARM_CARGA,
    					DINCL_REG,
    					DALT_REG)
    		VALUES		(3,
    		 			5,
    		  			9000,
    		   			'SGPB6011',
    		    		SYSDATE,
    		     		NULL);

                
    COMMIT;
 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_CAMPA;
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
   TRATA_PARAMETRO;  -- PROCEDURE INTERNA (SUB-PROGRAMA)
   
   --EXECUTA OS SCRIPTS
   EXECUTA_SCRIPT_CAMPA;
    
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
        
end SGPB6011;
/

