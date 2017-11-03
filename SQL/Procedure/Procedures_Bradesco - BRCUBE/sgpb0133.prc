CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0133
(
  Intrcompetencia  prod_crrtr.ccompt_prod %TYPE,
  Intrcanal        Crrtr_Eleit_Campa.Ccanal_Vda_Segur %TYPE,
  Var_Crotna       VARCHAR2
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0133
  --      DATA            : 11/12/2006 14:16:46
  --      AUTOR           : VINÍCIUS FARIA
  --      OBJETIVO        : Procedure para deletar os corretores que já estão selecionados.
  --      ALTERAÇÕES      : Tratar Campanha Encerrada. Ass. Wassily ( 24/09/2007 )
  --                        Essa Rotina precisa apenas "pegar" a campanha que está com DATA FIM igual a nula
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro%TYPE;
BEGIN
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 0 -- tira de eleito se já estava
   WHERE Cr.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod) IN
         (SELECT Cr.Ccrrtr, Cr.Cund_Prod
            FROM Crrtr Cr
            JOIN parm_info_campa pic ON pic.Ccanal_Vda_Segur = Intrcanal
                                    AND DFIM_VGCIA_PARM is null            
            JOIN crrtr_eleit_campa cec ON Cr.Ccpf_Cnpj_Base = cec.ccpf_cnpj_base            
                                          AND Cr.Ctpo_Pssoa = cec.ctpo_pssoa
                                          AND cec.Ccanal_Vda_Segur = pic.Ccanal_Vda_Segur
                                          AND cec.dinic_vgcia_parm = pic.dinic_vgcia_parm 
           WHERE Cr.Cind_Crrtr_Selec = 1);
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
END SGPB0133;
/

