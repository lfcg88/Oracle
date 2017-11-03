CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6002_2 IS
-------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.
--  DATA            : 08/10/2007
--  AUTOR           : JOÃO GRIMALDE - VALUE TEAM
--  PROGRAMA        : SGPB6002.SQL
--  OBJETIVO        : CARGA DIARIA DA POSIÇÃO REGIONAL DO CORRETOR COM/SEM PRODUÇÃO
--  ALTERAÇÕES      : ALTERADA A QUERY QUE PEGA AS APOLICES A SEREM PROCESSADAS.
--                    PASSOU A SER UTILIZADO O CAMPO DINCL_LCTO_PRMIO PARA DATA DE "CORTE" E NÃO A DATA DE EMISSÃO DA APOLICE.
--				      ASS. WASSILY ( 13/12/2007 )
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
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_AP		     	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE'; -- PROCESSADO COM ERRO
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;
VAR_STATUS_ROTNA_ANT	    SIT_ROTNA.CSIT_ROTNA%TYPE;
--
W_HORA_PROC_INICIAL        DATE  							:= SYSDATE;
W_TEMPO_PROC               NUMBER;
-- VARIAVEIS UTILIZADAS NO PROCESSO DE APURAÇÃO DA PRODUÇÃO DO CORRETOR
VAR_CCAMPA_DSTAQ            POSIC_CRRTR_DSTAQ.CCAMPA_DSTAQ%TYPE                := 2;   -- DEVE SER TROCADO VALOR DE RETORNO DA PROCEDURE
VAR_BASE_CNPJ_UNFCA 	    CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE%TYPE;
VAR_TPO_PSSOA               CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE;
VAR_EXISTE_PROD_COMPL       VARCHAR2(1) := 'N';
VAR_DULT_APURC_DSTAQ        DATE ;                        -- DATA DA ULTIMA APURAÇÃO DESTAQUE
VAR_VPRMIO_DSTAQ            CAMPA_DSTAQ.VPRMIO_DSTAQ%TYPE                 ;
VAR_CIND_DEB_CUPOM          CAMPA_DSTAQ.CIND_DEB_CUPOM%TYPE               ;
--
--CRGNAL
VAR_VPROD_RGNAL_RE          POSIC_RGNAL_DSTAQ.VPROD_RGNAL_RE%TYPE         ;
VAR_VPROD_RGNAL_AUTO        POSIC_RGNAL_DSTAQ.VPROD_RGNAL_AUTO%TYPE       ;
--
VAR_NRKING_PROD_RGNAL       POSIC_RGNAL_DSTAQ.NRKING_PROD_RGNAL%TYPE       ;
VAR_NRKING_PERC_CRSCT_RGNAL POSIC_RGNAL_DSTAQ.NRKING_PERC_CRSCT_RGNAL%TYPE ;
--
VAR_VPERC_CRSCT_RGNAL_AUTO  POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL_AUTO%TYPE   ;
VAR_VPERC_CRSCT_RGNAL_RE    POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL_RE%TYPE     ;
VAR_VPERC_CRSCT_RGNAL       POSIC_RGNAL_DSTAQ.VPERC_CRSCT_RGNAL%TYPE        ;
--
VAR_TOT_REG_PROC           	NUMBER := 0;
VAR_TOT_REG_COM_PROD_DIA   	NUMBER := 0;
VAR_TOT_REG_SEM_PROD_DIA   	NUMBER := 0;
--
-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - Término normal, processos dependentes podem continuar.
-- 2 - Término com alerta, processos dependentes podem continuar,
--     e o log deverá ser encaminhado ao analista.
-- 3 - Término com alerta grave, possível erro de ambiente,
--     o processo poderá ser reiniciado.
-- 4 - Término com erro, o processo não deve prosseguir.
--     O analista/DBA deverá ser notificado.
-- 5 - Término com erro crítico, o processo não deve prosseguir.
--     O analista/DBA deverá ser contactado imediatamente.
-- 6 - Término com erro desconhecido. O processo não deve continuar.
--     O analista deverá ser contactado.
--*******************************************************************
--
PROCEDURE PR_INCR_POSIC_DIA_PROD_RGNAL (
					PAR_CCAMPA_DSTAQ            IN NUMBER,
					PAR_CTPO_PSSOA              IN VARCHAR2,
					PAR_CCPF_CNPJ_BASE          IN NUMBER,
					PAR_CRGNAL                  IN NUMBER,
					PAR_DAPURC_DSTAQ            IN DATE,
					PAR_NRKING_PROD_RGNAL       IN NUMBER,
					PAR_NRKING_PERC_CRSCT_RGNAL IN NUMBER,
					PAR_VPROD_RGNAL_AUTO        IN NUMBER,
					PAR_VPROD_RGNAL_RE          IN NUMBER,
					VPERC_CRSCT_RGNAL_AUTO      IN NUMBER,
					VPERC_CRSCT_RGNAL_RE        IN NUMBER,
					PAR_DINCL_REG               IN DATE
					)IS

