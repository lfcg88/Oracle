CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0186
 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0186
  --      DATA            : 03/05/2007
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de atualização da apólice, Banco e Finasa. com conceito Teleempresa e Correntista Banco.
  --
  --      ALTERAÇÕES      : Não precisava passar canal, pode atualizar para os dois canais (banco e Finasa)
  --                        Nao precisava de programa chamador do dwscheduler, mas estava preparado para isso
  --                        Nao tinham mensagens de log se desse erro no meio do programa. 
  --                        Não dava looping para atualizar todos os meses.
  --                        Não comitava de 10000 em 10000 somente no fim certamente iria dar snapshot too old ou rollback).
  --                        Ass. Wassily. (21/06/2007)
  -------------------------------------------------------------------------------------------------
  var_Rotina 	CONSTANT VARCHAR2(08) := 'SGPB0186';
  Var_Crotna 	CONSTANT  INT := '722';
  --INTRCODCANAL  CONSTANT CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR%TYPE := 1;
  INICIAFAIXA 	Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  FIMFAIXA    	Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_LOG_ERRO 	VARCHAR2(1000);
  VAR_STOP		  NUMBER;
  VAR_CONTA_REG NUMBER;
  VAR_CONTA_REJ NUMBER;
  VAR_CONTA_TOT NUMBER;
