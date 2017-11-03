CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0194(
  curvrelat        OUT SYS_REFCURSOR,
  Intcompetinicial IN NUMBER,    
  Intcompetfinal   IN NUMBER,
  intcanal		   in number
) IS
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0194
  --      data            : 26/06/07 11:26:18
  --      autor           : Wassily/Alexandre Cysne Esteves
  --      objetivo        : (SGPB) procedure que retorna todos os corretores nao eleitos
  --                        COLOCADA NOVA QUERY, SEM A TABELA ANTIGA DE IMPEDIDOS. WASSILY. 01/08/2007
  -------------------------------------------------------------------------------------------------
BEGIN
  BEGIN
  
  if Intcompetinicial = '200703' then -- CONTINGECIA SGPB DESTAQUE MAIS (DE 20071001 ATÉ 20071004)
   OPEN curvrelat FOR
   --
   select a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR,
       SUM(a.vl_prod_auto) vl_prod_auto, SUM(a.vl_prod_re) vl_prod_re,
       (SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re)) VL_TOTAL,
       trunc((SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re)) / 7000) QT_RASPADINHA
       from (
              -- Auto Extra Banco
              select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'YYYYMMDD') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = va.CCRRTR and
                      c.CUND_PROD = va.CSUCUR and
                      va.CRAMO IN (120,460,519) AND
                      (va.DEMIS_ENDSS between to_date('20071001','YYYYMMDD') and
                                              to_date('20071004','YYYYMMDD') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR, to_char(va.DEMIS_ENDSS,'YYYYMMDD'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Re Extra Banco
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'YYYYMMDD') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = vE.CCRRTR and
                      c.CUND_PROD = vE.CSUCUR and
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      (vE.DEMIS_PRMIO between to_date('20071001','YYYYMMDD') and
                                              to_date('20071004','YYYYMMDD') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'YYYYMMDD'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Auto Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'YYYYMMDD') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR > 199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (va.DEMIS_ENDSS between to_date('20071001','YYYYMMDD') and
                                              to_date('20071004','YYYYMMDD') ) AND
                      MAC.CCRRTR_ORIGN = vA.CCRRTR AND
                      MAC.CUND_PROD = VA.CSUCUR AND
                      va.CRAMO IN (120,460,519) AND
                      vA.DEMIS_ENDSS >= MAC.DENTRD_CRRTR_AG AND
                      vA.DEMIS_ENDSS < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(va.DEMIS_ENDSS,'YYYYMMDD'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
              UNION ALL
                -- Re Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'YYYYMMDD') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR >  199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (vE.DEMIS_PRMIO between to_date('20071001','YYYYMMDD') and
                                              to_date('20071004','YYYYMMDD') ) AND
                      MAC.CCRRTR_ORIGN = ve.CCRRTR AND
                      MAC.CUND_PROD = vE.CSUCUR AND
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      vE.DEMIS_PRMIO >= MAC.DENTRD_CRRTR_AG AND
                      vE.DEMIS_PRMIO < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'YYYYMMDD'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
       ) a
       GROUP BY a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR
       ORDER BY a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR;
       --sair
       return;
   end if;
        
   if Intcompetinicial = '200704' then -- CONTINGECIA SGPB DESTAQUE MAIS (DE 20071005 ATÉ 20071010)
   OPEN curvrelat FOR
   --
   select a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR,
       SUM(a.vl_prod_auto) vl_prod_auto, SUM(a.vl_prod_re) vl_prod_re,
       (SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re)) VL_TOTAL,
       trunc((SUM(a.vl_prod_auto)+ SUM(a.vl_prod_re)) / 7000) QT_RASPADINHA
       from (
              -- Auto Extra Banco
              select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'YYYYMMDD') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = va.CCRRTR and
                      c.CUND_PROD = va.CSUCUR and
                      va.CRAMO IN (120,460,519) AND
                      (va.DEMIS_ENDSS between to_date('20071005','YYYYMMDD') and
                                              to_date('20071010','YYYYMMDD') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR, to_char(va.DEMIS_ENDSS,'YYYYMMDD'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Re Extra Banco
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'YYYYMMDD') DT_COMPT, C.CCRRTR, c.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  C.CCRRTR <= 199992 AND
	                  C.CCRRTR = vE.CCRRTR and
                      c.CUND_PROD = vE.CSUCUR and
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      (vE.DEMIS_PRMIO between to_date('20071005','YYYYMMDD') and
                                              to_date('20071010','YYYYMMDD') )
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'YYYYMMDD'),
                         C.CCRRTR, c.CUND_PROD
              UNION ALL
                -- Auto Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(va.DEMIS_ENDSS,'YYYYMMDD') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                sum(VPRMIO_LIQ_AUTO) vl_prod_auto,0 vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_AT va, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR > 199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (va.DEMIS_ENDSS between to_date('20071005','YYYYMMDD') and
                                              to_date('20071010','YYYYMMDD') ) AND
                      MAC.CCRRTR_ORIGN = vA.CCRRTR AND
                      MAC.CUND_PROD = VA.CSUCUR AND
                      va.CRAMO IN (120,460,519) AND
                      vA.DEMIS_ENDSS >= MAC.DENTRD_CRRTR_AG AND
                      vA.DEMIS_ENDSS < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(va.DEMIS_ENDSS,'YYYYMMDD'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
              UNION ALL
                -- Re Banco e Finasa
                select c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,
                to_char(vE.DEMIS_PRMIO,'YYYYMMDD') DT_COMPT,  MAC.CCRRTR_DSMEM CCRRTR, MAC.CUND_PROD,
                0 vl_prod_auto, SUM(VPRMIO_EMTDO_CSSRO_CDIDO) vl_prod_re
	            from CRRTR c, VACPROD_CRRTR_CALC_BONUS_RE ve, MPMTO_AG_CRRTR MAC
	            where c.CCPF_CNPJ_BASE not in (846415,2170592,2519440,30816391,53215653,
	                                           59995639,63002745,90251042,2209148) and
	                  c.CUND_PROD <> 202 and
	                  c.CCRRTR <> 899997 and
	                  C.CCRRTR >  199992 AND
	                  C.CCRRTR = MAC.CCRRTR_DSMEM and
                      c.CUND_PROD = MAC.CUND_PROD and
                      (vE.DEMIS_PRMIO between to_date('20071005','YYYYMMDD') and
                                              to_date('20071010','YYYYMMDD') ) AND
                      MAC.CCRRTR_ORIGN = ve.CCRRTR AND
                      MAC.CUND_PROD = vE.CSUCUR AND
                      vE.CRAMO IN (331,351,600,917,925,927,810,919,921,923,926,292,574,613) AND
                      vE.DEMIS_PRMIO >= MAC.DENTRD_CRRTR_AG AND
                      vE.DEMIS_PRMIO < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                group by c.CCPF_CNPJ_BASE, c.CTPO_PSSOA, c.ICRRTR,to_char(vE.DEMIS_PRMIO,'YYYYMMDD'),
                         MAC.CCRRTR_DSMEM, MAC.CUND_PROD
       ) a
       GROUP BY a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR
       ORDER BY a.CCPF_CNPJ_BASE, a.CTPO_PSSOA, a.ICRRTR;
       --sair
       return;
   end if;
  
  
   if Intcompetinicial = '200701' then
      --
      if intcanal = pc_util_01.Extra_Banco then
      --
      OPEN curvrelat FOR
          select cUc.ccpf_cnpj_base, cUc.iatual_crrtr,'',
                SUM(CASE
                    WHEN apc.cgrp_ramo_plano = 120 THEN
                        pc.vprod_crrtr
                    ELSE
                        0
                END) PROD_AUTO,'',
                SUM(CASE
                    WHEN apc.cgrp_ramo_plano = 810 THEN
                        pc.vprod_crrtr
                    ELSE
                        0
                END) PROD_RE,'','','',
                mcc.pmargm_contb,
                nvl(opc1.vobjtv_prod_crrtr_alt,0) +
                nvl(opc2.vobjtv_prod_crrtr_alt,0) +
                nvl(opc3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_auto,
                nvl(opcRE1.vobjtv_prod_crrtr_alt,0) +
                nvl(opcRE2.vobjtv_prod_crrtr_alt,0) +
                nvl(opcRE3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_RE,'',
                SUM (CASE
                    WHEN apc.ctpo_apurc = 1 THEN
                       pc.vprod_crrtr * (apc.pbonus_apurc /100)
                    ELSE
                        0
                END) BONUS,'','','',
                SUM (CASE
                    WHEN apc.ctpo_apurc = 2 THEN
                        pc.vprod_crrtr * (apc.pbonus_apurc /100)
                   ELSE
                        0
                END) BONUS_ADICIONAL, '','',SUM(pc.vprod_crrtr * (apc.pbonus_apurc /100)) BONUS_TOTAL
           from crrtr c
           join  prod_crrtr  pc
            on pc.ccrrtr    = c.ccrrtr
           and pc.cund_prod = c.cund_prod
           and pc.ctpo_comis = 'CN'
           and pc.ccompt_prod between 200707 and 200709
           join crrtr_unfca_cnpj cuc
            on cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
           and cuc.ctpo_pssoa     = c.ctpo_pssoa
           join apurc_prod_crrtr apc
            on apc.ccrrtr    = pc.ccrrtr
           and apc.cund_prod = pc.cund_prod
           AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
           AND apc.ccompt_prod     = pc.ccompt_prod
           AND apc.ctpo_comis      = pc.ctpo_comis
           and apc.ccanal_vda_segur = 1
           and apc.cgrp_ramo_plano  in (120,810)
          left join margm_contb_crrtr mcc
           on mcc.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and mcc.ctpo_pssoa = cuc.ctpo_pssoa
           and mcc.ccanal_vda_segur = apc.ccanal_vda_segur
           and mcc.ccompt_margm = 200709
          left join objtv_prod_crrtr opc1
           on opc1.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opc1.ctpo_pssoa = cuc.ctpo_pssoa
           and opc1.ccanal_vda_segur = apc.ccanal_vda_segur
           and opc1.cano_mes_compt_objtv  = ( mcc.ccompt_margm - 2 ) --200704
           and opc1.cgrp_ramo_plano = 120
           and opc1.cind_reg_ativo = 'S'
          left join objtv_prod_crrtr opc2
           on opc2.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opc2.ctpo_pssoa = cuc.ctpo_pssoa
           and opc2.ccanal_vda_segur = apc.ccanal_vda_segur
           and opc2.cgrp_ramo_plano = 120
           and opc2.cano_mes_compt_objtv  = ( mcc.ccompt_margm - 1 ) --200705
           and opc2.cind_reg_ativo = 'S'
          left join objtv_prod_crrtr opc3
           on opc3.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opc3.ctpo_pssoa = cuc.ctpo_pssoa
           and opc3.ccanal_vda_segur = apc.ccanal_vda_segur
           and opc3.cgrp_ramo_plano = 120
           and opc3.cano_mes_compt_objtv  = ( mcc.ccompt_margm ) --200706
           and opc3.cind_reg_ativo = 'S'
          left join objtv_prod_crrtr opcRE1
           on opcRE1.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opcRE1.ctpo_pssoa = cuc.ctpo_pssoa
           and opcRE1.ccanal_vda_segur = apc.ccanal_vda_segur
           and opcRE1.cano_mes_compt_objtv  = ( mcc.ccompt_margm - 2 ) --200704
           and opcRE1.cgrp_ramo_plano = 810
           and opcRE1.cind_reg_ativo = 'S'
          left join objtv_prod_crrtr opcRE2
           on opcRE2.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opcRE2.ctpo_pssoa = cuc.ctpo_pssoa
           and opcRE2.ccanal_vda_segur = apc.ccanal_vda_segur
           and opcRE2.cgrp_ramo_plano = 810
           and opcRE2.cano_mes_compt_objtv  = ( mcc.ccompt_margm - 1 ) --200705
           and opcRE2.cind_reg_ativo = 'S'
          left join objtv_prod_crrtr opcRE3
           on opcRE3.ccpf_cnpj_base = cuc.ccpf_cnpj_base
           and opcRE3.ctpo_pssoa = cuc.ctpo_pssoa
           and opcRE3.ccanal_vda_segur = apc.ccanal_vda_segur
           and opcRE3.cgrp_ramo_plano = 810
           and opcRE3.cano_mes_compt_objtv  = ( mcc.ccompt_margm ) --200706
           and opcRE3.cind_reg_ativo = 'S'
           group by cUc.ccpf_cnpj_base, cUc.iatual_crrtr, mcc.pmargm_contb, opc1.vobjtv_prod_crrtr_alt,
                   opc2.vobjtv_prod_crrtr_alt, opc3.vobjtv_prod_crrtr_alt, opcRE1.vobjtv_prod_crrtr_alt,
                   opcRE2.vobjtv_prod_crrtr_alt, opcRE3.vobjtv_prod_crrtr_alt
           order by PROD_AUTO desc;
           
           --sair
           return;
      end if;
      
      
      --
      if intcanal = pc_util_01.Banco then
      --
      OPEN curvrelat FOR
           Select c.ccpf_cnpj_base, c.ICRRTR,
           --
           '',
           --
          SUM(CASE
              WHEN apc.cgrp_ramo_plano = 120 THEN
                  pc.vprod_crrtr
              ELSE
                  0
          END) PROD_AUTO,
          --
          '',
          --
          SUM(CASE
              WHEN apc.cgrp_ramo_plano = 810 THEN
                  pc.vprod_crrtr
              ELSE
                  0
          END) PROD_RE,
          mcc.pmargm_contb,
          --
          '',
          '',
          '',
          --
          nvl(opc1.vobjtv_prod_crrtr_alt,0) +
          nvl(opc2.vobjtv_prod_crrtr_alt,0) +
          nvl(opc3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_auto,
          nvl(opcRE1.vobjtv_prod_crrtr_alt,0) +
          nvl(opcRE2.vobjtv_prod_crrtr_alt,0) +
          nvl(opcRE3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_RE,
          --
          '',
          --
          SUM (CASE
              WHEN apc.ctpo_apurc = 1 THEN
                  pc.vprod_crrtr * (apc.pbonus_apurc /100)
              ELSE
                  0
          END) BONUS,
          --
          '',
          '',
          '',
          --
          SUM (CASE
              WHEN apc.ctpo_apurc = 2 THEN
                  pc.vprod_crrtr * (apc.pbonus_apurc /100)
              ELSE
                  0
          END) BONUS_ADICIONAL,
          --
          SUM(pc.vprod_crrtr * (apc.pbonus_apurc /100)) BONUS_TOTAL
     from prod_crrtr pc
     JOIN CRRTR C
          on c.CCRRTR            = PC.CCRRTR
          AND c.CUND_PROD        = PC.CUND_PROD
     join apurc_prod_crrtr apc
          on apc.ccrrtr          = pc.ccrrtr
         and apc.cund_prod       = pc.cund_prod
         AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
         AND apc.ccompt_prod     = pc.ccompt_prod
         AND apc.ctpo_comis      = pc.ctpo_comis
         AND apc.ctpo_comis      = 'CN'
         and apc.ccanal_vda_segur= 2
         AND apc.ccompt_prod  IN (200707,200708,200709)
         AND apc.ccompt_APURC = 200709
         and apc.cgrp_ramo_plano  in (120,810)
         AND APC.CCRRTR           = C.CCRRTR
         AND APc.CUND_PROD        = C.CUND_PROD
    left join margm_contb_crrtr mcc
         on mcc.ccpf_cnpj_base = c.ccpf_cnpj_base
         and mcc.ctpo_pssoa = c.ctpo_pssoa
         and mcc.ccanal_vda_segur = apc.ccanal_vda_segur
         and mcc.ccompt_margm = apc.ccompt_APURC
    left join objtv_prod_crrtr opc1
         on opc1.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc1.ctpo_pssoa = c.ctpo_pssoa
         and opc1.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc1.cano_mes_compt_objtv  = 200707
         and opc1.cgrp_ramo_plano = 120
         and opc1.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opc2
         on opc2.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc2.ctpo_pssoa = c.ctpo_pssoa
         and opc2.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc2.cgrp_ramo_plano = 120
         and opc2.cano_mes_compt_objtv  = 200708
         and opc2.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opc3
         on opc3.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc3.ctpo_pssoa = c.ctpo_pssoa
         and opc3.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc3.cgrp_ramo_plano = 120
         and opc3.cano_mes_compt_objtv  = 200709
         and opc3.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE1
         on opcRE1.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE1.ctpo_pssoa = c.ctpo_pssoa
         and opcRE1.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE1.cano_mes_compt_objtv  = 200707
         and opcRE1.cgrp_ramo_plano = 810
         and opcRE1.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE2
         on opcRE2.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE2.ctpo_pssoa = c.ctpo_pssoa
         and opcRE2.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE2.cgrp_ramo_plano = 810
         and opcRE2.cano_mes_compt_objtv  = 200708
         and opcRE2.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE3
         on opcRE3.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE3.ctpo_pssoa = c.ctpo_pssoa
         and opcRE3.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE3.cgrp_ramo_plano = 810
         and opcRE3.cano_mes_compt_objtv  = 200709
         and opcRE3.cind_reg_ativo = 'S'
    group by c.ccpf_cnpj_base,
             c.ICRRTR,
             mcc.pmargm_contb,
             opc1.vobjtv_prod_crrtr_alt,
             opc2.vobjtv_prod_crrtr_alt,
             opc3.vobjtv_prod_crrtr_alt,
             opcRE1.vobjtv_prod_crrtr_alt,
             opcRE2.vobjtv_prod_crrtr_alt,
             opcRE3.vobjtv_prod_crrtr_alt
     order by PROD_AUTO desc;

      return; 
      --     
      end if;
      
      --
      if intcanal = pc_util_01.Finasa then
      --
      OPEN curvrelat FOR
           Select c.ccpf_cnpj_base, c.ICRRTR,
           --
           '',
           --
          SUM(CASE
              WHEN apc.cgrp_ramo_plano = 120 THEN
                  pc.vprod_crrtr
              ELSE
                  0
          END) PROD_AUTO,
          --
          '',
          --
          SUM(CASE
              WHEN apc.cgrp_ramo_plano = 810 THEN
                  pc.vprod_crrtr
              ELSE
                  0
          END) PROD_RE,
          mcc.pmargm_contb,
          --
          '',
          '',
          '',
          --
          nvl(opc1.vobjtv_prod_crrtr_alt,0) +
          nvl(opc2.vobjtv_prod_crrtr_alt,0) +
          nvl(opc3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_auto,
          nvl(opcRE1.vobjtv_prod_crrtr_alt,0) +
          nvl(opcRE2.vobjtv_prod_crrtr_alt,0) +
          nvl(opcRE3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_RE,
          --
          '',
          --
          SUM (CASE
              WHEN apc.ctpo_apurc = 1 THEN
                  pc.vprod_crrtr * (apc.pbonus_apurc /100)
              ELSE
                  0
          END) BONUS,
          --
          '',
          '',
          '',
          --
          SUM (CASE
              WHEN apc.ctpo_apurc = 2 THEN
                  pc.vprod_crrtr * (apc.pbonus_apurc /100)
              ELSE
                  0
          END) BONUS_ADICIONAL,
          --
          SUM(pc.vprod_crrtr * (apc.pbonus_apurc /100)) BONUS_TOTAL
     from prod_crrtr pc
     JOIN CRRTR C
          on c.CCRRTR            = PC.CCRRTR
          AND c.CUND_PROD        = PC.CUND_PROD
     join apurc_prod_crrtr apc
          on apc.ccrrtr          = pc.ccrrtr
         and apc.cund_prod       = pc.cund_prod
         AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
         AND apc.ccompt_prod     = pc.ccompt_prod
         AND apc.ctpo_comis      = pc.ctpo_comis
         AND apc.ctpo_comis      = 'CN'
         and apc.ccanal_vda_segur= 3
         AND apc.ccompt_prod  IN (200707,200708,200709)
         AND apc.ccompt_APURC = 200709
         and apc.cgrp_ramo_plano  in (120,810)
         AND APC.CCRRTR           = C.CCRRTR
         AND APc.CUND_PROD        = C.CUND_PROD
    left join margm_contb_crrtr mcc
         on mcc.ccpf_cnpj_base = c.ccpf_cnpj_base
         and mcc.ctpo_pssoa = c.ctpo_pssoa
         and mcc.ccanal_vda_segur = apc.ccanal_vda_segur
         and mcc.ccompt_margm = apc.ccompt_APURC
    left join objtv_prod_crrtr opc1
         on opc1.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc1.ctpo_pssoa = c.ctpo_pssoa
         and opc1.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc1.cano_mes_compt_objtv  = 200707
         and opc1.cgrp_ramo_plano = 120
         and opc1.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opc2
         on opc2.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc2.ctpo_pssoa = c.ctpo_pssoa
         and opc2.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc2.cgrp_ramo_plano = 120
         and opc2.cano_mes_compt_objtv  = 200708
         and opc2.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opc3
         on opc3.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opc3.ctpo_pssoa = c.ctpo_pssoa
         and opc3.ccanal_vda_segur = apc.ccanal_vda_segur
         and opc3.cgrp_ramo_plano = 120
         and opc3.cano_mes_compt_objtv  = 200709
         and opc3.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE1
         on opcRE1.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE1.ctpo_pssoa = c.ctpo_pssoa
         and opcRE1.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE1.cano_mes_compt_objtv  = 200707
         and opcRE1.cgrp_ramo_plano = 810
         and opcRE1.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE2
         on opcRE2.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE2.ctpo_pssoa = c.ctpo_pssoa
         and opcRE2.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE2.cgrp_ramo_plano = 810
         and opcRE2.cano_mes_compt_objtv  = 200708
         and opcRE2.cind_reg_ativo = 'S'
    left join objtv_prod_crrtr opcRE3
         on opcRE3.ccpf_cnpj_base = c.ccpf_cnpj_base
         and opcRE3.ctpo_pssoa = c.ctpo_pssoa
         and opcRE3.ccanal_vda_segur = apc.ccanal_vda_segur
         and opcRE3.cgrp_ramo_plano = 810
         and opcRE3.cano_mes_compt_objtv  = 200709
         and opcRE3.cind_reg_ativo = 'S'
    group by c.ccpf_cnpj_base,
             c.ICRRTR,
             mcc.pmargm_contb,
             opc1.vobjtv_prod_crrtr_alt,
             opc2.vobjtv_prod_crrtr_alt,
             opc3.vobjtv_prod_crrtr_alt,
             opcRE1.vobjtv_prod_crrtr_alt,
             opcRE2.vobjtv_prod_crrtr_alt,
             opcRE3.vobjtv_prod_crrtr_alt
     order by PROD_AUTO desc;

      --
      return; 
      --     
      end if;
   end if;
  
  
   --------original
   if intcanal = pc_util_01.Extra_Banco then
     OPEN curvrelat FOR
      SELECT decode(cec.ccpf_cnpj_base, null, 'Não Eleito', 'Eleito') "ELEITO",
       cvs.ICANAL_VDA_SEGUR CANAL,Cuc.Iatual_Crrtr NOME_CORRETOR,
       Cuc.Ccpf_Cnpj_Base "CNPJ_CPF_BASE",Cuc.Ctpo_Pssoa TP_PES,C.Cund_Prod SUC,
       C.Ccrrtr COD_CPD, TO_CHAR(MIN(c.Dcadto_Crrtr),'DD/MM/YYYY') DT_CADASTRO,
       CASE
       		WHEN MONTHS_BETWEEN(to_date(200701||'01','yyyymmdd'),C.Dcadto_Crrtr) >= pcvs.QTEMPO_MIN_RLCTO
       			THEN
       				'Tempo de Cadastro Maior Ou Igual a '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       			ELSE
       				'Tempo de Cadastro Menor do Que '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       end as "Tempo Cadastro",
       IGRP_RAMO_PLANO RAMO,Pc.Ccompt_Prod COMPETENCIA, PC.CTPO_COMIS TP_COMIS,
       SUM(Pc.Qtot_Item_Prod) QT_PROD,SUM(Pc.Vprod_Crrtr) VL_PROD,
       CASE
         WHEN ((ilnc.csit_crrtr_bdsco IS NULL) OR
              (ilnc.csit_crrtr_bdsco = 0)) THEN
          'Sem Restricoes'
         WHEN ilnc.csit_crrtr_bdsco = 1 THEN
          'Susep'
         WHEN ilnc.csit_crrtr_bdsco = 2 THEN
          'CCC'
         WHEN ilnc.csit_crrtr_bdsco = 3 THEN
          'Cia'
         WHEN ilnc.csit_crrtr_bdsco = 4 THEN
          'INSS'
         WHEN ilnc.csit_crrtr_bdsco = 5 THEN
          'CESP'
       END "RESTRICOES",
       DECODE(EXE.CTPO_EXCEC_CRRTR,'I','IMPEDIMENTO MANUAL','SEM IMPEDIDO MANUAL') "IMPEDIMENTO",
       MIN(pcvs.QTEMPO_MIN_RLCTO) QT_MESES_CONS, MIN(Ppmcp.Vmin_Prod_Crrtr) "VL_PRD_MIN_TOTAL",
       MIN(Ppmcp.Vmin_Prod_Crrtr)/ MIN(pcvs.QTEMPO_MIN_RLCTO) "VL_PRD_MIN_MENSAL" ,
       MIN(Mcc.Ccompt_Margm) "COMP_MARGEM",MIN(MCC.PMARGM_CONTB) "PMARGM_CONTB" ,
       MIN(NVL(CCC.PCRSCT_PROD_ORIGN,0)) "PERC_CRESC_ORIG", MIN(NVL(CCC.PCRSCT_PROD_ALT,0)) "PERC_CRESC_ALT"
    FROM Parm_Canal_Vda_Segur Pcvs
    JOIN Crrtr c ON c.Ccrrtr BETWEEN Pcvs.Cinic_Faixa_Crrtr AND Pcvs.Cfnal_Faixa_Crrtr
    JOIN Crrtr_Unfca_Cnpj Cuc ON Cuc.Ctpo_Pssoa = c.Ctpo_Pssoa
                           AND Cuc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
    JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = c.Ccrrtr
                    AND Pc.Cund_Prod = c.Cund_Prod
                    AND CTPO_COMIS = pc_util_01.COMISSAO_NORMAL
    JOIN GRP_RAMO_PLANO GRP ON GRP.CGRP_RAMO_PLANO = PC.CGRP_RAMO_PLANO
    JOIN CANAL_VDA_SEGUR CVS ON CVS.CCANAL_VDA_SEGUR = PCVS.CCANAL_VDA_SEGUR
    LEFT JOIN margm_contb_crrtr mcc ON Mcc.Ccpf_Cnpj_Base = Cuc.Ccpf_Cnpj_Base
            AND Mcc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Mcc.Ccanal_Vda_Segur = Pcvs.Ccanal_Vda_Segur
            AND Mcc.Ccompt_Margm = Pc.Ccompt_Prod
    LEFT JOIN Info_Lista_Negra_Crrtr Ilnc ON Ilnc.Ccpf_Cnpj_Base = Cuc.Ccpf_Cnpj_Base
            AND Ilnc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Ilnc.Ccompt_Sit_Crrtr = Intcompetinicial
    LEFT JOIN Parm_Prod_Min_Crrtr Ppmcp ON Ppmcp.Ccanal_Vda_Segur = Pcvs.Ccanal_Vda_Segur
            AND Ppmcp.Cgrp_Ramo_Plano = decode(Pc.Cgrp_Ramo_Plano,pc_util_01.Auto,Pc.Cgrp_Ramo_Plano,pc_util_01.Re)
            AND Ppmcp.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Ppmcp.Ctpo_Per = DECODE(PC.CGRP_RAMO_PLANO,pc_util_01.Auto,PC_UTIL_01.Periodo,PC_UTIL_01.MENSAL)
            AND ( To_Date(Intcompetinicial||'01','YYYYMMDD') - 1 ) BETWEEN
 			     Ppmcp.Dinic_Vgcia_Parm AND Nvl(Ppmcp.Dfim_Vgcia_Parm,To_Date(99991231,'YYYYMMDD'))
    left join parm_info_campa pic on pic.ccanal_vda_segur = pcvs.ccanal_vda_segur
                               and to_date(Intcompetinicial||'01', 'YYYYMMDD') between pic.dinic_vgcia_parm and
                                   nvl(pic.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
    LEFT JOIN CRRTR_EXCEC_CAMPA EXE
        	ON EXE.CCANAL_VDA_SEGUR  = pcvs.CCANAL_VDA_SEGUR
       		AND EXE.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       		AND EXE.CCPF_CNPJ_BASE   = CUC.CCPF_CNPJ_BASE
       		AND EXE.CTPO_PSSOA       = CUC.CTPO_PSSOA
       		AND EXE.CIND_REG_ATIVO   = 'S'
       		AND EXE.CTPO_EXCEC_CRRTR = 'I'
    LEFT JOIN CARAC_CRRTR_CANAL CCC
        	ON CCC.CCANAL_VDA_SEGUR = pcvs.CCANAL_VDA_SEGUR
       		AND CCC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       		AND CCC.CCPF_CNPJ_BASE   = CUC.CCPF_CNPJ_BASE
       		AND CCC.CTPO_PSSOA       = CUC.CTPO_PSSOA
       		AND CCC.CIND_PERC_ATIVO = 'S'
    left join crrtr_eleit_campa cec on cec.ccpf_cnpj_base = cuc.ccpf_cnpj_base
            and cec.ctpo_pssoa = cuc.ctpo_pssoa
            AND CeC.CCANAL_VDA_SEGUR = Pcvs.ccanal_vda_segur
            and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
    WHERE Pcvs.Ccanal_Vda_Segur = pc_util_01.Extra_Banco
    AND Pc.Ccompt_Prod BETWEEN Intcompetinicial AND Intcompetfinal
    and cec.ccpf_cnpj_base is null
    GROUP BY decode(cec.ccpf_cnpj_base, null, 'Não Eleito', 'Eleito'),
       cvs.ICANAL_VDA_SEGUR,Cuc.Iatual_Crrtr,
       Cuc.Ccpf_Cnpj_Base,Cuc.Ctpo_Pssoa,C.Ccrrtr,C.Cund_Prod,
       CASE
       		WHEN MONTHS_BETWEEN(to_date(200701||'01','yyyymmdd'),C.Dcadto_Crrtr) >= pcvs.QTEMPO_MIN_RLCTO
       			THEN
       				'Tempo de Cadastro Maior Ou Igual a '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       			ELSE
       				'Tempo de Cadastro Menor do Que '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       end,
       IGRP_RAMO_PLANO,Pc.Ccompt_Prod, PC.CTPO_COMIS,
       CASE
         WHEN ((ilnc.csit_crrtr_bdsco IS NULL) OR
              (ilnc.csit_crrtr_bdsco = 0)) THEN
          'Sem Restricoes'
         WHEN ilnc.csit_crrtr_bdsco = 1 THEN
          'Susep'
         WHEN ilnc.csit_crrtr_bdsco = 2 THEN
          'CCC'
         WHEN ilnc.csit_crrtr_bdsco = 3 THEN
          'Cia'
         WHEN ilnc.csit_crrtr_bdsco = 4 THEN
          'INSS'
         WHEN ilnc.csit_crrtr_bdsco = 5 THEN
          'CESP'
       END,
       DECODE(EXE.CTPO_EXCEC_CRRTR,'I','IMPEDIMENTO MANUAL','SEM IMPEDIDO MANUAL');
  else
    OPEN curvrelat FOR 
     SELECT decode(cec.ccpf_cnpj_base, null, 'Não Eleito', 'Eleito') "ELEITO",
       cvs.ICANAL_VDA_SEGUR CANAL,Cuc.Iatual_Crrtr NOME_CORRETOR,
       Cuc.Ccpf_Cnpj_Base "CNPJ_CPF_BASE",Cuc.Ctpo_Pssoa TP_PES,CDESM.Cund_Prod SUC,
       CDESM.Ccrrtr COD_CPD,TO_CHAR(MIN(CDESM.Dcadto_Crrtr),'DD/MM/YYYY') DT_CADASTRO,
       CASE
       		WHEN MONTHS_BETWEEN(to_date(200701||'01','yyyymmdd'),CDESM.Dcadto_Crrtr) >= pcvs.QTEMPO_MIN_RLCTO
       			THEN
       				'Tempo de Cadastro Maior Ou Igual a '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       			ELSE
       				'Tempo de Cadastro Menor do Que '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       end as "Tempo Cadastro",
       IGRP_RAMO_PLANO RAMO,Pc.Ccompt_Prod COMPETENCIA, PC.CTPO_COMIS TP_COMIS,
       SUM(Pc.Qtot_Item_Prod) QT_PROD,SUM(Pc.Vprod_Crrtr) VL_PROD,
       CASE
         WHEN ((ilnc.csit_crrtr_bdsco IS NULL) OR
              (ilnc.csit_crrtr_bdsco = 0)) THEN
          'Sem Restricoes'
         WHEN ilnc.csit_crrtr_bdsco = 1 THEN
          'Susep'
         WHEN ilnc.csit_crrtr_bdsco = 2 THEN
          'CCC'
         WHEN ilnc.csit_crrtr_bdsco = 3 THEN
          'Cia'
         WHEN ilnc.csit_crrtr_bdsco = 4 THEN
          'INSS'
         WHEN ilnc.csit_crrtr_bdsco = 5 THEN
          'CESP'
       END "RESTRICOES",
       DECODE(EXE.CTPO_EXCEC_CRRTR,'I','IMPEDIMENTO MANUAL','SEM IMPEDIDO MANUAL') "IMPEDIMENTO",
       MIN(pcvs.QTEMPO_MIN_RLCTO) QT_MESES_CONS, MIN(Ppmcp.Vmin_Prod_Crrtr) "VL_PRD_MIN_TOTAL",
       MIN(Ppmcp.Vmin_Prod_Crrtr)/ MIN(pcvs.QTEMPO_MIN_RLCTO) "VL_PRD_MIN_MENSAL" ,
       MIN(Mcc.Ccompt_Margm) "COMP_MARGEM",MIN(MCC.PMARGM_CONTB) "PMARGM_CONTB" ,
       MIN(NVL(CCC.PCRSCT_PROD_ORIGN,0)) "PERC_CRESC_ORIG", MIN(NVL(CCC.PCRSCT_PROD_ALT,0)) "PERC_CRESC_ALT"
    FROM Parm_Canal_Vda_Segur Pcvs
    JOIN mpmto_ag_crrtr mac
     on MAC.CCRRTR_ORIGN between pcvs.cinic_faixa_crrtr AND pcvs.cfnal_faixa_crrtr
    AND TO_DATE(Intcompetinicial||'01', 'YYYYMMDD') >= MAC.DENTRD_CRRTR_AG
    AND TO_DATE(Intcompetfinal||'01', 'YYYYMMDD') <= NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
    JOIN CANAL_VDA_SEGUR CVS ON CVS.CCANAL_VDA_SEGUR = PCVS.CCANAL_VDA_SEGUR
    left JOIN Crrtr cDesm ON cDesm.Ccrrtr = MAC.Ccrrtr_Dsmem AND cDesm.Cund_Prod = mac.cund_prod
    left JOIN CRRTR cOri ON cOri.Ccrrtr = MAC.Ccrrtr_Orign AND cOri.Cund_Prod = mac.cund_prod
    left JOIN CRRTR_UNFCA_CNPJ cuc ON cuc.ctpo_pssoa = cDesm.ctpo_pssoa
                           AND cuc.ccpf_cnpj_base = cDesm.ccpf_cnpj_base
    left JOIN PROD_CRRTR pc ON pc.ccrrtr = cDesm.ccrrtr
                    AND pc.cund_prod = cDesm.cund_prod
                    AND pc.ctpo_comis = pc_util_01.COMISSAO_NORMAL
                    and pc.cgrp_ramo_plano in (pc_util_01.Auto,pc_util_01.Re)
    JOIN GRP_RAMO_PLANO GRP ON GRP.CGRP_RAMO_PLANO = PC.CGRP_RAMO_PLANO
    LEFT JOIN margm_contb_crrtr mcc ON Mcc.Ccpf_Cnpj_Base = Cuc.Ccpf_Cnpj_Base
            AND Mcc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Mcc.Ccanal_Vda_Segur = Pcvs.Ccanal_Vda_Segur
            AND Mcc.Ccompt_Margm = Pc.Ccompt_Prod
    LEFT JOIN Info_Lista_Negra_Crrtr Ilnc ON Ilnc.Ccpf_Cnpj_Base = Cuc.Ccpf_Cnpj_Base
            AND Ilnc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Ilnc.Ccompt_Sit_Crrtr = Intcompetinicial
    LEFT JOIN Parm_Prod_Min_Crrtr Ppmcp ON Ppmcp.Ccanal_Vda_Segur = Pcvs.Ccanal_Vda_Segur
            AND Ppmcp.Cgrp_Ramo_Plano = Pc.Cgrp_Ramo_Plano
            AND Ppmcp.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
            AND Ppmcp.Ctpo_Per = DECODE(PC.CGRP_RAMO_PLANO,pc_util_01.Auto,PC_UTIL_01.Periodo,PC_UTIL_01.Mensal)
            AND ( To_Date(Intcompetinicial||'01','YYYYMMDD') - 1 ) BETWEEN
 			     Ppmcp.Dinic_Vgcia_Parm AND Nvl(Ppmcp.Dfim_Vgcia_Parm,To_Date(99991231,'YYYYMMDD'))
    left join parm_info_campa pic on pic.ccanal_vda_segur = pcvs.ccanal_vda_segur
                               and to_date(Intcompetinicial||'01', 'YYYYMMDD') between pic.dinic_vgcia_parm and
                                   nvl(pic.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
    LEFT JOIN CRRTR_EXCEC_CAMPA EXE
        	ON EXE.CCANAL_VDA_SEGUR  = pcvs.CCANAL_VDA_SEGUR
       		AND EXE.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       		AND EXE.CCPF_CNPJ_BASE   = CUC.CCPF_CNPJ_BASE
       		AND EXE.CTPO_PSSOA       = CUC.CTPO_PSSOA
       		AND EXE.CIND_REG_ATIVO   = 'S'
       		AND EXE.CTPO_EXCEC_CRRTR = 'I'
    LEFT JOIN CARAC_CRRTR_CANAL CCC
        	ON CCC.CCANAL_VDA_SEGUR = pcvs.CCANAL_VDA_SEGUR
       		AND CCC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       		AND CCC.CCPF_CNPJ_BASE   = CUC.CCPF_CNPJ_BASE
       		AND CCC.CTPO_PSSOA       = CUC.CTPO_PSSOA
       		AND CCC.CIND_PERC_ATIVO = 'S'
    left join crrtr_eleit_campa cec on cec.ccpf_cnpj_base = cuc.ccpf_cnpj_base
            and cec.ctpo_pssoa = cuc.ctpo_pssoa
            AND CeC.CCANAL_VDA_SEGUR = Pcvs.ccanal_vda_segur
            and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
    WHERE Pcvs.Ccanal_Vda_Segur = intcanal
    AND Pc.Ccompt_Prod BETWEEN Intcompetinicial AND Intcompetfinal
    and cec.ccpf_cnpj_base is null
    GROUP BY decode(cec.ccpf_cnpj_base, null, 'Não Eleito', 'Eleito'),
       cvs.ICANAL_VDA_SEGUR,Cuc.Iatual_Crrtr,
       Cuc.Ccpf_Cnpj_Base,Cuc.Ctpo_Pssoa,CDESM.Ccrrtr,CDESM.Cund_Prod,
       CASE
       		WHEN MONTHS_BETWEEN(to_date(200701||'01','yyyymmdd'),CDESM.Dcadto_Crrtr) >= pcvs.QTEMPO_MIN_RLCTO
       			THEN
       				'Tempo de Cadastro Maior Ou Igual a '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       			ELSE
       				'Tempo de Cadastro Menor do Que '||pcvs.QTEMPO_MIN_RLCTO||' Meses'
       end,
       IGRP_RAMO_PLANO,Pc.Ccompt_Prod, PC.CTPO_COMIS,
       CASE
         WHEN ((ilnc.csit_crrtr_bdsco IS NULL) OR
              (ilnc.csit_crrtr_bdsco = 0)) THEN
          'Sem Restricoes'
         WHEN ilnc.csit_crrtr_bdsco = 1 THEN
          'Susep'
         WHEN ilnc.csit_crrtr_bdsco = 2 THEN
          'CCC'
         WHEN ilnc.csit_crrtr_bdsco = 3 THEN
          'Cia'
         WHEN ilnc.csit_crrtr_bdsco = 4 THEN
          'INSS'
         WHEN ilnc.csit_crrtr_bdsco = 5 THEN
          'CESP'
       END,
       DECODE(EXE.CTPO_EXCEC_CRRTR,'I','IMPEDIMENTO MANUAL','SEM IMPEDIDO MANUAL');  
    end if;
       --Raise_Application_Error(-20212,'TUDO BEM');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;      
      Raise_Application_Error(-20212,'ERRO NA GERACAO DO REALTORIO DE CORRETORES NAO ELEITOS ERRO: '||SUBSTR(SQLERRM,1,100));
  END;
END SGPB0194;
/