BEGIN
   BEGIN
   --
	  BEGIN
          -- Cadastra Produção do Corretor na tabela POSIC_CRRTR_DSTAQ
             INSERT INTO POSIC_RGNAL_DSTAQ
             ( CCAMPA_DSTAQ,
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
		       DINCL_REG,
		       DALT_REG,
           CIND_RGNAL_ALCAN_META )  -- OBS : CAMPO ACRESCENTADO POR EXISTIR MAIS UM CAMPO NA TABELA POSIC_RGNAL_DSTAQ ainda nao tem paremetro
             VALUES
             ( PAR_CCAMPA_DSTAQ,
		       PAR_CTPO_PSSOA,
		       PAR_CCPF_CNPJ_BASE,
		       PAR_CRGNAL,
		       PAR_DAPURC_DSTAQ,      -- DATA DA APURAÇÃO ATUAL
		       nvl(PAR_NRKING_PROD_RGNAL,0),
		       nvl(PAR_NRKING_PERC_CRSCT_RGNAL,0),
		       nvl(PAR_VPROD_RGNAL_AUTO,0),
		       nvl(PAR_VPROD_RGNAL_RE,0),
		       nvl(VPERC_CRSCT_RGNAL_AUTO,0),
		       nvl(VPERC_CRSCT_RGNAL_RE,0),
		       0,                 -- VPERC_CRSCT_RGNAL
		       PAR_DINCL_REG,
		       NULL ,  -- DALT_REG
           'S');  -- CAMPO SEM PARAMETRO
          --
	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODUÇÃO POR REGIONAL JÁ CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(PAR_CCAMPA_DSTAQ)||
           	           ' REGIONAL: '        || TO_CHAR(PAR_CRGNAL)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(PAR_CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURAÇÃO: '  || TO_CHAR(PAR_DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
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
            VPRMIO_DSTAQ
        INTO VAR_DULT_APURC_DSTAQ,
             VAR_VPRMIO_DSTAQ
       FROM CAMPA_DSTAQ
      WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ;

      --> RECUPERA OS DADOS DE PARAMETRO DE CARGA (O CÓDIGO DE PARâMETRO DE CARGA FOI INICIALIZADO NO DECLARE)
      PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
   --
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;
   END;
END;
--
--
PROCEDURE PR_POSIC_DIA_PROD_RGNAL IS  -- POSICAO DIARIA PRODUÇÃO DA SUPEX
BEGIN

   	VAR_LOG  := '------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECUÇÃO CURSOR DE RECUPERAÇÃO DA PRODUÇÃO DIARIA DA SUPEX ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 3, NULL);
    VAR_LOG  := '-------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	--
	FOR REG IN(
               SELECT CDIR_RGNAL, CCPF_CNPJ_BASE, CTPO_PSSOA,  DEMIS,
			          sum(VPROD_AUTO) VPROD_RGNAL_AUTO, sum(VPROD_RE) VPROD_RGNAL_RE
			    FROM (  -- PRODUCAO AUTO QUE NÃO TEM DESMEMBRAMENTO
					    select A.CDIR_RGNAL, D.CCPF_CNPJ_BASE, C.CTPO_PSSOA, A.DEMIS_ENDSS DEMIS,
					           sum(A.VPRMIO_LIQ_AUTO) VPROD_AUTO, 0  VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_AT A, CAMPA_DSTAQ B, CRRTR C, CRRTR_UNFCA_CNPJ D
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
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
					             A.DEMIS_ENDSS = VAR_DPROX_CARGA
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
					            (A.CCRRTR BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
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
					             A.DEMIS_ENDSS = VAR_DPROX_CARGA
					             GROUP BY A.CDIR_RGNAL,
 					           			  D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DEMIS_ENDSS
					  UNION
					  -- PRODUCAO RE SEM DESMENBRAMENTO
					  select A.CDIR_RGNAL,
					         D.CCPF_CNPJ_BASE,
					         C.CTPO_PSSOA,
					         --A.DEMIS_PRMIO DEMIS,
					         A.DINCL_LCTO_PRMIO DEMIS,
					         0 VPROD_AUTO,
					         sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D,
					           GRP_RAMO_CAMPA_DSTAQ E
					      WHERE B.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ AND
					            (A.CCRRTR NOT BETWEEN B.CFAIXA_INIC_DSMTO_CRRTR AND B.CFAIXA_FNAL_DSMTO_CRRTR) AND
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
					             --A.DEMIS_PRMIO =  VAR_DPROX_CARGA
					             A.DINCL_LCTO_PRMIO = VAR_DPROX_CARGA -- ALTERAÇÃO DE 13/12/2007 ( WASSILY )
					             GROUP BY A.CDIR_RGNAL,
					                      D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DINCL_LCTO_PRMIO
					  UNION
					  -- PRODUCAO RE COM DESMEMBRAMENTO
					  select A.CDIR_RGNAL,
					         D.CCPF_CNPJ_BASE,
					         C.CTPO_PSSOA,
					         --A.DEMIS_PRMIO DEMIS,
					         A.DINCL_LCTO_PRMIO DEMIS,
					         0 VPROD_AUTO,
					         sum(A.VPRMIO_EMTDO_CSSRO_CDIDO) VPROD_RE
					      from VACPROD_CRRTR_CALC_BONUS_RE A,
					           CAMPA_DSTAQ B,
					           CRRTR C,
					           CRRTR_UNFCA_CNPJ D,
					           MPMTO_AG_CRRTR E,
					           GRP_RAMO_CAMPA_DSTAQ F
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
					             -- A.DEMIS_PRMIO = VAR_DPROX_CARGA
					             A.DINCL_LCTO_PRMIO = VAR_DPROX_CARGA -- ALTERAÇÃO DE 13/12/2007 ( WASSILY )
					             GROUP BY A.CDIR_RGNAL,
					                      D.CCPF_CNPJ_BASE,
					                      C.CTPO_PSSOA,
					                      A.DINCL_LCTO_PRMIO
			                      )
                         GROUP BY CDIR_RGNAL,
					              CCPF_CNPJ_BASE,
					              CTPO_PSSOA,
              		              DEMIS
               )
    LOOP

      BEGIN

        --
        select nvl(NRKING_PROD_RGNAL,0),        -- C
		       nvl(NRKING_PERC_CRSCT_RGNAL,0),  -- D
		       nvl(VPROD_RGNAL_AUTO,0),         -- A
		       nvl(VPROD_RGNAL_RE,0),           -- B
               nvl(VPERC_CRSCT_RGNAL_AUTO,0),   -- F
		       nvl(VPERC_CRSCT_RGNAL_RE,0)     -- E
	     into  VAR_NRKING_PROD_RGNAL,
		       VAR_NRKING_PERC_CRSCT_RGNAL,
		       VAR_VPROD_RGNAL_AUTO,
		       VAR_VPROD_RGNAL_RE,
		       VAR_VPERC_CRSCT_RGNAL_AUTO,
	           VAR_VPERC_CRSCT_RGNAL_RE
        from POSIC_RGNAL_DSTAQ
         where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and CRGNAL              = REG.CDIR_RGNAL
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ  ;
          --
	      VAR_VPROD_RGNAL_AUTO           := VAR_VPROD_RGNAL_AUTO + REG.VPROD_RGNAL_AUTO;   -- G
		  VAR_VPROD_RGNAL_RE             := VAR_VPROD_RGNAL_RE   + REG.VPROD_RGNAL_RE;     -- H
          --
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		     VAR_VPROD_RGNAL_RE        := REG.VPROD_RGNAL_RE;
	         VAR_VPROD_RGNAL_AUTO      := REG.VPROD_RGNAL_AUTO;
	         --
		     VAR_NRKING_PROD_RGNAL       := 0;
		     VAR_NRKING_PERC_CRSCT_RGNAL := 0;
		     VAR_VPERC_CRSCT_RGNAL_AUTO  := 0;
		     VAR_VPERC_CRSCT_RGNAL_RE    := 0;
    	WHEN OTHERS THEN
    	    --
			VAR_CSIT_CTRLM := 6;
            --
           	VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 4, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 5, NULL);
             --
		     RAISE VAR_FIM_PROCESSO_ERRO;
      END;
      -- Cadastra Produção do Corretor na tabela POSIC_RGNAL_DSTAQ
      PR_INCR_POSIC_DIA_PROD_RGNAL (
					VAR_CCAMPA_DSTAQ            ,
					REG.CTPO_PSSOA              ,
					REG.CCPF_CNPJ_BASE          ,
					REG.CDIR_RGNAL              ,
					VAR_DPROX_CARGA             , -- DATA DA APURAÇÃO ATUAL
					VAR_NRKING_PROD_RGNAL       ,
					VAR_NRKING_PERC_CRSCT_RGNAL ,
					VAR_VPROD_RGNAL_AUTO        ,
					VAR_VPROD_RGNAL_RE          ,
					VAR_VPERC_CRSCT_RGNAL_AUTO  ,
					VAR_VPERC_CRSCT_RGNAL_RE    ,
					SYSDATE );
          --
          VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
          --
          VAR_TOT_REG_COM_PROD_DIA := VAR_TOT_REG_COM_PROD_DIA + 1;
          --
	      IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
	         COMMIT;
	      END IF;
          --
    END LOOP;
--
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

--
PROCEDURE PR_POSIC_DIA_PROD_RGNAL_COMPL IS  -- POSICAO DIARIA PRODUÇÃO SUPEX COMPLEMENTAR
BEGIN
    --
   	VAR_LOG  := '------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECUÇÃO CURSOR DE RECUPERAÇÃO DA PRODUÇÃO DA SUPEX COMPLEMENTAR ';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 8, NULL);
    VAR_LOG  := '------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	--
	FOR REG IN(
	           -- Seleciona Registros da Campanha do dia Anterior
	            select CCAMPA_DSTAQ,
                       CCPF_CNPJ_BASE,
                       CTPO_PSSOA,
                       CRGNAL
                  from POSIC_RGNAL_DSTAQ
                 where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                   and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ
                minus
	           -- Seleciona Registros da Campanha do dia Atual
                select CCAMPA_DSTAQ,
                       CCPF_CNPJ_BASE,
                       CTPO_PSSOA,
                       CRGNAL
                  from POSIC_RGNAL_DSTAQ
                 where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                   and TRUNC(DAPURC_DSTAQ) = VAR_DPROX_CARGA
               )
    LOOP
      BEGIN
       --
        --
        select nvl(VPROD_RGNAL_AUTO,0),
               nvl(VPROD_RGNAL_RE,0),
               nvl(NRKING_PROD_RGNAL,0),        -- C
		       nvl(NRKING_PERC_CRSCT_RGNAL,0),  -- D
		       nvl(VPROD_RGNAL_AUTO,0),         -- A
		       nvl(VPROD_RGNAL_RE,0),           -- B
               nvl(VPERC_CRSCT_RGNAL_AUTO,0),   -- F
		       nvl(VPERC_CRSCT_RGNAL_RE,0)      -- E
	     into  VAR_VPROD_RGNAL_AUTO,
	           VAR_VPROD_RGNAL_RE,
	           VAR_NRKING_PROD_RGNAL,
		       VAR_NRKING_PERC_CRSCT_RGNAL,
		       VAR_VPROD_RGNAL_AUTO,
		       VAR_VPROD_RGNAL_RE,
		       VAR_VPERC_CRSCT_RGNAL_AUTO,
	           VAR_VPERC_CRSCT_RGNAL_RE
         from POSIC_RGNAL_DSTAQ
         where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and CRGNAL              = REG.CRGNAL
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ  ;
          --
           VAR_EXISTE_PROD_COMPL    := 'S' ;
          --
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	     VAR_EXISTE_PROD_COMPL    := 'N' ;
    	WHEN OTHERS THEN
    	    --
			VAR_CSIT_CTRLM := 6;
            --
           	VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 9, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 10, NULL);
             --
		     RAISE VAR_FIM_PROCESSO_ERRO;
      END;
      IF VAR_EXISTE_PROD_COMPL = 'S' THEN
      -- Cadastra Produção do Corretor na tabela POSIC_RGNAL_DSTAQ
      PR_INCR_POSIC_DIA_PROD_RGNAL (
					VAR_CCAMPA_DSTAQ            ,
					REG.CTPO_PSSOA              ,
					REG.CCPF_CNPJ_BASE          ,
					REG.CRGNAL                  ,
					VAR_DPROX_CARGA             , -- DATA DA APURAÇÃO ATUAL
					VAR_NRKING_PROD_RGNAL       ,
					VAR_NRKING_PERC_CRSCT_RGNAL ,
					VAR_VPROD_RGNAL_AUTO        ,
					VAR_VPROD_RGNAL_RE          ,
					VAR_VPERC_CRSCT_RGNAL_AUTO  ,
					VAR_VPERC_CRSCT_RGNAL_RE    ,
					SYSDATE );
	          --
	          VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
	          --
              VAR_TOT_REG_SEM_PROD_DIA := VAR_TOT_REG_SEM_PROD_DIA + 1;
              --
		      IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
		         COMMIT;
		      END IF;
	          --
      END IF;
    END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;
