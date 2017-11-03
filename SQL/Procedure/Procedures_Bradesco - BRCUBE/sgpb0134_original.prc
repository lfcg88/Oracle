CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0134_ORIGINAL
(
  Intrcompetencia  prod_crrtr.ccompt_prod %TYPE,
  Intrcanal        Crrtr_Eleit_Campa.Ccanal_Vda_Segur %TYPE,
  Var_Crotna       VARCHAR2
) IS

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0134
  --      DATA            : 16/12/2006 14:16:46
  --      AUTOR           : VINÍCIUS FARIA
  --      OBJETIVO        : Procedure para deletar os corretores que estão impedido.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
BEGIN
  --
  --
  --
  --
  UPDATE Crrtr C
     SET C.Cind_Crrtr_Selec = 0
   WHERE C.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod) IN
         (SELECT C.Ccrrtr,
                 C.Cund_Prod

            FROM Crrtr C

            JOIN parm_info_campa pic
              ON pic.Ccanal_Vda_Segur = Intrcanal
             AND Last_Day(To_Date(Intrcompetencia,'YYYYMM'))
                 BETWEEN pic.dinic_vgcia_parm
                     AND Nvl(pic.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))

            JOIN crrtr_excec_campa cecp
              ON cecp.Ccpf_Cnpj_Base = C.ccpf_cnpj_base
             AND cecp.Ctpo_Pssoa    = C.ctpo_pssoa
             AND cecp.Ccanal_Vda_Segur = pic.Ccanal_Vda_Segur
             AND cecp.dinic_vgcia_parm = pic.dinic_vgcia_parm
             AND cecp.ctpo_excec_crrtr = 'I'
             and cecp.cind_reg_ativo  = 'S'

            WHERE C.Cind_Crrtr_Selec = 1);
  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor. Data de Início da Vigência:' || Intrcompetencia || ' canal: ' ||
                           Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor. Data de Início da Vigência:' || Intrcompetencia ||
                           ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores com margem de contribuição abaixo do minimo.
                            Data de Início da Vigência:' || Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
END SGPB0134_ORIGINAL;
/

