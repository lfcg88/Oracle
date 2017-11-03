CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6002_NOVO IS
-------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                            
--  DATA            : 08/10/2007
--  AUTOR           : JO�O GRIMALDE - VALUE TEAM
--  PROGRAMA        : SGPB6002.SQL                                                   
--  OBJETIVO        : CARGA DIARIA DA POSI��O REGIONAL DO CORRETOR COM/SEM PRODU��O 
--  ALTERA��ES      : 04/12/2007 - Implementada regra para campanha 2008 e Looping para possibilitar mais de uma
--                                 Campanha simultanea. Ass. Wassily Chuk Seiblitz Guanaes
-------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO    
VAR_CROTNA					ARQ_TRAB.CROTNA%TYPE            := 'SGPB6002';
VAR_DINIC_ROTNA         	DATE                            := SYSDATE;          
VAR_CPARM               	PARM_CARGA.CPARM%TYPE           := 752;
VAR_DCARGA		          	PARM_CARGA.DCARGA%TYPE; 
VAR_DPROX_CARGA             PARM_CARGA.DCARGA%TYPE; 
VAR_ERRO 					VARCHAR2(1);
VAR_TABELA      			VARCHAR2(30) 			   		:= 'POSIC_RGNAL_DSTAQ';
VAR_LOG                 	LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'P'; 
VAR_LOG_DADO            	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'D'; 
VAR_LOG_ADVERTENCIA     	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'A';   
VAR_TPO_LOG_PROCESSO        LOG_CARGA.CTPO_REG_LOG%TYPE     ;   
VAR_CSIT_CTRLM          	SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO   	EXCEPTION;   
VAR_CCTRL_ATULZ				NUMBER := 1;
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_AP		     	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE'; -- PROCESSADO COM ERRO
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;     
VAR_STATUS_ROTNA_ANT	    SIT_ROTNA.CSIT_ROTNA%TYPE;
W_HORA_PROC_INICIAL        DATE  							:= SYSDATE;
W_TEMPO_PROC               NUMBER;     
-- VARIAVEIS UTILIZADAS NO PROCESSO DE APURA��O DA PRODU��O DO CORRETOR 
VAR_BASE_CNPJ_UNFCA 	    CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE%TYPE;
VAR_TPO_PSSOA               CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE;  
VAR_EXISTE_PROD_COMPL       VARCHAR2(1) := 'N';
-- VARIAVEIS DE PARAMETRO DA CAMPANHA CORRENTE
VAR_CCAMPA_DSTAQ 			CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE;
VAR_ICAMPA_DSTAQ		    CAMPA_DSTAQ.ICAMPA_DSTAQ%TYPE;
VAR_CIND_DEB_CUPOM          CAMPA_DSTAQ.CIND_DEB_CUPOM%TYPE;
VAR_VPERC_PRMIO_PCIAL       CAMPA_DSTAQ.VPERC_PRMIO_PCIAL%TYPE;
VAR_VMETA_MIN_RE			CAMPA_DSTAQ.VMETA_MIN_RE%TYPE;
VAR_VMETA_MIN_AUTO          CAMPA_DSTAQ.VMETA_MIN_AUTO%TYPE;
VAR_DULT_APURC_DSTAQ        CAMPA_DSTAQ.DAPURC_DSTAQ%TYPE;
VAR_CFAIXA_INIC_DSMTO_CRRTR CAMPA_DSTAQ.CFAIXA_INIC_DSMTO_CRRTR%TYPE;
VAR_CFAIXA_FNAL_DSMTO_CRRTR CAMPA_DSTAQ.CFAIXA_FNAL_DSMTO_CRRTR%TYPE; 
VAR_VPRMIO_DSTAQ            CAMPA_DSTAQ.VPRMIO_DSTAQ%TYPE;
VAR_CIND_CAMPA_ATIVO        CAMPA_DSTAQ.CIND_CAMPA_ATIVO%TYPE;
VAR_CIND_CUPOM_PROML	    VARCHAR2(1);
VAR_CIND_GRP_RGNAL		    VARCHAR2(1);
VAR_CIND_PRMIO_PCIAL	    VARCHAR2(1);
VAR_CIND_SITE_ATIVO	    	VARCHAR2(1);
VAR_CIND_AG				    VARCHAR2(1);
VAR_CIND_CANAL			    VARCHAR2(1);
VAR_CIND_PROC_CORRETOR_BLOQ VARCHAR2(1);
VAR_CIND_CONSIDERA_CP       VARCHAR2(1);
--CRGNAL
VAR_VPROD_RGNAL_RE          POSIC_RGNAL_DSTAQ.VPROD_RGNAL_RE%TYPE; 
VAR_VPROD_RGNAL_AUTO        POSIC_RGNAL_DSTAQ.VPROD_RGNAL_AUTO%TYPE;
VAR_NRKING_PROD_RGNAL       POSIC_RGNAL_DSTAQ.NRKING_PROD_RGNAL%TYPE; 
VAR_NRKING_PERC_CRSCT_RGNAL POSIC_RGNAL_DSTAQ.NRKING_PERC_CRSCT_RGNAL%TYPE; 
VAR_VPERC_CRSCT_RGNAL_AUTO  POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL_AUTO%TYPE; 
VAR_VPERC_CRSCT_RGNAL_RE    POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL_RE%TYPE; 
VAR_VPERC_CRSCT_RGNAL       POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL%TYPE;
VAR_TOT_REG_PROC           	NUMBER := 0;
VAR_TOT_REG_COM_PROD_DIA   	NUMBER := 0;
VAR_TOT_REG_SEM_PROD_DIA   	NUMBER := 0;
-- ------------------------------------------------------------------------
PROCEDURE PR_INCR_POSIC_DIA_PROD_RGNAL (PAR_CCAMPA_DSTAQ            IN NUMBER,
					                    PAR_CTPO_PSSOA              IN VARCHAR2,
					                    PAR_CCPF_CNPJ_BASE          IN NUMBER,
					                    PAR_CRGNAL                  IN NUMBER,
					                    PAR_DAPURC_DSTAQ            IN DATE,
					                    PAR_NRKING_PROD_RGNAL       IN NUMBER,
					                    PAR_NRKING_PERC_CRSCT_RGNAL IN NUMBER,
					                    PAR_VPROD_RGNAL_AUTO        IN NUMBER,
					                    PAR_VPROD_RGNAL_RE          IN NUMBER,
					                    VPERC_CRSCT_RGNAL_AUTO      IN NUMBER,
					                    VPERC_CRSCT_RGNAL_RE        IN NUMBER) IS
