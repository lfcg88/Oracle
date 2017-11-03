create or replace procedure sgpb_proc.SGPB6007_2 is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.
--  DATA            : 13/10/2007
--  AUTOR           : JOSEVALDO / JOÃO GRIMALDE - VALUE TEAM
--  PROGRAMA        : SGPB6007.SQL
--  OBJETIVO        : CARGA (INICIAL) FIXA DA META REGIONAL  - SGPB6007
--  ALTERAÇÕES      :
--            DATA  : -
--            AUTOR : -
--            OBS   : -
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             	:= 'SGPB';
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE           		:= 'SGPB6007';
VAR_TABELA      			VARCHAR2(30) 			   			:= 'META_RGNAL_DSTAQ';
VAR_ERRO                    VARCHAR2(1)       					:= 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A';
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P';
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 757;
VAR_DCARGA                  PARM_CARGA.DCARGA%TYPE;
VAR_DPROX_CARGA             PARM_CARGA.DPROX_CARGA%TYPE;
VAR_DULT_APURC_DSTAQ        DATE ;                        -- DATA DA ULTIMA APURAÇÃO DESTAQUE
VAR_VPRMIO_DSTAQ            CAMPA_DSTAQ.VPRMIO_DSTAQ%TYPE                 ;
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_PC       			SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PC';
VAR_ROTNA_PO       			SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PO';
VAR_ROTNA_PE          		SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PE';
W_HORA_PROC_INICIAL        DATE  							:= SYSDATE;
W_TEMPO_PROC               NUMBER;
--
-- VARIAVEIS UTILIZADAS NO PROCESSO DE CARGA DE ATUALIZAÇÃO DIÁRIA DAS METAS DOS NOVOS CORRETORES
VAR_CCAMPA_DSTAQ            POSIC_CRRTR_DSTAQ.CCAMPA_DSTAQ%TYPE                := 2;   -- DEVE SER TROCADO VALOR DE RETORNO DA PROCEDURE
VAR_DINIC_ROTNA             DATE                            := SYSDATE;
VAR_DAPURC_ANOMES_ANTER_DSTAQ		DATE;
VAR_CIND_CAMPA_ATIVO        VARCHAR2(1)  := 'S' ;
VAR_EXISTE_PROD_ATUAL       VARCHAR2(1)  ;
VAR_CDIR_RGNAL              POSIC_RGNAL_DSTAQ.CRGNAL%TYPE;
VAR_CCPF_CNPJ_BASE          POSIC_RGNAL_DSTAQ.CCPF_CNPJ_BASE%TYPE;
VAR_CTPO_PSSOA              POSIC_RGNAL_DSTAQ.CTPO_PSSOA%TYPE;
VAR_DEMIS                   DATE;
VAR_VPROD_RGNAL_AUTO        NUMBER(15,2);
VAR_VPROD_RGNAL_RE          NUMBER(15,2);
VAR_VMETA_AUTO              NUMBER(15,2);
VAR_VMETA_RE                NUMBER(15,2);
VAR_VMETA_MIN_RE            NUMBER(15,2);
VAR_VMETA_MIN_AUTO          NUMBER(15,2);
VAR_TOT_REG_PROC           	NUMBER := 0;
VAR_DAPURC_INI_TMES_ANTER   DATE;
VAR_DAPURC_FIM_TMES_ANTER   DATE;
--
--
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


