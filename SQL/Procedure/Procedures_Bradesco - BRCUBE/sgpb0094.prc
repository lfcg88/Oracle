CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0094(
  curvrelat        OUT SYS_REFCURSOR,
  intCanal         IN NUMBER,
  Intcompetinicial IN NUMBER,
  Intcompetfinal   IN NUMBER
) IS
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0094
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure retorna lista devalores para homologação extra-banco - Publico Inicial
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------

BEGIN
  --
  OPEN curvrelat FOR
  
  
  SELECT decode(cec.ccpf_cnpj_base, null, 'Não', 'Sim') "ELEITO",
       Cuc.Iatual_Crrtr "NOME CORRETORA/RAZÃO SOCIAL",
       Cuc.Ccpf_Cnpj_Base "CNPJ/CPF BASE",
       CASE
         WHEN Cuc.Ctpo_Pssoa = 'F' THEN
          'Fisica'
         ELSE
          'Juridica'
       END AS "PESSOA",
       c.Ccrrtr "CPD (COD. CORRETOR)",
       c.Cund_Prod "SUCURSAL",
       c.Dcadto_Crrtr "DATA-CADASTRO",
       CASE
         WHEN Pc.Cgrp_Ramo_Plano = 810 THEN
          'RE'
         ELSE
          'Auto'
       END "RAMO",
       Pc.Ccompt_Prod "COMPETÊNCIA",
       Pc.Qtot_Item_Prod "ITENS",
       CASE
         WHEN pc.ctpo_comis = 'CN' THEN
          Pc.Vprod_Crrtr
         ELSE
          0
       END "TOTAL COMISSÃO NORMAL",
       CASE
         WHEN pc.ctpo_comis = 'CE' THEN
          Pc.Vprod_Crrtr
         ELSE
          0
       END "TOTAL COMISSÃO ESPECIAL",
       Mcc.Pmargm_Contb "MARGEM",
       CASE
         WHEN ((Ilnc.Csit_Crrtr_Bdsco IS NULL) OR
              (Ilnc.Csit_Crrtr_Bdsco = 0)) THEN
          'Sem Restricoes'
         ELSE
          'BLOQUEADO'
       END "RESTRIÇÕES",
       nvl(ceca.rmotvo_excec_crrtr, 'NAO IMPEDIDO MANUALMENTE') "IMPEDIMENTOS",
       Ppmcp.Vmin_Prod_Crrtr "VALOR MINIMO"
--
  FROM Parm_Canal_Vda_Segur Pcvs
--
  JOIN Crrtr c ON c.Ccrrtr BETWEEN Pcvs.Cinic_Faixa_Crrtr AND
                  Pcvs.Cfnal_Faixa_Crrtr
--
  JOIN Crrtr_Unfca_Cnpj Cuc ON Cuc.Ctpo_Pssoa = c.Ctpo_Pssoa
                           AND Cuc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
--
  JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = c.Ccrrtr
                    AND Pc.Cund_Prod = c.Cund_Prod
                    --AND Pc.Ctpo_Comis = 'CN'
                    AND PC.CGRP_RAMO_PLANO = Pc_Util_01.Auto
--
  LEFT JOIN margm_contb_crrtr mcc ON Mcc.Ccpf_Cnpj_Base =
                                     Cuc.Ccpf_Cnpj_Base
                                 AND Mcc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
                                 AND Mcc.Ccanal_Vda_Segur =
                                     Pcvs.Ccanal_Vda_Segur
                                 AND Mcc.Ccompt_Margm = Pc.Ccompt_Prod
--
  LEFT JOIN Info_Lista_Negra_Crrtr Ilnc ON Ilnc.Ccpf_Cnpj_Base =
                                           Cuc.Ccpf_Cnpj_Base
                                       AND Ilnc.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
                                       AND Ilnc.Ccompt_Sit_Crrtr = Intcompetfinal
--
  LEFT JOIN Parm_Prod_Min_Crrtr Ppmcp ON Ppmcp.Ccanal_Vda_Segur =
                                         Pcvs.Ccanal_Vda_Segur
                                     AND Ppmcp.Cgrp_Ramo_Plano =
                                         Pc.Cgrp_Ramo_Plano
                                     AND Ppmcp.Ctpo_Pssoa = Cuc.Ctpo_Pssoa
                                     AND Ppmcp.Ctpo_Per = 'P'
                                     AND last_day(to_date(Intcompetinicial, 'YYYYMM')) BETWEEN
                                         Ppmcp.Dinic_Vgcia_Parm AND
                                         Nvl(Ppmcp.Dfim_Vgcia_Parm,
                                             To_Date(99991231, 'YYYYMMDD'))

  left join parm_info_campa pic on pic.ccanal_vda_segur =
                                   pcvs.ccanal_vda_segur
                               and last_day(to_date(Intcompetinicial, 'YYYYMM')) between
                                   pic.dinic_vgcia_parm and
                                   nvl(pic.dfim_vgcia_parm,
                                       to_date(99991231, 'YYYYMMDD'))
--
--
  left join crrtr_excec_campa ceca on ceca.ccpf_cnpj_base =
                                          cuc.ccpf_cnpj_base
                                      and ceca.ctpo_pssoa = cuc.ctpo_pssoa
                                      AND ceca.CCANAL_VDA_SEGUR =
                                          pcvs.ccanal_vda_segur
                                      and ceca.dinic_vgcia_parm =
                                          pic.dinic_vgcia_parm
--
  left join crrtr_eleit_campa cec on cec.ccpf_cnpj_base =
                                     cuc.ccpf_cnpj_base
                                 and cec.ctpo_pssoa = cuc.ctpo_pssoa
                                 AND CeC.CCANAL_VDA_SEGUR =
                                     pcvs.ccanal_vda_segur
                                 and cec.dinic_vgcia_parm =
                                     pic.dinic_vgcia_parm

     WHERE Pcvs.Ccanal_Vda_Segur = intCanal
       AND Pc.Ccompt_Prod BETWEEN Intcompetinicial AND Intcompetfinal

--   and cec.ccpf_cnpj_base is not null
--
 ORDER BY "ELEITO" desc, "NOME CORRETORA/RAZÃO SOCIAL";

  --
END SGPB0094;
/

