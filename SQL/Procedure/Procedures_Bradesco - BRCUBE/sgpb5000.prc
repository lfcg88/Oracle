CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB5000(
  --curv_legenda    OUT SYS_REFCURSOR,
  curv_relat      OUT SYS_REFCURSOR,
  VAR_DATA_INICIO IN VARCHAR2, -- DDMMYYYY    
  VAR_DATA_FINAL  IN VARCHAR2  -- DDMMYYYY
) IS
-----------------------------------------------------------------------------------------------------------
  --      Bradesco Seguros s.a.
  --      procedure       : SGPB5000
  --      data            : 02/10/2007
  --      autor           : Wassily
  --      objetivo        : Retorna Cursor com Producao dos corretores do Plano de Bonus Destaque Mais
  --      Nome = Relatorio de Producao da Campanha Plano de Bonus Destaque Mais - Contingencia Raspadinha
  ---------------------------------------------------------------------------------------------------------
BEGIN
  BEGIN
   --OPEN curv_legenda FOR    
   --     select 'CCPF_CNPJ_BASE', 'TPO_PSSOA', 'RAZAO_SOCIAL', 'PRODUCAO_AUTO', 'PRODUCAO_RE', 'PRODUCAO_TOTAL',
   --            'RASPADINHAS', 'ROTINA', 'DATA_INICIO', 'DATA_FINAL', 'DATA_SISTEMA' FROM DUAL;
   OPEN curv_relat FOR    
        select a.CCPF_CNPJ_BASE,a.CTPO_PSSOA,a.ICRRTR,SUM(a.vl_prod_auto), SUM(a.vl_prod_re),
               SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re),
               TRUNC((SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re))/7000),
               'SGPB5000', VAR_DATA_INICIO, VAR_DATA_FINAL, TO_CHAR(SYSDATE,'DD/MM/YYYY')
              from (
              -- Auto Extra Banco
              select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'DD/MM/YYYY') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va
	            where c.CCPF_CNPJ_BASE not in (846415,2190592,2519440,30816391,53215653, 
	                                           59995639,63002745,90251042,2209148,43338235) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = va.CCRRTR and
                      c.CUND_PROD = va.CSUCUR and
                      va.CRAMO IN (120,460,519) AND
                      (va.DEMIS_ENDSS between to_date(VAR_DATA_INICIO,'DD/MM/YYYY') and
                                              to_date(VAR_DATA_FINAL,'DD/MM/YYYY') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR, to_char(va.DEMIS_ENDSS,'DD/MM/YYYY'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Re Extra Banco
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'DD/MM/YYYY') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve
	            where c.CCPF_CNPJ_BASE not in (846415,2190592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148,43338235) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = vE.CCRRTR and
                      c.CUND_PROD = vE.CSUCUR and
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      (vE.DEMIS_PRMIO between to_date(VAR_DATA_INICIO,'DD/MM/YYYY') and
                                              to_date(VAR_DATA_FINAL,'DD/MM/YYYY') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'DD/MM/YYYY'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Auto Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'DD/MM/YYYY') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2190592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148,43338235) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR > 199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (va.DEMIS_ENDSS between to_date(VAR_DATA_INICIO,'DD/MM/YYYY') and
                                              to_date(VAR_DATA_FINAL,'DD/MM/YYYY') ) AND
                      MAC.CCRRTR_ORIGN = vA.CCRRTR AND
                      MAC.CUND_PROD = VA.CSUCUR AND
                      va.CRAMO IN (120,460,519) AND
                      vA.DEMIS_ENDSS >= MAC.DENTRD_CRRTR_AG AND
                      vA.DEMIS_ENDSS < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE('31/12/9999', 'DD/MM/YYYY'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(va.DEMIS_ENDSS,'DD/MM/YYYY'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
              UNION ALL
                -- Re Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'DD/MM/YYYY') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2190592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148,43338235) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR >  199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (vE.DEMIS_PRMIO between to_date(VAR_DATA_INICIO,'DD/MM/YYYY') and
                                              to_date(VAR_DATA_FINAL,'DD/MM/YYYY') ) AND
                      MAC.CCRRTR_ORIGN = ve.CCRRTR AND
                      MAC.CUND_PROD = vE.CSUCUR AND
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      vE.DEMIS_PRMIO >= MAC.DENTRD_CRRTR_AG AND
                      vE.DEMIS_PRMIO < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE('31/12/9999', 'DD/MM/YYYY'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'DD/MM/YYYY'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
       ) a
       GROUP BY a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;      
      Raise_Application_Error(-20212,'ERRO NA EXECUCAO. ERRO: '||SUBSTR(SQLERRM,1,100));
  END;
END SGPB5000;
/

