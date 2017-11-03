CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0139
( Intrcompetencia prod_crrtr.ccompt_prod%TYPE,
  Intrcanal       Crrtr_Eleit_Campa.Ccanal_Vda_Segur%TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0139
  --      DATA            : 16/12/2006 14:16:46
  --      AUTOR           : VINÍCIUS FARIA
  --      OBJETIVO        : Procedure para deletar os corretores que não tem objetivo cadastrado.
  --                        25/09/2007 - MELHORADAS ROTINAS DE EXCEPTION. ASS. WASSILY
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro%TYPE;
  Var_Crotna   VARCHAR2(8) := 'SGPB9022';
  IntrcompetenciaProx  prod_crrtr.ccompt_prod%TYPE;
BEGIN       
  IntrcompetenciaProx := TO_CHAR(ADD_MONTHS(to_date(Intrcompetencia, 'YYYYMM'),1), 'YYYYMM');
  UPDATE Crrtr C
     SET C.Cind_Crrtr_Selec = 0  -- tira de eleito SE NÃO TEM OBJETIVO
   WHERE C.Cind_Crrtr_Selec = 1
     AND (Ccrrtr, Cund_Prod)      
     NOT IN ( SELECT C.Ccrrtr, C.Cund_Prod
                    FROM Crrtr C
                    join objtv_prod_crrtr opc
                     on opc.ccpf_cnpj_base = c.ccpf_cnpj_base
                    and opc.ctpo_pssoa = c.ctpo_pssoa
                    and opc.ccanal_vda_segur = Intrcanal               
                    and opc.CGRP_RAMO_PLANO = Pc_Util_01.auto
                    and opc.cano_mes_compt_objtv = IntrcompetenciaProx
                    and opc.cind_reg_ativo = 'S'
                    WHERE C.Cind_Crrtr_Selec = 1);
EXCEPTION
  WHEN No_Data_Found THEN
       Var_Log_Erro := Substr('Retorno de nenhum valor. Data de Início da Vigência:' || Intrcompetencia || ' canal: ' ||
                              Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
       Var_Log_Erro := Substr('Retorno de mais de um valor. Data de Início da Vigência:' || Intrcompetencia ||
                              ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
       Var_Log_Erro := Substr('Erro ao retirar corretores sem objetivo.
                              Data de Início da Vigência:' || Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM,
                              1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       Raise_Application_Error(-20210,var_log_erro);
END SGPB0139;
/

