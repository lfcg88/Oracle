CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6501 IS
------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.                                                                                           
--      DATA            : 14/02/2008                                                                              
--      AUTOR           : FABIO GIGLIO - VALUE TEAM                               
--      PROGRAMA        : SGPB6501                                                                             
--      OBJETIVO        : CARGA DOS DADOS DA META E PRODUÇÃO DA CAMPANHA ANTERIOR
--      ALTERAÇÕES      :                                                                                               
--                DATA  :  
--                AUTOR :  
--                OBS   :  
------------------------------------------------------------------------------------------------------------------------
--
-- VARIAVEIS DE TRABALHO         
--
VAR_TABELA	  			VARCHAR2(30) 					:= 'HIERQ_PBLIC_ALVO';
VAR_TABELA1	  			VARCHAR2(30) 					:= 'META_DSTAQ';
VAR_TABELA3	  			VARCHAR2(30) 					:= 'POSIC_DSTAQ';
VAR_TABELA_TRAB			VARCHAR2(30) 					:= NULL;
--
VAR_TOT_REG_INCL        NUMBER							:= 0;
VAR_TOT_REG_INCL1       NUMBER                          := 0;
VAR_TOT_REG_INCL2       NUMBER							:= 0;
VAR_TOT_REG_INCL3       NUMBER                          := 0;
-- 
VAR_COUNT_DEL			NUMBER					  		:= 0;
VAR_COUNT_DEL2			NUMBER					  		:= 0;
--
VAR_CCAMPA_DSTAQ                HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ%TYPE;
VAR_CPARM_HIERQ_DSTAQ   		HIERQ_PBLIC_ALVO.CPARM_HIERQ_DSTAQ%TYPE;
VAR_CHIERQ_PBLIC_ALVO_DSTAQ     HIERQ_PBLIC_ALVO.CHIERQ_PBLIC_ALVO_DSTAQ%TYPE;
--
VAR_FIM_PROCESSO_ERRO   EXCEPTION;
--
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
W_HORA_PROC_INICIAL     DATE  							:= SYSDATE;
W_TEMPO_PROC            NUMBER;
--
-- VARIAVEIS DE CONTROLE 
VAR_CROTNA              ARQ_TRAB.CROTNA%TYPE	  		:= 'SGPB6501';
--
-- VARIAVEIS PARA O PARAMETRO DE CARGA
VAR_CPARM               PARM_CARGA.CPARM%TYPE     		:= 754; 
VAR_DCARGA_ATUAL        PARM_CARGA.DPROX_CARGA%TYPE;
VAR_ULT_CARGA           PARM_CARGA.DCARGA%TYPE; 
VAR_ANOMES_CARGA_ATUAL	NUMBER(6);
VAR_ANOMES_ULT_CARGA	NUMBER(6);
VAR_ANOMES           	NUMBER(6);
VAR_ANO_MES_TRAB  	    NUMBER(6);
VAR_ANO_TRAB  	        NUMBER(4);
VAR_MES_TRAB  	        NUMBER(2);
--
VAR_DINI_PERIODO       	PARM_CARGA.DCARGA%TYPE;
VAR_DFIM_PERIODO       	PARM_CARGA.DPROX_CARGA%TYPE;
--
-- VARIAVEIS PARA A GERACAO DE LOGS
VAR_LOG                 LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        LOG_CARGA.CTPO_REG_LOG%TYPE 	:= 'P'; 
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
      VAR_ANOMES_CARGA_ATUAL   := TO_NUMBER(TO_CHAR(VAR_DCARGA_ATUAL,  'YYYYMM'));
      VAR_ANOMES_ULT_CARGA     := TO_NUMBER(TO_CHAR(VAR_ULT_CARGA + 1, 'YYYYMM'));
--
      VAR_LOG := 'DATA DA ÚLTIMA CARGA: ' || TO_CHAR( VAR_ULT_CARGA, 'DD/MM/YYYY');
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--     
      VAR_LOG := 'DATA DA CARGA ATUAL: ' || TO_CHAR( VAR_DCARGA_ATUAL, 'DD/MM/YYYY');
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
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
--
/* ***************************************************************** */
--               
PROCEDURE DELETA_MOVIMENTO_META_DSTAQ IS
--                       
BEGIN
--          
      VAR_LOG  := 'DELETANDO TABELA '||VAR_TABELA;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));          
