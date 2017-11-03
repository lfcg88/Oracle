CREATE OR REPLACE PROCEDURE SGPB_PROC.PR_CARREGA_HIERQ_PBLIC_ALVO (PAR_CROTNA IN CHAR,
									   PAR_CCANAL_PROD_DW IN NUMBER,
									   PAR_CCAMPA_DSTAQ IN NUMBER,
									   PAR_CPARM_HIERQ_DSTAQ IN NUMBER,
									   PAR_CTPO_PSSOA IN CHAR,
									   PAR_CCPF_CNPJ_BASE IN NUMBER,
									   PAR_CRGNAL IN NUMBER,
									   PAR_CBCO	IN NUMBER,
									   PAR_CAG_BCRIA IN NUMBER,
									   PAR_CHIERQ_PBLIC_ALVO_DSTAQ OUT NUMBER,
									   PAR_ERRO_CARGA OUT CHAR) IS
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 21/02/2008
--  AUTOR           : FABIO GIGLIO - VALUE TEAM                              
--  PROGRAMA        : PR_CARREGA_HIERQ_PBLIC_ALVO                                                                             
--  OBJETIVO        : PREENCHE OS DADOS REFERENTE A HIERARQUIA PARA AS CAMPANHAS DESTAQUE (TABELA HIERQ_PBLIC_ALVO)
--					  RECEBE COMO PARAMETRO DE ENTRADA APENAS AS INFORMAÇÕES REF A HIERARQUIA Q SERA CADASTRADA
--					  OS DEMAIS PARAMETROS DEVEM SER PASSADOS COMO NULO.
--					  OS VALORES DOS GRUPOS DE REGIONAL E FINASA SÃO RECUPERADOS.
--  ALTERAÇÕES      :                                                                                               
--            DATA  : - 11/03/2008                                                                                              
--            AUTOR : - MONIQUE MARQUES - VALUE TEAM                                                                                              
--            OBS   : - ANTES DE INSERIR VERIFICA (ATRAVES DA FUNCAO INTERNA FC_HIERARQUIA_NOVA) 
--						SE A COMBINAÇÃO DA HIERARQUIA JA EXISTE,
--					    SE NÃO INCLUI NORMALMENTE E SE JÁ EXISTIA APENAS INFORMA O CODIGO SEQUENCIA DA HIERARQUIA.
--
--            DATA  : - 24/03/2008                                                                                              
--            AUTOR : - MONIQUE MARQUES - VALUE TEAM                                                                                              
--            OBS   : - INCLUSAO DE REGIONAL E GRUPO PARA CANAL BANCO POR CNPJ.
--
--            DATA  : -                                                                                              
--            AUTOR : - 
--            OBS   : - 
------------------------------------------------------------------------------------------------------------------------ 									   
--
  VAR_CROTNA					ARQ_TRAB.CROTNA%TYPE;
  VAR_CCANAL_PROD_DW			HIERQ_PBLIC_ALVO.CCANAL_PROD_DW%TYPE;
  VAR_CCAMPA_DSTAQ				HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ%TYPE;
  VAR_CPARM_HIERQ_DSTAQ 		HIERQ_PBLIC_ALVO.CPARM_HIERQ_DSTAQ%TYPE;
  VAR_CHIERQ_PBLIC_ALVO_DSTAQ   HIERQ_PBLIC_ALVO.CHIERQ_PBLIC_ALVO_DSTAQ%TYPE;
  VAR_CTPO_PSSOA				HIERQ_PBLIC_ALVO.CTPO_PSSOA%TYPE;
  VAR_CCPF_CNPJ_BASE			HIERQ_PBLIC_ALVO.CCPF_CNPJ_BASE%TYPE;
  VAR_CRGNAL					HIERQ_PBLIC_ALVO.CRGNAL%TYPE;
  VAR_CBCO						HIERQ_PBLIC_ALVO.CBCO%TYPE;
  VAR_CAG_BCRIA					HIERQ_PBLIC_ALVO.CAG_BCRIA%TYPE;
  VAR_CGRP_RGNAL				HIERQ_PBLIC_ALVO.CGRP_RGNAL%TYPE;
  VAR_CGRP_FNASA            	HIERQ_PBLIC_ALVO.CGRP_FNASA%TYPE;
