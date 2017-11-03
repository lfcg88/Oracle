CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0140
( Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
  Intrcanal       Margm_Contb_Crrtr.Ccanal_Vda_Segur%TYPE) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0140
  --      DATA            : 8/3/2006 16:01:46
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para deletar corretores da tabela temporaria que estao na lista negra (Banco)
  --                        25/09/2007 - MELHORADAS ROTINAS DE EXCEPTION. ASS. WASSILY
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'SGPB9022';
BEGIN
  UPDATE Crrtr c
     SET c.Cind_Crrtr_Selec = 0
   WHERE c.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod) IN
         (SELECT c.Ccrrtr, c.Cund_Prod
            FROM Crrtr c
            LEFT JOIN Info_Lista_Negra_Crrtr ilnc ON ilnc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
                                                 AND ilnc.Ctpo_Pssoa = c.Ctpo_Pssoa
                                                 AND ilnc.Ccompt_Sit_Crrtr = Intrcompetencia
            WHERE c.Cind_Crrtr_Selec = 1
              AND ilnc.Csit_Crrtr_Bdsco in (1,2,3,4) --
          );
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' canal: ' ||
                           Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
    COMMIT;
    Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia ||
                           ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
    COMMIT;
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores com margem de contribuição abaixo do minimo.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
    COMMIT;
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0140;
/