--
      VAR_COUNT_DEL := 0;
--
      LOOP
--     
        DELETE FROM META_DSTAQ
         WHERE CCAMPA_DSTAQ      = VAR_CCAMPA_DSTAQ
           AND CPARM_HIERQ_DSTAQ = VAR_CPARM_HIERQ_DSTAQ
           AND ROWNUM <= 5000;
--
        VAR_COUNT_DEL := VAR_COUNT_DEL + SQL%ROWCOUNT;
--
        IF SQL%ROWCOUNT = 0 THEN
           EXIT;
        END IF;
--        
        COMMIT;        
--
      END LOOP;
--
      VAR_LOG := 'QUANTIDADE DE REGISTROS DELETADOS(META_DSTAQ): ' || TO_CHAR(VAR_COUNT_DEL);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      COMMIT;      
--          
EXCEPTION
   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;
--              
        VAR_LOG  := 'ERRO AO DELETAR MOVIMENTO(META_DSTAQ). -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END DELETA_MOVIMENTO_META_DSTAQ;
--
/* ***************************************************************** */
--               
PROCEDURE DELETA_MOVIMENTO_POSIC_DSTAQ IS
--                       
BEGIN
--          
      VAR_LOG  := 'DELETANDO TABELA '||VAR_TABELA;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));          
--
      VAR_COUNT_DEL2 := 0;
--
      LOOP
--     
        DELETE FROM POSIC_DSTAQ
         WHERE CCAMPA_DSTAQ      = VAR_CCAMPA_DSTAQ
           AND CPARM_HIERQ_DSTAQ = VAR_CPARM_HIERQ_DSTAQ
           AND ROWNUM <= 5000;
--
        VAR_COUNT_DEL2 := VAR_COUNT_DEL2 + SQL%ROWCOUNT;
--
        IF SQL%ROWCOUNT = 0 THEN
           EXIT;
        END IF;
--        
        COMMIT;        
--
      END LOOP;
--
      VAR_LOG := 'QUANTIDADE DE REGISTROS DELETADOS(POSIC_DSTAQ): ' || TO_CHAR(VAR_COUNT_DEL2);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      COMMIT;      
--          
EXCEPTION
   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;
--              
        VAR_LOG  := 'ERRO AO DELETAR MOVIMENTO(POSIC_DSTAQ). -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END DELETA_MOVIMENTO_POSIC_DSTAQ;
--
/* ***************************************************************** */
--               
PROCEDURE LE_MAX_CHIERQ_PBLIC_ALVO_DSTAQ IS
--                       
BEGIN
--          
      VAR_LOG  := 'LENDO DA TABELA '||VAR_TABELA||
                  ' CCAMPA_DSTAQ = '||TO_CHAR(VAR_CCAMPA_DSTAQ)||' E '||
                  'CPARM_HIERQ_DSTAQ = '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ)||
                  ' MAX CHIERQ_PBLIC_ALVO_DSTAQ';
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
	  SELECT NVL(MAX(CHIERQ_PBLIC_ALVO_DSTAQ),0)+1
        INTO VAR_CHIERQ_PBLIC_ALVO_DSTAQ
        FROM HIERQ_PBLIC_ALVO
       WHERE CCAMPA_DSTAQ 	   = VAR_CCAMPA_DSTAQ
         AND CPARM_HIERQ_DSTAQ = VAR_CPARM_HIERQ_DSTAQ;
--
      VAR_LOG  := 'PARA A TABELA '||VAR_TABELA||
                  ' CCAMPA_DSTAQ = '||TO_CHAR(VAR_CCAMPA_DSTAQ)||' E '||
                  'CPARM_HIERQ_DSTAQ = '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ)||
                  ' MAX CHIERQ_PBLIC_ALVO_DSTAQ = '||TO_CHAR(VAR_CHIERQ_PBLIC_ALVO_DSTAQ);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      COMMIT;      
--          
EXCEPTION        
   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;