--  
  VAR_LOG                   	LOG_CARGA.RLOG%TYPE;
  VAR_LOG_PROCESSO          	LOG_CARGA.CTPO_REG_LOG%TYPE      			:= 'P';
  VAR_LOG_DADO              	LOG_CARGA.CTPO_REG_LOG%TYPE      			:= 'D';
  VAR_QTD                   	NUMBER(3);
  VAR_ERRO 			     		VARCHAR2(1);
  ERRO_CARGA					EXCEPTION;
--
---------------------------------------------------------------------------------------------------
--SUB-FUNCTION QUE VERIFICA SE A HIERARQUI JA EXISTE ANTES DE INSERIR
FUNCTION FC_HIERARQUIA_NOVA RETURN BOOLEAN IS
VAR_AUX_CHIERQ_PBLIC_ALVO HIERQ_PBLIC_ALVO.CHIERQ_PBLIC_ALVO_DSTAQ%TYPE :=0;
BEGIN


	IF VAR_CPARM_HIERQ_DSTAQ IN (1) THEN --EXTRA BANCO
		SELECT CHIERQ_PBLIC_ALVO_DSTAQ 
			INTO VAR_AUX_CHIERQ_PBLIC_ALVO
		FROM HIERQ_PBLIC_ALVO
		WHERE CCAMPA_DSTAQ				= VAR_CCAMPA_DSTAQ                                                            
		  AND CPARM_HIERQ_DSTAQ			= VAR_CPARM_HIERQ_DSTAQ                                                       
		  AND CCANAL_PROD_DW			= VAR_CCANAL_PROD_DW                                                          
		  AND CTPO_PSSOA				= VAR_CTPO_PSSOA                                                              
		  AND CCPF_CNPJ_BASE			= VAR_CCPF_CNPJ_BASE                                                          
		  AND CRGNAL					= VAR_CRGNAL                                                                  
		  AND CGRP_RGNAL				= VAR_CGRP_RGNAL;  
	ELSIF VAR_CPARM_HIERQ_DSTAQ IN (2) THEN --BANCO AGENCIA
		SELECT CHIERQ_PBLIC_ALVO_DSTAQ 
			INTO VAR_AUX_CHIERQ_PBLIC_ALVO
		FROM HIERQ_PBLIC_ALVO
		WHERE CCAMPA_DSTAQ				= VAR_CCAMPA_DSTAQ                                                            
		  AND CPARM_HIERQ_DSTAQ			= VAR_CPARM_HIERQ_DSTAQ                                                       
		  AND CCANAL_PROD_DW			= VAR_CCANAL_PROD_DW                                                          
		  AND CRGNAL					= VAR_CRGNAL                                                                  
		  AND CBCO						= VAR_CBCO                                                                    
		  AND CAG_BCRIA					= VAR_CAG_BCRIA                                                               
		  AND CGRP_RGNAL				= VAR_CGRP_RGNAL;
	ELSIF VAR_CPARM_HIERQ_DSTAQ IN (3) THEN --BANCO CNPJ
		SELECT CHIERQ_PBLIC_ALVO_DSTAQ 
			INTO VAR_AUX_CHIERQ_PBLIC_ALVO
		FROM HIERQ_PBLIC_ALVO
		WHERE CCAMPA_DSTAQ				= VAR_CCAMPA_DSTAQ                                                            
		  AND CPARM_HIERQ_DSTAQ			= VAR_CPARM_HIERQ_DSTAQ                                                       
		  AND CCANAL_PROD_DW			= VAR_CCANAL_PROD_DW                                                          
		  AND CTPO_PSSOA				= VAR_CTPO_PSSOA                                                              
		  AND CCPF_CNPJ_BASE			= VAR_CCPF_CNPJ_BASE
		  AND CRGNAL					= VAR_CRGNAL                                                                  
		  AND CGRP_RGNAL				= VAR_CGRP_RGNAL;	
	ELSIF VAR_CPARM_HIERQ_DSTAQ IN (4) THEN --FINASA
		SELECT CHIERQ_PBLIC_ALVO_DSTAQ 
			INTO VAR_AUX_CHIERQ_PBLIC_ALVO
		FROM HIERQ_PBLIC_ALVO
		WHERE CCAMPA_DSTAQ				= VAR_CCAMPA_DSTAQ                                                            
		  AND CPARM_HIERQ_DSTAQ			= VAR_CPARM_HIERQ_DSTAQ                                                       
		  AND CCANAL_PROD_DW			= VAR_CCANAL_PROD_DW                                                          
		  AND CTPO_PSSOA				= VAR_CTPO_PSSOA                                                              
		  AND CCPF_CNPJ_BASE			= VAR_CCPF_CNPJ_BASE                                                              
		  AND CGRP_FNASA				= VAR_CGRP_FNASA;
	END IF;
		
	IF VAR_AUX_CHIERQ_PBLIC_ALVO > 0 THEN
		VAR_CHIERQ_PBLIC_ALVO_DSTAQ	:= VAR_AUX_CHIERQ_PBLIC_ALVO;
		RETURN (FALSE);
	END IF;	    
		
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN (TRUE);
	WHEN TOO_MANY_ROWS THEN
		VAR_LOG := 'FC_HIERARQUIA_NOVA - EXISTEM MAIS DE UMA HIERARQUIA CADSTRADA!';
		RAISE ERRO_CARGA;	
	WHEN OTHERS THEN
		VAR_LOG := 'FC_HIERARQUIA_NOVA - ERRO ORACLE'||SUBSTR(SQLERRM, 1, 120);
		RAISE ERRO_CARGA;
