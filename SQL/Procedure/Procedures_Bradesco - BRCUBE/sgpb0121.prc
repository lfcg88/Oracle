CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0121
(
  intrdia                IN DATE,
  intrCanal              IN canal_vda_segur.ccanal_vda_segur %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0121'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0121
  --      DATA            :
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Carga de apolices auto na tabela apolc banco/finasa
  --      ALTERAÇÕES      : 21/06/07 - Foram colocadas mensagens de registro de processamento. Ass. Wassily
  --                      : 19/10/07 - Retirado do JOIN da View de Comissão a Faixa. Ass. Wassily
  --                        31/10/07 - Criado FOR para dar insert por item, se der erro em uma apolice, vai continuar. Ass. Wassily
  --                        04/12/07 - Finasa passa a não ter CP para Propduto teleempresa. Ass. wassily
  --
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO   VARCHAR2(1000);
  chrLocalErro   VARCHAR2(2) := '00';
  intFaixaInicio Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  intFaixaFim    Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
BEGIN
  chrLocalErro := 01;
  --  Informa ao scheduler o começo da procedure
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.Var_Rotna_Pc);
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'INICIO DA CARGA DIARIA, AUTO, CANAL: '||intrCanal||' MOVIMENTO: '||
  												TO_CHAR(intrdia,'DD/MM/YYYY')||' EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
  COMMIT;
  chrLocalErro := 02;
  -- Verifica se esta sendo executada para o canal certo
  IF (intrCanal NOT IN (pc_util_01.Banco, pc_util_01.Finasa)) THEN
    RAISE_APPLICATION_ERROR(-20001,'ROTINA ADEQUADA APENAS PARA BANCO E FINASA');
  END IF;
  chrLocalErro := 03;
  -- Busca faixa de códico de corretores para o canal
  pc_util_01.Sgpb0003(intFaixaInicio, intFaixaFim, intrCanal, intrdia);
  chrLocalErro := 04;
  -- select na view e insert na tabela de apolices
  FOR I IN ( SELECT DISTINCT VAT.CSUCUR, VAT.CCIA_SEGDR, VAT.CRAMO, VAT.CAPOLC, VAT.CITEM_APOLC,
           			CASE
             			WHEN (VAT.CTPO_ENDSS_DW = 3) THEN PC_UTIL_01.EMISSAO
             			ELSE PC_UTIL_01.ENDOSSO
           			END TP_END, VAT.CNRO_ENDSS, VAT.DEMIS_ENDSS,
           			CASE
           			    WHEN (intrCanal = pc_util_01.Finasa and VAT.CIND_PRODT_TLEMP = 5 ) -- é Finasa e teleempresa
           			    THEN
             			  	'CN'
             			ELSE
             		        CASE
             			       WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR 
             			       		THEN 'CE'
             			       ELSE 'CN'
             			    END
           			END TP_COMI,
           			MAC.CCRRTR_DSMEM CCRRTR, max(VAT.DINIC_VGCIA_ENDSS) DINIC_VGCIA_ENDSS, 
           			max(VAT.DFIM_VGCIA_ITEM) DFIM_VGCIA_ITEM, SUM(VAT.VPRMIO_LIQ_AUTO) VPRMIO_LIQ_AUTO,
           			VAT.CCHAVE_ORIGE_ENDSS, VAT.CIND_PRODT_CRRTT_BCO, TO_CHAR(VAT.CIND_PRODT_TLEMP) CIND_PRODT_TLEMP
      				FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
      				JOIN MPMTO_AG_CRRTR MAC ON MAC.CCRRTR_ORIGN = VAT.CCRRTR
                             AND MAC.CUND_PROD = VAT.CSUCUR
                             AND vat.demis_endss >= MAC.DENTRD_CRRTR_AG
                             AND vat.demis_endss < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
      				JOIN VACOMIS_CRRTR_CALC_BONUS VCO ON VCO.CCRRTR = VAT.CCRRTR
                             AND VCO.CUND_PROD = VAT.CSUCUR
                             AND VCO.CRAMO = VAT.CRAMO
                    JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN (PC_UTIL_01.Auto)
                             AND ARP.CRAMO = VAT.cramo
     				WHERE VAT.ccrrtr BETWEEN intFaixaInicio AND intFaixaFim
       				AND vat.demis_endss = intrdia
       				AND EXISTS (SELECT 1 FROM CRRTR C
             						WHERE C.CCRRTR = MAC.CCRRTR_DSMEM
               						AND C.CUND_PROD = VAT.CSUCUR)
     				GROUP BY VAT.CSUCUR, VAT.CCIA_SEGDR, VAT.CRAMO, VAT.CAPOLC, VAT.CITEM_APOLC,
           					CASE
             					WHEN (VAT.CTPO_ENDSS_DW = 3) THEN PC_UTIL_01.EMISSAO
             					ELSE PC_UTIL_01.ENDOSSO
           					END, VAT.CNRO_ENDSS, VAT.DEMIS_ENDSS,
           					CASE
           					    WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN 'CE'
             					ELSE 'CN'
           					END, MAC.CCRRTR_DSMEM, VAT.CCHAVE_ORIGE_ENDSS, VAT.CIND_PRODT_CRRTT_BCO, VAT.CIND_PRODT_TLEMP)
  LOOP
  	BEGIN
  		INSERT INTO APOLC_PROD_CRRTR (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, 
  									  DEMIS_APOLC, CTPO_COMIS, CCRRTR, DINIC_VGCIA_APOLC, DFIM_VGCIA_APOLC, VPRMIO_EMTDO_APOLC, 
  									  CCHAVE_LGADO_APOLC, DINCL_LCTO_PRMIO, CIND_CRRTT_BCO, CIND_PRODT_TLEMP)
  									  VALUES ( I.CSUCUR, I.CCIA_SEGDR, I.CRAMO, I.CAPOLC, I.CITEM_APOLC, I.TP_END, 
  									           I.CNRO_ENDSS, I.DEMIS_ENDSS, I.TP_COMI, I.CCRRTR, I.DINIC_VGCIA_ENDSS,
  									           I.DFIM_VGCIA_ITEM, I.VPRMIO_LIQ_AUTO, I.CCHAVE_ORIGE_ENDSS, SYSDATE,
  									           I.CIND_PRODT_CRRTT_BCO, I.CIND_PRODT_TLEMP);
    EXCEPTION
		WHEN OTHERS THEN
    		var_log_erro := 'Erro no Insert Da Apolice: SUC: '||I.CSUCUR||' CIA: '||I.CCIA_SEGDR||' RAMO: '||I.CRAMO||
    						' APOLC: '||I.CAPOLC||' ITEM: '||I.CITEM_APOLC||' NUM.END: '||I.CNRO_ENDSS||' DT.EMISSAO: '||
    						I.DEMIS_ENDSS||' TP_COMIS: '||I.TP_COMI||' CODCPD: '||I.ccrrtr||' Canal: '||
    						intrCanal||' ERRO: '|| SUBSTR(SQLERRM,1,200);
    		PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    		COMMIT;
  	END;
  END LOOP;     
  chrLocalErro := 05;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.Var_Rotna_Po);
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'TERMINO DA CARGA DIARIA. MOVIMENTO: '||
  							TO_CHAR(intrdia,'DD/MM/YYYY')||' EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
    ROLLBACK;
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrdia,
                                   'DD/MM/YYYY') || ' Canal: ' || to_char(intrCanal) || ' # ' || SQLERRM,
                           1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --PR_GRAVA_MSG_LOG_CARGA('SGPB0120',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,708,PC_UTIL_01.VAR_ROTNA_PE);
    raise;
END SGPB0121;
/

