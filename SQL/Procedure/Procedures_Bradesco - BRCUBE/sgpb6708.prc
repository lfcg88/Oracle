CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6708 is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 30/10/2007
--  AUTOR           : CRISTIANE FERREIRA- VALUE TEAM                              
--  PROGRAMA        : SGPB6708.SQL                                                                             
--  OBJETIVO        : Insere nas tabelas POSIC_DSTAQ linhas da tabela  META_RGNAL_DSTAQ
--  ALTERAÇÕES      :                                                                                                                                                     
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO    
VAR_CAMP_DSTAQ   			NUMBER ;     
VAR_ERRO                    VARCHAR2(1)    					    := 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A'; 
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P'; 
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_FIM_PROCESSO_CRITICO    EXCEPTION;
-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO              
VAR_CAMBTE                  ARQ_TRAB.CAMBTE%TYPE;           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             := 'SGPB'; 
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE            := 'SGPB6708';
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
VAR_DPROX_CARGA             PARM_CARGA.DPROX_CARGA%TYPE;
VAR_DCARGA					PARM_CARGA.DPROX_CARGA%TYPE;
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 670;     
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
------------- PROCEDURE DE INSERCAO NAS TABELAS POSIC_RGNAL_DSTAQ  E POSIC_CRRTR_DSTAQ----------------------------
--
PROCEDURE EXECUTA_SCRIPT_INSERCAO_01 IS
VAR_DAPURC  DATE; 
BEGIN
    VAR_LOG := 'COLOCANDO NA POSIC_DSTAQ REGISTROS DA META_DSTAQ';      
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;

    SELECT CCAMPA_DSTAQ, DAPURC_DSTAQ
    INTO VAR_CAMP_DSTAQ, VAR_DAPURC
    FROM CAMPA_DSTAQ
    WHERE CIND_CAMPA_ATIVO = 'S' ;
         
      FOR REG IN (  select META.CCAMPA_DSTAQ, META.CHIERQ_PBLIC_ALVO_DSTAQ, META.CPARM_HIERQ_DSTAQ, META.DAPURC_DSTAQ, META.CCANAL_PROD_DW
                   from META_DSTAQ META
                   where CCAMPA_DSTAQ = VAR_CAMP_DSTAQ 
                   AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 3
                   AND 
                   CHIERQ_PBLIC_ALVO_DSTAQ IN ( 
                   SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM META_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
                   AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 3
		    		MINUS
         		    SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM POSIC_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
         		    AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 3  ))
       LOOP            
       Begin 
          INSERT INTO POSIC_DSTAQ      
             (  CCAMPA_DSTAQ,
				CHIERQ_PBLIC_ALVO_DSTAQ,
				DAPURC_DSTAQ,
				NRKING_PROD,
				CPARM_HIERQ_DSTAQ,
				NRKING_PERC_CRSCT,
				VPROD_AUTO,
				VPROD_RE,
				VPERC_CRSCT_AUTO,
				VPERC_CRSCT_RE,
				DINCL_REG,
				DALT_REG,
				VPERC_CRSCT,
				CIND_ALCAN_META,
				CIND_BLOQ_CAMPA,
				CCANAL_PROD_DW,
				NRKING_PROD_RGNAL,
				NRKING_PERC_CRSCT_RGNAL,
				CIND_FALTA_META

             ) 
             VALUES
             (REG.CCAMPA_DSTAQ,
              REG.CHIERQ_PBLIC_ALVO_DSTAQ, 
              VAR_DPROX_CARGA,  -- DATA CAMPA_DSTAQ.DAPURC_DSTAQ
              99999,
              REG.CPARM_HIERQ_DSTAQ, 
              99999,
              0,
              0,
              0,
              0,
              sysdate,
              null,
              0,
              'N',
              NULL,
              REG.CCANAL_PROD_DW,
              99999,
              99999,
              NULL );    
              
              
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := '01 PRODUÇÃO JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           'HIERQ_PBLIC_ALVO:' || TO_CHAR(REG.CHIERQ_PBLIC_ALVO_DSTAQ)||
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

 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_INSERCAO_01;