END FC_HIERARQUIA_NOVA;
---------------------------------------------------------------------------------------------------
BEGIN
--
  PAR_ERRO_CARGA := 'ERRO NO INÍCIO DA PROCEDURE PR_CARREGA_HIERQ_PBLIC_ALVO';
--
  VAR_CROTNA            := PAR_CROTNA;  
  VAR_CCANAL_PROD_DW    := PAR_CCANAL_PROD_DW;
  VAR_CCAMPA_DSTAQ		:= PAR_CCAMPA_DSTAQ;
  VAR_CPARM_HIERQ_DSTAQ := PAR_CPARM_HIERQ_DSTAQ;
  VAR_CTPO_PSSOA		:= PAR_CTPO_PSSOA;
  VAR_CCPF_CNPJ_BASE	:= PAR_CCPF_CNPJ_BASE;
  VAR_CRGNAL			:= PAR_CRGNAL;
  VAR_CBCO				:= PAR_CBCO;
  VAR_CAG_BCRIA			:= PAR_CAG_BCRIA;
--  
  VAR_ERRO := 'N';
--
  ---------------------------------------------------------------------------------------------------
-- VALIDANDO PARÂMETROS
--
  -- PARÂMETROS OBRIGATÓRIOS
  IF VAR_CROTNA IS NULL OR
     VAR_CCANAL_PROD_DW IS NULL OR
     VAR_CCAMPA_DSTAQ IS NULL OR
     VAR_CPARM_HIERQ_DSTAQ IS NULL THEN 
     VAR_ERRO := 'S';
     VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. PARÂMETROS OBRIGATÓRIOS'||
                 ', DEVEM TER O VALOR DIFERENTE DE NULO'||
                 ', CROTNA: '||VAR_CROTNA||                 
                 ', CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
                 ', CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
                 ', CPARM_HIERQ_DSTAQ: '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ);       
  -- CANAL DE PRODUÇÃO = EXTRA BANCO OU CANAL BANCO   
  ELSIF VAR_CCANAL_PROD_DW IN (3, 5) THEN
     IF VAR_CTPO_PSSOA IS NULL OR
        VAR_CCPF_CNPJ_BASE IS NULL OR
        VAR_CRGNAL IS NULL THEN
        VAR_ERRO := 'S';
        VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. QUANDO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW|| 
                    ' (3 = EXTRA BANCO OU 5 = CANAL BANCO)'||
                    ', DEVEM TER O VALOR DIFERENTE DE NULO, OS PARÂMETROS'||
				    '. CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                    ', CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE)||
                    ', CRGNAL: '||VAR_CRGNAL;
     ELSE
        SELECT COUNT(*) 
          INTO VAR_QTD
          FROM CPVO.CRRTR_UNFCA_CNPJ
         WHERE CTPO_PSSOA     = VAR_CTPO_PSSOA
           AND CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE;