BEGIN 
   BEGIN       
	  BEGIN
            -- Cadastra Produ��o do Corretor na tabela POSIC_CRRTR_DSTAQ
            INSERT INTO POSIC_RGNAL_DSTAQ
                   (CCAMPA_DSTAQ, CTPO_PSSOA, CCPF_CNPJ_BASE, CRGNAL, DAPURC_DSTAQ, NRKING_PROD_RGNAL,
		            NRKING_PERC_CRSCT_RGNAL, VPROD_RGNAL_AUTO, VPROD_RGNAL_RE, VPERC_CRSCT_RGNAL_AUTO,
		            VPERC_CRSCT_RGNAL_RE, VPERC_CRSCT_RGNAL, DINCL_REG, DALT_REG,
                    CIND_RGNAL_ALCAN_META )
                    VALUES
                   (PAR_CCAMPA_DSTAQ, PAR_CTPO_PSSOA, PAR_CCPF_CNPJ_BASE, 
		            PAR_CRGNAL, PAR_DAPURC_DSTAQ, nvl(PAR_NRKING_PROD_RGNAL,0), nvl(PAR_NRKING_PERC_CRSCT_RGNAL,0),
		            nvl(PAR_VPROD_RGNAL_AUTO,0), nvl(PAR_VPROD_RGNAL_RE,0), nvl(VPERC_CRSCT_RGNAL_AUTO,0),
		            nvl(VPERC_CRSCT_RGNAL_RE,0), 0, sysdate, NULL, 'S');
	  EXCEPTION    
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODU��O POR REGIONAL J� CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(PAR_CCAMPA_DSTAQ)||
           	           ' REGIONAL: '       || TO_CHAR(PAR_CRGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(PAR_CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURA��O: '  || TO_CHAR(PAR_DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
    	WHEN OTHERS THEN    	    
           	VAR_LOG := ' ERRO AO CARREGAR REGISTRO NA TABELA. ERRO: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
			VAR_CSIT_CTRLM := 5;
	  END;   
   EXCEPTION
     WHEN OTHERS THEN RAISE VAR_FIM_PROCESSO_ERRO;  
   END;
END;
PROCEDURE PR_POSIC_DIA_PROD_RGNAL IS  -- POSICAO DIARIA PRODU��O DA SUPEX
BEGIN 
   	VAR_LOG  := '------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECU��O CURSOR DE RECUPERA��O DA PRODU��O DIARIA DA SUPEX ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 3, NULL);
    VAR_LOG  := '-------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	-- ---------------------------------------------------------------
   	-- Na query abaixo pegar o canal (vai ser incluido no RE e AUTO)
   	-- Ass. Wassily ( 10/12/2007 )
   	-- --------------------------------------------------------------
	FOR REG IN(SELECT CDIR_RGNAL, CCPF_CNPJ_BASE, CTPO_PSSOA, DEMIS,
	                  sum(VPROD_AUTO) VPROD_RGNAL_AUTO, sum(VPROD_RE) VPROD_RGNAL_RE
			    FROM (-- PRODUCAO AUTO QUE N�O TEM DESMEMBRAMENTO
					  select A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_ENDSS DEMIS,
					           sum(A.VPRMIO_LIQ_AUTO) VPROD_AUTO, 0  VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_AT A, CAMPA_DSTAQ B, CRRTR C, CRRTR_UNFCA_CNPJ D
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR            = C.CCRRTR AND
					             A.CSUCUR            = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE    = D.CCPF_CNPJ_BASE AND
					             --NOT EXISTS (SELECT CCONTD_PARM_CARGA
					             --              FROM CAMPA_PARM_CARGA_DSTAQ X
					             --             WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					             --                   X.CPARM_CARGA_DSTAQ = 1 and
					             --                   C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 2 and
					                                A.CSUCUR            = CCONTD_PARM_CARGA ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 3 and
					                                A.CCRRTR   = CCONTD_PARM_CARGA ) AND
					             A.DEMIS_ENDSS = VAR_DPROX_CARGA 
					             GROUP BY A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_ENDSS
					  UNION
					  -- PRODUCAO AUTO COM DESMEMBRAMENTO
					  select A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_ENDSS DEMIS,
					         sum(A.VPRMIO_LIQ_AUTO) VPROD_AUTO, 0  VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_AT A, CAMPA_DSTAQ B, CRRTR C, CRRTR_UNFCA_CNPJ D,
					           MPMTO_AG_CRRTR E
					     WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR = E.CCRRTR_ORIGN AND
					             A.CSUCUR = E.CUND_PROD   AND
					             A.DEMIS_ENDSS >= E.DENTRD_CRRTR_AG AND
					             A.DEMIS_ENDSS < NVL(E.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) AND
					             E.CCRRTR_DSMEM = C.CCRRTR AND
					             E.CUND_PROD = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             --NOT EXISTS (SELECT CCONTD_PARM_CARGA
					             --              FROM CAMPA_PARM_CARGA_DSTAQ X
					             --             WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					             --                   X.CPARM_CARGA_DSTAQ = 1 and
					             --                   C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 2 and
					                                A.CSUCUR            = CCONTD_PARM_CARGA ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 3 and
					                                A.CCRRTR   = CCONTD_PARM_CARGA ) AND
					             A.DEMIS_ENDSS = VAR_DPROX_CARGA 
					             GROUP BY A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_ENDSS
					  UNION
					  -- PRODUCAO RE SEM DESMENBRAMENTO
					  select A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_PRMIO DEMIS, 0 VPROD_AUTO,
					         sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A, CAMPA_DSTAQ B, CRRTR C, CRRTR_UNFCA_CNPJ D,
					           GRP_RAMO_CAMPA_DSTAQ E
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR = C.CCRRTR AND
					             A.CSUCUR = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             E.CCAMPA_DSTAQ = B.CCAMPA_DSTAQ AND
					             A.CRAMO = E.CRAMO AND
					             --NOT EXISTS (SELECT CCONTD_PARM_CARGA
					             --              FROM CAMPA_PARM_CARGA_DSTAQ X
					             --             WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					             --                   X.CPARM_CARGA_DSTAQ = 1 and
					             --                   C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 2 and
					                                A.CSUCUR            = CCONTD_PARM_CARGA ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 3 and
					                                A.CCRRTR   = CCONTD_PARM_CARGA ) AND
					             A.DEMIS_PRMIO =  VAR_DPROX_CARGA 
					             GROUP BY A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_PRMIO
					  UNION
					  -- PRODUCAO RE COM DESMEMBRAMENTO
					  select A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_PRMIO DEMIS,
					         0 VPROD_AUTO, sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A, CAMPA_DSTAQ B, CRRTR C,
					           CRRTR_UNFCA_CNPJ D, MPMTO_AG_CRRTR E, GRP_RAMO_CAMPA_DSTAQ F
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR = E.CCRRTR_ORIGN AND
					             A.CSUCUR = E.CUND_PROD   AND
					             A.DEMIS_PRMIO >= E.DENTRD_CRRTR_AG AND
					             A.DEMIS_PRMIO < NVL(E.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) AND
					             E.CCRRTR_DSMEM = C.CCRRTR AND
					             E.CUND_PROD = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             F.CCAMPA_DSTAQ = B.CCAMPA_DSTAQ AND
					             A.CRAMO = F.CRAMO AND
					             --NOT EXISTS (SELECT CCONTD_PARM_CARGA
					             --              FROM CAMPA_PARM_CARGA_DSTAQ X
					             --             WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					             --                   X.CPARM_CARGA_DSTAQ = 1 and
					             --                   C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 2 and
					                                A.CSUCUR            = CCONTD_PARM_CARGA ) AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 3 and
					                                A.CCRRTR   = CCONTD_PARM_CARGA ) AND
					             A.DEMIS_PRMIO = VAR_DPROX_CARGA 
					             GROUP BY A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_PRMIO)
                      GROUP BY CDIR_RGNAL, CCPF_CNPJ_BASE, CTPO_PSSOA, DEMIS) 
    LOOP
      BEGIN
        -- -----------------------------------------------------
        -- Colocar aqui para verificar se o corretor est� no CCC
        -- Colocar aqui os "IF'S" das condi��es de cada Campanha
        -- Ass. Wassily (10/12/2007)
        -- -----------------------------------------------------
        select nvl(NRKING_PROD_RGNAL,0),        -- C
		       nvl(NRKING_PERC_CRSCT_RGNAL,0),  -- D 
		       nvl(VPROD_RGNAL_AUTO,0),         -- A
		       nvl(VPROD_RGNAL_RE,0),           -- B
               nvl(VPERC_CRSCT_RGNAL_AUTO,0),   -- F
		       nvl(VPERC_CRSCT_RGNAL_RE,0)      -- E
	     into  VAR_NRKING_PROD_RGNAL, VAR_NRKING_PERC_CRSCT_RGNAL, VAR_VPROD_RGNAL_AUTO, VAR_VPROD_RGNAL_RE,
		       VAR_VPERC_CRSCT_RGNAL_AUTO, VAR_VPERC_CRSCT_RGNAL_RE 
        from POSIC_RGNAL_DSTAQ
         where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and CRGNAL              = REG.CDIR_RGNAL
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ;
	     VAR_VPROD_RGNAL_AUTO     := VAR_VPROD_RGNAL_AUTO + REG.VPROD_RGNAL_AUTO;   -- G
		 VAR_VPROD_RGNAL_RE       := VAR_VPROD_RGNAL_RE   + REG.VPROD_RGNAL_RE;     -- H
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN              
		     VAR_VPROD_RGNAL_RE         := REG.VPROD_RGNAL_RE;
	         VAR_VPROD_RGNAL_AUTO       := REG.VPROD_RGNAL_AUTO;
		     VAR_NRKING_PROD_RGNAL      := 0;
		     VAR_NRKING_PERC_CRSCT_RGNAL:= 0;
		     VAR_VPERC_CRSCT_RGNAL_AUTO := 0;
		     VAR_VPERC_CRSCT_RGNAL_RE   := 0;
    	WHEN OTHERS THEN
			 VAR_CSIT_CTRLM := 6;
           	 VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	 PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 4, NULL);
           	 VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	 PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 5, NULL);
		     RAISE VAR_FIM_PROCESSO_ERRO;             
      END; 
      -- Cadastra Produ��o do Corretor na tabela POSIC_RGNAL_DSTAQ 
      PR_INCR_POSIC_DIA_PROD_RGNAL (VAR_CCAMPA_DSTAQ, REG.CTPO_PSSOA, REG.CCPF_CNPJ_BASE, REG.CDIR_RGNAL, 
							        VAR_DPROX_CARGA, VAR_NRKING_PROD_RGNAL,	VAR_NRKING_PERC_CRSCT_RGNAL,
							        VAR_VPROD_RGNAL_AUTO, VAR_VPROD_RGNAL_RE, VAR_VPERC_CRSCT_RGNAL_AUTO,
									VAR_VPERC_CRSCT_RGNAL_RE);
      VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;	
      VAR_TOT_REG_COM_PROD_DIA := VAR_TOT_REG_COM_PROD_DIA + 1;
	  IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
	     COMMIT;
	  END IF;
    END LOOP;
