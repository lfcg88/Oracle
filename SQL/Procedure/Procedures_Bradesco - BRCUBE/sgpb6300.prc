CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6300 IS
-------------------------------------------------------------------------------------------------
-- BRADESCO SEGUROS S.A.
-- DATA            : 22/10/2007
-- AUTOR           : WASSILY CHUK SEIBLITZ GUANAES
-- PROGRAMA        : SGPB6300.SQL
-- OBJETIVO        : Refresh da view VACPROD_CRRTR_DSTAQ
-------------------------------------------------------------------------------------------------
VAR_CPARM               	PARM_CARGA.CPARM%TYPE               := 857;
VAR_CROTNA               	ARQ_TRAB.CROTNA%TYPE                := 'SGPB6300'; 
VAR_VIEW_MATERIALIZADA      VARCHAR2(100)                       := 'VACPROD_CRRTR_DSTAQ';
VAR_LOG                 	LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        	LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P';
VAR_STATUS_PROCESSANDO	    VARCHAR2(02)				        := 'PC';
VAR_STATUS_PROCESSADO_OK    VARCHAR2(02)				        := 'PO';
VAR_STATUS_ERRO	   	   		VARCHAR2(02)				        := 'PE';
VAR_STATUS_ROTNA	        VARCHAR2(02);
VAR_CSIT_CTRLM          	SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;  
VAR_DINIC_ROTNA         	DATE                                := SYSDATE;
BEGIN
    PR_LIMPA_LOG_CARGA (VAR_CROTNA);
    PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_PROCESSANDO);
    VAR_LOG := 'INICIO DO PROCESSO DE ATUALIZAÇÃO DA VIEW MATERIALIZADA';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG,VAR_LOG_PROCESSO,NULL,NULL);
   	COMMIT;
   	VAR_CSIT_CTRLM := 1; 
   	BEGIN 
       DBMS_MVIEW.REFRESH('SGPB.VACPROD_CRRTR_DSTAQ','?', '',TRUE,FALSE,0,0,0,FALSE);       	
    EXCEPTION
		WHEN OTHERS THEN	         
	         VAR_LOG := 'ERRO NO REFRESH DA VIEW. ERRO ORACLE: '||SUBSTR(SQLERRM,1,200);
	         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG,VAR_LOG_PROCESSO,NULL,NULL);
	         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_ERRO);
	         COMMIT;
	         RAISE_APPLICATION_ERROR(-21000,VAR_LOG);
    END;
   	PR_GRAVA_LOG_EXCUC_CTRLM (VAR_DINIC_ROTNA,VAR_CROTNA,SYSDATE,NULL,NULL,VAR_LOG,VAR_CSIT_CTRLM);
    PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_PROCESSADO_OK);
	VAR_LOG := 'TERMINO NORMAL DO REFRESH. OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	COMMIT;
EXCEPTION
   	WHEN OTHERS THEN
         VAR_LOG := 'ERRO EXCEPTION NO REFRESH DA VIEW - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
         PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, VAR_CROTNA, SYSDATE, NULL, NULL, VAR_LOG, VAR_CSIT_CTRLM );
         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_CPARM,VAR_STATUS_ERRO);
         COMMIT;
         RAISE_APPLICATION_ERROR(-21000,VAR_LOG);
END;
/

