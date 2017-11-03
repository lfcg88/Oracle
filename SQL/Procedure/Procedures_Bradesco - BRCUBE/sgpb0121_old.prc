CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0121_OLD
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
  --      ALTERA��ES      : Foram colocadas mensagens de registro de processamento. Ass. Wassily (21/06/2007)
  --                DATA  : 19/10/2007 - Retirado do JOIN da View de Comiss�o a Faixa. Ass. Wassily
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_LOG_ERRO   VARCHAR2(1000);
  chrLocalErro   VARCHAR2(2) := '00';
  intFaixaInicio Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr %TYPE;
  intFaixaFim    Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr %TYPE;
BEGIN
  chrLocalErro := 01;
  --  Informa ao scheduler o come�o da procedure
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
  -- Busca faixa de c�dico de corretores para o canal
  pc_util_01.Sgpb0003(intFaixaInicio, intFaixaFim, intrCanal, intrdia);
  chrLocalErro := 04;
  -- select na view e insert na tabela de apolices
  INSERT INTO APOLC_PROD_CRRTR
    (CUND_PROD, CCIA_SEGDR, CRAMO_APOLC, CAPOLC, CITEM_APOLC, CTPO_DOCTO, CENDSS_APOLC, DEMIS_APOLC, CTPO_COMIS, CCRRTR,
     DINIC_VGCIA_APOLC, DFIM_VGCIA_APOLC, VPRMIO_EMTDO_APOLC, CCHAVE_LGADO_APOLC, DINCL_LCTO_PRMIO, CIND_CRRTT_BCO, CIND_PRODT_TLEMP)
    SELECT VAT.CSUCUR, VAT.CCIA_SEGDR, VAT.CRAMO, VAT.CAPOLC, VAT.CITEM_APOLC,
           CASE
             WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
              PC_UTIL_01.EMISSAO
             ELSE
              PC_UTIL_01.ENDOSSO
           END,
           VAT.CNRO_ENDSS, VAT.DEMIS_ENDSS,
           CASE
             WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
              'CE'
             ELSE
              'CN'
           END,
           MAC.CCRRTR_DSMEM, max(VAT.DINIC_VGCIA_ENDSS), max(VAT.DFIM_VGCIA_ITEM), SUM(VAT.VPRMIO_LIQ_AUTO),
           VAT.CCHAVE_ORIGE_ENDSS, SYSDATE, VAT.CIND_PRODT_CRRTT_BCO, TO_CHAR(VAT.CIND_PRODT_TLEMP)
      FROM VACPROD_CRRTR_CALC_BONUS_AT VAT
      JOIN MPMTO_AG_CRRTR MAC ON MAC.CCRRTR_ORIGN = VAT.CCRRTR
                             AND MAC.CUND_PROD = VAT.CSUCUR
                             AND vat.demis_endss >= MAC.DENTRD_CRRTR_AG
                             AND vat.demis_endss < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
      JOIN VACOMIS_CRRTR_CALC_BONUS VCO ON VCO.CCRRTR = VAT.CCRRTR
                                       AND VCO.CUND_PROD = VAT.CSUCUR
                                       AND VCO.CRAMO = VAT.CRAMO
                                       -- RETIRADO POR CAUSA DA NOVA VIEW DO DWCO. ASS. WASSILY ( 18/10/07 )
                                       --and vat.demis_endss between vco.dinic_vgcia and nvl(vco.dfim_vgcia, TO_DATE(99991231, 'YYYYMMDD'))
      JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN (PC_UTIL_01.Auto)
                               AND ARP.CRAMO = VAT.cramo
     WHERE VAT.ccrrtr BETWEEN intFaixaInicio AND intFaixaFim
       AND vat.demis_endss = intrdia
       AND EXISTS (SELECT 1 FROM CRRTR C
             		WHERE C.CCRRTR = MAC.CCRRTR_DSMEM
               		AND C.CUND_PROD = VAT.CSUCUR)
     GROUP BY VAT.CSUCUR, VAT.CCIA_SEGDR, VAT.CRAMO, VAT.CAPOLC, VAT.CITEM_APOLC,
           CASE
             WHEN (VAT.CTPO_ENDSS_DW = 3) THEN
              PC_UTIL_01.EMISSAO
             ELSE
              PC_UTIL_01.ENDOSSO
           END,
           VAT.CNRO_ENDSS, VAT.DEMIS_ENDSS,
           CASE
             WHEN VAT.PCOMIS_CRRTG_AUTO > VCO.PCOMIS_CRRTR THEN
              'CE'
             ELSE
              'CN'
           END,
           MAC.CCRRTR_DSMEM, VAT.CCHAVE_ORIGE_ENDSS, VAT.CIND_PRODT_CRRTT_BCO, VAT.CIND_PRODT_TLEMP;
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
END SGPB0121_OLD;
/

