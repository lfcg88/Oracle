create or replace procedure sgpb_proc.SGPB0174
is
 -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0174
  --      DATA            :
  --      AUTOR           : VINÍCIUS FARIA - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : INCLUSÃO DA BONIFICAÇÃO DO CORRETOR NA TABELA DE RESUMO 
  --                        DE BÔNUS DO CORRETOR
  --      ALTERAÇÕES      : 1) Colocado o paramentro 853 (carga diária). ass. Wassily (22/06/07)
  --                DATA  : 2) cOLOCADAS MENSAGENS DE MONITORAÇÃO. ass. Wassily (22/06/07)
  --					    3) Retirados os parametros passados pelo programa chamador, porque era desnecessário
  --                        4) No delete dava abend se não deletadava nada. ass. Wassily (22/06/07)
  --                        5) Colocadas várias clausulas de exception. ass. Wassily (22/06/07)
  --                        6) Rotina era diária foi alterada para ser trimestral. ass. Wassily (09/08/2007)
-------------------------------------------------------------------------------------------------
  chrNomeRotinaScheduler CONSTANT CHAR(08) := 'SGPB0174';
  Intinicialfaixa 		Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  Intfinalfaixa   		Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_DCARGA 			date;
  VAR_DPROX_CARGA   	date;
  INTCOMPT 				OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%TYPE;
  Var_Crotna 			CONSTANT INT := 855;
  Var_Log_Erro 			Pc_Util_01.Var_Log_Erro%TYPE; 
  -------------------------------------------------------------------------------------------------
   PROCEDURE getIntervaloFaixa(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr%TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr%TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE) IS  
  BEGIN
  	begin
    	SELECT PCVS.CINIC_FAIXA_CRRTR,
           		PCVS.CFNAL_FAIXA_CRRTR
      			INTO 	INTRFAIXAINICIAL,
           				INTRFAIXAFINAL
      			FROM PARM_CANAL_VDA_SEGUR PCVS
     			WHERE PCVS.CCANAL_VDA_SEGUR = INTRCANAL
       					AND LAST_DAY(TO_DATE(INTRVIGENCIA, 'YYYYMM')) BETWEEN
           					PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'DD/MM/YYYY'));
    exception
      	WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Select da PARM_CANAL_VDA_SEGUR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK; 
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    end;
  END getIntervaloFaixa;
BEGIN
  PR_LIMPA_LOG_CARGA(chrNomeRotinaScheduler);
  PR_LE_PARAMETRO_CARGA(Var_Crotna, VAR_DCARGA, VAR_DPROX_CARGA);
  INTCOMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
  var_log_erro := 'INICIO DO PROCESSAMENTO. COMPETENCIA: '||INTCOMPT||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.Var_Rotna_Pc);  
  commit;
  -- Vai fazer um looping para cada canal ativo
  for INTCANAL in ( select distinct CCANAL_VDA_SEGUR from PARM_CANAL_VDA_SEGUR where DFIM_VGCIA_PARM is null ) 
  loop
  	var_log_erro := 'PROCESSAMENTO (DELETE) DO CANAL '||INTCANAL.CCANAL_VDA_SEGUR||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;    
  	--Recupera o intervalo da faixa do canal
  	getIntervaloFaixa(Intinicialfaixa,Intfinalfaixa,INTCANAL.CCANAL_VDA_SEGUR,Intcompt);
  	begin  
  		DELETE FROM RSUMO_BONUS_CRRTR RBC
  			WHERE RBC.CCOMPT = INTCOMPT
    			AND RBC.CCANAL_VDA_SEGUR = INTCANAL.CCANAL_VDA_SEGUR;
    exception
        WHEN No_Data_Found THEN null;
      	WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Delete da RSUMO_BONUS_CRRTR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK; 
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    end;
  	COMMIT;
  	var_log_erro := 'PROCESSAMENTO (INSERT) DO CANAL '||INTCANAL.CCANAL_VDA_SEGUR||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
  	INSERT INTO RSUMO_BONUS_CRRTR
    	(CCOMPT, CCANAL_VDA_SEGUR, CGRP_RAMO_PLANO, CCPF_CNPJ_BASE, CTPO_PSSOA, CTPO_COMIS, CTPO_APURC, PMARGM_CONTB,
	     PBONUS_ADCIO, PBONUS_APURC, VPROD_CRRTR, QTOT_ITEM_PROD, DALT_REG, DINCL_REG)
	    SELECT APC.Ccompt_Apurc, APC.CCANAL_VDA_SEGUR, PC.CGRP_RAMO_PLANO, C.CCPF_CNPJ_BASE, C.CTPO_PSSOA,
	           PC.CTPO_COMIS, APC.CTPO_APURC, MCC.PMARGM_CONTB, APC.PBONUS_APURC, APC.PBONUS_APURC,
	           SUM(PC.VPROD_CRRTR), SUM(PC.QTOT_ITEM_PROD), SYSDATE, SYSDATE
	      FROM CRRTR C
	      JOIN APURC_PROD_CRRTR APC
	        on APC.CCRRTR = C.CCRRTR
	       AND APC.CUND_PROD = C.CUND_PROD
	       AND APC.CSIT_APURC IN ('PG','PL','PR')
	      JOIN PROD_CRRTR PC 
	        ON PC.CGRP_RAMO_PLANO = APC.CGRP_RAMO_PLANO
	       AND PC.CCOMPT_PROD = APC.CCOMPT_PROD
	       AND PC.CTPO_COMIS = APC.CTPO_COMIS
	       AND PC.CCRRTR = APC.CCRRTR
	       AND PC.CUND_PROD = APC.CUND_PROD
	      JOIN MARGM_CONTB_CRRTR MCC
	        ON MCC.CCANAL_VDA_SEGUR = APC.CCANAL_VDA_SEGUR
	       AND MCC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
	       AND MCC.CTPO_PSSOA = C.CTPO_PSSOA
	       AND MCC.CCOMPT_MARGM = APC.Ccompt_Apurc
	      where APC.CCANAL_VDA_SEGUR = INTCANAL.CCANAL_VDA_SEGUR
	        and APC.Ccompt_Apurc = INTCOMPT
	      GROUP BY APC.Ccompt_Apurc, APC.CCANAL_VDA_SEGUR, PC.CGRP_RAMO_PLANO, C.CCPF_CNPJ_BASE, C.CTPO_PSSOA, PC.CTPO_COMIS,
	           	APC.CTPO_APURC, MCC.PMARGM_CONTB, APC.PBONUS_APURC;
    end loop;
	PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PO);
    var_log_erro := 'TERMINO DO PROCESSAMENTO DA COMPETENCIA: '||INTCOMPT||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor. Competência: '||IntCompt||' # '||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      rollback;
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler, Var_Crotna, PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    WHEN OTHERS THEN
      var_log_erro := substr(' Compet: '||INTCOMPT||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      ROLLBACK; 
      PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
end SGPB0174;
/