BEGIN
    -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
    PR_LIMPA_LOG_CARGA(var_Rotina);   
    -- GRAVA LOG INICIAL DE CARGA
    PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'INICIO DA IMPLANTACAO DO CONCEITO TELE-EMPRESA E CORRENTISTA BANCO, BANCO E FINASA. EM '||
                                      TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P', NULL, NULL);
    -- TROCA STATUS
    PR_ATUALIZA_STATUS_ROTINA(var_Rotina,Var_Crotna,PC_UTIL_01.Var_Rotna_Pc);
    COMMIT;
    VAR_CONTA_REG := 0;
	  VAR_CONTA_TOT := 0;
   	VAR_CONTA_REJ := 0;
	  VAR_STOP := 1;

        PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'INICIANDO ATUALIZACAO','P', NULL, NULL);
        -- vai processar por canal (2 = banco e 3 = finasa)
       	VAR_STOP := 2;
        for for_canal in 2 .. 3
        loop
            VAR_STOP := 3;
	          Pc_Util_01.Sgpb0003(INICIAFAIXA,FIMFAIXA,for_canal,200704);
	          VAR_STOP := 30;	        
            PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'PROCESSANDO O CANAL: '||for_canal,'P', NULL, NULL);
            COMMIT;
	          VAR_STOP := 4;
	    	FOR C IN(SELECT MAC.CCRRTR_DSMEM, VAT.*
      						 FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
      						 JOIN MPMTO_AG_CRRTR MAC 
        						 ON MAC.CCRRTR_ORIGN = VAT.CCRRTR --MAC.CCRRTR_DSMEM = VAT.CCRRTR
       							AND MAC.CUND_PROD = VAT.CSUCUR
       							AND MAC.CCRRTR_ORIGN BETWEEN INICIAFAIXA AND FIMFAIXA
       							--WHERE to_number(to_char(VAT.DEMIS_ENDSS,'yyyymm')) = i.INTCOMPT
       						WHERE VAT.DEMIS_ENDSS BETWEEN TO_DATE(20070401, 'YYYYMMDD') AND
              							                    TO_DATE(20070630, 'YYYYMMDD') -- A PARTIR DE 200704
             				AND ((VAT.CIND_PRODT_CRRTT_BCO = 'S') OR (VAT.CIND_PRODT_TLEMP = 'S'))
          					AND EXISTS (SELECT 1 FROM CRRTR C
                      									WHERE C.CCRRTR = MAC.CCRRTR_DSMEM
                      									  AND C.CUND_PROD = VAT.CSUCUR)
                )
    		LOOP
        		--ATUALIZAÇÃO DA TABELA DE APÓLICE
        		VAR_STOP := 5;
            BEGIN
              --
              IF(C.CIND_PRODT_CRRTT_BCO = 'S') THEN        
                     --ATUALIZAÇÃO DA TABELA DE APÓLICE SEGURO CORRENTISTA
              			 UPDATE APOLC_PROD_CRRTR APC
          	       			SET APC.CIND_CRRTT_BCO = C.CIND_PRODT_CRRTT_BCO, 
              	       			APC.CIND_PRODT_TLEMP = C.CIND_PRODT_TLEMP,
          	       				  APC.CTPO_COMIS = 'CN',
                            APC.CGRP_RAMO_PLANO 	= NULL,
           			            APC.CCOMPT_PROD       = NULL
                  		WHERE APC.CUND_PROD = C.CSUCUR
                 			--AND APC.CCRRTR = C.CCRRTR_DSMEM -- usa corretor desmensado por que é banco ou finasa
          	       			AND APC.CCIA_SEGDR = C.CCIA_SEGDR
              	   			AND APC.CRAMO_APOLC = C.CRAMO
                 				AND APC.CAPOLC = C.CAPOLC
                 				AND APC.CITEM_APOLC = C.CITEM_APOLC
                 				AND APC.CTPO_DOCTO = DECODE(C.CTPO_ENDSS_DW,3,'M','D')
          	       			AND APC.CENDSS_APOLC = C.CNRO_ENDSS
              	   			AND APC.DEMIS_APOLC = C.DEMIS_ENDSS;
                        --
                        IF SQL%NOTFOUND THEN
                           --CONTADOR PARA OS REJEITADOS
                           VAR_CONTA_REJ := VAR_CONTA_REJ + 1;
                           VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
                     	  	 PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'BCO APOLICE NAO ENCONTRADA, MESMO ASSIM VAI CONTINUAR. CUND_PROD = '||C.CSUCUR||
                     			 ' CCRRTR = '||C.CCRRTR_DSMEM||' CCIA_SEGDR = '||C.CCIA_SEGDR||' RAMO_APOLC = '||C.CRAMO||
                     			 ' CAPOLC = '||C.CAPOLC||' CITEM_APOLC = '||C.CITEM_APOLC||
                  	   		 ' CENDSS_APOLC = '||C.CNRO_ENDSS||' DEMIS_APOLC = '||C.DEMIS_ENDSS,'P', NULL, NULL);
                        ELSE
                           --CONTADOR PARA OS UPDATE CONCLUIDOS
                           VAR_CONTA_REG := VAR_CONTA_REG + 1;
                           VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
                        END IF;
              --
              ELSE
              --
                     --ATUALIZAÇÃO DA TABELA DE APÓLICE TELE-EMPRESA
              			 UPDATE APOLC_PROD_CRRTR APC
          	       			SET APC.CIND_CRRTT_BCO = C.CIND_PRODT_CRRTT_BCO, 
              	       			APC.CIND_PRODT_TLEMP = C.CIND_PRODT_TLEMP,
                            APC.CGRP_RAMO_PLANO 	= NULL,
           			            APC.CCOMPT_PROD       = NULL
                  		WHERE APC.CUND_PROD = C.CSUCUR
                 			--AND APC.CCRRTR = C.CCRRTR_DSMEM -- usa corretor desmensado por que é banco ou finasa
          	       			AND APC.CCIA_SEGDR = C.CCIA_SEGDR
              	   			AND APC.CRAMO_APOLC = C.CRAMO
                 				AND APC.CAPOLC = C.CAPOLC
                 				AND APC.CITEM_APOLC = C.CITEM_APOLC
                 				AND APC.CTPO_DOCTO = DECODE(C.CTPO_ENDSS_DW,3,'M','D')
          	       			AND APC.CENDSS_APOLC = C.CNRO_ENDSS
              	   			AND APC.DEMIS_APOLC = C.DEMIS_ENDSS;
                        --
                        IF SQL%NOTFOUND THEN
                           --CONTADOR PARA OS REJEITADOS
                           VAR_CONTA_REJ := VAR_CONTA_REJ + 1;
                           VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
                     	  	 PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'TLEP APOLICE NAO ENCONTRADA, MESMO ASSIM VAI CONTINUAR. CUND_PROD = '||C.CSUCUR||
                     			 ' CCRRTR = '||C.CCRRTR_DSMEM||' CCIA_SEGDR = '||C.CCIA_SEGDR||' RAMO_APOLC = '||C.CRAMO||
                     			 ' CAPOLC = '||C.CAPOLC||' CITEM_APOLC = '||C.CITEM_APOLC||
                  	   		 ' CENDSS_APOLC = '||C.CNRO_ENDSS||' DEMIS_APOLC = '||C.DEMIS_ENDSS,'P', NULL, NULL);
                        ELSE
                           --CONTADOR PARA OS UPDATE CONCLUIDOS
                           VAR_CONTA_REG := VAR_CONTA_REG + 1;
                           VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
                        END IF;
              --
              END IF;
              --
       	     END;
       	     VAR_STOP := 50;
	       	   --COMMIT
             IF ((VAR_CONTA_TOT mod 10000) = 0) THEN
      	   	    PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'ATE O MOMENTO FORAM REJEITADOS  '||VAR_CONTA_REJ||' REGISTROS.','P', NULL, NULL);
      	   	    PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'ATE O MOMENTO FORAM ATUALIZADOS '||VAR_CONTA_REG||' REGISTROS.','P', NULL, NULL);
      		      COMMIT;
      		   END IF; 
           --             
  			END LOOP;
  		END LOOP;
      VAR_STOP := 6;
      PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'TERMINO DA ATUALIZACAO - TOTAL REJEITADOS  '||VAR_CONTA_REJ||' REGISTROS.','P', NULL, NULL);
      PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'TERMINO DA ATUALIZACAO - TOTAL ATUALIZADOS '||VAR_CONTA_REG||' REGISTROS.','P', NULL, NULL);
      PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'TERMINO DA ATUALIZACAO - TOTAL GERAL       '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
      Pr_Atualiza_Status_Rotina(var_Rotina,Var_Crotna,Pc_Util_01.Var_Rotna_Po);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Var_Log_Erro := Substr('Erro Ao Executar a Atualização Na Apólice. Ponto: '||VAR_STOP||
		                       ' ERRO: '||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
		Pr_Grava_Msg_Log_Carga(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
		Pr_Atualiza_Status_Rotina(var_Rotina,Var_Crotna,Pc_Util_01.Var_Rotna_Pe);
		commit;
		RAISE_APPLICATION_ERROR(-20001,Var_Log_Erro);
END SGPB0186;
/

