CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0101
(
  curvrelat             OUT SYS_REFCURSOR,
  Intrcompetencia       IN Prod_Crrtr.Ccompt_Prod %TYPE,
  Intcodcanal_Vda_Segur IN Parm_Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
  chrNomeCorretor       IN crrtr_unfca_cnpj.iatual_crrtr %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0101
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna lista de corretorUnificado->corretores->apuracoes Liberacao manual
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
  Intcomptemp        Prod_Crrtr.Ccompt_Prod %TYPE;
  Intqmes_Perdc_Pgto Parm_Per_Apurc_Canal.Qmes_Perdc_Pgto%TYPE;
BEGIN
  --  busca de quanto em quanto tempo paga-se para o canal
  SELECT Qmes_Perdc_Pgto
    INTO Intqmes_Perdc_Pgto -- 3
    FROM Parm_Per_Apurc_Canal Ppac
   WHERE Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
     AND Ppac.Ctpo_Apurc = Pc_Util_01.Normal
     AND Sgpb0016(Intrcompetencia) BETWEEN Ppac.Dinic_Vgcia_Parm AND
         Nvl(Ppac.Dfim_Vgcia_Parm,
             To_Date('99991231',
                     'YYYYMMDD'));
  --
  Intcomptemp := Pc_Util_01.Sgpb0017(Intrcompetencia,
                                     Intqmes_Perdc_Pgto - 1); --OLHANDO PARA TRÁS
  --
  OPEN curvrelat FOR
  --
    SELECT cuc.ccpf_cnpj_base,
           cuc.ctpo_pssoa,
           cuc.iatual_crrtr,
           (pc.vprod_crrtr * (apc.pbonus_apurc / 100)) valor_bonus,
           pc.ccompt_prod,
           apc.csit_apurc,
           pc.vprod_crrtr,
           apc.pbonus_apurc,
           case when Apc.Ccompt_Apurc < Intcomptemp
                then 'true'
                else 'false'
           end as "retido",
           /*PK DE APURACAO*/
           apc.ccanal_vda_segur,
           apc.ctpo_apurc,
           apc.ccompt_apurc,
           apc.cgrp_ramo_plano,
           apc.ccompt_prod,
           apc.ctpo_comis,
           apc.ccrrtr,
           apc.cund_prod,
           --
           up.iund_prod,
           grp.igrp_ramo_plano
           --
      FROM Apurc_Prod_Crrtr Apc
      --
      JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                  AND c.Cund_Prod = Apc.Cund_Prod
                  --
      JOIN crrtr_unfca_cnpj cuc ON cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
                               AND cuc.ctpo_pssoa = c.ctpo_pssoa
                               --
      JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                        AND Pc.Cund_Prod = Apc.Cund_Prod
                        AND Pc.Ccrrtr = Apc.Ccrrtr
                        AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                        AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
                        ---
      JOIN grp_ramo_plano grp ON grp.cgrp_ramo_plano = apc.cgrp_ramo_plano
      --
      JOIN und_prod up ON up.cund_prod = c.cund_prod
      --

     WHERE (
             (
               Apc.Ccompt_Apurc BETWEEN Intcomptemp AND Intrcompetencia
             AND
               Apc.Csit_Apurc IN ('AP', 'LM', 'LG')
             )
           OR
             (
               Apc.Ccompt_Apurc < Intcomptemp
             AND
               Apc.Csit_Apurc IN ('LM', 'LG')
             )
           )
       --
       AND ((chrNomeCorretor IS NULL) OR (cuc.iatual_crrtr LIKE '%' || chrNomeCorretor || '%'))
       --
       AND Apc.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
       AND NOT EXISTS (SELECT 1
              FROM Papel_Apurc_Pgto Pap
             WHERE Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
               AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
               AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
               AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
               AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
               AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
               AND Pap.Ccrrtr = Apc.Ccrrtr
               AND Pap.Cund_Prod = Apc.Cund_Prod
               AND Pap.Cindcd_Papel = 1 /*ELEICAO*/
            )
     --
     ORDER BY cuc.ccpf_cnpj_base,
              cuc.ctpo_pssoa,
              "retido",
              pc.ccompt_prod DESC,
              grp.cgrp_ramo_plano,
              c.ccrrtr,
              c.cund_prod;
  --
END SGPB0101;
/

