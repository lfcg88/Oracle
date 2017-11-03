CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0009
(
  Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
  Intrcanal       NUMBER
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0009
  --      DATA            : 8/3/2006 15:49:37
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para deletar corretores da tabela temporaria que não apresentem Rating valido
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro    Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna      VARCHAR2(8) := 'SGPB0009';
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
BEGIN

  Pc_Util_01.Sgpb0003(Intinicialfaixa,
                      Intfinalfaixa,
                      Intrcanal,
                      Intrcompetencia);
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 0
   WHERE Cr.Cind_Crrtr_Selec = 1
     AND ( --
          Ccrrtr, --
          Cund_Prod --
         ) --
         IN --
         ( --
          SELECT C.Ccrrtr,
                  C.Cund_Prod
            FROM Crrtr c
          --
            JOIN Clasf_Ag Ca ON Ca.Cag_Bcria = C.Cag_Bcria
                            AND ca.cbco = c.cbco
                            AND Ca.Ccompt_Clasf = Intrcompetencia
          --
           WHERE C.Cind_Crrtr_Selec = 1
             AND Ca.Cclasf_Ag NOT IN
                 (SELECT pca.Cclasf_Ag_Exgdo
                  --
                    FROM Parm_Canal_Vda_Segur pcvs
                  --
                    JOIN Parm_Clasf_Ag pca ON pca.Dinic_Vgcia_Parm = pcvs.Dinic_Vgcia_Parm
                                          AND pca.Ccanal_Vda_Segur = pcvs.Ccanal_Vda_Segur
                  --
                   WHERE pcvs.Ccanal_Vda_Segur = Intrcanal
                     AND Last_Day(To_Date(Intrcompetencia,
                                          'YYYYMM')) BETWEEN pcvs.Dinic_Vgcia_Parm AND
                         Nvl(pcvs.Dfim_Vgcia_Parm,
                             To_Date('99991231',
                                     'YYYYMMDD')) --
                  ) --
          );
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' canal: ' ||
                           Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia ||
                           ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar coretores com rating não aceito.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0009;
/

