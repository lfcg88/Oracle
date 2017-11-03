CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6702 IS
---------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROGRAMA         : sgpb6520.SQL
--      AUTOR            : HUGO CARDOSO - VALUE TEAM IT CONSULTING
--      DATA             : 04/03/2008
--      OBJETIVO         : CARGA NA TABELA GRP_FNASA_DSTAQ
--      FREQUENCIA       : TRIMESTRAL
----------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO
VAR_ERRO 		   		    VARCHAR2(1) 						:= 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE        	:= 'P';
VAR_LOG_DADO                LOG_CARGA.CTPO_REG_LOG%TYPE        	:= 'D';
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE     :=  1;
VAR_TOT_REG_LIDO_BODY       NUMBER;
VAR_TOT_REG_PROC            NUMBER;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_CCAMPA_DSTAQ            GRP_FNASA_DSTAQ.CCAMPA_DSTAQ%TYPE;
VAR_CTPO_PSSOA              GRP_FNASA_DSTAQ.CTPO_PSSOA%TYPE;
VAR_CCPF_CNPJ_BASE          GRP_FNASA_DSTAQ.CCPF_CNPJ_BASE%TYPE;
VAR_CGRP_FNASA              GRP_FNASA_DSTAQ.CGRP_FNASA%TYPE;
VAR_IGRP_FNASA              GRP_FNASA_DSTAQ.IGRP_FNASA%TYPE;
VAR_DINCL_REG               GRP_FNASA_DSTAQ.DINCL_REG%TYPE       := SYSDATE;
VAR_DALT_REG                GRP_FNASA_DSTAQ.DALT_REG%TYPE        := SYSDATE;
--
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_STATUS_PROCESSANDO	   VARCHAR2(02)			            	:= 'PC';
VAR_STATUS_PROCESSADO_OK   VARCHAR2(02)				            := 'PO';
VAR_STATUS_ERRO	   	   	   VARCHAR2(02)			             	:= 'PE';
VAR_STATUS_ROTNA	   	     VARCHAR2(02);
--
-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO
VAR_ARQUIVO                UTL_FILE.FILE_TYPE;
VAR_REGISTRO_ARQUIVO       VARCHAR2(500);
VAR_CAMBTE                 ARQ_TRAB.CAMBTE%TYPE;              	-- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                  ARQ_TRAB.CSIST%TYPE                	:= 'SGPB';
VAR_CROTNA                 ARQ_TRAB.CROTNA%TYPE               	:= 'SGPB6702';
VAR_CTPO_ACSSO             ARQ_TRAB.CTPO_ACSSO%TYPE           	:= 'R';
VAR_IARQ_TRAB              ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB            DTRIO_TRAB.IDTRIO_TRAB%TYPE;
--
-- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
VAR_CSEQ_ARQ_TRAB          ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE        	:= 1;
--
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                  PARM_CARGA.CPARM%TYPE              	:= 670; -- PARAMETRO DE CARGA PARA OS DADOS DE REDE
VAR_DCARGA                 PARM_CARGA.DCARGA%TYPE;
VAR_DPROX_CARGA            PARM_CARGA.DPROX_CARGA%TYPE;
VAR_DINIC_ROTNA            DATE                                 := SYSDATE;

-- VARIAVEL REFERENTE A TABELA ALVO
WROW                       HIERQ_PBLIC_ALVO%ROWTYPE;
/* ***************************************************************** */
PROCEDURE TRATA_PARAMETRO IS
--
BEGIN
   --
    VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   IF VAR_CAMBTE NOT IN ('DESV','PROD') THEN
 	   VAR_LOG := 'PARAMETRO INVALIDO. AMBIENTE INFORMADO NO PARAMETRO: ' || VAR_CAMBTE;
     	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		VAR_LOG := null;
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;
   --
   VAR_LOG := 'PARAMETRO DE AMBIENTE INFORMADO: ' || VAR_CAMBTE;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   VAR_LOG := null;
   --
   COMMIT;
   --
-- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_LOG := 'DATA DA ULTIMA CARGA: ' || TO_CHAR(VAR_DCARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --
   VAR_LOG := 'DATA DA PROXIMA CARGA: ' || TO_CHAR(VAR_DPROX_CARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --      
EXCEPTION
   WHEN OTHERS THEN
        VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: ' || SUBSTR( SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		VAR_LOG := null;
        --
        RAISE VAR_FIM_PROCESSO_ERRO;
END TRATA_PARAMETRO;
--   
/* ***************************************************************** */
--
PROCEDURE ABRE_ARQUIVO IS
BEGIN
--
   BEGIN
      PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                            VAR_CSIST,
                            VAR_CROTNA,
                            VAR_CTPO_ACSSO, 
                            VAR_CSEQ_ARQ_TRAB, 
                            VAR_IDTRIO_TRAB, 
                            VAR_IARQ_TRAB );
--
      VAR_LOG := 'DIRET�RIO: '  || VAR_IDTRIO_TRAB ||
                 ' -- ARQUIVO: '    || VAR_IARQ_TRAB;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      VAR_LOG := 'ABRINDO ARQUIVO DE CARGA.';
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB, VAR_CTPO_ACSSO);
--
      IF NOT UTL_FILE.IS_OPEN(VAR_ARQUIVO) THEN 
--
         VAR_CSIT_CTRLM := 6;   
--
         VAR_LOG := 'ERRO NA ABERTURA DO ARQUIVO.'||
                    ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
         --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
         UTL_FILE.FCLOSE(VAR_ARQUIVO);
         RAISE VAR_FIM_PROCESSO_ERRO;
--
      END IF;
--
   EXCEPTION
      WHEN OTHERS THEN
--
           VAR_CSIT_CTRLM := 6;
--
           VAR_LOG := 'ERRO AO TENTAR ABRIR O ARQUIVO USANDO UTL_FILE.FOPEN.'||
                      ' -- DIRETORIO: '  || VAR_IDTRIO_TRAB ||
                      ' -- ARQUIVO: '    || VAR_IARQ_TRAB||
                      ' -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
           --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
           RAISE VAR_FIM_PROCESSO_ERRO;
--
   END;
--
   -- RECUPERA OS DADOS DE PAR�METRO DE CARGA
   PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_LOG := 'DATA DA �LTIMA CARGA: ' || TO_CHAR(VAR_DCARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));                                           
