CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0019(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0019
  --      DATA            : 9/3/2006 11:38:46
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para Apurar os valores devidos de bilhete para o canal Extra-Banco
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Intqtmesapurc  Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc %TYPE;
  Intcount       NUMBER := 0;
  Intrqtmesanlse Parm_Per_Apurc_Canal.Qmes_Anlse %TYPE;
  Var_Log_Erro   Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna     VARCHAR2(8) := 'Sgpb0019';
  Dtini          NUMBER;
BEGIN
  -- Quantidade de meses para se poder fazer uma apuração
  -- Desabilitado por motivo do movimento contabil.
  -- em seu lugar é passado apenas 1 mes para analisse
  Intqtmesapurc := 1;
  /* Pc_Util_01.Sgpb0007(Intqtmesapurc,
  Pc_Util_01.Extra_Banco,
  Intrcompetencia,
  Pc_Util_01.Extra);*/
  --
  Pc_Util_01.Sgpb0005(Intrqtmesanlse,
                      Pc_Util_01.Extra_Banco,
                      Intrcompetencia,
                      Pc_Util_01.Extra);
  -- DEsabilitado por causa do Movimento contabil
  /*  SELECT COUNT(*)
    INTO Intcount
    FROM Apurc_Prod_Crrtr Ap
   WHERE Ap.Ccompt_Apurc BETWEEN
         Pc_Util_01.Sgpb0017(Intrcompetencia, Intqtmesapurc - 1) AND
         Intrcompetencia
     AND Ap.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco
     AND Ap.Ctpo_Apurc = Pc_Util_01.Extra;
  --
  IF Intcount > 0
  THEN
    RETURN;
  END IF;*/
  --
  Dtini := Pc_Util_01.Sgpb0017(Intrcompetencia, Intrqtmesanlse - 1);
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
    SELECT Ap.Ccanal_Vda_Segur,
           Pc_Util_01.Extra,
           Intrcompetencia,
           Pc.Cgrp_Ramo_Plano,
           Pc.Ccompt_Prod,
           Pc.Ctpo_Comis,
           Pc.Ccrrtr,
           Pc.Cund_Prod,
           'AP',
           Pb.Pbonus_Apurc,
           0
      FROM Apurc_Prod_Crrtr Ap
    --
      JOIN Prod_Crrtr Pc ON Pc.Ccompt_Prod = Ap.Ccompt_Prod
                        AND Pc.Ccrrtr = Ap.Ccrrtr
                        AND Pc.Cund_Prod = Ap.Cund_Prod
                        AND Pc.Ctpo_Comis = Ap.Ctpo_Comis
                        AND Pc.Cgrp_Ramo_Plano = Ap.Cgrp_Ramo_Plano
    --
      JOIN Crrtr Cr ON Cr.Ccrrtr = Pc.Ccrrtr
                   AND Cr.Cund_Prod = Pc.Cund_Prod
    --
      JOIN (SELECT Cr.Ccpf_Cnpj_Base,
                   Cr.Ctpo_Pssoa,
                   Pc.Ccompt_Prod
              FROM Apurc_Prod_Crrtr Ap
            --
              JOIN Prod_Crrtr Pc ON Pc.Ccompt_Prod = Ap.Ccompt_Prod
                                AND Pc.Ccrrtr = Ap.Ccrrtr
                                AND Pc.Cund_Prod = Ap.Cund_Prod
                                AND Pc.Ctpo_Comis = Ap.Ctpo_Comis
                                AND Pc.Cgrp_Ramo_Plano = Pc_Util_01.Re
            --
              JOIN Crrtr Cr ON Cr.Ccrrtr = Pc.Ccrrtr
                           AND Cr.Cund_Prod = Pc.Cund_Prod
            --
              JOIN Parm_Prod_Min_Crrtr Pp ON Pp.Ccanal_Vda_Segur =
                                             Pc_Util_01.Extra_Banco
                                         AND Last_Day(To_Date(Intrcompetencia,
                                                              'YYYYMM')) BETWEEN
                                             Pp.Dinic_Vgcia_Parm AND
                                             Nvl(Pp.Dfim_Vgcia_Parm,
                                                 To_Date('99991231',
                                                         'YYYYMMDD'))
                                         AND Pp.Cgrp_Ramo_Plano =
                                             Pc_Util_01.Re
                                         AND Cr.Ctpo_Pssoa = Pp.Ctpo_Pssoa
                                         AND Pp.Ctpo_Per = Pc_Util_01.Mensal
            --
             WHERE Ap.Cgrp_Ramo_Plano = Pc_Util_01.Auto
               AND Ap.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco
               AND Ap.Ccompt_Apurc BETWEEN Dtini AND Intrcompetencia
               AND Ap.Ctpo_Comis = 'CN'
               AND Ap.Ctpo_Apurc = Pc_Util_01.Normal
            --
             GROUP BY Cr.Ccpf_Cnpj_Base,
                      Cr.Ctpo_Pssoa,
                      Pc.Ccompt_Prod
            --
            HAVING( --
            ( --
            (MAX(Pp.Qitem_Min_Prod_Crrtr) > 0) AND (SUM(Pc.Qtot_Item_Prod) >= MAX(Pp.Qitem_Min_Prod_Crrtr) AND SUM(Pc.Vprod_Crrtr) > 0)) OR ((MAX(Pp.Vmin_Prod_Crrtr) > 0) AND (SUM(Pc.Vprod_Crrtr) >= MAX(Pp.Vmin_Prod_Crrtr)))) --
            ) Aa ON Aa.Ccpf_Cnpj_Base = Cr.Ccpf_Cnpj_Base
                AND Aa.Ctpo_Pssoa = Cr.Ctpo_Pssoa
                AND Aa.Ccompt_Prod = Pc.Ccompt_Prod
      JOIN Parm_Perc_Pgto_Bonif Pb ON Pb.Ccanal_Vda_Segur =
                                      Pc_Util_01.Extra_Banco
                                  AND Pb.Ctpo_Apurc = Pc_Util_01.Extra
                                  AND Sgpb0016(Intrcompetencia) BETWEEN
                                      Pb.Dinic_Vgcia_Parm AND
                                      Pc_Util_01.Sgpb0031(Pb.Dfim_Vgcia_Parm)
      JOIN Margm_Contb_Crrtr Mc ON Mc.Ccpf_Cnpj_Base = Cr.Ccpf_Cnpj_Base
                               AND Mc.Ctpo_Pssoa = Cr.Ctpo_Pssoa
                               AND Mc.Ccanal_Vda_Segur =
                                   Pc_Util_01.Extra_Banco
                               AND Mc.Pmargm_Contb BETWEEN
                                   Pb.Pmin_Margm_Contb AND
                                   Pb.Pmax_Margm_Contb
                               AND Mc.Ccompt_Margm = Pc.Ccompt_Prod
    --
     WHERE Ap.Cgrp_Ramo_Plano = Pc_Util_01.Auto
       AND Ap.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco
       AND Ap.Ccompt_Apurc BETWEEN Dtini AND Intrcompetencia
       AND Ap.Ctpo_Comis = 'CN'
       AND Ap.Ctpo_Apurc = Pc_Util_01.Normal;
  --
  --
  --
  PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                              'Execução correta ao apurar bilhete para o canal Extra-Banco.',
                              Pc_Util_01.Var_Log_Processo,
                              NULL,
                              NULL);
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
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
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao apurar bilhete para o canal Extra-Banco.Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0019;
/