EXCEPTION
	WHEN OTHERS THEN 
    	 VAR_CSIT_CTRLM := 6;
         VAR_LOG := 'ERRO NO SUB-PROGRAMA que CARREGA OS DADOS PARA TABELA ' || VAR_TABELA;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 6, NULL); 
         VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 7, NULL);
         RAISE VAR_FIM_PROCESSO_ERRO;
END; 
PROCEDURE PR_POSIC_DIA_PROD_RGNAL_COMPL IS  -- POSICAO DIARIA PRODU��O SUPEX COMPLEMENTAR
BEGIN
   	VAR_LOG  := '------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECU��O CURSOR DE RECUPERA��O DA PRODU��O DA SUPEX COMPLEMENTAR ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 8, NULL);
    VAR_LOG  := '------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	FOR REG IN( -- Seleciona Registros da Campanha do dia Anterior 
	            select CCAMPA_DSTAQ, CCPF_CNPJ_BASE, CTPO_PSSOA, CRGNAL
                        from POSIC_RGNAL_DSTAQ
                       where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                         and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ
                minus   
	           -- Seleciona Registros da Campanha do dia Atual 
                select CCAMPA_DSTAQ, CCPF_CNPJ_BASE, CTPO_PSSOA, CRGNAL
                        from POSIC_RGNAL_DSTAQ
                       where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                         and TRUNC(DAPURC_DSTAQ) = VAR_DPROX_CARGA) 
    LOOP
      BEGIN
        select nvl(VPROD_RGNAL_AUTO,0),
               nvl(VPROD_RGNAL_RE,0),
               nvl(NRKING_PROD_RGNAL,0),        -- C
		       nvl(NRKING_PERC_CRSCT_RGNAL,0),  -- D 
		       nvl(VPROD_RGNAL_AUTO,0),         -- A
		       nvl(VPROD_RGNAL_RE,0),           -- B
               nvl(VPERC_CRSCT_RGNAL_AUTO,0),   -- F
		       nvl(VPERC_CRSCT_RGNAL_RE,0)      -- E
	     into  VAR_VPROD_RGNAL_AUTO, VAR_VPROD_RGNAL_RE, VAR_NRKING_PROD_RGNAL, VAR_NRKING_PERC_CRSCT_RGNAL,
		       VAR_VPROD_RGNAL_AUTO, VAR_VPROD_RGNAL_RE, VAR_VPERC_CRSCT_RGNAL_AUTO, VAR_VPERC_CRSCT_RGNAL_RE 
         from POSIC_RGNAL_DSTAQ
         where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and CRGNAL              = REG.CRGNAL
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ  ;
           VAR_EXISTE_PROD_COMPL    := 'S' ;
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN 
    	     VAR_EXISTE_PROD_COMPL    := 'N' ;
    	WHEN OTHERS THEN
			 VAR_CSIT_CTRLM := 6;
           	 VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	 PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 9, NULL);
           	 VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	 PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 10, NULL);
		     RAISE VAR_FIM_PROCESSO_ERRO;             
      END;
      IF VAR_EXISTE_PROD_COMPL = 'S' THEN 
         -- Cadastra Produ��o do Corretor na tabela POSIC_RGNAL_DSTAQ 
         PR_INCR_POSIC_DIA_PROD_RGNAL (VAR_CCAMPA_DSTAQ, REG.CTPO_PSSOA, REG.CCPF_CNPJ_BASE,  
					                REG.CRGNAL, VAR_DPROX_CARGA, VAR_NRKING_PROD_RGNAL,
					                VAR_NRKING_PERC_CRSCT_RGNAL, VAR_VPROD_RGNAL_AUTO,
					                VAR_VPROD_RGNAL_RE, VAR_VPERC_CRSCT_RGNAL_AUTO,	VAR_VPERC_CRSCT_RGNAL_RE); 
	     VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
         VAR_TOT_REG_SEM_PROD_DIA := VAR_TOT_REG_SEM_PROD_DIA + 1;
	     IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
	        COMMIT;
	     END IF;
      END IF;
    END LOOP;
   EXCEPTION
     WHEN OTHERS THEN RAISE VAR_FIM_PROCESSO_ERRO;  