--      
   VAR_LOG := 'DATA DA PR�XIMA CARGA: ' || TO_CHAR(VAR_DPROX_CARGA, 'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));
--
   COMMIT;   
--
EXCEPTION
   WHEN OTHERS THEN
--
        VAR_CSIT_CTRLM := 6;
        VAR_LOG  := 'ERRO NO ABRE_ARQUIVO. -- ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        --DBMS_OUTPUT.PUT_LINE(SUBSTR(VAR_LOG,1,255));   
--
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE VAR_FIM_PROCESSO_ERRO;
--
END ABRE_ARQUIVO;
--
-------------------------------------------------------------------------------------------------------
--
PROCEDURE INSERE_GRP_FNASA IS
--
VAR_EXISTE_CPF_CNPJ   	NUMBER		   :=0;
--
BEGIN
    --
    SELECT COUNT(*) INTO VAR_EXISTE_CPF_CNPJ FROM CRRTR_UNFCA_CNPJ
     WHERE VAR_CCPF_CNPJ_BASE = CCPF_CNPJ_BASE
       AND VAR_CTPO_PSSOA = CTPO_PSSOA;
    --
	IF (VAR_EXISTE_CPF_CNPJ = 0) THEN
    --
    IF (VAR_CTPO_PSSOA = 'F') THEN
        VAR_LOG := 'O SEGUINTE CPF N�O EXISTE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
    --
    ELSE
        VAR_LOG := 'O SEGUINTE CNPJ N�O EXISTE: '||TO_CHAR(VAR_CCPF_CNPJ_BASE);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
    --
    END IF;
    --                                                                                 
		RAISE VAR_FIM_PROCESSO_ERRO;
    --
  ELSE
	--
  --    
 
  INSERT INTO GRP_FNASA_DSTAQ
       (
        CCAMPA_DSTAQ,
        CTPO_PSSOA,  
        CCPF_CNPJ_BASE,
        CGRP_FNASA,    
        IGRP_FNASA,    
        DINCL_REG,     
        DALT_REG
       )
  VALUES
       (
        VAR_CCAMPA_DSTAQ,
        VAR_CTPO_PSSOA,
        VAR_CCPF_CNPJ_BASE,
        VAR_CGRP_FNASA,              
        VAR_IGRP_FNASA,              
        VAR_DINCL_REG,               
        VAR_DALT_REG
       );
  --
  --
  END IF;
  --
	--
END INSERE_GRP_FNASA;
--
-----------------------------------------------------------------------
--
PROCEDURE CARREGA_DETALHE IS
--
BEGIN
 --
 VAR_ERRO                     := 'N';
 WROW.CCANAL_PROD_DW          := NULL;
 WROW.CCPF_CNPJ_BASE          := NULL;
 WROW.CTPO_PSSOA              := NULL;
  
 
-- SEQU�NCIA DE EXTRA��O DOS DADOS DO ARQUIVO
--
-- 1) C�DIGO DA CAMPANHA DESTAQUE

 BEGIN
  VAR_CCAMPA_DSTAQ       := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 1, 6));
  --
  --
  EXCEPTION
 	WHEN OTHERS THEN
 		   VAR_CCAMPA_DSTAQ	:= NULL;
       VAR_ERRO 	        	:= 'S';
 		   VAR_CSIT_CTRLM       	:= 2;

 		--
		VAR_LOG := '01-ERRO DE FORMATO. C�DIGO DA CAMPANHA DESTAQUE. ';
		--
 		VAR_LOG := VAR_LOG || 'CCAMPA_DSTAQ: ' || TO_CHAR(VAR_CCAMPA_DSTAQ)
		                   || 'ERRO ORACLE: '  || SUBSTR( SQLERRM, 1, 120);
		--
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
		VAR_LOG := null;
			--
 END;
 --
 -- 2) C�DIGO DO TIPO DE PESSOA

 BEGIN
  VAR_CTPO_PSSOA       := SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 1);
  --
  --
  EXCEPTION
 	WHEN OTHERS THEN
 		   VAR_CTPO_PSSOA    	:= NULL;
       VAR_ERRO 	        := 'S';
 		   VAR_CSIT_CTRLM     := 2;
 		--
		VAR_LOG := '01-ERRO DE FORMATO. C�DIGO DO TIPO PESSOA. ';
		--
 		VAR_LOG := VAR_LOG || 'CTPO_PSSOA: ' || VAR_CTPO_PSSOA
		                   || 'ERRO ORACLE: '  || SUBSTR( SQLERRM, 1, 120);
		--
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
		VAR_LOG := null;
			--
 END;
  --
 -- 3) C�DIGO DO CPF CNPJ BASE

 BEGIN
  VAR_CCPF_CNPJ_BASE       := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 8, 9));
  --
  --
  EXCEPTION
 	WHEN OTHERS THEN
 		   VAR_CCPF_CNPJ_BASE    	:= NULL;
       VAR_ERRO 	        := 'S';
 		   VAR_CSIT_CTRLM     := 2;
 		--
		VAR_LOG := '01-ERRO DE FORMATO. C�DIGO DO CPF/CNPJ BASE. ';
		--
 		VAR_LOG := VAR_LOG || 'VAR_CCPF_CNPJ_BASE: ' || VAR_CTPO_PSSOA
		                   || 'ERRO ORACLE: '  || SUBSTR( SQLERRM, 1, 120);
		--
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
		VAR_LOG := null;
			--
 END;
   --
 -- 4) C�DIGO DO GRUPO FINASA

 BEGIN
  VAR_CGRP_FNASA       := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 17, 6));
  --
  --
  EXCEPTION
 	WHEN OTHERS THEN
 		   VAR_CGRP_FNASA    	:= NULL;
       VAR_ERRO 	        := 'S';
 		   VAR_CSIT_CTRLM     := 2;
 		--
		VAR_LOG := '01-ERRO DE FORMATO. C�DIGO DO GRUPO FINASA. ';
		--
 		VAR_LOG := VAR_LOG || 'VAR_CGRP_FNASA: ' || TO_CHAR(VAR_CGRP_FNASA)
		                   || 'ERRO ORACLE: '  || SUBSTR( SQLERRM, 1, 120);
		--
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
		VAR_LOG := null;
			--
 END;
    --
 -- 4) NOME DO GRUPO FINASA

 BEGIN
  VAR_IGRP_FNASA       := SUBSTR(VAR_REGISTRO_ARQUIVO, 23, 20);
  --
  --
  EXCEPTION
 	WHEN OTHERS THEN
 		   VAR_IGRP_FNASA    	:= NULL;
       VAR_ERRO 	        := 'S';
 		   VAR_CSIT_CTRLM     := 2;
 		--
		VAR_LOG := '01-ERRO DE FORMATO. NOME DO GRUPO FINASA. ';
		--
 		VAR_LOG := VAR_LOG || 'VAR_IGRP_FNASA: ' || TO_CHAR(VAR_CGRP_FNASA)
		                   || 'ERRO ORACLE: '  || SUBSTR( SQLERRM, 1, 120);
		--
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_DADO, NULL, NULL);
		VAR_LOG := null;
			--
 END;  
 
 --
 -- 
 -- INSER��O NA TABELA DE GRUPO FINASA
    INSERE_GRP_FNASA;
 --
 --
 --
