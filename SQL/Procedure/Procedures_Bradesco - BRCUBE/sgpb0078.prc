CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0078(Intrcodcrrtr    Crrtr_Unfca_Cnpj.Ccpf_Cnpj_Base %TYPE,
                                     Chrrtipopessoa  Crrtr_Unfca_Cnpj.Ctpo_Pssoa%TYPE,
                                     Intrcanal       Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
                                     Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrminimo      NUMBER)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0078
  --      DATA            : 12/04/2006 3:27:22 PM
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : bloquear corretores do canal banco individualmente
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Crotna CONSTANT CHAR(8) := 'SGPB0078';
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  --
  Intcomini     Apurc_Prod_Crrtr.Ccompt_Apurc %TYPE;
  Intquantmespg Apurc_Prod_Crrtr.Ccompt_Apurc %TYPE;
BEGIN
  BEGIN
    SELECT Pp.Qmes_Perdc_Pgto
      INTO Intquantmespg
      FROM Parm_Per_Apurc_Canal Pp
     WHERE Pp.Ccanal_Vda_Segur = Intrcanal
       AND Pp.Ctpo_Apurc = Pc_Util_01.Normal
       AND Sgpb0016(Intrcompetencia) BETWEEN Pp.Dinic_Vgcia_Parm AND
           Pc_Util_01.Sgpb0031(Pp.Dfim_Vgcia_Parm);
  EXCEPTION
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao buscar quantidade de meses para pagamento:' ||
                             Intrcompetencia || ' # ' || SQLERRM,
                             1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                  Var_Log_Erro,
                                  Pc_Util_01.Var_Log_Processo,
                                  NULL,
                                  NULL);
      RAISE;
  END;
  --
  Intcomini := Pc_Util_01.Sgpb0017(Intrcompetencia, Intquantmespg - 1);
  UPDATE Apurc_Prod_Crrtr Ap
     SET Ap.Csit_Apurc = Decode(Intrminimo,
                                Pc_Util_01.Var_Acima_Minimo,
                                'BG',
                                Pc_Util_01.Var_Abaixo_Minimo,
                                'LM',
                                'AP')
   WHERE (Ap.Ccrrtr, Ap.Cund_Prod) IN
         (SELECT Ap.Ccrrtr,
                 Ap.Cund_Prod
            FROM (SELECT Tap.Ccrrtr,
                         Tap.Cund_Prod
                    FROM Apurc_Prod_Crrtr Tap
                    LEFT JOIN Papel_Apurc_Pgto Tpa ON Tap.Ccanal_Vda_Segur =
                                                      Tpa.Ccanal_Vda_Segur
                                                  AND Tap.Ctpo_Apurc =
                                                      Tpa.Ctpo_Apurc
                                                  AND Tap.Ccompt_Apurc =
                                                      Tpa.Ccompt_Apurc
                                                  AND Tap.Cgrp_Ramo_Plano =
                                                      Tpa.Cgrp_Ramo_Plano
                                                  AND Tap.Ccompt_Prod =
                                                      Tpa.Ccompt_Prod
                                                  AND Tap.Ctpo_Comis =
                                                      Tpa.Ctpo_Comis
                                                  AND Tap.Ccrrtr = Tpa.Ccrrtr
                                                  AND Tap.Cund_Prod =
                                                      Tpa.Cund_Prod
                   WHERE Tap.Ccompt_Apurc BETWEEN Intcomini AND
                         Intrcompetencia
                     AND Tap.Ccanal_Vda_Segur = Intrcanal
                     AND Tpa.Cpgto_Bonus = NULL
                   GROUP BY Tap.Ccrrtr,
                            Tap.Cund_Prod
                  HAVING SUM(CASE WHEN Tap.Cgrp_Ramo_Plano = Pc_Util_01.Auto
                  --
                  THEN 1 ELSE 0 END) = Intquantmespg) Ap
            JOIN Crrtr Cr ON Ap.Ccrrtr = Cr.Ccrrtr
                         AND Ap.Cund_Prod = Cr.Cund_Prod
           WHERE Cr.Ccpf_Cnpj_Base = Intrcodcrrtr
             AND Cr.Ctpo_Pssoa = Chrrtipopessoa)
     AND Ap.Ccompt_Apurc BETWEEN Intcomini AND Intrcompetencia
        -- Apenas é retirdo do pagamento quem está apurado
     AND Ap.Csit_Apurc IN ('AP');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao Bloquiar os corretores do canal Banco individualmente pelo gestor. Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END Sgpb0078;
/

