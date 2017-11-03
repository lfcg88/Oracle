CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0020(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       NUMBER) IS
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  Intquantminrel  Parm_Canal_Vda_Segur . Qtempo_Min_Rlcto %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0020
  --      DATA            : 8/3/2006 14:46:47
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : - Procedure para inserir na tabela temporaria os corretores que apresentarem 
  --                      :   tempo de relacionamento, comissão normal e estiverem no canal Extra-Banco.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'SGPB9024';
  Intrqtmesanlse Parm_Per_Apurc_Canal.Qmes_Anlse %TYPE;
  intComptInicial number(6);
BEGIN
  Pc_Util_01.Sgpb0005(Intrqtmesanlse,Pc_Util_01.Extra_Banco,Intrcompetencia,Pc_Util_01.Normal); -- se 200709, volta 6
  intComptInicial:=To_Number(To_Char(Add_Months(To_Date(Intrcompetencia,'yyyymm'),((Intrqtmesanlse -1)*-1)),'YYYYMM')); -- 200704
  Pc_Util_01.Sgpb0003(Intinicialfaixa,Intfinalfaixa,Pc_Util_01.Extra_Banco,Intrcompetencia); -- volta 100000 e 199999
  Pc_Util_01.Sgpb0006(Intquantminrel, Intrcanal, Intrcompetencia); -- se extrabanco volta 6
  UPDATE Crrtr C
     SET C.Cind_Crrtr_Selec = 1
   WHERE (Ccrrtr, Cund_Prod) IN
         (SELECT distinct C.Ccrrtr, C.Cund_Prod
            FROM Crrtr C
            join prod_crrtr pc
              on pc.ccrrtr = c.ccrrtr
             and pc.cund_prod = c.cund_prod
             and pc.ccompt_prod between intComptInicial and Intrcompetencia
             and pc.ctpo_comis = 'CN'
             and pc.cgrp_ramo_plano = pc_util_01.Auto
           WHERE (C.Ccrrtr BETWEEN Intinicialfaixa AND Intfinalfaixa --
                 OR C.Ccrrtr = 334441)
          );
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao inserir na tabela temporaria corretores que apresentem tempo de relacionamento e comissão normal.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0020;
/

