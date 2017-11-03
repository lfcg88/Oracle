create or replace procedure sgpb_proc.SGPB6008_Novo is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 30/10/2007
--  AUTOR           : Daniel Monteiro - VALUE TEAM                              
--  PROGRAMA        : SGPBteste.SQL                                                                             
--  OBJETIVO        : Insere nas tabelas POSIC_DSTAQ 
--  ALTERAÇÕES      :                                                                                               
--            DATA  : -25/01/2008                                                                                             
--            AUTOR : - wellington P Medeiros - Value Team Ltda                                                                                             
--            OBS   : -                                                                                              
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO    
VAR_CAMP_DSTAQ   			NUMBER := 1;     
VAR_ERRO                    VARCHAR2(1)    					    := 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A'; 
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P'; 
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_FIM_PROCESSO_CRITICO    EXCEPTION;
VAR_DAPURC  				DATE;   ----FOI ADICIONADO
VAR_CPARM_HIERQ_DSTAQ       NUMBER := 4;  
-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO              
VAR_CAMBTE                  ARQ_TRAB.CAMBTE%TYPE;           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             := 'SGPB'; 
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE            := 'SGPB6008_Novo';
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 753;     
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
------------- PROCEDURE DE INSERCAO NAS TABELAS  POSIC_DSTAQ  

