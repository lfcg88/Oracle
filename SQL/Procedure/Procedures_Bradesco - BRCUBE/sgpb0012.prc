CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0012(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0011
  --      DATA            : 8/3/2006 16:26:37
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para deletar corretores da tabela temporaria que não apresentem Produção minima
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Intrqtmesanlse Parm_Per_Apurc_Canal.Qmes_Anlse %TYPE;
  Var_Log_Erro   Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna     VARCHAR2(8) := 'SGPB0012';
BEGIN
  Pc_Util_01.Sgpb0005(Intrqtmesanlse,
                      Pc_Util_01.Extra_Banco,
                      Intrcompetencia,
                      Pc_Util_01.Normal);
  --
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 0
   WHERE CR.CIND_CRRTR_SELEC = 1
     AND (Cr.Ccrrtr, Cr.Cund_Prod) IN
         ( --
          SELECT Cr.Ccrrtr,
                 Cr.Cund_Prod
            FROM ( --
                   SELECT LMT.Ccpf_Cnpj_Base,
                           LMT.Ctpo_Pssoa
                     FROM (SELECT Cr.Ccpf_Cnpj_Base,
                                   Cr.Ctpo_Pssoa
                              FROM Crrtr Cr
                              JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
                                                AND Pc.Cund_Prod = Cr.Cund_Prod
                              JOIN Parm_Prod_Min_Crrtr Pm ON Pm.Ctpo_Pssoa = Cr.Ctpo_Pssoa
                                                         AND Pm.Cgrp_Ramo_Plano = Pc.Cgrp_Ramo_Plano
                             WHERE Cr.Cind_Crrtr_Selec = 1
                               AND Pm.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco
                               AND Pm.Ctpo_Per = Pc_Util_01.Mensal
                               AND Pc.Ctpo_Comis = 'CN'
                               AND Pc.Cgrp_Ramo_Plano = Pc_Util_01.Auto
                               AND Last_Day(To_Date(Intrcompetencia,
                                                    'YYYYMM')) BETWEEN Pm.Dinic_Vgcia_Parm AND
                                   Nvl(Pm.Dfim_Vgcia_Parm,
                                       To_Date('99991231',
                                               'YYYYMMDD'))


                               AND Pc.Ccompt_Prod BETWEEN
                                   To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((Intrqtmesanlse -1) * -1)), 'YYYYMM'))
                                    AND Intrcompetencia
                             GROUP BY Cr.Ccpf_Cnpj_Base,
                                      Cr.Ctpo_Pssoa,
                                      pc.ccompt_prod
                            HAVING(
                                      (
                                         SUM(Pc.Qtot_Item_Prod) >= MAX(Pm.Qitem_Min_Prod_Crrtr)
                                       AND
                                         SUM(Pc.Vprod_Crrtr) > 0
                                       )
                                   OR
                                      SUM(Pc.Vprod_Crrtr) >= MAX(Pm.Vmin_Prod_Crrtr)
                                  ) --
                            ) Lmt
                    GROUP BY LMT.Ccpf_Cnpj_Base,
                              LMT.Ctpo_Pssoa
                   HAVING COUNT(*) < Intrqtmesanlse) LINT
            --
            JOIN Crrtr Cr ON Cr.Ccpf_Cnpj_Base = LINT.Ccpf_Cnpj_Base
                         AND Cr.Ctpo_Pssoa = LINT.Ctpo_Pssoa
                         AND CR.CIND_CRRTR_SELEC = 1 --
          );
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' # ' ||
                           SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia || ' # ' ||
                           SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores que apresentem produção mensal em um periodo no canal extra-banco.Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0012;
/