--
        VAR_LOG  := 'ERRO AO LER A TABELA '||VAR_TABELA||
                    ' CCAMPA_DSTAQ = '||TO_CHAR(VAR_CCAMPA_DSTAQ)||' E '||
                    'CPARM_HIERQ_DSTAQ = '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ)||
                    ' MAX CHIERQ_PBLIC_ALVO_DSTAQ'||
                    '. -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
        COMMIT;  
--
        RAISE VAR_FIM_PROCESSO_ERRO;        
--
END LE_MAX_CHIERQ_PBLIC_ALVO_DSTAQ;
--
/* ***************************************************************** */
--      
PROCEDURE CARREGA_META_DW IS  
--
BEGIN
--          
   VAR_LOG  := 'CARREGANDO A TABELA '||VAR_TABELA||' E A TABELA '||VAR_TABELA1;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--       
   VAR_TOT_REG_INCL 	 := 0;
--        
   VAR_TOT_REG_INCL1 	 := 0;   
--
   FOR REG IN ( SELECT CCAMPA_DSTAQ,
					   CTPO_PSSOA,
					   CCPF_CNPJ_BASE,
					   CRGNAL,
					   DAPURC_DSTAQ,
					   VMETA_AUTO,
					   VMETA_RE,
					   DINCL_REG,
					   DALT_REG
               	  FROM META_RGNAL_DSTAQ
               	  WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
                 ORDER BY CRGNAL,
					      CTPO_PSSOA,
					      CCPF_CNPJ_BASE,
					      DAPURC_DSTAQ					                    
                  ) LOOP
--                         
   BEGIN
--
	  VAR_CHIERQ_PBLIC_ALVO_DSTAQ := VAR_CHIERQ_PBLIC_ALVO_DSTAQ + 1;
--
      VAR_TABELA_TRAB := VAR_TABELA;
--   
      INSERT INTO HIERQ_PBLIC_ALVO
  	     		 (CCAMPA_DSTAQ,
				  CPARM_HIERQ_DSTAQ,
				  CHIERQ_PBLIC_ALVO_DSTAQ,
				  CTPO_PSSOA,
				  CCPF_CNPJ_BASE,
				  CRGNAL,
				  CBCO,
				  CAG_BCRIA,
				  CCANAL_PROD_DW,
				  CGRP_RGNAL,
				  CGRP_FNASA,
				  DINCL_REG,
				  DALT_REG
	             )
    	  VALUES
    		     (REG.CCAMPA_DSTAQ,
				  VAR_CPARM_HIERQ_DSTAQ,
				  VAR_CHIERQ_PBLIC_ALVO_DSTAQ,
				  REG.CTPO_PSSOA,
				  REG.CCPF_CNPJ_BASE,
				  REG.CRGNAL,
				  NULL,
				  NULL,
				  3,
				  NULL,
				  NULL,
				  REG.DINCL_REG,
				  REG.DALT_REG
    	    	 );
--
      VAR_TOT_REG_INCL := VAR_TOT_REG_INCL + 1;
--
      VAR_TABELA_TRAB := VAR_TABELA1;
--   
      INSERT INTO META_DSTAQ
  	     		 (CCAMPA_DSTAQ,
				  CPARM_HIERQ_DSTAQ,
				  CHIERQ_PBLIC_ALVO_DSTAQ,
				  DAPURC_DSTAQ,
				  CCANAL_PROD_DW,
				  VMETA_AUTO,
				  VMETA_RE,
				  DINCL_REG,
				  DALT_REG
	             )
    	  VALUES
    		     (REG.CCAMPA_DSTAQ,
				  VAR_CPARM_HIERQ_DSTAQ,
				  VAR_CHIERQ_PBLIC_ALVO_DSTAQ,
				  REG.DAPURC_DSTAQ,
				  3,
				  REG.VMETA_AUTO,
				  REG.VMETA_RE,
				  REG.DINCL_REG,
				  REG.DALT_REG
    	    	 );
--
      VAR_TOT_REG_INCL1 := VAR_TOT_REG_INCL1 + 1;      
--            
      IF MOD(VAR_TOT_REG_INCL, 5000 ) = 0 THEN
         COMMIT;
      END IF;
--             
	EXCEPTION
       WHEN OTHERS THEN
            VAR_CSIT_CTRLM := 5;        