--
        IF VAR_QTD = 1 THEN
  		   BEGIN
  		     SELECT CGRP_RGNAL 
    		   INTO VAR_CGRP_RGNAL
    		   FROM SGPB.GRP_RGNAL_DSTAQ
   			  WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
     			AND CRGNAL       = VAR_CRGNAL;
               VAR_CBCO       := NULL;
	           VAR_CAG_BCRIA  := NULL;
	           VAR_CGRP_FNASA := NULL;     			         
           EXCEPTION          
              WHEN NO_DATA_FOUND THEN
              		--TESTADO MM CARGA PRODUÇÃO 11/03/2008
                   VAR_ERRO := 'S';
                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                               ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				               ' - CRGNAL: '||VAR_CRGNAL;
      		  WHEN TOO_MANY_ROWS THEN
                   VAR_ERRO := 'S';
                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                               ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				               ' - CRGNAL: '||VAR_CRGNAL;
      		  WHEN OTHERS THEN
                   VAR_ERRO := 'S';
                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                               ' COM AS COLUNAS'||
                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				               ' - CRGNAL: '||VAR_CRGNAL||
                               ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
           END;
        ELSIF VAR_QTD = 0 THEN
           VAR_ERRO := 'S';
           VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
                       ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
                       ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
		               ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                       ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
        ELSE
           VAR_ERRO := 'S';
           VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
                       ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
                       ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
		               ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                       ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
        END IF;
     END IF;        
  -- CANAL DE PRODUÇÃO = BANCO  
  ELSIF VAR_CCANAL_PROD_DW = 4 THEN
     -- CANAL DE PRODUÇÃO = BANCO, COM INFORMAÇÃO DE AGÊNCIA BANCÁRIA E BANCO
     IF VAR_CAG_BCRIA IS NOT NULL AND VAR_CBCO IS NOT NULL THEN
        IF VAR_CRGNAL IS NULL THEN     
           VAR_ERRO := 'S';
           VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. QUANDO CCANAL_PROD_DW = 4 (BANCO), COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
           			   ', DEVEM TER O VALOR DIFERENTE DE NULO, OS PARÂMETROS'||
                       ', CRGNAL: '||VAR_CRGNAL;
        ELSE        
           SELECT COUNT(*) 
             INTO VAR_QTD
             FROM CPVO.AG_BCRIA
            WHERE CBCO      = VAR_CBCO
              AND CAG_BCRIA = VAR_CAG_BCRIA;
