CREATE OR REPLACE PROCEDURE SGPB_PROC.sgpb0091
(
  curvrelat        OUT SYS_REFCURSOR,
  intriniciocompet margm_contb_crrtr.ccompt_margm %TYPE,
  intrfimcompet    margm_contb_crrtr.ccompt_margm %TYPE,
  pcnpj            crrtr_unfca_cnpj.ccpf_cnpj_base %TYPE,
  pnome            crrtr_unfca_cnpj.iatual_crrtr %TYPE,
  psucursal        und_prod.cund_prod %TYPE,
  ptipopessoa      crrtr_unfca_cnpj.ctpo_pssoa %TYPE
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : sgpb0091
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure retorna uma lista de sucursais. lista de apura��es pagas. relatorio de extra-banco
  --      altera��es      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
  intcanal canal_vda_segur.ccanal_vda_segur %TYPE := pc_util_01.extra_banco;
BEGIN
  --
  OPEN curvrelat FOR
  --
    SELECT up.cund_prod,
           MAX(up.iund_prod) AS iund_prod,
           --
           cuc.ccpf_cnpj_base,
           cuc.ctpo_pssoa,
           MAX(cuc.iatual_crrtr) AS iatual_crrtr,
           --
           decode(apc.ctpo_apurc, 1, 'Normal', 2, 'Extra') ctpo_apurc,
           --
           SUM((apc.pbonus_apurc * pc.vprod_crrtr) / 100) AS valor
    --
      FROM crrtr c
    --
      JOIN und_prod up ON up.cund_prod = c.cund_prod
    --
      JOIN crrtr_unfca_cnpj cuc ON cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
                               AND cuc.ctpo_pssoa = c.ctpo_pssoa
    --
      JOIN prod_crrtr pc ON pc.ccrrtr = c.ccrrtr
                        AND pc.cund_prod = c.cund_prod
                        AND pc.ctpo_comis = 'CN'
    --
      JOIN apurc_prod_crrtr apc ON apc.ccrrtr = pc.ccrrtr
                               AND apc.cund_prod = pc.cund_prod
                               AND apc.cgrp_ramo_plano = pc.cgrp_ramo_plano
                               AND apc.ccompt_prod = pc.ccompt_prod
                               AND apc.ctpo_comis = 'CN'
    --
     WHERE apc.ccanal_vda_segur = intcanal
       AND apc.csit_apurc = 'PG'
       AND apc.ccompt_apurc BETWEEN intriniciocompet AND intrfimcompet
       AND ((pcnpj IS NULL) OR (cuc.ccpf_cnpj_base = pcnpj))
       AND ((pnome IS NULL) OR (cuc.iatual_crrtr LIKE pnome || '%'))
       AND ((psucursal IS NULL) OR (up.cund_prod = psucursal))
       AND ((ptipopessoa IS NULL) OR (cuc.ctpo_pssoa = ptipopessoa))
    --
     GROUP BY up.cund_prod,
              cuc.ccpf_cnpj_base,
              cuc.ctpo_pssoa,
              decode(apc.ctpo_apurc, 1, 'Normal', 2, 'Extra')
    --
     ORDER BY up.cund_prod,
              cuc.ccpf_cnpj_base,
              cuc.ctpo_pssoa,
              decode(apc.ctpo_apurc, 1, 'Normal', 2, 'Extra');
  --
  --
END sgpb0091;
/

