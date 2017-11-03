CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0163(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       NUMBER) IS
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  Intquantminrel  Parm_Canal_Vda_Segur . Qtempo_Min_Rlcto %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0163
  --      DATA            : 8/3/2006 14:46:47
  --      AUTOR           : Ricardo - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para inserir na tabela temporaria os corretores que foram adicionados manualmente - extra-banco
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'Sgpb0163';
  Intrqtmesanlse Parm_Per_Apurc_Canal.Qmes_Anlse %TYPE;
BEGIN
  Pc_Util_01.Sgpb0005(Intrqtmesanlse,
                      Pc_Util_01.Extra_Banco,
                      Intrcompetencia,
                      Pc_Util_01.Normal);
  --
  Pc_Util_01.Sgpb0003(Intinicialfaixa,
                      Intfinalfaixa,
                      Pc_Util_01.Extra_Banco,
                      Intrcompetencia);
  --
  Pc_Util_01.Sgpb0006(Intquantminrel, Intrcanal, Intrcompetencia);
  --
  UPDATE Crrtr C
     SET C.Cind_Crrtr_Selec = 1
   WHERE (Ccrrtr, Cund_Prod) IN
         (SELECT distinct C.Ccrrtr, C.Cund_Prod
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
             AND cecp.ctpo_excec_crrtr = 'A'
             and cecp.cind_reg_ativo  = 'S'

           WHERE (C.Ccrrtr BETWEEN Intinicialfaixa AND Intfinalfaixa --
                 OR C.Ccrrtr = 334441)
          --
          );
  --
  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao inserir na tabela temporaria corretores que apresentem tempo de relacionamento e comissão normal.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0163;
/

