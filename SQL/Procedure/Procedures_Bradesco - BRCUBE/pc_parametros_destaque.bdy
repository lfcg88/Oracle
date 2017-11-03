CREATE OR REPLACE PACKAGE BODY SGPB_PROC.PC_PARAMETROS_DESTAQUE IS
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 19/02/2008
--  AUTOR           : MONIQUE MARQUES - VALUE TEAM                              
--  PROGRAMA        :                                                                              
--  OBJETIVO        : BUSCAR PARAMETROS DA CAMPANHA DESTAQUE
--					  FUNÇÕES CRIADAS:
--                    - TE
--  ALTERAÇÕES      :                                                                                               
--            DATA  : -                                                                                              
--            AUTOR : -                                                                                              
--            OBS   : -                                                                                              
------------------------------------------------------------------------------------------------------------------------    
	
	FUNCTION FC_PER_INIC_META_CAMPA(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN CAMPA_DSTAQ.DINIC_CAMPA_DSTAQ%TYPE AS
	--ESTA FUNCAO FOI FEITA PARA RETORNAR O PERIODO INICIAL PARA BASE DOS CALCULOS DE META
	VAR_AUX_RETORNO	CAMPA_DSTAQ.DINIC_CAMPA_DSTAQ%TYPE;
	BEGIN
		--A META É CALCULA COM BASE NO MESMO PERIODO DO ANO PASSADO
		SELECT ADD_MONTHS(DINIC_CAMPA_DSTAQ,-12)
		INTO VAR_AUX_RETORNO
		FROM CAMPA_DSTAQ
		WHERE CIND_CAMPA_ATIVO = 'S'
		  AND CCAMPA_DSTAQ = PAR_CCAMPA;
		
		RETURN(VAR_AUX_RETORNO);
			
	END FC_PER_INIC_META_CAMPA;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_PER_FIM_META_CAMPA(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN CAMPA_DSTAQ.DINIC_CAMPA_DSTAQ%TYPE AS
	--ESTA FUNCAO FOI FEITA PARA RETORNAR O PERIODO INICIAL PARA BASE DOS CALCULOS DE META
	VAR_AUX_RETORNO	CAMPA_DSTAQ.DINIC_CAMPA_DSTAQ%TYPE;
	BEGIN
		--A META É CALCULA COM BASE NO MESMO PERIODO DO ANO PASSADO
		SELECT LAST_DAY(ADD_MONTHS(DINIC_CAMPA_DSTAQ,-10))
		INTO VAR_AUX_RETORNO
		FROM CAMPA_DSTAQ
		WHERE CIND_CAMPA_ATIVO = 'S'
		  AND CCAMPA_DSTAQ = PAR_CCAMPA;
		
		RETURN(VAR_AUX_RETORNO);
			
	END FC_PER_FIM_META_CAMPA;
	
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_META_MIN_AUTO(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN CAMPA_PARM_CARGA_DSTAQ.CCONTD_PARM_CARGA%TYPE AS
	VAR_AUX_RETORNO	CAMPA_PARM_CARGA_DSTAQ.CCONTD_PARM_CARGA%TYPE;
	BEGIN
		--RECUPERA META MÍNIMA AUTO PARA O CANAL EXTRA BANCO
		SELECT CCONTD_PARM_CARGA
		INTO VAR_AUX_RETORNO
		FROM CAMPA_PARM_CARGA_DSTAQ
		WHERE CCAMPA_DSTAQ = PAR_CCAMPA
		  AND CPARM_CARGA_DSTAQ = 4;
		
		RETURN(VAR_AUX_RETORNO);
			
	END FC_RCUPD_META_MIN_AUTO;

---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_META_MIN_RE(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN CAMPA_PARM_CARGA_DSTAQ.CCONTD_PARM_CARGA%TYPE AS
	VAR_AUX_RETORNO	CAMPA_PARM_CARGA_DSTAQ.CCONTD_PARM_CARGA%TYPE;
	BEGIN
		--RECUPERA META MÍNIMA RE PARA O CANAL EXTRA BANCO
		SELECT CCONTD_PARM_CARGA
		INTO VAR_AUX_RETORNO
		FROM CAMPA_PARM_CARGA_DSTAQ
		WHERE CCAMPA_DSTAQ = PAR_CCAMPA
		  AND CPARM_CARGA_DSTAQ = 5;
		
		RETURN(VAR_AUX_RETORNO);
			
	END FC_RCUPD_META_MIN_RE;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_BCO_CNPJ(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	    
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_BCO_CNPJ;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_BCO_AG(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	    
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW
							,HIERQ_PBLIC_ALVO.CGRP_RGNAL';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_BCO_AG;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_EXTRA_BCO(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW
							,HIERQ_PBLIC_ALVO.CGRP_RGNAL';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_EXTRA_BCO;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_FNASA(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW
							,HIERQ_PBLIC_ALVO.CGRP_FNASA';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_FNASA;
--TESTE
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_BCO_AG_RGNAL(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW
							,HIERQ_PBLIC_ALVO.CGRP_RGNAL
							,HIERQ_PBLIC_ALVO.CRGNAL';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_BCO_AG_RGNAL;
---------------------------------------------------------------------------------------------------------------------------	
	
	FUNCTION FC_RCUPD_HIERQ_EXTRA_BCO_RGNAL(PAR_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) RETURN VARCHAR AS
	VAR_AUX_RETORNO	VARCHAR2(2000) := '';
	BEGIN
	
		VAR_AUX_RETORNO :=	'HIERQ_PBLIC_ALVO.CCAMPA_DSTAQ
							,HIERQ_PBLIC_ALVO.CCANAL_PROD_DW
							,HIERQ_PBLIC_ALVO.CGRP_RGNAL
							,HIERQ_PBLIC_ALVO.CRGNAL';
		
		RETURN(VAR_AUX_RETORNO);
		
	END FC_RCUPD_HIERQ_EXTRA_BCO_RGNAL;
			
END PC_PARAMETROS_DESTAQUE;
/