------------- PROCEDURE DE INSERCAO NAS TABELAS POSIC_RGNAL_DSTAQ  E POSIC_CRRTR_DSTAQ----------------------------
--
PROCEDURE EXECUTA_SCRIPT_INSERCAO_02 IS
VAR_DAPURC  DATE; 
BEGIN
    VAR_LOG := 'COLOCANDO NA POSIC_DSTAQ REGISTROS DA META_DSTAQ';      
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;

    SELECT CCAMPA_DSTAQ, DAPURC_DSTAQ
    INTO VAR_CAMP_DSTAQ, VAR_DAPURC
    FROM CAMPA_DSTAQ
    WHERE CIND_CAMPA_ATIVO = 'S' ;
         
      FOR REG IN (  select META.CCAMPA_DSTAQ, META.CHIERQ_PBLIC_ALVO_DSTAQ, META.CPARM_HIERQ_DSTAQ, META.DAPURC_DSTAQ, META.CCANAL_PROD_DW
                   from META_DSTAQ META
                   where CCAMPA_DSTAQ = VAR_CAMP_DSTAQ AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 2
                   AND 
                   CHIERQ_PBLIC_ALVO_DSTAQ IN ( 
                   SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM META_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
                   AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 2
		    		MINUS
         		    SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM POSIC_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
         		    AND CCANAL_PROD_DW = 4 AND CPARM_HIERQ_DSTAQ = 2  ))
       LOOP            
       Begin 
          INSERT INTO POSIC_DSTAQ      
             (  CCAMPA_DSTAQ,
				CHIERQ_PBLIC_ALVO_DSTAQ,
				DAPURC_DSTAQ,
				NRKING_PROD,
				CPARM_HIERQ_DSTAQ,
				NRKING_PERC_CRSCT,
				VPROD_AUTO,
				VPROD_RE,
				VPERC_CRSCT_AUTO,
				VPERC_CRSCT_RE,
				DINCL_REG,
				DALT_REG,
				VPERC_CRSCT,
				CIND_ALCAN_META,
				CIND_BLOQ_CAMPA,
				CCANAL_PROD_DW,
				NRKING_PROD_RGNAL,
				NRKING_PERC_CRSCT_RGNAL,
				CIND_FALTA_META

             ) 
             VALUES
             (REG.CCAMPA_DSTAQ,
              REG.CHIERQ_PBLIC_ALVO_DSTAQ, 
              VAR_DPROX_CARGA,  -- DATA CAMPA_DSTAQ.DAPURC_DSTAQ
              99999,
              REG.CPARM_HIERQ_DSTAQ, 
              99999,
              0,
              0,
              0,
              0,
              sysdate,
              null,
              0,
              'N',
              NULL,
              REG.CCANAL_PROD_DW,
              99999,
              99999,
              NULL );    
              
              
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           'HIERQ_PBLIC_ALVO:' || TO_CHAR(REG.CHIERQ_PBLIC_ALVO_DSTAQ)||
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

 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_INSERCAO_02;
------------- PROCEDURE DE INSERCAO NAS TABELAS POSIC_RGNAL_DSTAQ  E POSIC_CRRTR_DSTAQ----------------------------
--
PROCEDURE EXECUTA_SCRIPT_INSERCAO_03 IS
VAR_DAPURC  DATE; 
BEGIN
    VAR_LOG := 'COLOCANDO NA POSIC_DSTAQ REGISTROS DA META_DSTAQ';      
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;

    SELECT CCAMPA_DSTAQ, DAPURC_DSTAQ
    INTO VAR_CAMP_DSTAQ, VAR_DAPURC
    FROM CAMPA_DSTAQ
    WHERE CIND_CAMPA_ATIVO = 'S' ;
         
      FOR REG IN (  select META.CCAMPA_DSTAQ, META.CHIERQ_PBLIC_ALVO_DSTAQ, META.CPARM_HIERQ_DSTAQ, META.DAPURC_DSTAQ, META.CCANAL_PROD_DW
                   from META_DSTAQ META
                   where CCAMPA_DSTAQ = VAR_CAMP_DSTAQ AND CCANAL_PROD_DW = 8
                   AND 
                   CHIERQ_PBLIC_ALVO_DSTAQ IN ( 
                   SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM META_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
                   AND CCANAL_PROD_DW = 8
		    		MINUS
         		    SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM POSIC_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
         		    AND CCANAL_PROD_DW = 8  ))
       LOOP            
       Begin 
          INSERT INTO POSIC_DSTAQ      
             (  CCAMPA_DSTAQ,
				CHIERQ_PBLIC_ALVO_DSTAQ,
				DAPURC_DSTAQ,
				NRKING_PROD,
				CPARM_HIERQ_DSTAQ,
				NRKING_PERC_CRSCT,
				VPROD_AUTO,
				VPROD_RE,
				VPERC_CRSCT_AUTO,
				VPERC_CRSCT_RE,
				DINCL_REG,
				DALT_REG,
				VPERC_CRSCT,
				CIND_ALCAN_META,
				CIND_BLOQ_CAMPA,
				CCANAL_PROD_DW,
				NRKING_PROD_RGNAL,
				NRKING_PERC_CRSCT_RGNAL,
				CIND_FALTA_META

             ) 
             VALUES
             (REG.CCAMPA_DSTAQ,
              REG.CHIERQ_PBLIC_ALVO_DSTAQ, 
              VAR_DPROX_CARGA,  -- DATA CAMPA_DSTAQ.DAPURC_DSTAQ
              99999,
              REG.CPARM_HIERQ_DSTAQ, 
              99999,
              0,
              0,
              0,
              0,
              sysdate,
              null,
              0,
              'N',
              NULL,
              REG.CCANAL_PROD_DW,
              99999,
              99999,
              NULL );    
              
              
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           'HIERQ_PBLIC_ALVO:' || TO_CHAR(REG.CHIERQ_PBLIC_ALVO_DSTAQ)||
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

 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_INSERCAO_03;

