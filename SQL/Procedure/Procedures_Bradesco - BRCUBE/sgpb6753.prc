CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6753 IS
------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.                                                                                           
--      DATA            : 05/03/2008                                                                              
--      AUTOR           : FABIO GIGLIO - VALUE TEAM                              
--      PROGRAMA        : SGPB6753                                                                             
--      OBJETIVO        : ATUALIZAÇÃO DA TABELA POSIC_DSTAQ (COLUNA CIND_BLOQ_CAMPA)
--      ALTERAÇÕES      :                                                                                               
--                DATA  : 
--                AUTOR : - 
--                OBS   : - 
------------------------------------------------------------------------------------------------------------------------
--
-- VARIAVEIS DE TRABALHO         
--
VAR_TABELA	  			VARCHAR2(30) 					:= 'POSIC_DSTAQ';
VAR_TOT_REG_ALTE        NUMBER;
VAR_QTD_JURIDICA        NUMBER;
VAR_QTD_FISICA          NUMBER;
VAR_QTD_LISTA_NEGRA     NUMBER;
VAR_FIM_PROCESSO_ERRO   EXCEPTION;
--
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
W_HORA_PROC_INICIAL     DATE  							:= SYSDATE;
W_TEMPO_PROC            NUMBER;
--
-- VARIAVEIS DE CONTROLE 
VAR_CROTNA              ARQ_TRAB.CROTNA%TYPE	  		:= 'SGPB6753';
--
-- VARIAVEIS PARA O PARAMETRO DE CARGA
VAR_CPARM               PARM_CARGA.CPARM%TYPE     		:= 675; 
VAR_DCARGA_ATUAL        PARM_CARGA.DPROX_CARGA%TYPE;
VAR_ULT_CARGA           PARM_CARGA.DCARGA%TYPE;
--
-- VARIAVEIS PARA A GERACAO DE LOGS
VAR_LOG                 LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        LOG_CARGA.CTPO_REG_LOG%TYPE 	:= 'P';
VAR_LOG_DADO            LOG_CARGA.CTPO_REG_LOG%TYPE    	:= 'D'; 
--
-- VARIAVEIS PARA O CONTROLE DO CTRLM
VAR_CSIT_CTRLM          SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_DINIC_ROTNA         DATE                            := SYSDATE;
--
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
--
VAR_ROTNA_AP		   	ROTNA.CSIT_ROTNA%TYPE			:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	   	ROTNA.CSIT_ROTNA%TYPE			:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		   	ROTNA.CSIT_ROTNA%TYPE			:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	   	ROTNA.CSIT_ROTNA%TYPE			:= 'PE'; -- PROCESSADO COM ERRO

VAR_STATUS_ROTNA	   	ROTNA.CSIT_ROTNA%TYPE;

VAR_MAX_CCOMPT_SIT_CRRTR	INFO_LISTA_NEGRA_CRRTR.CCOMPT_SIT_CRRTR%TYPE;
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
PROCEDURE RECUPERA_PARAMETRO IS
--                       
BEGIN
--        
      -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
      PR_LE_PARAMETRO_CARGA (VAR_CPARM, VAR_ULT_CARGA, VAR_DCARGA_ATUAL);
--
      VAR_LOG := 'DATA DA ÚLTIMA CARGA: ' || TO_CHAR( VAR_ULT_CARGA, 'DD/MM/YYYY');
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--     
      VAR_LOG := 'DATA DA CARGA ATUAL: ' || TO_CHAR( VAR_DCARGA_ATUAL, 'DD/MM/YYYY');
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      COMMIT;
--     
EXCEPTION
   WHEN OTHERS THEN         
--   
        VAR_CSIT_CTRLM := 6;
--              
        VAR_LOG  := 'ERRO NO RECUPERA_PARÂMETRO. -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   

        RAISE VAR_FIM_PROCESSO_ERRO;

END RECUPERA_PARAMETRO;

/* ***************************************************************** */
--      
PROCEDURE ATUALIZA_TABELA IS  
--
BEGIN
--          
   VAR_LOG  := 'ATUALIZANDO A TABELA '||VAR_TABELA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
   --MM 18/03/2008
   SELECT MAX(CCOMPT_SIT_CRRTR) 
   	INTO VAR_MAX_CCOMPT_SIT_CRRTR
   FROM INFO_LISTA_NEGRA_CRRTR;             
--        
   VAR_TOT_REG_ALTE := 0;