--
            VAR_LOG  := 'ERRO NO INSERT NA BASE DW. NA TABELA '||VAR_TABELA_TRAB||                      
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
   VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA1||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL1);
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
        VAR_LOG := 'ERRO NO SUB-PROGRAMA QUE CARREGA A TABELA '||VAR_TABELA_TRAB||
                   ' -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--        
        RAISE VAR_FIM_PROCESSO_ERRO;
--        
END CARREGA_META_DW;
--
/* ***************************************************************** */
--      
PROCEDURE CARREGA_PRODUCAO_DW IS
--
BEGIN
--          
   VAR_LOG  := 'CARREGANDO A TABELA '||VAR_TABELA||' E A TABELA '||VAR_TABELA3;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--       
   VAR_TOT_REG_INCL2 	 := 0;
--        
   VAR_TOT_REG_INCL3 	 := 0;   
--
   FOR REG IN ( SELECT CCAMPA_DSTAQ,
					   CTPO_PSSOA,
					   CCPF_CNPJ_BASE,
					   CRGNAL,
					   DAPURC_DSTAQ,					   
					   NRKING_PROD_RGNAL,
					   NRKING_PERC_CRSCT_RGNAL,
					   VPROD_RGNAL_AUTO,
					   VPROD_RGNAL_RE,
					   VPERC_CRSCT_RGNAL_AUTO,
					   VPERC_CRSCT_RGNAL_RE,
					   VPERC_CRSCT_RGNAL,
					   CIND_RGNAL_ALCAN_META,					   
					   DINCL_REG,
					   DALT_REG
               	  FROM POSIC_RGNAL_DSTAQ
               	  WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
                 ORDER BY CRGNAL,
					      CTPO_PSSOA,
					      CCPF_CNPJ_BASE,
					      DAPURC_DSTAQ					                    
                  ) LOOP
--                         
   BEGIN
--
	  VAR_CHIERQ_PBLIC_ALVO_DSTAQ := VAR_CHIERQ_PBLIC_ALVO_DSTAQ + 1;
--
      VAR_TABELA_TRAB := VAR_TABELA;
--   
      INSERT INTO HIERQ_PBLIC_ALVO
  	     		 (CCAMPA_DSTAQ,
				  CPARM_HIERQ_DSTAQ,
				  CHIERQ_PBLIC_ALVO_DSTAQ,
				  CTPO_PSSOA,
				  CCPF_CNPJ_BASE,
				  CRGNAL,
				  CBCO,
				  CAG_BCRIA,
				  CCANAL_PROD_DW,
				  CGRP_RGNAL,
				  CGRP_FNASA,				  
				  DINCL_REG,
				  DALT_REG
	             )
    	  VALUES
    		     (REG.CCAMPA_DSTAQ,
				  VAR_CPARM_HIERQ_DSTAQ,
				  VAR_CHIERQ_PBLIC_ALVO_DSTAQ,
				  REG.CTPO_PSSOA,
				  REG.CCPF_CNPJ_BASE,
				  REG.CRGNAL,
				  NULL,
				  NULL,
				  3,
				  NULL,
				  NULL,				  
				  REG.DINCL_REG,
				  REG.DALT_REG
    	    	 );
--
      VAR_TOT_REG_INCL2 := VAR_TOT_REG_INCL2 + 1;
--
      VAR_TABELA_TRAB := VAR_TABELA3;