END;
--
------------------------------------  PROGRAMA PRINCIPAL  ------------------------------------
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
    VAR_LOG  := 'PRÊMIO DESTAQUE: ' || TO_CHAR(VAR_VPRMIO_DSTAQ) ;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	--
    VAR_LOG  := 'INICIANDO PROCESSO DE APURAÇÃO DA PRODUÇÃO DO CORRETOR';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);

  -- Limpeza dos dados da tabela POSIC_RGNAL_DSTAQ do dia = VAR_DPROX_CARGA

    DELETE POSIC_RGNAL_DSTAQ
    WHERE  DAPURC_DSTAQ = VAR_DPROX_CARGA AND CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ; -- AQUI NÃO TINHA A CAMPANHA. ASS. WASSILY
    COMMIT;

	--  Start das procedures de inclusao na tabela POSIC_RGNAL_DSTAQ
    PR_POSIC_DIA_PROD_RGNAL;
    --
    PR_POSIC_DIA_PROD_RGNAL_COMPL;

	-- Fim do START

    VAR_LOG  := 'TOTAL DE REGISTROS COM PRODUÇÃO INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_COM_PROD_DIA);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
	--
    VAR_LOG  := 'TOTAL DE REGISTROS DE PRODUÇÃO NOVA INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_SEM_PROD_DIA);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
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

