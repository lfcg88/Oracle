CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9988
IS

  -- controle de procedure chave
  AT_CSUCUR          VACPROD_CRRTR_CALC_BONUS_AT.CSUCUR%TYPE;
  AT_CCRRTR          VACPROD_CRRTR_CALC_BONUS_AT.CCRRTR%TYPE;
  AT_CCIA_SEGDR      VACPROD_CRRTR_CALC_BONUS_AT.CCIA_SEGDR%TYPE;
  AT_CRAMO           VACPROD_CRRTR_CALC_BONUS_AT.CRAMO%TYPE;
  AT_CAPOLC          VACPROD_CRRTR_CALC_BONUS_AT.CAPOLC%TYPE;
  AT_CITEM_APOLC     VACPROD_CRRTR_CALC_BONUS_AT.CITEM_APOLC%TYPE;
  AT_CTPO_ENDSS_DW   VACPROD_CRRTR_CALC_BONUS_AT.CTPO_ENDSS_DW%TYPE;
  AT_CNRO_ENDSS      VACPROD_CRRTR_CALC_BONUS_AT.CNRO_ENDSS%TYPE;
  AT_DEMIS_ENDSS     VACPROD_CRRTR_CALC_BONUS_AT.DEMIS_ENDSS%TYPE;
  TESTE        NUMBER(6) := 0;
  var_qtd_linhas      NUMBER(8) := 0;
  TYPE T_CORRETOR IS REF CURSOR;
  C_CORRETOR_CCC T_CORRETOR;
  --dwsheluler
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9988';
  VAR_PARAMETRO		    NUMBER := 722;
  VAR_LOG_ERRO 				VARCHAR2(1000);

BEGIN
   -- DWSHEDULER
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   -- (O TRIGGER JOGARA AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA); 
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- INICIANDO A EXECUCAO
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   --

                OPEN C_CORRETOR_CCC FOR
               SELECT VAT.* FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
                      WHERE VAT.DEMIS_ENDSS BETWEEN TO_DATE(20070401,'YYYYMMDD') AND
                               TO_DATE(20070617,'YYYYMMDD') -- A PARTIR DE 200704
                               --   AND to_number(to_char(VAT.DEMIS_ENDSS,'yyyymm')) IN(200704,200705,200706)
                                  AND ((VAT.CIND_PRODT_CRRTT_BCO = 'S') OR (VAT.CIND_PRODT_TLEMP = 'S'))
                                  AND VAT.CCRRTR BETWEEN 100000 AND 199992
                                  AND EXISTS (SELECT 1 FROM CRRTR C
                                               WHERE C.CCRRTR = VAT.CCRRTR
                                                 AND C.CUND_PROD = VAT.CSUCUR);
             --
             LOOP
             FETCH C_CORRETOR_CCC INTO  AT_CSUCUR          ,
                                        AT_CCRRTR          ,
                                        AT_CCIA_SEGDR      ,
                                        AT_CRAMO           ,
                                        AT_CAPOLC          ,
                                        AT_CITEM_APOLC     ,
                                        AT_CTPO_ENDSS_DW   ,
                                        AT_CNRO_ENDSS      ,
                                        AT_DEMIS_ENDSS     ;                                                                              
              --
              EXIT WHEN C_CORRETOR_CCC%NOTFOUND;
                   --
                   BEGIN
                     	     SELECT 1 INTO TESTE
                             FROM APOLC_PROD_CRRTR APC
                      	 		WHERE APC.CUND_PROD = AT_CSUCUR
                       				AND APC.CCRRTR = AT_CCRRTR
                	       			AND APC.CCIA_SEGDR = AT_CCIA_SEGDR
                    	   			AND APC.CRAMO_APOLC = AT_CRAMO
                       				AND APC.CAPOLC = AT_CAPOLC
                       				AND APC.CITEM_APOLC = AT_CITEM_APOLC
                	       			AND APC.CTPO_DOCTO = DECODE(AT_CTPO_ENDSS_DW,3,'M','D')	       			
                    	   			AND APC.CENDSS_APOLC = AT_CNRO_ENDSS
                       				AND APC.DEMIS_APOLC = AT_DEMIS_ENDSS;   
                        EXCEPTION
                           WHEN OTHERS THEN
                           VAR_LOG_ERRO := 'SELECT-1 ' || SUBSTR(SQLERRM,1,490);
                           PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||VAR_LOG_ERRO,'P',NULL,NULL);
                           PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
                           COMMIT;
                   --
                   END;
                   IF TESTE = 1 THEN
                     var_qtd_linhas := var_qtd_linhas + 1;
                   END IF;

	            --
              END LOOP;
	            --              
              CLOSE C_CORRETOR_CCC;
              
              -- DWSHEDULER
              PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSO APOLC_PROD_CRRTR TOTAL DE LINHAS'||var_qtd_linhas,'P',NULL,NULL);
              PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
              COMMIT;
              --

END SGPB9988;
/