--   
      INSERT INTO POSIC_DSTAQ
  	     		 (CCAMPA_DSTAQ,
				  CPARM_HIERQ_DSTAQ,
				  CHIERQ_PBLIC_ALVO_DSTAQ,
				  DAPURC_DSTAQ,
				  CCANAL_PROD_DW,				  				  
				  NRKING_PROD_RGNAL,
                  NRKING_PERC_CRSCT_RGNAL,
				  NRKING_PROD,
				  NRKING_PERC_CRSCT,				  
				  VPROD_AUTO,
				  VPROD_RE,
				  VPERC_CRSCT_AUTO,
				  VPERC_CRSCT_RE,
				  VPERC_CRSCT,
				  CIND_ALCAN_META,
				  CIND_BLOQ_CAMPA,				  
				  CIND_FALTA_META,				  				  
				  DINCL_REG,
				  DALT_REG
	             )
    	  VALUES
    		     (REG.CCAMPA_DSTAQ,
				  VAR_CPARM_HIERQ_DSTAQ,
				  VAR_CHIERQ_PBLIC_ALVO_DSTAQ,
				  REG.DAPURC_DSTAQ,
				  3,				  
				  REG.NRKING_PROD_RGNAL,
				  REG.NRKING_PERC_CRSCT_RGNAL,
				  NULL,
				  NULL,				  
				  REG.VPROD_RGNAL_AUTO,
				  REG.VPROD_RGNAL_RE,
				  REG.VPERC_CRSCT_RGNAL_AUTO,
				  REG.VPERC_CRSCT_RGNAL_RE,
				  REG.VPERC_CRSCT_RGNAL,
				  REG.CIND_RGNAL_ALCAN_META,
				  NULL,
				  NULL,				  			  
				  REG.DINCL_REG,
				  REG.DALT_REG
    	    	 );
--
      VAR_TOT_REG_INCL3 := VAR_TOT_REG_INCL3 + 1;      
--            
      IF MOD(VAR_TOT_REG_INCL2, 5000 ) = 0 THEN
         COMMIT;
      END IF;
--             
	EXCEPTION
       WHEN OTHERS THEN
            VAR_CSIT_CTRLM := 5;        
--
            VAR_LOG  := 'ERRO NO INSERT NA BASE DW. NA TABELA '||VAR_TABELA_TRAB||                      
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
   VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL2);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA3||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL3);
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
        VAR_LOG := 'ERRO NO SUB-PROGRAMA QUE CARREGA A TABELA '||VAR_TABELA_TRAB||
                   ' -- ERRO ORACLE: '||SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--        
        RAISE VAR_FIM_PROCESSO_ERRO;
--        
END CARREGA_PRODUCAO_DW;
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
   VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '||VAR_CSIT_CTRLM;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   -- TRATA O PARAMETRO DO PROCESSO 
--   RECUPERA_PARAMETRO; 	-- PROCEDURE INTERNA (SUB-PROGRAMA)
--   
   COMMIT;
--     
   VAR_LOG  := '-------------------------------------------------------------------------------';     
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INÍCIO DO PROCESSAMENTO PARA CARGA DA TABELA '||VAR_TABELA||' E A TABELA '||VAR_TABELA1;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--   
   COMMIT;
--
   VAR_CCAMPA_DSTAQ      := 1;
   VAR_CPARM_HIERQ_DSTAQ := 1;  
--           
-- DELETA_MOVIMENTO_META_DSTAQ;        
--
   LE_MAX_CHIERQ_PBLIC_ALVO_DSTAQ;
--        
   CARREGA_META_DW;
--
   -- TEMPO DE PROCESSAMENTO PARCIAL
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO (PARCIAL) EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;
--
   VAR_LOG  := '-------------------------------------------------------------------------------';     
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));  
--
   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INÍCIO DO PROCESSAMENTO PARA CARGA DA TABELA '||VAR_TABELA||' E A TABELA '||VAR_TABELA3;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--   
   COMMIT;
--
   VAR_CCAMPA_DSTAQ      := 1;
   VAR_CPARM_HIERQ_DSTAQ := 3;
--           
-- DELETA_MOVIMENTO_POSIC_DSTAQ;        
--
   LE_MAX_CHIERQ_PBLIC_ALVO_DSTAQ;
--        
   CARREGA_PRODUCAO_DW;
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
      VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PO; 
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
-- 
   ELSE 
      RAISE VAR_FIM_PROCESSO_ERRO;
--
   END IF;              
--        
EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
	   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA1||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL1);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   		--DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));         
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL2);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
	   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA3||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL3);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   		--DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--      
	    -- ATUALIZA STATUS TERMINO DA ROTINA  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
--
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
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
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
	   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA1||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL1);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
   		--DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL2);
   		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL); 
	   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   		VAR_LOG  := 'TOTAL DE REGISTROS INCLUÍDOS '||VAR_TABELA3||' NO DW: '||TO_CHAR(VAR_TOT_REG_INCL3);
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
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
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
END SGPB6501;
/