END CARREGA_DETALHE;
/* *******************************************************************/
PROCEDURE TRATA_BODY IS
--
--
BEGIN
   --
   VAR_LOG := 'DADOS DO ARQUIVO DE CARGA. INICIANDO TRATAMENTO DO BODY.';
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
   --
   VAR_TOT_REG_LIDO_BODY := 0;
   VAR_TOT_REG_PROC      := 0;
   --
   LOOP
      BEGIN
         UTL_FILE.GET_LINE( VAR_ARQUIVO, VAR_REGISTRO_ARQUIVO);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN  -- FIM DE ARQUIVO
              UTL_FILE.FCLOSE( VAR_ARQUIVO);
              EXIT;
      END;
      --      
         VAR_TOT_REG_LIDO_BODY := VAR_TOT_REG_LIDO_BODY + 1;
         --     
         CARREGA_DETALHE;         -- INSER��O!!
         --     
   END LOOP;
   --
   COMMIT;
   --   
EXCEPTION
   WHEN OTHERS THEN
      VAR_LOG := 'ERRO NO TRATA BODY. REGISTRO: '|| SUBSTR( VAR_REGISTRO_ARQUIVO, 1, 200);
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      --
      VAR_LOG := 'ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	--
      UTL_FILE.FCLOSE( VAR_ARQUIVO);
      RAISE VAR_FIM_PROCESSO_ERRO;
   	--
END TRATA_BODY;
--
--------------------------------  PROGRAMA PRINCIPAL  -----------------------------
--
BEGIN

   -- VERIFICA STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO, SE ESTIVER COM
   -- STATUS DE PROCESSADO-OK ('PO') OU PROCESSANDO ('PC'), O PROCESSAMENTO N�O SER� FEITO

    VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM);
    
   -- ATUALIZA STATUS DA ROTINA
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_PROCESSANDO);         

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
   PR_LIMPA_LOG_CARGA ( VAR_CROTNA );

	VAR_LOG := 'VERIFICA STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.... ' || VAR_STATUS_ROTNA;
