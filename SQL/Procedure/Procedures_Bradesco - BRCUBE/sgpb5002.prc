CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB5002(
  --curv_legenda    OUT SYS_REFCURSOR,
  curv_relat      OUT SYS_REFCURSOR,
  VAR_CANAL       IN NUMBER,
  VAR_COMPT_INIC  IN NUMBER,    
  VAR_COMPT_FIM   IN NUMBER
) IS
-------------------------------------------------------------------------------------------------
  --      Bradesco Seguros s.a.
  --      procedure       : SGPB5000
  --      data            : 03/10/2007
  --      autor           : Wassily
  --      objetivo        : Retorna Planilha capuração de cada canal
  --      Nome = Relatorio de Apuracao da Campanha Plano de Bonus
  -------------------------------------------------------------------------------------------------
BEGIN
  BEGIN
   --OPEN curv_legenda FOR    
   --     select 'CANAL','CCPF_CNPJ_BASE', 'TPO_PSSOA', 'RAZAO_SOCIAL', 'PRODUCAO_AUTO', 'PRODUCAO_RE', 'MARGEM_CONTR',
   --            'OBJETIVO_TRIMESTRE_AUTO', 'OBJETIVO_TRIMESTRE_RE', 'BONUS', 'BONUS_ADICIONAL', 'BONUS_TOTAL',
   --            'ROTINA', 'COMPETENCIA_INICIAL', 'COMPETENCIA_FINAL', 'DATA_SISTEMA' FROM DUAL;
   IF VAR_CANAL = 1 THEN
      OPEN curv_relat FOR
       select 'EXTRABANCO', a.CCPF_CNPJ_BASE,a.CTPO_PSSOA,a.iatual_crrtr,
       a.PROD_AUTO,a.PROD_RE,a.pmargm_contb,a.objetivo_trimestre_auto,
       a.objetivo_trimestre_RE,a.BONUS,a.BONUS_ADICIONAL,a.BONUS_TOTAL,
       'SGPB5002', VAR_COMPT_INIC, VAR_COMPT_FIM, TO_CHAR(SYSDATE,'DD/MM/YYYY')
       from ( SELECT A.ccpf_cnpj_base, a.CTPO_PSSOA, A.iatual_crrtr, SUM(A.PROD_AUTO) PROD_AUTO, SUM(A.PROD_RE) PROD_RE,
       SUM(A.pmargm_contb) pmargm_contb, SUM(A.objetivo_trimestre_auto) objetivo_trimestre_auto,
       SUM(A.objetivo_trimestre_RE) objetivo_trimestre_RE, SUM(A.BONUS) BONUS, SUM(A.BONUS_ADICIONAL) BONUS_ADICIONAL,
       SUM(A.BONUS_TOTAL) BONUS_TOTAL FROM
      (select cUc.ccpf_cnpj_base, cuc.CTPO_PSSOA, cUc.iatual_crrtr,
      			SUM(CASE
          			WHEN pc.cgrp_ramo_plano = 120 THEN
              			pc.vprod_crrtr
          		ELSE
              			0
      			END) PROD_AUTO, 0 PROD_RE, mcc.pmargm_contb,
      			nvl(opc1.vobjtv_prod_crrtr_alt,0) + nvl(opc2.vobjtv_prod_crrtr_alt,0) +
      			nvl(opc3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_auto,
      			nvl(opcRE1.vobjtv_prod_crrtr_alt,0) + nvl(opcRE2.vobjtv_prod_crrtr_alt,0) +
      			nvl(opcRE3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_RE,
      			SUM (CASE
          			WHEN apc.ctpo_apurc = 1 THEN
             			pc.vprod_crrtr * (apc.pbonus_apurc /100)
          			ELSE
              			0
      				END) BONUS,
      				SUM (CASE
          				WHEN apc.ctpo_apurc = 2 THEN
              				pc.vprod_crrtr * (apc.pbonus_apurc /100)
         				ELSE
              				0
      					END) BONUS_ADICIONAL, SUM(pc.vprod_crrtr * (apc.pbonus_apurc /100)) BONUS_TOTAL
 				from crrtr c
 				join prod_crrtr pc
  				on pc.ccrrtr      = c.ccrrtr
 				and pc.cund_prod  = c.cund_prod
 				and pc.ctpo_comis = 'CN'
 				and pc.ccompt_prod between VAR_COMPT_INIC and VAR_COMPT_FIM
 				join crrtr_unfca_cnpj cuc
  				on cuc.ccpf_cnpj_base   = c.ccpf_cnpj_base
 				and cuc.ctpo_pssoa      = c.ctpo_pssoa
 				join apurc_prod_crrtr apc
  				on apc.ccrrtr           = pc.ccrrtr
 				and apc.cund_prod       = pc.cund_prod
 				AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
 				AND apc.ccompt_prod     = pc.ccompt_prod
 				AND apc.ctpo_comis      = pc.ctpo_comis
 				and apc.ccanal_vda_segur = 1
 				and apc.cgrp_ramo_plano  in (120,810)
				left join margm_contb_crrtr mcc
 				on mcc.ccpf_cnpj_base = cuc.ccpf_cnpj_base
 				and mcc.ctpo_pssoa = cuc.ctpo_pssoa
 				and mcc.ccanal_vda_segur = apc.ccanal_vda_segur
 				and mcc.ccompt_margm = VAR_COMPT_FIM
				left join objtv_prod_crrtr opc1
 				on opc1.ccpf_cnpj_base = cuc.ccpf_cnpj_base
 				and opc1.ctpo_pssoa = cuc.ctpo_pssoa
 				and opc1.ccanal_vda_segur = apc.ccanal_vda_segur
 				and opc1.cano_mes_compt_objtv  = VAR_COMPT_INIC
 				and opc1.cgrp_ramo_plano = 120
 				and opc1.cind_reg_ativo = 'S'
				left join objtv_prod_crrtr opc2
 				on opc2.ccpf_cnpj_base = cuc.ccpf_cnpj_base
 				and opc2.ctpo_pssoa = cuc.ctpo_pssoa
 				and opc2.ccanal_vda_segur = apc.ccanal_vda_segur
 				and opc2.cgrp_ramo_plano = 120
 				and opc2.cano_mes_compt_objtv  = VAR_COMPT_FIM - 1
 				and opc2.cind_reg_ativo = 'S'
				left join objtv_prod_crrtr opc3
 				on opc3.ccpf_cnpj_base = cuc.ccpf_cnpj_base
				 and opc3.ctpo_pssoa = cuc.ctpo_pssoa
				 and opc3.ccanal_vda_segur = apc.ccanal_vda_segur
				 and opc3.cgrp_ramo_plano = 120
				 and opc3.cano_mes_compt_objtv  = VAR_COMPT_FIM
				 and opc3.cind_reg_ativo = 'S'
				left join objtv_prod_crrtr opcRE1
				 on opcRE1.ccpf_cnpj_base = cuc.ccpf_cnpj_base
				 and opcRE1.ctpo_pssoa = cuc.ctpo_pssoa
				 and opcRE1.ccanal_vda_segur = apc.ccanal_vda_segur
				 and opcRE1.cano_mes_compt_objtv  = VAR_COMPT_INIC
				 and opcRE1.cgrp_ramo_plano = 810
				 and opcRE1.cind_reg_ativo = 'S'
				left join objtv_prod_crrtr opcRE2
				 on opcRE2.ccpf_cnpj_base = cuc.ccpf_cnpj_base
				 and opcRE2.ctpo_pssoa = cuc.ctpo_pssoa
				 and opcRE2.ccanal_vda_segur = apc.ccanal_vda_segur
				 and opcRE2.cgrp_ramo_plano = 810
				 and opcRE2.cano_mes_compt_objtv  = VAR_COMPT_FIM - 1
				 and opcRE2.cind_reg_ativo = 'S'
				left join objtv_prod_crrtr opcRE3
				 on opcRE3.ccpf_cnpj_base = cuc.ccpf_cnpj_base
				 and opcRE3.ctpo_pssoa = cuc.ctpo_pssoa
				 and opcRE3.ccanal_vda_segur = apc.ccanal_vda_segur
				 and opcRE3.cgrp_ramo_plano = 810
				 and opcRE3.cano_mes_compt_objtv  = VAR_COMPT_FIM
				 and opcRE3.cind_reg_ativo = 'S'
				 group by cUc.ccpf_cnpj_base,cuc.CTPO_PSSOA,cUc.iatual_crrtr,mcc.pmargm_contb,
				         opc1.vobjtv_prod_crrtr_alt,opc2.vobjtv_prod_crrtr_alt,opc3.vobjtv_prod_crrtr_alt,
				         opcRE1.vobjtv_prod_crrtr_alt,opcRE2.vobjtv_prod_crrtr_alt,opcRE3.vobjtv_prod_crrtr_alt
				 UNION
				 select cUc.ccpf_cnpj_base, cuc.CTPO_PSSOA, cUc.iatual_crrtr, 0 PROD_AUTO,
      			 SUM(CASE
          			WHEN pc.cgrp_ramo_plano = 810 THEN
              			pc.vprod_crrtr
          			ELSE
              			0
      			 END) PROD_RE, 0 pmargm_contb, 0 objetivo_trimestre_auto, 0 objetivo_trimestre_RE,
      			 0 BONUS,0 BONUS_ADICIONAL, 0 BONUS_TOTAL
 				from crrtr c
 				join prod_crrtr pc
  				on pc.ccrrtr             = c.ccrrtr
 				and pc.cund_prod         = c.cund_prod
 				and pc.ctpo_comis        = 'CN'
 				and pc.ccompt_prod between VAR_COMPT_INIC and VAR_COMPT_FIM
 				join crrtr_unfca_cnpj cuc
  				on cuc.ccpf_cnpj_base    = c.ccpf_cnpj_base
 				and cuc.ctpo_pssoa       = c.ctpo_pssoa
 				join apurc_prod_crrtr apc
  				on apc.ccrrtr            = pc.ccrrtr
 				and apc.cund_prod        = pc.cund_prod
 				AND apc.ccompt_prod      = pc.ccompt_prod
 				AND apc.ctpo_comis       = pc.ctpo_comis
 				and apc.ccanal_vda_segur = 1
 				and apc.cgrp_ramo_plano  in (120,810)
				group by cUc.ccpf_cnpj_base, cuc.CTPO_PSSOA, cUc.iatual_crrtr) A
		GROUP BY A.ccpf_cnpj_base, a.CTPO_PSSOA, A.iatual_crrtr
		ORDER BY A.ccpf_cnpj_base, a.CTPO_PSSOA, A.iatual_crrtr) A;
    ELSIF VAR_CANAL IN (2,3) THEN
        OPEN curv_relat FOR
    		SELECT DECODE(VAR_CANAL,2,'BANCO','FINASA'),B.ccpf_cnpj_base, CUC.CTPO_PSSOA, CUC.IATUAL_CRRTR, B.PROD_AUTO,
    		    B.PROD_RE, B.pmargm_contb,B.objetivo_trimestre_auto, B.objetivo_trimestre_RE, B.BONUS_TOTAL,
       			'SGPB5002', TO_CHAR(SYSDATE,'DD/MM/YYYY'), TO_CHAR(SYSDATE,'DD/MM/YYYY'), TO_CHAR(SYSDATE,'DD/MM/YYYY') FROM
 				( select A.ccpf_cnpj_base ccpf_cnpj_base, sum(A.PROD_AUTO) PROD_AUTO, sum(A.PROD_RE) PROD_RE,
       				max(A.pmargm_contb) pmargm_contb, max(A.objetivo_trimestre_auto) objetivo_trimestre_auto,
       				max(A.objetivo_trimestre_RE) objetivo_trimestre_RE, max(A.BONUS_TOTAL) BONUS_TOTAL
       				from (Select pbc.ccpf_cnpj_base, 0 PROD_AUTO, 0 PROD_RE, mcc.pmargm_contb,
           				nvl(opc1.vobjtv_prod_crrtr_alt,0) + nvl(opc2.vobjtv_prod_crrtr_alt,0) +
           				nvl(opc3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_auto,
           				nvl(opcRE1.vobjtv_prod_crrtr_alt,0) + nvl(opcRE2.vobjtv_prod_crrtr_alt,0) +
          			 	nvl(opcRE3.vobjtv_prod_crrtr_alt,0) objetivo_trimestre_RE,max(VPGTO_TOT) BONUS_TOTAL
           				from pgto_bonus_crrtr pbc
           				JOIN PAPEL_APURC_PGTO PAP
                			ON PAP.CPGTO_BONUS   = PBC.CPGTO_BONUS
               				AND PAP.CCOMPT_APURC = PBC.CCOMPT_PGTO
               				AND PAP.CTPO_COMIS   = 'CN'
               				AND PAP.CINDCD_PAPEL = 0
               				AND PAP.CGRP_RAMO_PLANO IN ( 120 )
           				join crrtr cr
                			on cr.ccpf_cnpj_base = pbc.ccpf_cnpj_base
               				and cr.ctpo_pssoa    = pbc.ctpo_pssoa
               				AND CR.CCRRTR        = PAP.CCRRTR
               				AND CR.CUND_PROD     = PAP.CUND_PROD
          				left join margm_contb_crrtr mcc
               				on mcc.ccpf_cnpj_base= pbc.ccpf_cnpj_base
               				and mcc.ctpo_pssoa   = pbc.ctpo_pssoa
               				and mcc.ccanal_vda_segur = PAP.CCANAL_VDA_SEGUR
               				and mcc.ccompt_margm     = PBC.CCOMPT_PGTO
          				left join objtv_prod_crrtr opc1
               				on opc1.ccpf_cnpj_base   = pbc.ccpf_cnpj_base
               				and opc1.ctpo_pssoa      = pbc.ctpo_pssoa
              				and opc1.ccanal_vda_segur= PAP.CCANAL_VDA_SEGUR
               				and opc1.cano_mes_compt_objtv  = ( VAR_COMPT_INIC )
               				and opc1.cgrp_ramo_plano = 120
               				and opc1.cind_reg_ativo  = 'S'
          				left join objtv_prod_crrtr opc2
               				on opc2.ccpf_cnpj_base   = pbc.ccpf_cnpj_base
               				and opc2.ctpo_pssoa      = pbc.ctpo_pssoa
               				and opc2.ccanal_vda_segur= PAP.CCANAL_VDA_SEGUR
               				and opc2.cgrp_ramo_plano = 120
               				and opc2.cano_mes_compt_objtv  = ( VAR_COMPT_FIM - 1 )
               				and opc2.cind_reg_ativo  = 'S'
               				left join objtv_prod_crrtr opc3
               				on opc3.ccpf_cnpj_base    = pbc.ccpf_cnpj_base
               				and opc3.ctpo_pssoa       = pbc.ctpo_pssoa
               				and opc3.ccanal_vda_segur = PAP.CCANAL_VDA_SEGUR
               				and opc3.cgrp_ramo_plano  = 120
               				and opc3.cano_mes_compt_objtv  = VAR_COMPT_FIM
               				and opc3.cind_reg_ativo   = 'S'
          				left join objtv_prod_crrtr opcRE1
               				on opcRE1.ccpf_cnpj_base    = pbc.ccpf_cnpj_base
               				and opcRE1.ctpo_pssoa       = pbc.ctpo_pssoa
               				and opcRE1.ccanal_vda_segur = PAP.CCANAL_VDA_SEGUR
               				and opcRE1.cano_mes_compt_objtv  = ( VAR_COMPT_INIC )
               				and opcRE1.cgrp_ramo_plano  = 810
               				and opcRE1.cind_reg_ativo   = 'S'
          				left join objtv_prod_crrtr opcRE2
               				on opcRE2.ccpf_cnpj_base    = pbc.ccpf_cnpj_base
               				and opcRE2.ctpo_pssoa       = pbc.ctpo_pssoa
               				and opcRE2.ccanal_vda_segur = PAP.CCANAL_VDA_SEGUR
               				and opcRE2.cgrp_ramo_plano  = 810
               				and opcRE2.cano_mes_compt_objtv  = ( VAR_COMPT_FIM - 1 )
               				and opcRE2.cind_reg_ativo   = 'S'
          				left join objtv_prod_crrtr opcRE3
               				on opcRE3.ccpf_cnpj_base    = pbc.ccpf_cnpj_base
               				and opcRE3.ctpo_pssoa       = pbc.ctpo_pssoa
               				and opcRE3.ccanal_vda_segur = PAP.CCANAL_VDA_SEGUR
               				and opcRE3.cgrp_ramo_plano  = 810
               				and opcRE3.cano_mes_compt_objtv  = VAR_COMPT_FIM
               				and opcRE3.cind_reg_ativo= 'S'
           				WHERE 	PBC.CCOMPT_PGTO      = VAR_COMPT_FIM and
                 				PAP.CCANAL_VDA_SEGUR = VAR_CANAL
               			group by pbc.ccpf_cnpj_base, mcc.pmargm_contb,opc1.vobjtv_prod_crrtr_alt, opc2.vobjtv_prod_crrtr_alt,
                   				 opc3.vobjtv_prod_crrtr_alt, opcRE1.vobjtv_prod_crrtr_alt,opcRE2.vobjtv_prod_crrtr_alt,
                   				 opcRE3.vobjtv_prod_crrtr_alt
  					union all
  							Select cUc.ccpf_cnpj_base,
  							SUM(CASE WHEN apc.cgrp_ramo_plano = 120 THEN
                        			pc.vprod_crrtr
         						ELSE
                        			0
                   			END) PROD_AUTO,
              				SUM(CASE WHEN apc.cgrp_ramo_plano = 810 THEN
                       				pc.vprod_crrtr
                  			ELSE
                       				0
                  			END) PROD_RE, 0 pmargm_contb, 0 objetivo_trimestre_auto, 0 objetivo_trimestre_RE, 0 BONUS_TOTAL
              		from crrtr c
              			join prod_crrtr  pc
                   			on pc.ccrrtr            = c.ccrrtr
                  			and pc.cund_prod        = c.cund_prod
             			join crrtr_unfca_cnpj cuc
                   			on cuc.ccpf_cnpj_base   = c.ccpf_cnpj_base
                  			and cuc.ctpo_pssoa      = c.ctpo_pssoa
             			join apurc_prod_crrtr apc
                   			on apc.ccrrtr           = pc.ccrrtr
                  			and apc.cund_prod       = pc.cund_prod
                  			AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
                  			AND apc.ccompt_prod     = pc.ccompt_prod
                  			AND apc.ctpo_comis      = pc.ctpo_comis
                  			and apc.cgrp_ramo_plano  in (120,810)
                  			and apc.ctpo_comis      = pc.ctpo_comis
                  			and apc.ctpo_comis      = 'CN'
       				where 	apc.CCOMPT_APURC        = VAR_COMPT_FIM
             				and apc.ccanal_vda_segur= VAR_CANAL
       				group by cUc.ccpf_cnpj_base ) A
  			group by A.ccpf_cnpj_base) B, CRRTR_UNFCA_CNPJ CUC
  			WHERE B.ccpf_cnpj_base = CUC.ccpf_cnpj_base
  			ORDER BY CUC.IATUAL_CRRTR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;      
      Raise_Application_Error(-20212,'ERRO NA EXECUCAO. ERRO: '||SUBSTR(SQLERRM,1,100));
  END;
END SGPB5002;
/

