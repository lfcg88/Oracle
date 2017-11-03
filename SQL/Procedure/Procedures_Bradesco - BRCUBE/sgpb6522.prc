CREATE OR REPLACE PROCEDURE SGPB_PROC.sgpb6522 IS
---------------------------------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROGRAMA         : sgpb6522.SQL
--      AUTOR            : HUGO CARDOSO - VALUE TEAM IT CONSULTING
--      DATA             : 06/03/2008
--      OBJETIVO         : VERIFICA QUEM NÃO TEM META CADASTRADA PARA AQUELA CAMPANHA
--      FREQUENCIA       : DIÁRIO
----------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE        	:= 'P';
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE     :=  1;
VAR_TOT_REG_PROC            NUMBER;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_DAPURC_DSTAQ			CAMPA_DSTAQ.DAPURC_DSTAQ%TYPE;
VAR_META_MIN_AUTO			META_DSTAQ.VMETA_AUTO%TYPE;
VAR_META_MIN_RE				META_DSTAQ.VMETA_AUTO%TYPE;

-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_STATUS_PROCESSANDO	   VARCHAR2(02)			            	:= 'PC';
VAR_STATUS_PROCESSADO_OK   VARCHAR2(02)				            := 'PO';
VAR_STATUS_ERRO	   	   	   VARCHAR2(02)			             	:= 'PE';
VAR_STATUS_ROTNA	   	     VARCHAR2(02);
--
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CROTNA                 ARQ_TRAB.CROTNA%TYPE               	:= 'SGPB6522';
VAR_CPARM                  PARM_CARGA.CPARM%TYPE              	:= 635; -- PARAMETRO DE CARGA PARA OS DADOS DE REDE
VAR_DINIC_ROTNA            DATE                                 := SYSDATE;
--
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
PROCEDURE CALCULA_META (PI_CCAMPA CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE) IS
--
BEGIN
     VAR_TOT_REG_PROC := 0;
     --     
     FOR REG IN (SELECT PD.CHIERQ_PBLIC_ALVO_DSTAQ,
					    PD.DAPURC_DSTAQ,
					    MD.VMETA_AUTO,
					    PD.CPARM_HIERQ_DSTAQ,
					    MD.VMETA_RE,
					    PD.CCANAL_PROD_DW
                   FROM POSIC_DSTAQ PD, META_DSTAQ MD
                  WHERE PD.CCAMPA_DSTAQ            = MD.CCAMPA_DSTAQ (+)
					AND PD.CHIERQ_PBLIC_ALVO_DSTAQ = MD.CHIERQ_PBLIC_ALVO_DSTAQ (+)
					AND PD.CPARM_HIERQ_DSTAQ       = MD.CPARM_HIERQ_DSTAQ (+)
					AND PD.CCANAL_PROD_DW          = MD.CCANAL_PROD_DW (+)
					AND PD.DAPURC_DSTAQ            = VAR_DAPURC_DSTAQ
					AND PD.CCAMPA_DSTAQ            = PI_CCAMPA                    
                 )
             LOOP
                 BEGIN
                      IF (REG.CCANAL_PROD_DW = 3 OR REG.CCANAL_PROD_DW = 5) THEN
                      --
                         IF (REG.VMETA_AUTO IS NULL AND REG.VMETA_RE IS NOT NULL) THEN
                         --
                           INSERT INTO META_DSTAQ
                           ( 
                           CCAMPA_DSTAQ,
                           CHIERQ_PBLIC_ALVO_DSTAQ,
                           DAPURC_DSTAQ,
                           VMETA_AUTO,
                           CPARM_HIERQ_DSTAQ,
                           DINCL_REG,
                           CCANAL_PROD_DW
                           )
                           values
                           (
                           PI_CCAMPA,
                           REG.CHIERQ_PBLIC_ALVO_DSTAQ,
                           VAR_DAPURC_DSTAQ,
                           VAR_META_MIN_AUTO,
                           REG.CPARM_HIERQ_DSTAQ,
                           SYSDATE,
                           REG.CCANAL_PROD_DW
                           );
                           --
                           --
                           VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
                           --
                         ELSIF (REG.VMETA_AUTO IS NOT NULL AND REG.VMETA_RE IS NULL) THEN
                         --
                           INSERT INTO META_DSTAQ
                           ( 
                           CCAMPA_DSTAQ,
                           CHIERQ_PBLIC_ALVO_DSTAQ,
                           DAPURC_DSTAQ,
                           CPARM_HIERQ_DSTAQ,
                           VMETA_RE,
                           DINCL_REG,
                           CCANAL_PROD_DW
                           )
                           values
                           (
                           PI_CCAMPA,
                           REG.CHIERQ_PBLIC_ALVO_DSTAQ,
                           VAR_DAPURC_DSTAQ,
                           REG.CPARM_HIERQ_DSTAQ,
                           VAR_META_MIN_RE,
                           SYSDATE,
                           REG.CCANAL_PROD_DW
                           );
                           --
                           --
                           VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
                           --                         
                         ELSE
                         --
                           INSERT INTO META_DSTAQ
                           ( 
                           CCAMPA_DSTAQ,
                           CHIERQ_PBLIC_ALVO_DSTAQ,
                           DAPURC_DSTAQ,                           
                           CPARM_HIERQ_DSTAQ,
                           VMETA_AUTO,
                           VMETA_RE,
                           DINCL_REG,
                           CCANAL_PROD_DW
                           )
                           values
                           (
                           PI_CCAMPA,
                           REG.CHIERQ_PBLIC_ALVO_DSTAQ,
                           VAR_DAPURC_DSTAQ,                           
                           REG.CPARM_HIERQ_DSTAQ,
                           VAR_META_MIN_AUTO,
                           VAR_META_MIN_RE,
                           SYSDATE,
                           REG.CCANAL_PROD_DW
                           );
                           --
                           --
                           VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
                           --
                          END IF;                                                    
                        ELSIF (REG.CCANAL_PROD_DW = 4 OR REG.CCANAL_PROD_DW = 8) THEN
                            UPDATE POSIC_DSTAQ
                               SET CIND_FALTA_META = 'S', DALT_REG = SYSDATE
                             WHERE CCAMPA_DSTAQ = PI_CCAMPA
                               AND CHIERQ_PBLIC_ALVO_DSTAQ = REG.CHIERQ_PBLIC_ALVO_DSTAQ
                               AND CPARM_HIERQ_DSTAQ = REG.CPARM_HIERQ_DSTAQ;
                               --    
                           --
                           VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;
                           --                               
                        END IF;
                        --
                 EXCEPTION
                        WHEN OTHERS THEN
                             VAR_LOG := 'ERRO NO SUB-PROGRAMA QUE CARREGA TABELA META_DSTAQ';
               	             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
                             --
                             ROLLBACK;
                             --
                             COMMIT;
                             --
                             VAR_LOG := 'ERRO ORACLE: '|| SUBSTR( SQLERRM, 1, 120);
                             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
                             --
                             COMMIT;
                             --
                             RAISE VAR_FIM_PROCESSO_ERRO;
                             --
                END;
            END LOOP;
    --
    COMMIT;
    --
     VAR_LOG := 'TOTAL DE REGISTROS INSERIDOS: '|| TO_CHAR(VAR_TOT_REG_PROC);
               	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
                --
     COMMIT;
    --