--         
           IF VAR_QTD = 1 THEN
  		      BEGIN
  		        SELECT CGRP_RGNAL 
    		      INTO VAR_CGRP_RGNAL
    		      FROM SGPB.GRP_RGNAL_DSTAQ
   			     WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
     			   AND CRGNAL       = VAR_CRGNAL;
         		  VAR_CTPO_PSSOA     := NULL;
                  VAR_CCPF_CNPJ_BASE := NULL;
         	      VAR_CGRP_FNASA     := NULL;
              EXCEPTION          
                 WHEN NO_DATA_FOUND THEN
                      VAR_ERRO := 'S';
                      VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                                  ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                                  ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
                                  ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				                  ' - CRGNAL: '||VAR_CRGNAL;
      		     WHEN TOO_MANY_ROWS THEN
                      VAR_ERRO := 'S';
                      VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                                  ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                                  ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
                                  ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				                  ' - CRGNAL: '||VAR_CRGNAL;
      		     WHEN OTHERS THEN
                      VAR_ERRO := 'S';
                      VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                                  ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
                                  ' COM AS COLUNAS'||
                                  ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				                  ' - CRGNAL: '||VAR_CRGNAL||
                                  ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
              END;
           ELSIF VAR_QTD = 0 THEN
              VAR_ERRO := 'S';
              VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                          ', NA TABELA CPVO.AG_BCRIA'||
                          ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
                          ' - CAG_BCRIA: '||TO_CHAR(VAR_CAG_BCRIA)||
                          ' - CBCO: '||TO_CHAR(VAR_CBCO);
           ELSE
              VAR_ERRO := 'S';
              VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) COM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                          ', NA TABELA CPVO.AG_BCRIA'||
                          ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
                          ' - CAG_BCRIA: '||TO_CHAR(VAR_CAG_BCRIA)||
                          ' - CBCO: '||TO_CHAR(VAR_CBCO);
           END IF;
        END IF;                       
     -- CANAL DE PRODUÇÃO = BANCO, SEM INFORMAÇÃO DE AGÊNCIA BANCÁRIA E BANCO                               			       
     ELSIF VAR_CAG_BCRIA IS NULL AND VAR_CBCO IS NULL THEN
        IF VAR_CTPO_PSSOA IS NULL OR
           VAR_CCPF_CNPJ_BASE IS NULL OR
           VAR_CRGNAL IS NULL THEN --MM INCLUIR REGIONAL P/ BCO CNPJ
           VAR_ERRO := 'S';
           VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. QUANDO CCANAL_PROD_DW = 4 (BAMCO), SEM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
           			   ', DEVEM TER O VALOR DIFERENTE DE NULO, OS PARÂMETROS'||
				       '. CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                       ', CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
        ELSE-------------------------
        --MM INCLUIR REGIONAL P/ BCO CNPJ
        	SELECT COUNT(*) 
	          INTO VAR_QTD
	          FROM CPVO.CRRTR_UNFCA_CNPJ
	         WHERE CTPO_PSSOA     = VAR_CTPO_PSSOA
	           AND CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE;
	--
	        IF VAR_QTD = 1 THEN
	  		   BEGIN
	  		     SELECT CGRP_RGNAL 
	    		   INTO VAR_CGRP_RGNAL
	    		   FROM SGPB.GRP_RGNAL_DSTAQ
	   			  WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
	     			AND CRGNAL       = VAR_CRGNAL;
	               VAR_CBCO       := NULL;
		           VAR_CAG_BCRIA  := NULL;
		           VAR_CGRP_FNASA := NULL;     			         
	           EXCEPTION          
	              WHEN NO_DATA_FOUND THEN
	                   VAR_ERRO := 'S';
	                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
	                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
	                               ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
	                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
					               ' - CRGNAL: '||VAR_CRGNAL;
	      		  WHEN TOO_MANY_ROWS THEN
	                   VAR_ERRO := 'S';
	                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
	                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
	                               ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
	                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
					               ' - CRGNAL: '||VAR_CRGNAL;
	      		  WHEN OTHERS THEN
	                   VAR_ERRO := 'S';
	                   VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = '||VAR_CCANAL_PROD_DW||
	                               ', NA TABELA SGPB.GRP_RGNAL_DSTAQ'||
	                               ' COM AS COLUNAS'||
	                               ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
					               ' - CRGNAL: '||VAR_CRGNAL||
	                               ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
	           END;
	        ELSIF VAR_QTD = 0 THEN
	           VAR_ERRO := 'S';
	           VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
	                       ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
	                       ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
			               ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
	                       ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
	        ELSE
	           VAR_ERRO := 'S';
	           VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
	                       ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
	                       ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
			               ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
	                       ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
	        END IF;
	     END IF;        
         --MM INCLUIR REGIONAL P/ BCO CNPJ
        
           /*SELECT COUNT(*) 
             INTO VAR_QTD
             FROM CPVO.CRRTR_UNFCA_CNPJ
            WHERE CTPO_PSSOA     = VAR_CTPO_PSSOA
              AND CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE;
--
           IF VAR_QTD = 1 THEN
	          VAR_CRGNAL	 := NULL;
              VAR_CBCO       := NULL;
	          VAR_CAG_BCRIA  := NULL;
	          VAR_CGRP_RGNAL := NULL;
	          VAR_CGRP_FNASA := NULL;
           ELSIF VAR_QTD = 0 THEN
              VAR_ERRO := 'S';
              VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) SEM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                          ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
                          ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
				          ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                          ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           ELSE
              VAR_ERRO := 'S';
              VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 4 (BANCO) SEM INFORMAÇÃO DE CAG_BCRIA E CBCO'||
                          ', NA TABELA CPVO.CRRTR_UNFCA_CNPJ'||
                          ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
				          ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                          ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           END IF;
           
        END IF;
        */
     -- CANAL DE PRODUÇÃO = BANCO, COM AGÊNCIA BANCÁRIA E BANCO INCOMPATÍVEIS
     ELSE
        VAR_ERRO := 'S';
        VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. QUANDO CCANAL_PROD_DW = 4 (BANCO), COM AGÊNCIA BANCÁRIA E BANCO INCOMPATÍVEIS'||
				    '. CAG_BCRIA: '||TO_CHAR(VAR_CAG_BCRIA)||
                    ', CBCO: '||TO_CHAR(VAR_CBCO);     
     END IF;        
  -- CANAL DE PRODUÇÃO = FINASA 
  ELSIF VAR_CCANAL_PROD_DW = 8 THEN
     IF VAR_CTPO_PSSOA IS NULL OR
        VAR_CCPF_CNPJ_BASE IS NULL THEN
        VAR_ERRO := 'S';
        VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. QUANDO CCANAL_PROD_DW = 8 (FINASA)'||
                    ', DEVEM TER O VALOR DIFERENTE DE NULO, OS PARÂMETROS'||
				    '. CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                    ', CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
     ELSE
        BEGIN
         SELECT CGRP_FNASA      
           INTO VAR_CGRP_FNASA
           FROM SGPB.GRP_FNASA_DSTAQ
          WHERE CTPO_PSSOA     = VAR_CTPO_PSSOA
            AND CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE
            AND CCAMPA_DSTAQ   = VAR_CCAMPA_DSTAQ;
	       VAR_CRGNAL	  := NULL;
           VAR_CBCO       := NULL;
	       VAR_CAG_BCRIA  := NULL;
	       VAR_CGRP_RGNAL := NULL;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                VAR_ERRO := 'S';
                VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 8 (FINASA)'||
                            ', NA TABELA SGPB.GRP_FNASA_DSTAQ'||
                            ' NÃO FOI ENCONTRADA UMA LINHA COM AS COLUNAS'||
                            ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				            ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                            ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           WHEN TOO_MANY_ROWS THEN
                VAR_ERRO := 'S';
                VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 8 (FINASA)'||
                            ', NA TABELA SGPB.GRP_FNASA_DSTAQ'||
                            ' FORAM ENCONTRADOS UMA OU MAIS LINHAS COM AS COLUNAS'||
                            ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
				            ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                            ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           WHEN OTHERS THEN
                VAR_ERRO := 'S';
                VAR_LOG  := 'ERRO NA VALIDAÇÃO DO CCANAL_PROD_DW = 8 (FINASA)'||
                            ', NA TABELA SGPB.GRP_FNASA_DSTAQ'||
                            ' COM AS COLUNAS'||
                            ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
			      	        ' - CTPO_PSSOA: '||VAR_CTPO_PSSOA||
                            ' - CCPF_CNPJ_BASE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE)||
                            ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
        END;
     END IF;          