--    DBMS_OUTPUT.PUT_LINE('VERIFICA STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.... ' || VAR_STATUS_ROTNA);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
     COMMIT;     
   
   -- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   VAR_LOG := 'LIMPA A TABELA DE LOG NO INICIO DO PROCESSO ' || VAR_CROTNA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
     COMMIT;

   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DA TABELA GRP_FNASA_DSTAQ NO NI';
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
     COMMIT;
    --
    -- TRATA O PARAMETRO DO PROCESSO
   VAR_LOG := 'TRATA O PARAMETRO DO PROCESSO - TRATA_PARAMETRO' ;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
   TRATA_PARAMETRO; 	-- PROCEDURE INTERNA (SUB-PROGRAMA)
   --        
   -- ABRE ARQUIVO
   VAR_LOG := 'TRATA O PARAMETRO DO PROCESSO - TRATA_PARAMETRO' ;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
   ABRE_ARQUIVO;
   --
   -- PROCESSA ARQUIVO (CARREGA A TABELA)
   VAR_LOG := 'PROCESSA ARQUIVO (CARREGA A TABELA GRP_FNASA_DSTAQ) - TRATA_BODY' ;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
   TRATA_BODY;		-- PROCEDURE INTERNA (SUB-PROGRAMA)
   ----
    IF VAR_CSIT_CTRLM = 1 THEN
      VAR_LOG  := 'TOTAL DE REGISTROS PROCESSADOS NO NI: '      || TO_CHAR(VAR_TOT_REG_PROC);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      VAR_LOG :=  'TERMINO NORMAL DO PROCESSO(STATUS = 1).  OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	  COMMIT;
   ELSIF VAR_CSIT_CTRLM = 2 THEN
      VAR_LOG := 'TOTAL DE REGISTROS PROCESSADOS NO NI: '      || TO_CHAR(VAR_TOT_REG_PROC);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      VAR_LOG := 'TERMINO NORMAL DO PROCESSO(STATUS = 1).  OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	  COMMIT;
   ELSIF VAR_CSIT_CTRLM = 6 THEN
      -- ATUALIZA STATUS DA ROTINA
      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_ERRO);
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;
-- ---------------------------------------------------------------------------------------------------------------
-- GRAVA A SITUACAO DESTE PROCESSO NA TABELA DE CONTROLE DO CTRLM
-- EM CASO DE ERRO ESTA GRAVACAO SO SERA FEITA NA EXCEPTION
   PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA,
                              VAR_CROTNA     ,
                              SYSDATE        , -- DFIM_ROTNA
                              NULL           , -- IPROG
                              NULL           , -- CERRO
                              VAR_LOG        , -- RERRO
                              VAR_CSIT_CTRLM             );

   -- ATUALIZA STATUS DA ROTINA
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_PROCESSADO_OK);
	--
   VAR_LOG := 'FIM PROCESSO. '  || VAR_CROTNA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   commit;
   --
EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        VAR_CSIT_CTRLM := 6;
        --
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO(STATUS = 6). ' ||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '      ||
                   'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, VAR_CROTNA, SYSDATE, NULL, NULL, VAR_LOG, VAR_CSIT_CTRLM );
        -- ATUALIZA STATUS DA ROTINA
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_ERRO);
   WHEN OTHERS THEN
        VAR_CSIT_CTRLM := 6;
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO(STATUS = 6). ' ||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '      ||
                   'O ANALISTA DEVERA SER CONTACTADO.';
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, VAR_CROTNA, SYSDATE, NULL, NULL, SQLERRM, VAR_CSIT_CTRLM );
        -- ATUALIZA STATUS DA ROTINA
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_ERRO);
--        
END SGPB6702;
/
