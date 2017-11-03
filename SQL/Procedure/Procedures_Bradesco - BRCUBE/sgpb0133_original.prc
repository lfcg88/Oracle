CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0133_ORIGINAL
(
  Intrcompetencia  prod_crrtr.ccompt_prod %TYPE,
  Intrcanal        Crrtr_Eleit_Campa.Ccanal_Vda_Segur %TYPE,
  Var_Crotna       VARCHAR2
) IS

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0133
  --      DATA            : 11/12/2006 14:16:46
  --      AUTOR           : VIN�CIUS FARIA
  --      OBJETIVO        : Procedure para deletar os corretores que j� est�o selecionados.
  --      ALTERA��ES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  --Var_Crotna   VARCHAR2(8) := 'SGPB0133';
BEGIN
  --
  --
  --
  --
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 0
   WHERE Cr.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod) IN
         (SELECT Cr.Ccrrtr,
                 Cr.Cund_Prod

            FROM Crrtr Cr
            JOIN parm_info_campa pic ON pic.Ccanal_Vda_Segur = Intrcanal
                              AND Last_Day(To_Date(Intrcompetencia,'YYYYMM'))
                              BETWEEN pic.dinic_vgcia_parm
                              AND Nvl(pic.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))

            
            JOIN crrtr_eleit_campa cec ON Cr.Ccpf_Cnpj_Base = cec.ccpf_cnpj_base            
                                          AND Cr.Ctpo_Pssoa = cec.ctpo_pssoa
                                          AND cec.Ccanal_Vda_Segur = pic.Ccanal_Vda_Segur
                                          AND cec.dinic_vgcia_parm = pic.dinic_vgcia_parm

 
           WHERE Cr.Cind_Crrtr_Selec = 1);
  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Compet�ncia:' || Intrcompetencia || ' canal: ' ||
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
    Var_Log_Erro := Substr('Retorno de mais de um valor.Compet�ncia:' || Intrcompetencia ||
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
    Var_Log_Erro := Substr('Erro ao retirar corretores com margem de contribui��o abaixo do minimo.Compet�ncia:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
END SGPB0133_ORIGINAL;
/

