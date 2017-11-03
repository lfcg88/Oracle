CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0096(
  curvrelat        OUT SYS_REFCURSOR,
  intCanal         IN NUMBER,
  Intcompetinicial IN NUMBER,
  Intcompetfinal   IN NUMBER
) IS
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0096
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure retorna lista devalores para homologação banco/Finasa - Publico Inicial
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------

BEGIN
  --
  OPEN curvrelat FOR

SELECT decode(cec.ccpf_cnpj_base, null, 'Não', 'Sim') Eleito,
       cuc.iatual_crrtr,
       cuc.ccpf_cnpj_base,
       CASE
         WHEN cuc.ctpo_pssoa = 'F' THEN
          'Fisica'
         ELSE
          'Juridica'
       END AS ctpo_pssoa,
       cDesm.ccrrtr,
       cDesm.cund_prod,
       cDesm.dcadto_crrtr,
       cori.cag_bcria,
       mac.dentrd_crrtr_ag,
       mac.dsaida_crrtr_ag,
       CASE
         WHEN pc.cgrp_ramo_plano = 810 THEN
          'RE'
         ELSE
          'Auto'
       END cgrp_ramo_plano,
       pc.ccompt_prod,
       pc.qtot_item_prod,
       pc.vprod_crrtr,
       mcc.pmargm_contb,
       CASE
         WHEN ((ilnc.csit_crrtr_bdsco IS NULL) OR
              (ilnc.csit_crrtr_bdsco = 0)) THEN
          'Sem Restricoes'
         ELSE
          'BLOQUEADO'
       END csit_crrtr_bdsco,
       nvl(ceca.rmotvo_excec_crrtr, 'NAO IMPEDIDO MANUALMENTE') IMPEDIDO,
       OPC.VOBJTV_PROD_CRRTR_ALT "OBJETIVO"
--
  FROM parm_canal_vda_segur pcvs
--
  JOIN mpmto_ag_crrtr mac
    on MAC.CCRRTR_ORIGN between pcvs.cinic_faixa_crrtr AND pcvs.cfnal_faixa_crrtr
    AND last_day(to_date(Intcompetfinal, 'YYYYMM')) >= MAC.DENTRD_CRRTR_AG
    AND last_day(to_date(Intcompetinicial, 'YYYYMM')) < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
--
  left JOIN Crrtr cDesm ON cDesm.Ccrrtr = MAC.Ccrrtr_Dsmem
                 AND cDesm.Cund_Prod = mac.cund_prod
--
  left JOIN Crrtr cOri ON cOri.Ccrrtr = MAC.Ccrrtr_Orign
                 AND cOri.Cund_Prod = mac.cund_prod
--
  left JOIN CRRTR_UNFCA_CNPJ cuc ON cuc.ctpo_pssoa = cDesm.ctpo_pssoa
                           AND cuc.ccpf_cnpj_base = cDesm.ccpf_cnpj_base
--

  left JOIN PROD_CRRTR pc ON pc.ccrrtr = cDesm.ccrrtr
                    AND pc.cund_prod = cDesm.cund_prod
                    AND pc.ctpo_comis = Pc_Util_01.COMISSAO_NORMAL
                    AND pc.ccompt_prod = Intcompetfinal
                    and pc.cgrp_ramo_plano = PC_UTIL_01.Auto

--
  left JOIN MARGM_CONTB_CRRTR mcc ON mcc.ccpf_cnpj_base = cuc.ccpf_cnpj_base
                            AND mcc.ctpo_pssoa = cuc.ctpo_pssoa
                            AND mcc.ccanal_vda_segur = pcvs.ccanal_vda_segur
                            AND mcc.ccompt_margm = Intcompetfinal
--
  LEFT JOIN info_lista_negra_crrtr ilnc ON ilnc.ccpf_cnpj_base = cuc.ccpf_cnpj_base
                                       AND ilnc.ctpo_pssoa = cuc.ctpo_pssoa
                                       AND ilnc.ccompt_sit_crrtr = Intcompetfinal
--
  LEFT JOIN PARM_PROD_MIN_CRRTR ppmc ON ppmc.ccanal_vda_segur = pcvs.ccanal_vda_segur
                                    AND ppmc.cgrp_ramo_plano = pc.cgrp_ramo_plano
                                    AND last_day(to_date(Intcompetinicial, 'YYYYMM'))
                                        BETWEEN ppmc.dinic_vgcia_parm
                                            AND nvl(ppmc.dfim_vgcia_parm, TO_DATE(99991231, 'YYYYMMDD'))
--
--
  left join parm_info_campa pic on pic.ccanal_vda_segur = pcvs.ccanal_vda_segur
                               and last_day(to_date(Intcompetinicial, 'YYYYMM'))
                                   between pic.dinic_vgcia_parm
                                       and nvl(pic.dfim_vgcia_parm, to_date(99991231, 'YYYYMMDD'))
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
--
  left join crrtr_eleit_campa cec on cec.ccpf_cnpj_base = cuc.ccpf_cnpj_base
                                 and cec.ctpo_pssoa = cuc.ctpo_pssoa
                                 AND CeC.CCANAL_VDA_SEGUR = pcvs.ccanal_vda_segur
                                 and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
--
--
  LEFT join objtv_prod_crrtr opc on opc.ccpf_cnpj_base = cDesm.Ccpf_Cnpj_Base
                                and opc.ctpo_pssoa = cDesm.Ctpo_Pssoa
                                and opc.cano_mes_compt_objtv = TO_CHAR(ADD_MONTHS(to_date(Intcompetfinal, 'YYYYMM'),1), 'YYYYMM')
                                and opc.cgrp_ramo_plano = PC_UTIL_01.Auto
                                and opc.ccanal_vda_segur =  pcvs.ccanal_vda_segur
                                and opc.cind_reg_ativo = 'S'
--
--
   WHERE pcvs.ccanal_vda_segur = intCanal
     and last_day(to_date(Intcompetinicial, 'YYYYMM'))
         between pcvs.dinic_vgcia_parm
             and nvl(pcvs.dfim_vgcia_parm, to_date('99991231', 'YYYYMMDD'))
-- 
 ORDER BY decode(cec.ccpf_cnpj_base, null, 'Não', 'Sim') DESC,
       cuc.iatual_crrtr;
  --
END SGPB0096;
/