--
--
/*
PROCEDURE PR_RETORNA_META_RGNAL (
	                    PAR_VPROD_RGNAL_AUTO  IN NUMBER,
	                    PAR_VPROD_RGNAL_RE    IN NUMBER,
	                    PAR_VMETA_MIN_AUTO    IN NUMBER,
	                    PAR_VMETA_MIN_RE      IN NUMBER,
	                    PAR_VMETA_AUTO        OUT NUMBER,
	                    PAR_VMETA_RE          OUT NUMBER) IS
BEGIN
	BEGIN
           IF PAR_VPROD_RGNAL_AUTO <= 300000 THEN
               PAR_VMETA_AUTO := PAR_VPROD_RGNAL_AUTO * 1.2;
               IF PAR_VMETA_AUTO < PAR_VMETA_MIN_AUTO THEN
                  PAR_VMETA_AUTO := PAR_VMETA_MIN_AUTO;
               END IF;

            ELSIF PAR_VPROD_RGNAL_AUTO BETWEEN 300000.1 AND 600000  THEN
               PAR_VMETA_AUTO := PAR_VPROD_RGNAL_AUTO * 1.1;
               IF PAR_VMETA_AUTO < PAR_VMETA_MIN_AUTO THEN
                  PAR_VMETA_AUTO := PAR_VMETA_MIN_AUTO;
               END IF;

            ELSIF PAR_VPROD_RGNAL_AUTO >= 600000.1 THEN
               PAR_VMETA_AUTO := PAR_VPROD_RGNAL_AUTO * 1.05;
               IF PAR_VMETA_AUTO < PAR_VMETA_MIN_AUTO THEN
                  PAR_VMETA_AUTO := PAR_VMETA_MIN_AUTO;
               END IF;

            END IF;
            --
			-- CALCULO META RE
			--
            PAR_VMETA_RE := PAR_VPROD_RGNAL_RE * 1.35;
            IF PAR_VMETA_RE < PAR_VMETA_MIN_RE THEN
               PAR_VMETA_RE := PAR_VMETA_MIN_RE;
            END IF;
		    --
 	END;
END;
*/
--
--
PROCEDURE PR_INCR_META_RGNAL_DSTAQ (
					PAR_CCAMPA_DSTAQ            IN NUMBER,
					PAR_CTPO_PSSOA              IN VARCHAR2,
					PAR_CCPF_CNPJ_BASE          IN NUMBER,
					PAR_CRGNAL                  IN NUMBER,
					PAR_DAPURC_DSTAQ            IN DATE,
					PAR_VMETA_RGNAL_AUTO        IN NUMBER,
					PAR_VMETA_RGNAL_RE          IN NUMBER,
					PAR_DINCL_REG               IN DATE
					)IS

