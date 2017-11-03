CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0013(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE)
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
  Var_Crotna     VARCHAR2(8) := 'SGPB9024';
  intComptInicial number(6);
BEGIN
  Pc_Util_01.Sgpb0005(Intrqtmesanlse,
                      Pc_Util_01.Extra_Banco,
                      Intrcompetencia,
                      Pc_Util_01.Normal);
  --
  --
  intComptInicial := To_Number(To_Char(Add_Months(To_Date(Intrcompetencia, 'yyyymm'),  ((Intrqtmesanlse -1) * -1)), 'YYYYMM'));
  --
  --
  UPDATE Crrtr Cr_ext
     SET Cr_ext.Cind_Crrtr_Selec = 0
     WHERE Cr_ext.Cind_Crrtr_Selec = 1
     AND (Cr_ext.Ccrrtr, Cr_ext.Cund_Prod) IN
         (
          --
          SELECT distinct Cr_int.Ccrrtr, Cr_int.Cund_Prod
            FROM Crrtr Cr_int
            where Cr_int.Cind_Crrtr_Selec = 1 --
              and (Cr_int.Ccpf_Cnpj_Base, Cr_int.Ctpo_Pssoa) in
                  ( --
                      SELECT Cr.Ccpf_Cnpj_Base,Cr.Ctpo_Pssoa

                        FROM Crrtr Cr

                        JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
                                          AND Pc.Cund_Prod = Cr.Cund_Prod
--NÃO SERA MAIS CONSIDERADO               AND Pc.Ctpo_Comis = 'CN'
                                          AND Pc.Ccompt_Prod
                                                     BETWEEN intComptInicial
                                                         AND Intrcompetencia
                                          AND Pc.Cgrp_Ramo_Plano = Pc_Util_01.Auto

                        JOIN Parm_Prod_Min_Crrtr Pm ON Pm.Ctpo_Pssoa = Cr.Ctpo_Pssoa
                                                   AND Pm.Cgrp_Ramo_Plano = Pc_Util_01.Auto
                                                   AND Last_Day(To_Date(Intrcompetencia, 'YYYYMM'))
                                                       BETWEEN Pm.Dinic_Vgcia_Parm
                                                           AND Nvl(Pm.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))
                                                   AND Pm.Ctpo_Per = Pc_Util_01.Periodo
                                                   AND Pm.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco

                       WHERE Cr.Cind_Crrtr_Selec = 1
                       GROUP BY Cr.Ccpf_Cnpj_Base, Cr.Ctpo_Pssoa
                      HAVING SUM(Pc.Vprod_Crrtr) < MAX(Pm.Vmin_Prod_Crrtr)--
                 )
          );
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' # ' ||
                           SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
     Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia || ' # ' ||
                           SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
     Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores que não apresentem rendimentos em um determinado periodo no canal Extra-Banco.Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
     Raise_Application_Error(-20210,var_log_erro);
END Sgpb0013;
/