--
   FOR REG IN ( SELECT CCAMPA_DSTAQ,
				       DAPURC_DSTAQ
               	  FROM CAMPA_DSTAQ
                 WHERE CIND_CAMPA_ATIVO = 'S'
                  ) LOOP
--
    BEGIN
--   
       FOR REG2 IN ( SELECT P.ROWID,
                            P.CCAMPA_DSTAQ   CCAMPA_DSTAQ,
                            H.CTPO_PSSOA     CTPO_PSSOA,
                            H.CCPF_CNPJ_BASE CCPF_CNPJ_BASE,
                            H.CCANAL_PROD_DW --MM 18/03/2008
                       FROM POSIC_DSTAQ P,
                            HIERQ_PBLIC_ALVO H
                      WHERE P.CCAMPA_DSTAQ            = REG.CCAMPA_DSTAQ
                        AND P.DAPURC_DSTAQ            = REG.DAPURC_DSTAQ
                        AND P.CCAMPA_DSTAQ            = H.CCAMPA_DSTAQ
                        AND P.CPARM_HIERQ_DSTAQ       = H.CPARM_HIERQ_DSTAQ
				        AND P.CHIERQ_PBLIC_ALVO_DSTAQ = H.CHIERQ_PBLIC_ALVO_DSTAQ
				        AND P.CCANAL_PROD_DW          = H.CCANAL_PROD_DW                        
                   ) LOOP
--
        BEGIN
--
          VAR_QTD_JURIDICA    := 0;
          VAR_QTD_FISICA      := 0;
          VAR_QTD_LISTA_NEGRA := 0;
--
          IF REG2.CTPO_PSSOA = 'J' THEN
             SELECT COUNT(*)
               INTO VAR_QTD_JURIDICA
               FROM CAMPA_PARM_CARGA_DSTAQ C  
              WHERE C.CCAMPA_DSTAQ      = REG2.CCAMPA_DSTAQ
                AND C.CCONTD_PARM_CARGA = REG2.CCPF_CNPJ_BASE  
                AND C.CPARM_CARGA_DSTAQ = 1;
          ELSE
             SELECT COUNT(*)
               INTO VAR_QTD_FISICA
               FROM CAMPA_PARM_CARGA_DSTAQ C  
              WHERE C.CCAMPA_DSTAQ      = REG2.CCAMPA_DSTAQ
                AND C.CCONTD_PARM_CARGA = REG2.CCPF_CNPJ_BASE  
                AND C.CPARM_CARGA_DSTAQ = 8;            
          END IF;
--
          IF VAR_QTD_JURIDICA = 0 AND
             VAR_QTD_FISICA   = 0 THEN
             --MM 18/03/2008
             /*SELECT COUNT(*)
               INTO VAR_QTD_LISTA_NEGRA
               FROM INFO_LISTA_NEGRA_CRRTR I  
              WHERE I.CCPF_CNPJ_BASE = REG2.CCPF_CNPJ_BASE  
                AND I.CTPO_PSSOA     = REG2.CTPO_PSSOA;*/
             IF REG2.CCANAL_PROD_DW = 3 THEN
             	SELECT COUNT(*)
               INTO VAR_QTD_LISTA_NEGRA
               FROM INFO_LISTA_NEGRA_CRRTR I  
              WHERE I.CCPF_CNPJ_BASE = REG2.CCPF_CNPJ_BASE  
                AND I.CTPO_PSSOA     = REG2.CTPO_PSSOA
                AND CCOMPT_SIT_CRRTR = VAR_MAX_CCOMPT_SIT_CRRTR
                AND CSIT_CRRTR_BDSCO IN (1,2,3,4,5);
             ELSE
             	SELECT COUNT(*)
               INTO VAR_QTD_LISTA_NEGRA
               FROM INFO_LISTA_NEGRA_CRRTR I  
              WHERE I.CCPF_CNPJ_BASE = REG2.CCPF_CNPJ_BASE  
                AND I.CTPO_PSSOA     = REG2.CTPO_PSSOA
                AND CCOMPT_SIT_CRRTR = VAR_MAX_CCOMPT_SIT_CRRTR
                AND CSIT_CRRTR_BDSCO IN (1,2,3,4);
             END IF;
                
          END IF;                              
--
--
          IF VAR_QTD_JURIDICA    <> 0 OR
             VAR_QTD_FISICA      <> 0 OR            
             VAR_QTD_LISTA_NEGRA <> 0 THEN
--             
      		 UPDATE POSIC_DSTAQ
  	            SET CIND_BLOQ_CAMPA = 'S'
  	            	, DALT_REG = SYSDATE
              WHERE ROWID = REG2.ROWID;
