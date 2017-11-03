CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0033(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0033
  --      DATA            : 14/03/06 15:30:37
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure Incrementar na tabela temporaria corretores com exceção de tempo.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Crotna CONSTANT CHAR(8) := 'SGPB0033';
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
BEGIN
  --
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 1
   WHERE (Ccrrtr, Cund_Prod) IN
         (SELECT Tm.Ccrrtr,
                 Tm.Cund_Prod
            FROM Parm_Crrtr_Excec Ce
           INNER JOIN Crrtr Tm ON Ce.Ctpo_Pssoa = Tm.Ctpo_Pssoa
                              AND Ce.Ccpf_Cnpj_Base = Tm.Ccpf_Cnpj_Base
           INNER JOIN Parm_Canal_Vda_Segur Pv ON Ce.Ccanal_Vda_Segur =
                                                 Pv.Ccanal_Vda_Segur
           WHERE Ce.Ccanal_Vda_Segur = Intrcanal
             AND Last_Day(To_Date(Intrcompetencia,'YYYYMM')) BETWEEN Ce.Dinic_Vgcia_Parm AND
               Nvl(Ce.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))
             AND Last_Day(To_Date(Intrcompetencia,'YYYYMM')) BETWEEN Pv.Dinic_Vgcia_Parm AND
               Nvl(Pv.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))
             AND Tm.Cind_Crrtr_Selec = 0
             AND Tm.Ccrrtr BETWEEN Pv.Cinic_Faixa_Crrtr AND
                 Pv.Cfnal_Faixa_Crrtr);
  --
  --
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao incluir corretores com exceção à seleção. Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0033;
/