------------- PROCEDURE DE INSERCAO NAS TABELAS POSIC_RGNAL_DSTAQ  E POSIC_CRRTR_DSTAQ----------------------------
--
PROCEDURE EXECUTA_SCRIPT_INSERCAO_04 IS
VAR_DAPURC  DATE; 
BEGIN
    VAR_LOG := 'COLOCANDO NA POSIC_DSTAQ REGISTROS DA META_DSTAQ';      
    PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG, VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;

    SELECT CCAMPA_DSTAQ, DAPURC_DSTAQ
    INTO VAR_CAMP_DSTAQ, VAR_DAPURC
    FROM CAMPA_DSTAQ
    WHERE CIND_CAMPA_ATIVO = 'S' ;
         
      FOR REG IN (  select META.CCAMPA_DSTAQ, META.CHIERQ_PBLIC_ALVO_DSTAQ, META.CPARM_HIERQ_DSTAQ, META.DAPURC_DSTAQ, META.CCANAL_PROD_DW
                   from META_DSTAQ META
                   where CCAMPA_DSTAQ = VAR_CAMP_DSTAQ AND CCANAL_PROD_DW = 3 AND 
                   CHIERQ_PBLIC_ALVO_DSTAQ IN ( 
                   SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM META_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
                   AND CCANAL_PROD_DW = 3
		    		MINUS
         		    SELECT DISTINCT CHIERQ_PBLIC_ALVO_DSTAQ FROM POSIC_DSTAQ WHERE CCAMPA_DSTAQ = VAR_CAMP_DSTAQ
         		    AND CCANAL_PROD_DW = 3  ))
       LOOP            
       Begin 
          INSERT INTO POSIC_DSTAQ      
             (  CCAMPA_DSTAQ,
				CHIERQ_PBLIC_ALVO_DSTAQ,
				DAPURC_DSTAQ,
				NRKING_PROD,
				CPARM_HIERQ_DSTAQ,
				NRKING_PERC_CRSCT,
				VPROD_AUTO,
				VPROD_RE,
				VPERC_CRSCT_AUTO,
				VPERC_CRSCT_RE,
				DINCL_REG,
				DALT_REG,
				VPERC_CRSCT,
				CIND_ALCAN_META,
				CIND_BLOQ_CAMPA,
				CCANAL_PROD_DW,
				NRKING_PROD_RGNAL,
				NRKING_PERC_CRSCT_RGNAL,
				CIND_FALTA_META

             ) 
             VALUES
             (REG.CCAMPA_DSTAQ,
              REG.CHIERQ_PBLIC_ALVO_DSTAQ, 
              VAR_DPROX_CARGA,  -- DATA CAMPA_DSTAQ.DAPURC_DSTAQ
              99999,
              REG.CPARM_HIERQ_DSTAQ, 
              99999,
              0,
              0,
              0,
              0,
              sysdate,
              null,
              0,
              'N',
              NULL,
              REG.CCANAL_PROD_DW,
              99999,
              99999,
              NULL );    
              
              
       EXCEPTION    
	        WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO JÁ CADASTRADA NA TABELA ' ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(REG.CCAMPA_DSTAQ)||
           	           'HIERQ_PBLIC_ALVO:' || TO_CHAR(REG.CHIERQ_PBLIC_ALVO_DSTAQ)||
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

 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT_INSERCAO_04;

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
   
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA (O CÓDIGO DE PARâMETRO DE CARGA FOI INICIALIZADO NO DECLARE)
    PR_LE_PARAMETRO_CARGA(VAR_CPARM,VAR_DCARGA,VAR_DPROX_CARGA);
   
   -- TRATA O PARAMETRO DO PROCESSO 
   TRATA_PARAMETRO;  -- PROCEDURE INTERNA (SUB-PROGRAMA)
   
   --EXECUTA OS SCRIPTS
   EXECUTA_SCRIPT_INSERCAO_01;
   EXECUTA_SCRIPT_INSERCAO_02;
   EXECUTA_SCRIPT_INSERCAO_03;
   EXECUTA_SCRIPT_INSERCAO_04;
       
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
        
end SGPB6708;
/

