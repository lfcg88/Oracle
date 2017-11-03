CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0164(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       NUMBER) IS
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  Intquantminrel  Parm_Canal_Vda_Segur . Qtempo_Min_Rlcto %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0164
  --      DATA            : 8/3/2006 14:46:47
  --      AUTOR           : Ricardo - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para inserir na tabela temporaria os corretores que foram adicionados manualmente - banco
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'Sgpb0164';
BEGIN
  Pc_Util_01.Sgpb0003(Intinicialfaixa,
                      Intfinalfaixa,
                      Intrcanal,
                      Intrcompetencia);

  Pc_Util_01.Sgpb0006(Intquantminrel, Intrcanal, Intrcompetencia);
  --
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 1
   WHERE (Ccrrtr, Cund_Prod) IN
         (SELECT c.ccrrtr, c.cund_prod

             FROM MPMTO_AG_CRRTR MAC

             join crrtr c on c.ccrrtr = mac.ccrrtr_dsmem
                         and c.cund_prod = mac.cund_prod

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

            WHERE MAC.CCRRTR_ORIGN BETWEEN Intinicialfaixa AND Intfinalfaixa
              AND last_day(TO_DATE(Intrcompetencia, 'YYYYMM')) >= MAC.DENTRD_CRRTR_AG
              AND last_day(TO_DATE(Intrcompetencia, 'YYYYMM')) < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))

            group by c.ccrrtr, c.cund_prod

           having Months_Between(Last_Day(To_Date(Intrcompetencia, 'YYYYMM')), min(c.Dcadto_Crrtr)) >= Intquantminrel);
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
    Var_Log_Erro := Substr('Erro ao inserir corretores que apresentem tempo de relacionamento. Competência:' ||
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
END Sgpb0164;
/

