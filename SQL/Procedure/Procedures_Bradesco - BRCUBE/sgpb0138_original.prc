CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0138_ORIGINAL
(
  Intrcompetencia  prod_crrtr.ccompt_prod %TYPE,
  Intrcanal        Crrtr_Eleit_Campa.Ccanal_Vda_Segur %TYPE,  
  Var_Crotna   VARCHAR2
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0138
  --      DATA            : 11/12/2006 14:16:46
  --      AUTOR           : VINÍCIUS FARIA
  --      OBJETIVO        : Procedure para inserir os corretores selecionados ate o momento na tabela de corretores selecionados
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
BEGIN
  --
  --
  insert into crrtr_eleit_campa
    (ccanal_vda_segur, dinic_vgcia_parm, ctpo_pssoa, ccpf_cnpj_base, dcrrtr_selec_campa)
    SELECT pic.ccanal_vda_segur,
           pic.dinic_vgcia_parm,
           C.CTPO_PSSOA,
           C.CCPF_CNPJ_BASE,
           SYSDATE

      FROM Crrtr C

      JOIN parm_info_campa pic
        ON pic.Ccanal_Vda_Segur = Intrcanal
       AND Last_Day(To_Date(Intrcompetencia,'YYYYMM'))
                 BETWEEN pic.dinic_vgcia_parm
                     AND Nvl(pic.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))

     WHERE C.Cind_Crrtr_Selec = 1
     GROUP
        BY pic.ccanal_vda_segur,
           pic.dinic_vgcia_parm,
           C.CCPF_CNPJ_BASE,
           C.CTPO_PSSOA;  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor. canal: ' ||
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
    Var_Log_Erro := Substr('Retorno de mais de um valor. ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao retirar corretores com margem de contribuição abaixo do minimo.' ||
                           ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
END SGPB0138_ORIGINAL;
/

