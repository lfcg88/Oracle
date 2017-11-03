CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0093
(
  curvrelat        OUT SYS_REFCURSOR,
  intriniciocompet margm_contb_crrtr.ccompt_margm %TYPE,
  intrfimcompet    margm_contb_crrtr.ccompt_margm %TYPE,
  pcanal           canal_vda_segur.ccanal_vda_segur %TYPE
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0093
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure retorna uma lista de sucursais>CRRTR_UNIFICADO>CORRETOR>PRODUCAO>APURACAO. lista de apurações LM E BG. relatorio de POSICAO PENDENTE
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
BEGIN
  --
  OPEN curvrelat FOR
  --

  SELECT up.cund_prod,
       up.iund_prod,
       --
       cuc.ccpf_cnpj_base,
       cuc.ctpo_pssoa,
       cuc.iatual_crrtr,
       --
       c.ccrrtr,
       c.dcadto_crrtr,
       c.ccpf_cnpj_flial,
       c.ccpf_cnpj_dv,
       --
       pc.qtot_item_prod,
       DECODE(pc.ctpo_comis, 'CN', 'Comissão Normal', 'CE', 'Comissão Especial', pc.ctpo_comis) ctpo_comis,
       pc.ccompt_prod,
       pc.vprod_crrtr,
       --
       apc.ccompt_apurc,
       DECODE(apc.csit_apurc, 'LM', 'Abaixo Mínimo', 'BG', 'Bloqueada', apc.csit_apurc) csit_apurc,
       DECODE(apc.ctpo_apurc, Pc_Util_01.Normal, 'Normal', Pc_Util_01.Extra, 'Extra') ctpo_apurc,
       apc.pbonus_apurc,
       --
       grp.igrp_ramo_plano,
       grp.cgrp_ramo_plano
--
  FROM Apurc_Prod_Crrtr Apc
--
  JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
              AND c.Cund_Prod = Apc.Cund_Prod
--
  JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                    AND Pc.Cund_Prod = Apc.Cund_Prod
                    AND Pc.Ccrrtr = Apc.Ccrrtr
                    AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                    AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
--
  JOIN crrtr_unfca_cnpj cuc ON cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
                           AND cuc.ctpo_pssoa = c.ctpo_pssoa
--
  JOIN grp_ramo_plano grp ON grp.cgrp_ramo_plano = apc.cgrp_ramo_plano
--
  JOIN und_prod up ON up.cund_prod = c.cund_prod
--
 WHERE Apc.Ccompt_Apurc BETWEEN intriniciocompet AND intrfimcompet
   and (apc.csit_apurc = 'LM' OR apc.csit_apurc = 'BG')
   AND apc.ccanal_vda_segur = pcanal

     ORDER BY   up.cund_prod,
       --
       cuc.ccpf_cnpj_base,
       cuc.ctpo_pssoa,
       --
       c.ccrrtr,
       --
       pc.ccompt_prod,
       --
       grp.cgrp_ramo_plano;
  --
  --
END SGPB0093;
/

