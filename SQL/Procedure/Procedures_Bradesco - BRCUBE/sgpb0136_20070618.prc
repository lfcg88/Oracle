CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0136_20070618
(
  intrdia                IN DATE,
  intrCanal              IN canal_vda_segur.ccanal_vda_segur%TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9136'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0137
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Carga de produção Re Extra
  --      ALTERAÇÕES      : 1) Corrigido o problema de Snapshot too old devido a estar fazendo apenas um COMMIT e 
  --                           utilizando INSERT composto com SELECT.
  --				           Wassily Chuk (G&P) - 18/06/2007
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO   VARCHAR2(1000);
  chrLocalErro   VARCHAR2(2) := '00';
  intFaixaInicio Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  intFaixaFim    Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_CONTAGEM   NUMBER := 0;
  VAR_TOTAL_REG	 NUMBER := 0;
BEGIN
  chrLocalErro := 01;
  --  Informa ao scheduler o começo da procedure
  var_log_erro := 'REALIZANDO A ATUALIZACAO DIARIA. MOVIMENTO: '||TO_CHAR(intrdia,'DD/MM/YYYY');
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.Var_Rotna_Pc);
  COMMIT;
  chrLocalErro := 02;
  -- Verifica se esta sendo executada para o canal certo
  IF (intrCanal NOT IN (pc_util_01.Extra_Banco)) THEN
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'ERRO. ROTINA ADEQUADA APENAS EXTRA BANCO. CANAL INFORMADO: '||intrCanal,
                           pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
    RAISE_APPLICATION_ERROR(-20001,'ERRO. ROTINA ADEQUADA APENAS PARA EXTRA BANCO.');
  END IF;
  chrLocalErro := 03;
  -- Busca faixa de códico de corretores para o canal
  pc_util_01.Sgpb0003(intFaixaInicio,intFaixaFim,intrCanal,intrdia);
  chrLocalErro := 04;
  -- select na view e insert na tabela de apolices
  FOR I IN ( SELECT VRE.CSUCUR CUND_PROD,VRE.CCIA_SEGDR,VRE.CRAMO CRAMO_APOLC,VRE.CAPOLC,
                    trunc(dbms_random.value(1,9999)) CITEM_APOLC,
     				CASE
             			WHEN (VRE.CTPO_DOCTO_EMTDO_DW = 6) THEN
              					PC_UTIL_01.EMISSAO
             		ELSE
              			PC_UTIL_01.ENDOSSO
           			END CTPO_DOCTO,
           			VRE.CDOCTO_PRMIO CENDSS_APOLC,VRE.DEMIS_PRMIO DEMIS_APOLC, VRE.CCRRTR,
           			max(VRE.DINIC_VGCIA_DOCTO) DINIC_VGCIA_APOLC, max(VRE.DFIM_VGCIA_APOLC) DFIM_VGCIA_APOLC,
           			sum(VRE.VPRMIO_EMTDO_CSSRO_CDIDO) VPRMIO_EMTDO_APOLC, 
           			VRE.CCHAVE_DOCTO_PRMIO CCHAVE_LGADO_APOLC
     		 	FROM VACPROD_CRRTR_CALC_BONUS_RE VRE
      			JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN (PC_UTIL_01.RETODOS) AND ARP.CRAMO = VRE.CRAMO
      			WHERE VRE.CCRRTR BETWEEN INTFAIXAINICIO AND INTFAIXAFIM
       				AND VRE.DEMIS_PRMIO = INTRDIA
       				AND EXISTS (SELECT 1 FROM CRRTR C WHERE C.CCRRTR=VRE.CCRRTR AND C.CUND_PROD = VRE.CSUCUR)
     			GROUP BY VRE.CSUCUR,VRE.CCIA_SEGDR,VRE.CRAMO,VRE.CAPOLC,VRE.CITEM_APOLC,
           			CASE
             			WHEN (VRE.CTPO_DOCTO_EMTDO_DW = 6) THEN
              				PC_UTIL_01.EMISSAO
             			ELSE
              				PC_UTIL_01.ENDOSSO
           			END,
           			VRE.CDOCTO_PRMIO,VRE.DEMIS_PRMIO,VRE.CCRRTR,VRE.CCHAVE_DOCTO_PRMIO)
  LOOP
   	BEGIN
  	     -- A chave primaria da APOLICE DO PLANO DE BONUS é composta de um campo Randomico que é calculado no momento da carga
  	     -- Então tem que entrar deletando. Wassily.
  	     begin
	         DELETE FROM APOLC_PROD_CRRTR 
 	 				WHERE CUND_PROD=I.CUND_PROD AND
 	 			      CCIA_SEGDR=I.CCIA_SEGDR AND
 	 			      CRAMO_APOLC=I.CRAMO_APOLC AND
 	 			      CAPOLC=I.CAPOLC AND
 	 			      CTPO_DOCTO=I.CTPO_DOCTO AND
 	 			      CENDSS_APOLC=I.CENDSS_APOLC AND
 	 			      CCRRTR=I.CCRRTR AND
 	 			      DEMIS_APOLC=I.DEMIS_APOLC AND
 	 			      DINIC_VGCIA_APOLC=I.DINIC_VGCIA_APOLC AND
 	 			      DFIM_VGCIA_APOLC=I.DFIM_VGCIA_APOLC AND
 	 			      CCHAVE_LGADO_APOLC=I.CCHAVE_LGADO_APOLC;
 	 		 IF SQL%ROWCOUNT > 0 THEN  -- any rows were deleted
   				var_log_erro :=  'APOLICE DELETADA, POSSIVELMENTE HOUVE REPROCESSAMENTO. COMP: '||to_char(intrdia,'DD/MM/YYYY')||
                               ' CUND_PROD='||I.CUND_PROD||' CCIA_SEGDR= '||I.CCIA_SEGDR||' CRAMO_APOLC= '||I.CRAMO_APOLC||
                               ' CAPOLC= '||I.CAPOLC||' CITEM_APOLC= '||I.CITEM_APOLC||' CTPO_DOCTO= '||I.CTPO_DOCTO||
                               ' CENDSS_APOLC= '||I.CENDSS_APOLC||' CCRRTR= '||I.CCRRTR||
                               ' DEMIS_APOLC= '||I.DEMIS_APOLC||' CCHAVE_LGADO_APOLC= '||I.CCHAVE_LGADO_APOLC||
                               ' CANAL: '||to_char(intrCanal);
                PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
             END IF;
 	     EXCEPTION
 	      	WHEN NO_DATA_FOUND THEN NULL; 
          	WHEN OTHERS THEN 
               var_log_erro := SUBSTR('ERRO NO DELETE ANTES DO INSERT. COMPETENCIA: '||to_char(intrdia,'DD/MM/YYYY')||
                               ' CUND_PROD='||I.CUND_PROD||' CCIA_SEGDR= '||I.CCIA_SEGDR||' CRAMO_APOLC= '||I.CRAMO_APOLC||
                               ' CAPOLC= '||I.CAPOLC||' CITEM_APOLC= '||I.CITEM_APOLC||' CTPO_DOCTO= '||I.CTPO_DOCTO||
                               ' CENDSS_APOLC= '||I.CENDSS_APOLC||' CCRRTR= '||I.CCRRTR||
                               ' DEMIS_APOLC= '||I.DEMIS_APOLC||' CCHAVE_LGADO_APOLC= '||I.CCHAVE_LGADO_APOLC||
                               ' CANAL: '||to_char(intrCanal)||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
               ROLLBACK; 
               PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
               PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
               COMMIT;
               RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    	 END;
  		 INSERT INTO APOLC_PROD_CRRTR
    			(CUND_PROD,CCIA_SEGDR,CRAMO_APOLC,CAPOLC,CITEM_APOLC,CTPO_DOCTO,CENDSS_APOLC,CTPO_COMIS,CCRRTR,DEMIS_APOLC,
			     DINIC_VGCIA_APOLC,DFIM_VGCIA_APOLC,VPRMIO_EMTDO_APOLC,CCHAVE_LGADO_APOLC,CIND_PRODT_TLEMP,CIND_CRRTT_BCO,
			     DINCL_LCTO_PRMIO)
			     VALUES 
			     (I.CUND_PROD,I.CCIA_SEGDR,I.CRAMO_APOLC,I.CAPOLC,I.CITEM_APOLC,I.CTPO_DOCTO,I.CENDSS_APOLC,'CN',I.CCRRTR,
			     I.DEMIS_APOLC,I.DINIC_VGCIA_APOLC,I.DFIM_VGCIA_APOLC,I.VPRMIO_EMTDO_APOLC,I.CCHAVE_LGADO_APOLC,'N','N',SYSDATE);
		 VAR_CONTAGEM  := VAR_CONTAGEM + 1;		 		    
		 VAR_TOTAL_REG := VAR_TOTAL_REG + 1;
		 IF VAR_CONTAGEM = 100 THEN
		    VAR_CONTAGEM := 0;
		    COMMIT;
		 END IF;
    EXCEPTION
          WHEN OTHERS THEN 
               var_log_erro := SUBSTR('ERRO NO INSERT DA CARGA DIARIA. COMPETENCIA: '||to_char(intrdia,'DD/MM/YYYY')||
                               ' CUND_PROD='||I.CUND_PROD||' CCIA_SEGDR= '||I.CCIA_SEGDR||' CRAMO_APOLC= '||I.CRAMO_APOLC||
                               ' CAPOLC= '||I.CAPOLC||' CITEM_APOLC= '||I.CITEM_APOLC||' CTPO_DOCTO= '||I.CTPO_DOCTO||
                               ' CENDSS_APOLC= '||I.CENDSS_APOLC||' CCRRTR= '||I.CCRRTR||
                               ' DEMIS_APOLC= '||I.DEMIS_APOLC||' CCHAVE_LGADO_APOLC= '||I.CCHAVE_LGADO_APOLC||
                               ' CANAL: '||to_char(intrCanal)||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
               ROLLBACK; 
               PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
               PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
               COMMIT;
               RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    END;
  END LOOP;
  chrLocalErro := 05;
  var_log_erro := 'TERMINO DO PROCESSAMENTO DO CANAL '||intrCanal||'. TOTAL DE REGISTROS INSERIDOS '||VAR_TOTAL_REG;
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.Var_Rotna_Po);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: '||chrLocalErro||' Compet: '||to_char(intrdia,'DD/MM/YYYY')||
                           ' Canal: '||to_char(intrCanal)||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK; 
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    RAISE_APPLICATION_ERROR(-20001,var_log_erro);
END SGPB0136_20070618;
/

