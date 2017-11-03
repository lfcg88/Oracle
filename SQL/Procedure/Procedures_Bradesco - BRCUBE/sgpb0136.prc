CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0136(INTRDIA                IN DATE,
                             CHRNOMEROTINASCHEDULER VARCHAR2 := 'SGPB0136')
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0136
  --      DATA            :
  --      AUTOR           : VICTOR H. BILOURO - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : CARGA DIARIA DE PRODU��O RE - EXTRA_BANCO
  --      ALTERA��ES      : ALTERADA A QUERY QUE PEGA AS APOLICES A SEREM PROCESSADAS.
  --                        PASSOU A SER UTILIZADO O CAMPO DINCL_LCTO_PRMIO PARA DATA DE "CORTE" E N�O A DATA DE EMISS�O DA APOLICE.
  --				        ASS. WASSILY ( 13/12/2007 )
  -------------------------------------------------------------------------------------------------
 IS
  /*CONTROLE DE PROCEDURE*/
  VAR_LOG_ERRO   VARCHAR2(1000);
  CHRLOCALERRO   VARCHAR2(2) := '00';
  INTFAIXAINICIO PARM_CANAL_VDA_SEGUR.CINIC_FAIXA_CRRTR%TYPE;
  INTFAIXAFIM    PARM_CANAL_VDA_SEGUR.CFNAL_FAIXA_CRRTR%TYPE;
BEGIN
  CHRLOCALERRO := 01;
  --  INFORMA AO SCHEDULER O COME�O DA PROCEDURE
  PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER,708,PC_UTIL_01.VAR_ROTNA_PC);
  CHRLOCALERRO := 02;
  CHRLOCALERRO := 03;
  -- BUSCA FAIXA DE C�DICO DE CORRETORES PARA O CANAL
  PC_UTIL_01.SGPB0003(INTFAIXAINICIO, INTFAIXAFIM, PC_UTIL_01.EXTRA_BANCO, INTRDIA);
  CHRLOCALERRO := 04;
  -- SELECT NA VIEW E INSERT NA TABELA DE APOLICES
  INSERT INTO APOLC_PROD_CRRTR (CUND_PROD,CCIA_SEGDR,CRAMO_APOLC,CAPOLC,CITEM_APOLC,CTPO_DOCTO,CENDSS_APOLC,DEMIS_APOLC,
     							CTPO_COMIS,CCRRTR,DINIC_VGCIA_APOLC,DFIM_VGCIA_APOLC,VPRMIO_EMTDO_APOLC,CCHAVE_LGADO_APOLC,
							    DINCL_LCTO_PRMIO,CIND_CRRTT_BCO,CIND_PRODT_TLEMP)
    SELECT VRE.CSUCUR, VRE.CCIA_SEGDR, VRE.CRAMO, VRE.CAPOLC,
           trunc(dbms_random.value(1,9999)), --VRE.CITEM_APOLC, Solicita��o Felipe
           CASE
             WHEN (VRE.CTPO_DOCTO_EMTDO_DW = 6) THEN
              PC_UTIL_01.EMISSAO
             ELSE
              PC_UTIL_01.ENDOSSO
           END,
           VRE.CDOCTO_PRMIO, VRE.DINCL_LCTO_PRMIO, --VRE.DEMIS_PRMIO,
           'CN', VRE.CCRRTR,
           max(VRE.DINIC_VGCIA_DOCTO), max(VRE.DFIM_VGCIA_APOLC), sum(VRE.VPRMIO_EMTDO_CSSRO_CDIDO),
           VRE.CCHAVE_DOCTO_PRMIO, sysdate, 'N', 'N'
      FROM VACPROD_CRRTR_CALC_BONUS_RE VRE
      JOIN AGPTO_RAMO_PLANO ARP ON ARP.CGRP_RAMO_PLANO IN
                                   (PC_UTIL_01.RETODOS)
                               AND ARP.CRAMO = VRE.CRAMO
     WHERE VRE.CCRRTR BETWEEN INTFAIXAINICIO AND INTFAIXAFIM
       --AND VRE.DEMIS_PRMIO = INTRDIA
       AND VRE.DINCL_LCTO_PRMIO = INTRDIA -- ALTERA��O DE 13/12/2007 ( WASSILY )
       AND EXISTS (SELECT 1
              FROM CRRTR C
             WHERE C.CCRRTR = VRE.CCRRTR
               AND C.CUND_PROD = VRE.CSUCUR)
     GROUP BY VRE.CSUCUR, VRE.CCIA_SEGDR, VRE.CRAMO, VRE.CAPOLC, VRE.CITEM_APOLC,
           CASE
             WHEN (VRE.CTPO_DOCTO_EMTDO_DW = 6) THEN
              PC_UTIL_01.EMISSAO
             ELSE
              PC_UTIL_01.ENDOSSO
           END,
           VRE.CDOCTO_PRMIO,  VRE.DINCL_LCTO_PRMIO, --VRE.DEMIS_PRMIO, 
           'CN', VRE.CCRRTR, VRE.CCHAVE_DOCTO_PRMIO;
  CHRLOCALERRO := 05;
  PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER, 708, PC_UTIL_01.VAR_ROTNA_PO);
  CHRLOCALERRO := 06;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    VAR_LOG_ERRO := SUBSTR('COD.ERRO: ' || CHRLOCALERRO || ' COMPET: ' ||
                           TO_CHAR(INTRDIA, 'DD/MM/YYYY') || ' CANAL: ' ||
                           TO_CHAR(PC_UTIL_01.EXTRA_BANCO) || ' # ' ||
                           SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0136', VAR_LOG_ERRO, PC_UTIL_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(CHRNOMEROTINASCHEDULER, 708, PC_UTIL_01.VAR_ROTNA_PE);
    RAISE;
END SGPB0136;
/