END;
------------------------------------  PROGRAMA PRINCIPAL  ------------------------------------
BEGIN    
	-- A VARI�VEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA 
   	-- COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   	VAR_CSIT_CTRLM := 1;
	-- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
	-- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA);	 
    -- RECUPERA OS DADOS DE PARAMETRO DE CARGA (O C�DIGO DE PAR�METRO DE CARGA FOI INICIALIZADO NO DECLARE)
    PR_LE_PARAMETRO_CARGA(VAR_CPARM,VAR_DCARGA,VAR_DPROX_CARGA);	
	-- GRAVA LOG INICIAL DE CARGA
	VAR_LOG := 'INICIO DO PROCESSO CARGA DA TABELA '||VAR_TABELA;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
    -- TEMPO DE PROCESSAMENTO
    W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
    VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	-- Grava log inicial de carga
	VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '|| VAR_CSIT_CTRLM;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	-- Verifica status da rotina antes de iniciar o processamento 
  	VAR_LOG := 'VERIFICANDO STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.';
  	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
 	VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
 	VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
 	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);    
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    VAR_LOG  := 'INICIANDO PROCESSO DE APURA��O DA PRODU��O DO CORRETOR/REGIONAL';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	-- ---------------------------------------------------------------------------
	-- Aqui tem que colocar FOR para apurar campanha-a-campanha.
	-- Pegando somente quem est� ativa. 
	-- Ass. Wassily
	-- ----------------------------------------------------------------------------
	for VAR_CAMPA in ( select CCAMPA_DSTAQ, ICAMPA_DSTAQ, CIND_DEB_CUPOM, VPRMIO_DSTAQ, VPERC_PRMIO_PCIAL, VMETA_MIN_RE,
				              VMETA_MIN_AUTO, CIND_CAMPA_ATIVO, DAPURC_DSTAQ,
						      CFAIXA_INIC_DSMTO_CRRTR, CFAIXA_FNAL_DSMTO_CRRTR, 'N' CIND_CUPOM_PROML,
					          'N' CIND_GRP_RGNAL, 'N' CIND_PRMIO_PCIAL, 'N' CIND_SITE_ATIVO, 'N' CIND_AG, 
					          'N' CIND_CANAL, 'N' CIND_PROC_CORRETOR_BLOQ, 'N' CIND_CONSIDERA_CP
						      from campa_dstaq
						      where CIND_CAMPA_ATIVO = 'S')
    LOOP
        VAR_DULT_APURC_DSTAQ       := TRUNC(VAR_CAMPA.DAPURC_DSTAQ);
        VAR_CCAMPA_DSTAQ           := VAR_CAMPA.CCAMPA_DSTAQ;
        VAR_ICAMPA_DSTAQ           := VAR_CAMPA.ICAMPA_DSTAQ;
        VAR_CIND_DEB_CUPOM         := VAR_CAMPA.CIND_DEB_CUPOM;
        VAR_VPRMIO_DSTAQ           := VAR_CAMPA.VPRMIO_DSTAQ;
        VAR_VPERC_PRMIO_PCIAL      := VAR_CAMPA.VPERC_PRMIO_PCIAL;
        VAR_VMETA_MIN_RE           := VAR_CAMPA.VMETA_MIN_RE;
        VAR_VMETA_MIN_AUTO         := VAR_CAMPA.VMETA_MIN_AUTO;
        VAR_CIND_CAMPA_ATIVO       := VAR_CAMPA.CIND_CAMPA_ATIVO;
        VAR_CFAIXA_INIC_DSMTO_CRRTR:= VAR_CAMPA.CFAIXA_INIC_DSMTO_CRRTR;
        VAR_CFAIXA_FNAL_DSMTO_CRRTR:= VAR_CAMPA.CFAIXA_FNAL_DSMTO_CRRTR;
        VAR_CIND_CUPOM_PROML	   := VAR_CAMPA.CIND_CUPOM_PROML;
		VAR_CIND_GRP_RGNAL		   := VAR_CAMPA.CIND_GRP_RGNAL;
		VAR_CIND_PRMIO_PCIAL	   := VAR_CAMPA.CIND_PRMIO_PCIAL;
		VAR_CIND_SITE_ATIVO	       := VAR_CAMPA.CIND_SITE_ATIVO;
		VAR_CIND_AG				   := VAR_CAMPA.CIND_AG;
		VAR_CIND_CANAL			   := VAR_CAMPA.CIND_CANAL;
		VAR_CIND_PROC_CORRETOR_BLOQ:= VAR_CAMPA.CIND_PROC_CORRETOR_BLOQ;
		VAR_CIND_CONSIDERA_CP      := VAR_CAMPA.CIND_CONSIDERA_CP;
		VAR_LOG  := 'PROCESSANDO A CAMPANHA: '||VAR_CAMPA.CCAMPA_DSTAQ||'('||VAR_CAMPA.ICAMPA_DSTAQ||')';
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
		VAR_LOG  := 'PARAMETROS: DPROX_CARGA: '||TO_CHAR(VAR_DPROX_CARGA,'DD/MM/YYYY')||
		            ' ULTIMA DATA PROCESSADA: '|| TO_CHAR(VAR_DULT_APURC_DSTAQ,'DD/MM/YYYY')||
		            ' NOME CAMPANHA: '||VAR_ICAMPA_DSTAQ||' INDICA DEBITO CUPOM: '||VAR_CIND_DEB_CUPOM||
		            ' VALOR PREMIO CUPOM: '||VAR_VPRMIO_DSTAQ||' VALOR PERC. PREMIO PARCIAL: '||VAR_VPERC_PRMIO_PCIAL;
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
		VAR_LOG  := '            VALOR META MINIMA RE: '||VAR_VMETA_MIN_RE||' VALOR META MINIMA AUTO: '||VAR_VMETA_MIN_AUTO||
		            ' CAMPANHA ATIVA:'||VAR_CIND_CAMPA_ATIVO||' INICIO DESMEMBRAMENTO: '||VAR_CFAIXA_INIC_DSMTO_CRRTR||
		            ' FINAL DO DESMEMBRAMENTO: '||VAR_CFAIXA_FNAL_DSMTO_CRRTR||' CALCULA CUPOM: '||VAR_CIND_CUPOM_PROML||
		            ' USA GRUPO REGIONAL: '||VAR_CIND_GRP_RGNAL||' USA PREMIO PARCIAL: '||VAR_CIND_PRMIO_PCIAL||
		            ' SITE ATIVO: '||VAR_CIND_SITE_ATIVO||' USA AGENCIA: '||VAR_CIND_AG||' USA CANAL: '||VAR_CIND_CANAL||
		            ' PROCESSA CORRETOR BLOQUEADO: '||VAR_CIND_PROC_CORRETOR_BLOQ||' CONSIDERA CP: '||VAR_CIND_CONSIDERA_CP;
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	    COMMIT; 	  	    
    	DELETE POSIC_RGNAL_DSTAQ
        	   WHERE  DAPURC_DSTAQ = VAR_DPROX_CARGA AND
        	          CCAMPA_DSTAQ = VAR_CAMPA.CCAMPA_DSTAQ; -- Conceito Re-processamento
        IF SQL%ROWCOUNT > 0 THEN
           VAR_LOG := 'HOUVE RE-PROCESSAMENTO, FORAM DESMARCADAS '||SQL%ROWCOUNT||' LINHAS.';
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
        END IF;
    	PR_POSIC_DIA_PROD_RGNAL;
    	PR_POSIC_DIA_PROD_RGNAL_COMPL;    	                     
        VAR_LOG  := 'TOTAL DE REGISTROS COM PRODU��O INSERIDOS NA TABELA '||VAR_TABELA ||': '||TO_CHAR(VAR_TOT_REG_COM_PROD_DIA);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
        VAR_LOG  := 'TOTAL DE REGISTROS DE PRODU��O NOVA INSERIDOS NA TABELA '||VAR_TABELA ||': '||TO_CHAR(VAR_TOT_REG_SEM_PROD_DIA);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
        VAR_LOG  := 'TOTAL DE REGISTROS INSERIDOS NA TABELA  '||VAR_TABELA ||': '||TO_CHAR(VAR_TOT_REG_PROC);
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 	       
		COMMIT;
		VAR_TOT_REG_COM_PROD_DIA := 0;
		VAR_TOT_REG_SEM_PROD_DIA := 0;
		VAR_TOT_REG_PROC         := 0;
	END LOOP;
	IF VAR_CSIT_CTRLM = 1 THEN
		PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
		VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PO; 
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA,VAR_CROTNA,SYSDATE,NULL,NULL,VAR_LOG,VAR_CSIT_CTRLM);           
	ELSE
		RAISE VAR_FIM_PROCESSO_ERRO;
	END IF;
EXCEPTION
	WHEN VAR_FIM_PROCESSO_ERRO THEN
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO. OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
   	    PR_GRAVA_LOG_EXCUC_CTRLM(VAR_DINIC_ROTNA, VAR_CROTNA, SYSDATE, NULL, NULL, VAR_LOG, VAR_CSIT_CTRLM);
	WHEN OTHERS THEN
        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);        
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO. OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	    PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA,VAR_CROTNA, SYSDATE, NULL, NULL, VAR_LOG, VAR_CSIT_CTRLM);   	                                      
        VAR_CSIT_CTRLM := 6;
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
 END;
/