--       
             IF SQL%NOTFOUND THEN
                VAR_CSIT_CTRLM := 5; 
--         
                VAR_LOG  := 'ERRO NO UPDATE DA TABELA '||VAR_TABELA;
		        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL); 
                --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--         
		        RAISE VAR_FIM_PROCESSO_ERRO;
--
             END IF;
--
             VAR_TOT_REG_ALTE := VAR_TOT_REG_ALTE + 1;
--            
             IF MOD(VAR_TOT_REG_ALTE, 1000) = 0 THEN
                COMMIT;
             END IF;
--             
          END IF;            
--
	    EXCEPTION
           WHEN OTHERS THEN
                VAR_CSIT_CTRLM := 5;        
--
                VAR_LOG := 'ERRO NO SELECT DA TABELA '||VAR_TABELA||
                           ' -- CCAMPA_DSTAQ: '|| TO_CHAR(REG.CCAMPA_DSTAQ)||
                           ' -- DAPURC_DSTAQ: '|| TO_CHAR(REG.DAPURC_DSTAQ, 'DD/MM/YYYY')||                       
                           ' -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
                PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
                --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
                RAISE VAR_FIM_PROCESSO_ERRO;
--                  
	    END;
--          
       END LOOP;  -- REG2
--             
	EXCEPTION
       WHEN OTHERS THEN
            VAR_CSIT_CTRLM := 5;        
--
            VAR_LOG := 'ERRO NO SELECT DA TABELA CAMPA_DSTAQ (CIND_CAMPA_ATIVO = S)'||
                       ' -- CCAMPA_DSTAQ: '|| TO_CHAR(REG.CCAMPA_DSTAQ)||
                       ' -- DAPURC_DSTAQ: '|| TO_CHAR(REG.DAPURC_DSTAQ, 'DD/MM/YYYY')||                       
                       ' -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
           RAISE VAR_FIM_PROCESSO_ERRO;
--                  
	END;
--         
   END LOOP;
--
   VAR_LOG  := 'TOTAL DE REGISTROS ALTERADOS: '||TO_CHAR(VAR_TOT_REG_ALTE);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));          
--   
   COMMIT;
--             
EXCEPTION
   WHEN OTHERS THEN
--   
        VAR_CSIT_CTRLM := 6; 
--        
        VAR_LOG := 'ERRO NO SUB-PROGRAMA QUE ATUALIZA A TABELA '||VAR_TABELA||
                   ' -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--        
        RAISE VAR_FIM_PROCESSO_ERRO;
--        
END ATUALIZA_TABELA;
--
-----------------------------  PROGRAMA PRINCIPAL  -----------------------------
--
BEGIN
--                          
   -- A SITUACAO DA ROTINA ATUAL DEVE SER MARCADA COMO 'PC'
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
--
   -- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA COM O FLAG
   -- DE TERMINO NORMAL COM SUCESSO (=1)
   VAR_CSIT_CTRLM := 1;
--
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   -- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA );
--
   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INÍCIO DO PROCESSAMENTO PARA ATUALIZAÇÃO DA TABELA '||VAR_TABELA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '||VAR_CSIT_CTRLM;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
   VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;      
--
   -- TRATA O PARAMETRO DO PROCESSO 
   RECUPERA_PARAMETRO; 	-- PROCEDURE INTERNA (SUB-PROGRAMA)
--        
   ATUALIZA_TABELA;
--
   -- TEMPO DE PROCESSAMENTO
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--                                                                    
   IF VAR_CSIT_CTRLM = 1 THEN                                    
      -- ATUALIZA STATUS TERMINO DA ROTINA  
      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
--
      VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
--
      VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--         
      VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). '  ||
                 'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
-- 
      -- GRAVA LOG FIM DE CARGA PARA O CONTROL-M
      PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                                 VAR_CROTNA     , 
                                 SYSDATE        , -- DFIM_ROTNA
                                 NULL           , -- IPROG
                                 NULL           , -- CERRO
                                 VAR_LOG        , -- RERRO
                                 VAR_CSIT_CTRLM             ); 
   ELSE 
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;              
--        
EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
--                                    
        VAR_LOG  := 'TOTAL DE REGISTROS ALTERADOS: '|| 
                     TO_CHAR(VAR_TOT_REG_ALTE);
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
        VAR_LOG  := 'TOTAL DE REGISTROS ALTERADOS: '|| 
                     TO_CHAR(VAR_TOT_REG_ALTE);
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
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA DEVERA SER CONTACTADO IMEDIATAMENTE.';
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
END SGPB6753;
/

