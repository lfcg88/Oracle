CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0014(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
                                     Intrtpapurc     Tpo_Apurc.Ctpo_Apurc %TYPE,
                                     Intrgruporamo   Prod_Crrtr.Cgrp_Ramo_Plano %TYPE)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0014
  --      DATA            : 9/3/2006 09:06:42
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para Apurar os valores devidos para serem pagos e indicar se o corretor se apresenta impedimento nos canais Banco e Finasa
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Log_Erro  Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna    VARCHAR2(8) := 'SGPB0014';
  Intqtmesapurc NUMBER;
BEGIN
  Pc_Util_01.Sgpb0007(Intqtmesapurc,
                      Intrcanal,
                      Intrcompetencia,
                      Intrtpapurc);
  --
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
    --
      JOIN Margm_Contb_Crrtr Mc ON Mc.Ccpf_Cnpj_Base = Cr.Ccpf_Cnpj_Base
                               AND Mc.Ctpo_Pssoa = Cr.Ctpo_Pssoa
                               AND Mc.Ccanal_Vda_Segur = Intrcanal
    --
      JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
                        AND Pc.Cund_Prod = Cr.Cund_Prod
                        AND Pc.Ccompt_Prod = Mc.Ccompt_Margm
                        AND Pc.Ctpo_Comis = 'CN'
                        AND Pc.Cgrp_Ramo_Plano = Intrgruporamo
                        AND Pc.Ccompt_Prod BETWEEN
                            Pc_Util_01.Sgpb0017(Intrcompetencia,
                                                Intqtmesapurc - 1) AND
                            Intrcompetencia
    --
      JOIN Parm_Perc_Pgto_Bonif Pb ON Pb.Ccanal_Vda_Segur =
                                      Mc.Ccanal_Vda_Segur
                                  AND Pb.Ctpo_Apurc = Intrtpapurc
                                  AND Sgpb0016(Intrcompetencia) BETWEEN
                                      Pb.Dinic_Vgcia_Parm AND
                                      Pc_Util_01.Sgpb0031(Pb.Dfim_Vgcia_Parm)
    --
     WHERE Cr.Cind_Crrtr_Selec = 1
       AND Mc.Pmargm_Contb BETWEEN Pb.Pmin_Margm_Contb AND
           Pb.Pmax_Margm_Contb;
  --
  PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                              'Execução correta ao processar os valores da tabela temporaria para a tabela de apuração.',
                              Pc_Util_01.Var_Log_Processo,
                              NULL,
                              NULL);
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' Tipo de apuração: ' || Intrtpapurc || ' # ' ||
                           SQLERRM,
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
                           ' Tipo de apuração: ' || Intrtpapurc || ' # ' ||
                           SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    IF SQLCODE = -1
    THEN
      Var_Log_Erro := Substr('CUIDADO AS INFORMAÇÔES DE APURAÇÂO JÁ ESTÂO SENDO UTILIZADAS:# ',
                             1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                  Var_Log_Erro,
                                  Pc_Util_01.Var_Log_Processo,
                                  NULL,
                                  NULL);
    ELSE
      Var_Log_Erro := Substr('Erro ao processar os valores da tabela temporaria para a tabela de apuração.Competência:' ||
                             Intrcompetencia || ' canal: ' || Intrcanal ||
                             ' Tipo de apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM || ' Cod Erro ' || SQLCODE,
                             1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                  Var_Log_Erro,
                                  Pc_Util_01.Var_Log_Processo,
                                  NULL,
                                  NULL);
      RAISE;
    END IF;
END Sgpb0014;
/