PROCEDURE EXECUTA_SCRIPT_INSERCAO IS
VAR_DAPURC  DATE; 
BEGIN
    VAR_LOG := 'APAGA TABELA META_DSTAQ';      
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;

    SELECT DAPURC_DSTAQ
    INTO VAR_DAPURC
    FROM CAMPA_DSTAQ
    WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ ;  --VERIFICAR VAR_CAMP_DSTAQ 
    
    FOR REG IN (  select META.CCAMPA_DSTAQ, META.CHIERQ_PBLIC_ALVO_DSTAQ, META.DAPURC_DSTAQ , META.CPARM_HIERQ_DSTAQ , H.CCPF_CNPJ_BASE , H.CRGNAL
                   from META_DSTAQ META  ,HIERQ_PBLIC_ALVO H
                   where H.CCPF_CNPJ_BASE IN ( SELECT  DISTINCT H.CCPF_CNPJ_BASE
				FROM  META_DSTAQ M, HIERQ_PBLIC_ALVO H
				WHERE  M.CCAMPA_DSTAQ = H.CCAMPA_DSTAQ
				AND    M.CHIERQ_PBLIC_ALVO_DSTAQ  = H.CHIERQ_PBLIC_ALVO_DSTAQ
				AND    M.CPARM_HIERQ_DSTAQ =  H.CPARM_HIERQ_DSTAQ

				MINUS

				SELECT DISTINCT H.CCPF_CNPJ_BASE
				FROM POSIC_DSTAQ P, HIERQ_PBLIC_ALVO H
				WHERE  P.CCAMPA_DSTAQ = H.CCAMPA_DSTAQ
				AND    P.CHIERQ_PBLIC_ALVO_DSTAQ  = H.CHIERQ_PBLIC_ALVO_DSTAQ
				AND    P.CPARM_HIERQ_DSTAQ =  H.CPARM_HIERQ_DSTAQ  )  )
													
													
													
	   LOOP            


       Begin 
          INSERT INTO 
             		POSIC_DSTAQ
                   (CCAMPA_DSTAQ ,
				 	CHIERQ_PBLIC_ALVO_DSTAQ ,
				 	DAPURC_DSTAQ ,
				 	CPARM_HIERQ_DSTAQ,
					NRKING_PROD,
					NRKING_PERC_CRSCT,
					VPROD_AUTO,
					VPROD_RE,
					VPERC_CRSCT_AUTO,
					VPERC_CRSCT_RE ,
					DINCL_REG  ,
					DALT_REG,
					VPERC_CRSCT,
					CIND_ALCAN_META,
					CIND_BLOQ_CAMPA)
             VALUES
             		(REG.CCAMPA_DSTAQ,
              		REG.CHIERQ_PBLIC_ALVO_DSTAQ, 
              		REG.DAPURC_DSTAQ, 
              		REG.CPARM_HIERQ_DSTAQ,
              		0,
              		0,
              		0,
              		0,
              		0,
              		0,
              		SYSDATE,
              		NULL,
              		0,
              		'N',
              		'N' ) ;
                  
              
              
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO POR REGIONAL JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           ' REGIONAL: '        || TO_CHAR(REG.CRGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(REG.CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(VAR_DAPURC,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
            --
    	    WHEN OTHERS THEN   
    	      --			
			      VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	     END;               
            
      END LOOP;
 
    COMMIT;


   /* FOR REG IN (  select DISTINCT META.CCAMPA_DSTAQ, META.CTPO_PSSOA, META.CCPF_CNPJ_BASE, META.DAPURC_DSTAQ
                   from META_RGNAL_DSTAQ META
                   where CCPF_CNPJ_BASE IN ( SELECT DISTINCT CCPF_CNPJ_BASE FROM META_RGNAL_DSTAQ
                                             MINUS
                                             SELECT DISTINCT CCPF_CNPJ_BASE FROM POSIC_RGNAL_DSTAQ   ))
    LOOP            

    Begin     
           INSERT INTO POSIC_CRRTR_DSTAQ      
           ( CCAMPA_DSTAQ,
		     CTPO_PSSOA,
		     CCPF_CNPJ_BASE,
		     DAPURC_DSTAQ,    -- DATA CAMPA_DSTAQ.DAPURC_DSTAQ
             QCUPOM_DISPN,
             QCUPOM_RETRD,
             VPROD_PRMIO,
             VPROD_PEND,
             --VPROD_RE,         "campo trocado na tabela"
             --VPROD_AUTO,
             CIND_BLOQ_CAMPA,             
             CIDTFD_PRMIO_PCIAL,
		     --NRKING_PROD_NACIO,           "campo trocado na tabela"
		     --NRKING_PERC_CRSCT_NACIO,     "campo trocado na tabela"
		     --VPERC_CRSCT_auto ,      "campo trocado na tabela"
		     --VPERC_CRSCT_RE ,           "campo trocado na tabela"
		     --vperc_crsct_nacio ,        "campo trocado na tabela"
             --CIND_ALCAN_META  ,         "campo trocado na tabela"
		     DINCL_REG,
		     DALT_REG
           ) 
           VALUES
           (REG.CCAMPA_DSTAQ,
            REG.CTPO_PSSOA, 
            REG.CCPF_CNPJ_BASE, 
            VAR_DAPURC,
            0,
            0,
            0,
            0,
            0,
           -- 0,
            0,
            --99999,  
            --99999,
           -- 0,
            --0,
            --0,
            --'N',
            SYSDATE,
            NULL );
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(REG.CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(VAR_DAPURC,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL); 
            --
    	    WHEN OTHERS THEN   
    	      --			
			      VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	     END;     
        END LOOP;
 
    COMMIT;        */

 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_INSERCAO;

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
   PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
   -- ATUALIZA STATUS DA ROTINA  
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
   
   -- TRATA O PARAMETRO DO PROCESSO 
   TRATA_PARAMETRO;  -- PROCEDURE INTERNA (SUB-PROGRAMA)
   
   --EXECUTA OS SCRIPTS
   EXECUTA_SCRIPT_INSERCAO;
       
   IF VAR_CSIT_CTRLM = 1 THEN 
      VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS = 1). ' || 
                 'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
      PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
      
   ELSIF VAR_CSIT_CTRLM = 2 THEN 
      VAR_LOG := 'TERMINO DO PROCESSO COM ADVERTENCIA (STATUS = 2). ' || 
                 ' OS PROCESSOS DEPENDENTES PODEM CONTINUAR '||
                 'E O LOG DEVE SER ENCAMINHADO AO ANALISTA RESPONSAVEL.';
      PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
            
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
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
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
         PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
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
         PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
                  
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA DEVERA SER CONTACTADO.';
         PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
       
    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                                 VAR_CROTNA     , 
                               SYSDATE        , -- DFIM_ROTNA
                               NULL           , -- IPROG
                               NULL           , -- CERRO
                               VAR_LOG        , -- RERRO
                               VAR_CSIT_CTRLM             );
        
end SGPB6008_Novo;
/