--   
  ELSE
     VAR_ERRO := 'S';   
     VAR_LOG  := 'ERRO NA VALIDAÇÃO DOS PARÂMETROS. PARÂMETRO INVÁLIDO'||
                 ', CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW);
--
  END IF;                    
  ---------------------------------------------------------------------------------------------------   
--
  IF VAR_ERRO = 'N' THEN           
     BEGIN
	  SELECT NVL(MAX(CHIERQ_PBLIC_ALVO_DSTAQ),0)+1
        INTO VAR_CHIERQ_PBLIC_ALVO_DSTAQ
        FROM HIERQ_PBLIC_ALVO
       WHERE CCAMPA_DSTAQ 	   = VAR_CCAMPA_DSTAQ
         AND CPARM_HIERQ_DSTAQ = VAR_CPARM_HIERQ_DSTAQ;
   	--TESTE MM PRODUÇAO 10/03/2008        
     EXCEPTION
        WHEN OTHERS THEN
             VAR_LOG  := 'ERRO AO LER A TABELA HIERQ_PBLIC_ALVO.'||
                         ' COM CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
                         ', MAX CHIERQ_PBLIC_ALVO_DSTAQ'||                                      
                         ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
                         ' - CPARM_HIERQ_DSTAQ: '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ)||
                         '. -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
             RAISE ERRO_CARGA;
     END;
