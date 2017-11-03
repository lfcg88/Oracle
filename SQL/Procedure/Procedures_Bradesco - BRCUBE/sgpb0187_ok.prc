CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0187_OK
--(
  -- INTRCODCANAL       CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR%TYPE := 1, -- canal extrabanco (fixo, nao precisa)
  -- INTCOMPT           IN APOLC_PROD_CRRTR.CCOMPT_PROD%TYPE -- nao precisa, vai fazer looping para atualizar todos os meses
--)
 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0187
  --      DATA            : 03/05/2007
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de atualização da apólice, Extra-Banco. com conceito Teleempresa e Correntista Banco.
  --
  --      ALTERAÇÕES      : Não precisava passar canal, 
  --                        Nao precisava de programa chamador do dwscheduler, mas estava preparado para isso
  --                        Nao tinham mensagens de log se desse erro no meio do programa. 
  --                        Não dava looping para atualizar todos os meses.
  --                        Não comitava de 1000 em 1000 somente no fim certamente iria dar snapshot too old ou rollback).
  --                        Foi colocada alteração do CE para CN quando é correntista banco ou teleempresa. 
  --						Ass. Wassily.
  -------------------------------------------------------------------------------------------------
  var_Rotina 	CONSTANT VARCHAR2(08) := 'SGPB0187';
  Var_Crotna 	CONSTANT  INT := '722';
  INTRCODCANAL  CONSTANT CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR%TYPE := 1;
  INICIAFAIXA 	Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  FIMFAIXA    	Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_LOG_ERRO 	VARCHAR2(1000);
  VAR_CONTA_REG NUMBER;
  VAR_CONTA_TOT NUMBER;
BEGIN
    -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO
    PR_LIMPA_LOG_CARGA(var_Rotina);   
    -- GRAVA LOG INICIAL DE CARGA
    PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'INICIO DA IMPLANTACAO DO CONCEITO TELEEMPRESA E CORRENTISTA BANCO, CANAL EXTRABANCO. EM '||
                                      TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P', NULL, NULL);
    -- troca status
    PR_ATUALIZA_STATUS_ROTINA(var_Rotina,722,PC_UTIL_01.Var_Rotna_Pc);
    COMMIT;
    -- pega faixa. primeiro vai descobrir os meses de 2007 que existem na apolice.    
   	VAR_CONTA_REG := 0;
   	VAR_CONTA_TOT := 0;
    for i in ( select distinct to_number(to_char(DEMIS_APOLC,'YYYYMM')) INTCOMPT
                      FROM APOLC_PROD_CRRTR
                      WHERE DEMIS_APOLC > TO_DATE(20070331, 'YYYYMMDD') )
    LOOP
        Pc_Util_01.Sgpb0003(INICIAFAIXA,FIMFAIXA,INTRCODCANAL,I.INTCOMPT);
        PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'INICIANDO ATUALIZACAO DA COMPETENCIA: '||I.INTCOMPT,'P', NULL, NULL);
        COMMIT;
    	FOR C IN( SELECT VAT.* FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
                            --WHERE VAT.DEMIS_ENDSS BETWEEN TO_DATE(20070401,'YYYYMMDD') AND
                            --                             TO_DATE(99991231,'YYYYMMDD') -- A PARTIR DE 200704
                             WHERE to_number(to_char(VAT.DEMIS_ENDSS,'yyyymm')) = i.INTCOMPT
                             AND ((VAT.CIND_PRODT_CRRTT_BCO = 'S') OR (VAT.CIND_PRODT_TLEMP = 'S'))
                             AND VAT.CCRRTR BETWEEN INICIAFAIXA AND FIMFAIXA
                             AND EXISTS (SELECT 1 FROM CRRTR C
                      						WHERE C.CCRRTR = VAT.CCRRTR
                      						AND C.CUND_PROD = VAT.CSUCUR)
    	)LOOP
    	  begin
        	--ATUALIZAÇÃO DA TABELA DE APÓLICE
    		UPDATE APOLC_PROD_CRRTR APC
       		SET APC.CIND_CRRTT_BCO = C.CIND_PRODT_CRRTT_BCO,
	            APC.CIND_PRODT_TLEMP = C.CIND_PRODT_TLEMP,	            
	       		-- regra implementada em 29/06/07
	       		-- quando os indicadores telempresa e correntista forem 'S' (um deles) será trocado de CE para CN para
	       		-- que essas apolice passem a serem consideradas no plano de bonus.
	       		-- ---------------------------------------
	       		CTPO_COMIS = DECODE(C.CIND_PRODT_CRRTT_BCO,'N',DECODE(C.CIND_PRODT_TLEMP,'N','CE','CN'),'CN'),
	       		-- ---------------------------------------	       		
	       		CGRP_RAMO_PLANO 	= NULL,
           		CCOMPT_PROD         = NULL
    	 		WHERE APC.CUND_PROD = C.CSUCUR
       				AND APC.CCRRTR = C.CCRRTR -- usa o corretor original por que é extrabanco
	       			AND APC.CCIA_SEGDR = C.CCIA_SEGDR
    	   			AND APC.CRAMO_APOLC = C.CRAMO
       				AND APC.CAPOLC = C.CAPOLC
       				AND APC.CITEM_APOLC = C.CITEM_APOLC
	       			AND APC.CTPO_DOCTO = DECODE(C.CTPO_ENDSS_DW,3,'M','D')	       			
    	   			AND APC.CENDSS_APOLC = C.CNRO_ENDSS
       				AND APC.DEMIS_APOLC = C.DEMIS_ENDSS;
       	  exception
       	  	when no_data_found then
       	  		PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'APOLICE NAO ENCONTRADA, MESMO ASSIM VAI CONTINUAR. CUND_PROD = '||C.CSUCUR||
       				' CCRRTR = '||C.CCRRTR||' CCIA_SEGDR = '||C.CCIA_SEGDR||' RAMO_APOLC = '||C.CRAMO||
       				' CAPOLC = '||C.CAPOLC||' CITEM_APOLC = '||C.CITEM_APOLC||
    	   			' CENDSS_APOLC = '||C.CNRO_ENDSS||' DEMIS_APOLC = '||C.DEMIS_ENDSS,'P', NULL, NULL);
    		    COMMIT;    		
       	  end;
	       	IF VAR_CONTA_REG > 10000 THEN
    	   	   PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'ATE O MOMENTO FORAM ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
    		   COMMIT;
    	   	   VAR_CONTA_REG := 1;
    		ELSE
    	   		VAR_CONTA_REG := VAR_CONTA_REG + 1;
    	   		VAR_CONTA_TOT := VAR_CONTA_TOT + 1;
    		END IF;    	   
  		END LOOP;
    END LOOP;
  	PR_GRAVA_MSG_LOG_CARGA(var_Rotina,'TERMINO DA ATUALIZACAO. FORAM ATUALIZADOS '||VAR_CONTA_TOT||' REGISTROS.','P', NULL, NULL);
	Pr_Atualiza_Status_Rotina(var_Rotina,Var_Crotna,Pc_Util_01.Var_Rotna_Po);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Var_Log_Erro := Substr('Erro Ao Executar a Atualização Na Apólice. ERRO: '|| SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
		Pr_Grava_Msg_Log_Carga(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
		Pr_Atualiza_Status_Rotina(var_Rotina,Var_Crotna,Pc_Util_01.Var_Rotna_Pe);
		commit;
		RAISE_APPLICATION_ERROR(-20001,Var_Log_Erro);
END SGPB0187_OK;
/