END CALCULA_META;
--
-----------------------------------------------------------------------
--
/* *******************************************************************/
--
--------------------------------  PROGRAMA PRINCIPAL  -----------------------------
--
BEGIN

   -- VERIFICA STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO, SE ESTIVER COM
   -- STATUS DE PROCESSADO-OK ('PO') OU PROCESSANDO ('PC'), O PROCESSAMENTO NÃO SERÁ FEITO

    VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM);
    
   -- ATUALIZA STATUS DA ROTINA
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_PROCESSANDO);         

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
   PR_LIMPA_LOG_CARGA ( VAR_CROTNA );

	VAR_LOG := 'VERIFICA STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.... ' || VAR_STATUS_ROTNA;
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
     COMMIT;     
   
   -- (O TRIGGER JOGARA AS INFORMACOES PARA A TABELA DE HISTORICO)
   VAR_LOG := 'LIMPA A TABELA DE LOG NO INICIO DO PROCESSO ' || VAR_CROTNA;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
     COMMIT;

   /*-- INICIO DO PROCESSO DE PREENCHIMENTO DE META MÍNIMA NA TABELA META_DSTAQ NO NI
   VAR_LOG := 'INICIO DO PROCESSO DE PREENCHIMENTO DE META MÍNIMA NA TABELA META_DSTAQ NO NI';
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
   --
   INSERE_META_DSTAQ;*/
   
   VAR_DAPURC_DSTAQ	:= NULL;
	--SELECIONA TODAS AS CAMPANHAS ATIVAS	
	FOR CUR_CAMPA IN (SELECT CCAMPA_DSTAQ,ICAMPA_DSTAQ,DAPURC_DSTAQ
					  FROM CAMPA_DSTAQ
					  WHERE CIND_CAMPA_ATIVO = 'S'
					  ORDER BY CCAMPA_DSTAQ) LOOP

		VAR_LOG := '----------INICIO DO CALCULO DA META INICIAL/REPROCESSO DA CAMPANHA: '||
				   CUR_CAMPA.CCAMPA_DSTAQ||' - '||CUR_CAMPA.ICAMPA_DSTAQ;
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
		
  		--USA O PACOTE DE PARAMETROS DA DESTAQUE PARA CALCULAR AS DT PARA O CALCULO DAS METAS
		--VAR_DINIC_META	:=	PC_PARAMETROS_DESTAQUE.FC_PER_INIC_META_CAMPA(CUR_CAMPA.CCAMPA_DSTAQ);			
		--VAR_DFIM_META	:=	PC_PARAMETROS_DESTAQUE.FC_PER_FIM_META_CAMPA(CUR_CAMPA.CCAMPA_DSTAQ);
		
		--RECUPERA OS VALORES MINIMOS DE META
		VAR_META_MIN_AUTO	:=	PC_PARAMETROS_DESTAQUE.FC_RCUPD_META_MIN_AUTO(CUR_CAMPA.CCAMPA_DSTAQ);
		VAR_META_MIN_RE		:=	PC_PARAMETROS_DESTAQUE.FC_RCUPD_META_MIN_RE(CUR_CAMPA.CCAMPA_DSTAQ);
		
		VAR_DAPURC_DSTAQ	:= CUR_CAMPA.DAPURC_DSTAQ;

		--SUBPROGRAMA QUE CALCULA A META
		CALCULA_META(CUR_CAMPA.CCAMPA_DSTAQ);
		
		VAR_LOG := '----------TOTAL DE METAS PROCESSADAS PARA A CAMPANHA '||CUR_CAMPA.CCAMPA_DSTAQ||' '||CUR_CAMPA.ICAMPA_DSTAQ
				|| ': '||VAR_TOT_REG_PROC;
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG,VAR_LOG_PROCESSO,NULL,NULL);
			
	END LOOP;
     

    IF VAR_CSIT_CTRLM = 1 THEN
      VAR_LOG :=  'TERMINO NORMAL DO PROCESSO(STATUS = 1).  OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	  COMMIT;
   ELSIF VAR_CSIT_CTRLM = 2 THEN
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
END sgpb6522;
/