BEGIN
   BEGIN
   --
	  BEGIN
          -- Cadastra Produção do Corretor na tabela POSIC_CRRTR_DSTAQ
             INSERT INTO META_RGNAL_DSTAQ
             ( CCAMPA_DSTAQ,
		       CTPO_PSSOA,
		       CCPF_CNPJ_BASE,
		       CRGNAL,
		       DAPURC_DSTAQ,
		       VMETA_AUTO,
		       VMETA_RE,
		       DINCL_REG,
		       DALT_REG)
             VALUES
             ( PAR_CCAMPA_DSTAQ,
		       PAR_CTPO_PSSOA,
		       PAR_CCPF_CNPJ_BASE,
		       PAR_CRGNAL,
		       PAR_DAPURC_DSTAQ,      -- DATA DA APURAÇÃO ATUAL
		       nvl(PAR_VMETA_RGNAL_AUTO,0),
		       nvl(PAR_VMETA_RGNAL_RE,0),
		       PAR_DINCL_REG,
		       NULL );            -- DALT_REG
		  --
          VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
          --
          --
	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'META JÁ CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(PAR_CCAMPA_DSTAQ)||
           	           ' REGIONAL: '        || TO_CHAR(PAR_CRGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(PAR_CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(PAR_DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 11, NULL);
            --
    	WHEN OTHERS THEN
    	    --
			VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	  END;
   --
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;
   END;
END;
--
--
PROCEDURE PR_RECUPERA_PARM_APURACAO IS
BEGIN

   BEGIN
     SELECT TRUNC(DAPURC_DSTAQ),
            VPRMIO_DSTAQ,
			3000, --VMETA_MIN_RE,  -- WASSA
			10000 --VMETA_MIN_AUTO -- WASSA
        INTO VAR_DULT_APURC_DSTAQ,
             VAR_VPRMIO_DSTAQ,
			 VAR_VMETA_MIN_RE,
			 VAR_VMETA_MIN_AUTO
       FROM CAMPA_DSTAQ
      WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ;


      --> RECUPERA OS DADOS DE PARAMETRO DE CARGA (O CÓDIGO DE PARâMETRO DE CARGA FOI INICIALIZADO NO DECLARE)
      PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
      --

   VAR_DAPURC_INI_TMES_ANTER := to_char(add_months(VAR_DPROX_CARGA,-12),'DD/MM/YYYY') ;    -- INICIO TRIMESTRE ANO MES ANTERIOR
   VAR_DAPURC_FIM_TMES_ANTER := to_char(add_months(VAR_DPROX_CARGA,-9),'DD/MM/YYYY') ;     -- FIM TRIMESTRE ANO MES ANTERIOR
   --
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;
   END;
   --
END;
--
--
PROCEDURE PR_META_INICIAL_PROD_RGNAL IS  -- META INICIAL DIARIA DOS NOVOS CORRETORES
BEGIN

   	VAR_LOG  := '------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECUÇÃO CURSOR DE APURAÇÃO DA META INICIAL DA SUPEX       ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 3, NULL);
    VAR_LOG  := '------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	--
	FOR REG IN(
               SELECT CDIR_RGNAL,
                      CCPF_CNPJ_BASE,
                      CTPO_PSSOA,
			          sum(VPROD_AUTO) VPROD_RGNAL_AUTO,
			          sum(VPROD_RE) VPROD_RGNAL_RE
			    FROM (
					    -- PRODUCAO AUTO QUE NÃO TEM DESMEMBRAMENTO
					    select A.CDIR_RGNAL,
					           D.CCPF_CNPJ_BASE,
					           C.CTPO_PSSOA,
					           A.DEMIS_ENDSS DEMIS,
					           sum(A.VPRMIO_LIQ_AUTO) VPROD_AUTO,
					           0  VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_AT A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN 800000 AND 879999 )  AND
					            --B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND -- WASSA
					             A.CCRRTR            = C.CCRRTR AND
					             A.CSUCUR            = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE    = D.CCPF_CNPJ_BASE AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 1 and
					                                C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
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
					             (A.DEMIS_ENDSS >= VAR_DAPURC_INI_TMES_ANTER and
					              A.DEMIS_ENDSS < VAR_DAPURC_FIM_TMES_ANTER )
					             GROUP BY A.CDIR_RGNAL,
					                      D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DEMIS_ENDSS
					  UNION
					  -- PRODUCAO AUTO COM DESMEMBRAMENTO
					  select A.CDIR_RGNAL,
					         D.CCPF_CNPJ_BASE,
					         C.CTPO_PSSOA,
					         A.DEMIS_ENDSS DEMIS,
					         sum(A.VPRMIO_LIQ_AUTO) VPROD_AUTO,
					         0  VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_AT A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D,
					           MPMTO_AG_CRRTR E
					     WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					     (A.CCRRTR NOT BETWEEN 800000 AND 879999 )  AND
					            --(A.CCRRTR BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND -- WASSA
					             A.CCRRTR = E.CCRRTR_ORIGN AND
					             A.CSUCUR = E.CUND_PROD   AND
					             A.DEMIS_ENDSS >= E.DENTRD_CRRTR_AG AND
					             A.DEMIS_ENDSS < NVL(E.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) AND
					             E.CCRRTR_DSMEM = C.CCRRTR AND
					             E.CUND_PROD = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 1 and
					                                C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
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
					             (A.DEMIS_ENDSS >= VAR_DAPURC_INI_TMES_ANTER and
					              A.DEMIS_ENDSS < VAR_DAPURC_FIM_TMES_ANTER )
					             GROUP BY A.CDIR_RGNAL,
 					           			  D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DEMIS_ENDSS
					  UNION
					  -- PRODUCAO RE SEM DESMENBRAMENTO
					  select A.CDIR_RGNAL,
					         D.CCPF_CNPJ_BASE,
					         C.CTPO_PSSOA,
					         A.DEMIS_PRMIO DEMIS,
					         0 VPROD_AUTO,
					         sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D,
					           GRP_RAMO_CAMPA_DSTAQ E
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN 800000 AND 879999 )  AND
					            --B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND -- WASSA
					            --(A.CCRRTR NOT BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR = C.CCRRTR AND
					             A.CSUCUR = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             E.CCAMPA_DSTAQ = B.CCAMPA_DSTAQ AND
					             A.CRAMO = E.CRAMO AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 1 and
					                                C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
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
					             (A.DEMIS_PRMIO >= VAR_DAPURC_INI_TMES_ANTER and
					              A.DEMIS_PRMIO < VAR_DAPURC_FIM_TMES_ANTER )
					             GROUP BY A.CDIR_RGNAL,
					                      D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DEMIS_PRMIO
					  UNION
					  -- PRODUCAO RE COM DESMEMBRAMENTO
					  select A.CDIR_RGNAL,
					         D.CCPF_CNPJ_BASE,
					         C.CTPO_PSSOA,
					         A.DEMIS_PRMIO DEMIS,
					         0 VPROD_AUTO,
					         sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D,
					           MPMTO_AG_CRRTR E,
					           GRP_RAMO_CAMPA_DSTAQ F
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					      (A.CCRRTR BETWEEN 800000 AND 879999 )  AND
					            --B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND -- WASSA
					            --(A.CCRRTR BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
					             A.CCRRTR = E.CCRRTR_ORIGN AND
					             A.CSUCUR = E.CUND_PROD   AND
					             A.DEMIS_PRMIO >= E.DENTRD_CRRTR_AG AND
					             A.DEMIS_PRMIO < NVL(E.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) AND
					             E.CCRRTR_DSMEM = C.CCRRTR AND
					             E.CUND_PROD = C.CUND_PROD AND
					             C.CCPF_CNPJ_BASE = D.CCPF_CNPJ_BASE AND
					             F.CCAMPA_DSTAQ = B.CCAMPA_DSTAQ AND
					             A.CRAMO = F.CRAMO AND
					             NOT EXISTS (SELECT CCONTD_PARM_CARGA
					                           FROM CAMPA_PARM_CARGA_DSTAQ X
					                          WHERE X.CCAMPA_DSTAQ      = B.CCAMPA_DSTAQ AND
					                                X.CPARM_CARGA_DSTAQ = 1 and
					                                C.CCPF_CNPJ_BASE    = CCONTD_PARM_CARGA   ) AND
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
					             (A.DEMIS_PRMIO >= VAR_DAPURC_INI_TMES_ANTER and
					              A.DEMIS_PRMIO < VAR_DAPURC_FIM_TMES_ANTER )
					             GROUP BY A.CDIR_RGNAL,
					                      D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DEMIS_PRMIO
			                      )
                         GROUP BY CDIR_RGNAL,
					              CCPF_CNPJ_BASE,
					              CTPO_PSSOA
               )
    LOOP
    --
    BEGIN
            --
            --
            IF REG.VPROD_RGNAL_AUTO <= 300000 THEN
               VAR_VMETA_AUTO :=  REG.VPROD_RGNAL_AUTO * 1.2;
               IF VAR_VMETA_AUTO < VAR_VMETA_MIN_AUTO THEN
                  VAR_VMETA_AUTO := VAR_VMETA_MIN_AUTO;
               END IF;

            ELSIF  REG.VPROD_RGNAL_AUTO BETWEEN 300000.1 AND 600000  THEN
               VAR_VMETA_AUTO :=  REG.VPROD_RGNAL_AUTO * 1.1;
               IF VAR_VMETA_AUTO < VAR_VMETA_MIN_AUTO THEN
                  VAR_VMETA_AUTO := VAR_VMETA_MIN_AUTO;
               END IF;

            ELSIF  REG.VPROD_RGNAL_AUTO >= 600000.1 THEN
               VAR_VMETA_AUTO :=  REG.VPROD_RGNAL_AUTO * 1.05;
               IF VAR_VMETA_AUTO < VAR_VMETA_MIN_AUTO THEN
                  VAR_VMETA_AUTO := VAR_VMETA_MIN_AUTO;
               END IF;

            END IF;
            --
			-- CALCULO META RE
			--
            VAR_VMETA_RE :=  REG.VPROD_RGNAL_RE * 1.35;
            IF VAR_VMETA_RE < VAR_VMETA_MIN_RE THEN
               VAR_VMETA_RE := VAR_VMETA_MIN_RE;
            END IF;
		    --
            -- INCLUI A META NA TABELA META_RGNAL_DSTAQ - META REGIONAL DESTAQUE
			PR_INCR_META_RGNAL_DSTAQ (
									VAR_CCAMPA_DSTAQ,
									REG.CTPO_PSSOA ,
									REG.CCPF_CNPJ_BASE,
									REG.CDIR_RGNAL,
									VAR_DPROX_CARGA,
									VAR_VMETA_AUTO,
									VAR_VMETA_RE,
									SYSDATE);
				    --
			VAR_VMETA_AUTO       := 0 ;
			VAR_VMETA_RE         := 0  ;
			-- VAR_VPROD_RGNAL_AUTO := 0  ;
			-- VAR_VPROD_RGNAL_RE   := 0  ;
			--
          --
	      IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
	         COMMIT;
	      END IF;
          --
        END;
    END LOOP;
--
 COMMIT;
--
EXCEPTION
	WHEN OTHERS THEN
        --
    	VAR_CSIT_CTRLM := 6;
        --
         VAR_LOG := 'ERRO NO SUB-PROGRAMA que CARREGA OS DADOS PARA TABELA ' || VAR_TABELA;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 6, NULL);

        VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 7, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;

END;




----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN

	-- A VARIáVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA
   	-- COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   	VAR_CSIT_CTRLM := 1;

	--> LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
	-- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA);

	--> GRAVA LOG INICIAL DE CARGA
	VAR_LOG := 'INICIO DO PROCESSO CARGA DA TABELA '||VAR_TABELA;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

   -- TEMPO DE PROCESSAMENTO
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

	--> Grava log inicial de carga
	VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '|| VAR_CSIT_CTRLM;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

   	--> Verifica status da rotina antes de iniciar o processamento
  	VAR_LOG := 'VERIFICANDO STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.';
  	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

 	VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
 	VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA;
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

   	--> Atualiza status da rotina atual
 	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);

    --> RECUPERA PARÂMETROS DA CAMPANHA DESTAQUE
    PR_RECUPERA_PARM_APURACAO;
    VAR_LOG  := 'DATA DE APURAÇÃO: ' || TO_CHAR(VAR_DPROX_CARGA,'DD/MM/YYYY') ||
                ' -- ULTIMA DATA DE APURAÇÃO: ' || TO_CHAR(VAR_DULT_APURC_DSTAQ,'DD/MM/YYYY');
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    VAR_LOG  := 'DATA INICIO TRIMESTRE ANO MES ANTERIOR DE APURAÇÃO: ' || TO_CHAR(VAR_DAPURC_INI_TMES_ANTER,'DD/MM/YYYY') ||
                ' DATA FIM TRIMESTRE ANO MES ANTERIOR DE APURAÇÃO: : ' || TO_CHAR(VAR_DAPURC_FIM_TMES_ANTER,'DD/MM/YYYY');
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    VAR_LOG  := 'PRÊMIO DESTAQUE: ' || TO_CHAR(VAR_VPRMIO_DSTAQ) ;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	--
    VAR_LOG  := 'INICIANDO PROCESSO DE APURAÇÃO DA META INICIAL DA REGIONAL    ';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	--	
    PR_META_INICIAL_PROD_RGNAL;
    --
    VAR_LOG  := 'TOTAL DE REGISTROS INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_PROC);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    --
    --> Tempo de processamento
    --W_TEMPO_PROC :=  ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
    --VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||  TO_CHAR(W_TEMPO_PROC) ;
	--PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

	IF VAR_CSIT_CTRLM = 1 THEN

		--> Atualiza status termino da rotina
		PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
		VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PO;
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

		VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). ' ||
                   'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

		--> Grava a situacao deste processo na tabela de controle do ctrlm
		PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA,
                                  VAR_CROTNA     ,
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );
	ELSE

		RAISE VAR_FIM_PROCESSO_ERRO;

	END IF;

EXCEPTION
	WHEN VAR_FIM_PROCESSO_ERRO THEN

        --> Atualiza status termino da rotina
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE;
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = ' || VAR_CSIT_CTRLM ||
                   ' ). OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

   	    PR_GRAVA_LOG_EXCUC_CTRLM(VAR_DINIC_ROTNA,
                              	 VAR_CROTNA     ,
                                 SYSDATE        , -- DFIM_ROTNA
                                 NULL           , -- IPROG
                                 NULL           , -- CERRO
                                 VAR_LOG        , -- RERRO
                                 VAR_CSIT_CTRLM             );

	WHEN OTHERS THEN

        VAR_CSIT_CTRLM := 6;

        --> Atualiza status termino da rotina
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE;
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = 6). ' ||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '				 ||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

   	    PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA,
                              	  VAR_CROTNA     ,
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );

 END;
/

