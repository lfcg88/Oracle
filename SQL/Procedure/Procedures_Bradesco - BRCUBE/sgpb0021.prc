CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0021(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrtpapurc     Tpo_Apurc.Ctpo_Apurc %TYPE,
                                     Intrgpramo      Grp_Ramo_Plano.Cgrp_Ramo_Plano %TYPE)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0021
  --      DATA            : 9/3/2006 09:06:42
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para Apurar os valores devidos para serem pagos e indicar se o corretor se apresenta impedimento no canal Extra-Banco
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Intrcanal    Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE := Pc_Util_01.Extra_Banco;
  Var_Crotna   VARCHAR2(8) := 'SGPB0021';
BEGIN
  INSERT INTO Apurc_Prod_Crrtr
    (Ccanal_Vda_Segur,
     Ctpo_Apurc,
     Ccompt_Apurc,
     Cgrp_Ramo_Plano,
     Ccompt_Prod,
     Ctpo_Comis,
     Ccrrtr,
     Cund_Prod,
     Csit_Apurc,
     Pbonus_Apurc,
     Cind_Apurc_Selec)
    SELECT Intrcanal,
           Intrtpapurc,
           Intrcompetencia,
           Pc.Cgrp_Ramo_Plano,
           Pc.Ccompt_Prod,
           Pc.Ctpo_Comis,
           Pc.Ccrrtr,
           Pc.Cund_Prod,
           'AP',
           Pb.Pbonus_Apurc,
           0
      FROM Crrtr Cr
     INNER JOIN Margm_Contb_Crrtr Mc ON Cr.Ccpf_Cnpj_Base =
                                        Mc.Ccpf_Cnpj_Base
                                    AND Cr.Ctpo_Pssoa = Mc.Ctpo_Pssoa
     INNER JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
                             AND Pc.Cund_Prod = Cr.Cund_Prod
                             AND Pc.Ccompt_Prod = Mc.Ccompt_Margm
     INNER JOIN Parm_Perc_Pgto_Bonif Pb ON Pb.Ccanal_Vda_Segur =
                                           Mc.Ccanal_Vda_Segur
                                       AND Pb.Ctpo_Apurc = Intrtpapurc
     WHERE Mc.Ccanal_Vda_Segur = Intrcanal
       AND Cr.Cind_Crrtr_Selec = 1
       AND Pc.Ctpo_Comis = 'CN'
       AND Pc.Cgrp_Ramo_Plano = Intrgpramo
       AND Pc.Ccompt_Prod = Intrcompetencia
       AND Sgpb0016(Intrcompetencia) BETWEEN Pb.Dinic_Vgcia_Parm AND
           Pc_Util_01.Sgpb0031(Pb.Dfim_Vgcia_Parm)
       AND Mc.Pmargm_Contb BETWEEN Pb.Pmin_Margm_Contb AND
           Pb.Pmax_Margm_Contb;
  --
  PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                              'Execução correta ao apurar corretor no canal extra banco.',
                              Pc_Util_01.Var_Log_Processo,
                              NULL,
                              NULL);
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' Ramo:' || Intrgpramo || ' # ' || SQLERRM,
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
                           ' Ramo:' || Intrgpramo || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao apurar corretor no canal extra banco.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' Ramo:' || Intrgpramo || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0021;
/