--           
--         
     BEGIN
      --MM 10/03/08 ANTES DE INSERIR É NECESSÁRIO VERIFICAR SE A HIERARQUI JA EXISTE
      IF FC_HIERARQUIA_NOVA THEN
	      INSERT INTO HIERQ_PBLIC_ALVO
	  	     		 (CCAMPA_DSTAQ,
					  CPARM_HIERQ_DSTAQ,
					  CHIERQ_PBLIC_ALVO_DSTAQ,
					  CCANAL_PROD_DW,
					  CTPO_PSSOA,
					  CCPF_CNPJ_BASE,
					  CRGNAL,
					  CBCO,
					  CAG_BCRIA,
					  CGRP_RGNAL,
					  CGRP_FNASA,
					  DINCL_REG,
					  DALT_REG
		             )
	    	  VALUES
	  	     		 (VAR_CCAMPA_DSTAQ,
					  VAR_CPARM_HIERQ_DSTAQ,
					  VAR_CHIERQ_PBLIC_ALVO_DSTAQ,
					  VAR_CCANAL_PROD_DW,
					  VAR_CTPO_PSSOA,
					  VAR_CCPF_CNPJ_BASE,
					  VAR_CRGNAL,
					  VAR_CBCO,
					  VAR_CAG_BCRIA,
					  VAR_CGRP_RGNAL,
					  VAR_CGRP_FNASA,
					  SYSDATE,
					  NULL
	    	    	 );
      END IF;
     EXCEPTION
     	WHEN ERRO_CARGA THEN
     		RAISE ERRO_CARGA;
        WHEN OTHERS THEN
        --TESTE MM PRODUCAO 10/03/08
             VAR_LOG  := 'ERRO NA INSERÇÃO DA TABELA HIERQ_PBLIC_ALVO.'||
                         ' - CCANAL_PROD_DW: '||TO_CHAR(VAR_CCANAL_PROD_DW)||
                         ' - CCAMPA_DSTAQ: '||TO_CHAR(VAR_CCAMPA_DSTAQ)||
                         ' - CPARM_HIERQ_DSTAQ: '||TO_CHAR(VAR_CPARM_HIERQ_DSTAQ)||
                         ' - CHIERQ_PBLIC_ALVO_DSTAQ: '||TO_CHAR(VAR_CHIERQ_PBLIC_ALVO_DSTAQ)||
                         ' - ERRO ORACLE: '||SUBSTR(SQLERRM, 1, 120);
             RAISE ERRO_CARGA;
     END;
--
  ELSIF VAR_ERRO = 'S' THEN
     RAISE ERRO_CARGA;
--      
  ELSE
     VAR_LOG := 'ERRO NA CARGA DA TABELA HIERQ_PBLIC_ALVO.';     
     RAISE ERRO_CARGA;
--       
  END IF;
--
  COMMIT;
--
  PAR_CHIERQ_PBLIC_ALVO_DSTAQ := VAR_CHIERQ_PBLIC_ALVO_DSTAQ;
  PAR_ERRO_CARGA 			  := NULL;        
--
EXCEPTION
  WHEN ERRO_CARGA THEN  
--  
       ROLLBACK;
--
       PAR_CHIERQ_PBLIC_ALVO_DSTAQ := NULL; 
       PAR_ERRO_CARGA 			   := VAR_LOG;
--                   
       PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
--
       COMMIT;
       
       RAISE_APPLICATION_ERROR(-20001,'ERRO PR_CARREGA_HIERQ_PBLIC_ALVO: '||
                                       SUBSTR(SQLERRM,1,120));       
--              
  WHEN OTHERS THEN  
--  
       ROLLBACK;
--       
       VAR_LOG := 'ERRO NA PROCEDURE PR_CARREGA_HIERQ_PBLIC_ALVO'||
                  ' -- ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
--
       PAR_CHIERQ_PBLIC_ALVO_DSTAQ := NULL;  
       PAR_ERRO_CARGA 			   := VAR_LOG;
--
       PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);       
--
       COMMIT;       
--              
       RAISE_APPLICATION_ERROR(-20001,'ERRO PR_CARREGA_HIERQ_PBLIC_ALVO: '||
                                       SUBSTR(SQLERRM,1,120));
--
END PR_CARREGA_HIERQ_PBLIC_ALVO;
/

