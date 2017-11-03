CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0010
(
  Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
  Intrcanal       Margm_Contb_Crrtr.Ccanal_Vda_Segur %TYPE
) IS
  Dblmgmcontribuicao Parm_Canal_Vda_Segur . Pmargm_Contb_Min %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0010
  --      DATA            : 8/3/2006 16:01:46
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para deletar corretores da tabela temporaria que não apresentem Margem de contribuição minima
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'SGPB9024';
BEGIN
  --
  --
  --
  UPDATE Crrtr c
     SET c.Cind_Crrtr_Selec = 0
   WHERE c.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod) IN
         (SELECT c.Ccrrtr,
                 c.Cund_Prod
            FROM Crrtr c

            LEFT JOIN Info_Lista_Negra_Crrtr ilnc ON ilnc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
                                               AND ilnc.Ctpo_Pssoa = c.Ctpo_Pssoa
                                               AND ilnc.Ccompt_Sit_Crrtr = Intrcompetencia
           WHERE c.Cind_Crrtr_Selec = 1
             AND ilnc.Csit_Crrtr_Bdsco > 0--
          );
  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' canal: ' ||
                           Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia ||
                           ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores com margem de contribuição abaixo do minimo.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0010;
/

