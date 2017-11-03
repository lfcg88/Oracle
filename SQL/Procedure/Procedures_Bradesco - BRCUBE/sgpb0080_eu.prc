CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0080_eu(Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Chrnomerotinascheduler VARCHAR2 := 'SGPB9080')
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0080
  --      DATA            : 30/05/2006 4:53:12 PM
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Realização de pagamento de todos os canais. 
  --                        INSERE EM Apurc_Movto_Ctbil
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Crotna CONSTANT CHAR(8) := 'SGPB9080';
  Var_Irotna CONSTANT CHAR(4) := '848';
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
BEGIN
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                 Var_Irotna,
                                 Pc_Util_01.Var_Rotna_Pc);
  commit;
  INSERT INTO Apurc_Movto_Ctbil
    (Ccanal_Vda_Segur,
     Ctpo_Apurc,
     Ccompt_Apurc,
     Ccompt_Prod,
     Cgrp_Ramo_Plano,
     Ctpo_Comis,
     Ccrrtr,
     Cund_Prod,
     Dincl_Reg,
     Csit_Estrn,
     Cind_Arq_Expor,
     Ccompt_Movto_Ctbil)
    SELECT Apc.Ccanal_Vda_Segur,
           Apc.Ctpo_Apurc,
           Apc.Ccompt_Apurc,
           Apc.Ccompt_Prod,
           Apc.Cgrp_Ramo_Plano,
           Apc.Ctpo_Comis,
           Apc.Ccrrtr,
           Apc.Cund_Prod,
           SYSDATE,
           Pc_Util_01.Var_Aprov_Rz, -- 'RZ'
           0,
           Intrcompetencia
      FROM Pgto_Bonus_Crrtr Pbc
    --
      JOIN Papel_Apurc_Pgto Pap ON Pap.Cpgto_Bonus = Pbc.Cpgto_Bonus
                               AND Pap.Cindcd_Papel = 0
    --
      JOIN Apurc_Prod_Crrtr Apc ON Apc.Ccanal_Vda_Segur <> 1 --=
                                   --Pap.Ccanal_Vda_Segur
                               AND Apc.Ctpo_Apurc = Pap.Ctpo_Apurc
                               AND Apc.Ccompt_Apurc = Pap.Ccompt_Apurc
                               AND Apc.Cgrp_Ramo_Plano =
                                   Pap.Cgrp_Ramo_Plano
                               AND Apc.Ccompt_Prod = Pap.Ccompt_Prod
                               AND Apc.Ctpo_Comis = Pap.Ctpo_Comis
                               AND Apc.Ccrrtr = Pap.Ccrrtr
                               AND Apc.Cund_Prod = Pap.Cund_Prod
    --
     WHERE Pbc.Ccompt_Pgto = Intrcompetencia
       AND NOT EXISTS
     (SELECT 1
              FROM Apurc_Movto_Ctbil Amc
             WHERE Amc.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
               AND Amc.Ctpo_Apurc = Apc.Ctpo_Apurc
               AND Amc.Ccompt_Apurc = Apc.Ccompt_Apurc
               AND Amc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
               AND Amc.Ccompt_Prod = Apc.Ccompt_Prod
               AND Amc.Ctpo_Comis = Apc.Ctpo_Comis
               AND Amc.Ccrrtr = Apc.Ccrrtr
               AND Amc.Cund_Prod = Apc.Cund_Prod
               AND Amc.Csit_Estrn = Pc_Util_01.Var_Aprov_Rz);
--
--
  INSERT INTO Apurc_Movto_Ctbil
    (Ccanal_Vda_Segur,
     Ctpo_Apurc,
     Ccompt_Apurc,
     Ccompt_Prod,
     Cgrp_Ramo_Plano,
     Ctpo_Comis,
     Ccrrtr,
     Cund_Prod,
     Dincl_Reg,
     Csit_Estrn,
     Cind_Arq_Expor,
     Ccompt_Movto_Ctbil)
    SELECT Apc.Ccanal_Vda_Segur,
           Apc.Ctpo_Apurc,
           Apc.Ccompt_Apurc,
           Apc.Ccompt_Prod,
           Apc.Cgrp_Ramo_Plano,
           Apc.Ctpo_Comis,
           Apc.Ccrrtr,
           Apc.Cund_Prod,
           SYSDATE,
           Pc_Util_01.Var_Aprov_Pg, -- 'PG'
           0,
           Intrcompetencia
      FROM Pgto_Bonus_Crrtr Pbc
    --
      JOIN Papel_Apurc_Pgto Pap ON Pap.Cpgto_Bonus = Pbc.Cpgto_Bonus
                               AND Pap.Cindcd_Papel = 0
    --
      JOIN Apurc_Prod_Crrtr Apc ON Apc.Ccanal_Vda_Segur <> 1 --=
                                   --Pap.Ccanal_Vda_Segur
                               AND Apc.Ctpo_Apurc = Pap.Ctpo_Apurc
                               AND Apc.Ccompt_Apurc = Pap.Ccompt_Apurc
                               AND Apc.Cgrp_Ramo_Plano =
                                   Pap.Cgrp_Ramo_Plano
                               AND Apc.Ccompt_Prod = Pap.Ccompt_Prod
                               AND Apc.Ctpo_Comis = Pap.Ctpo_Comis
                               AND Apc.Ccrrtr = Pap.Ccrrtr
                               AND Apc.Cund_Prod = Pap.Cund_Prod
    --
     WHERE Pbc.Ccompt_Pgto = Intrcompetencia
       AND NOT EXISTS
     (SELECT 1
              FROM Apurc_Movto_Ctbil Amc
             WHERE Amc.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
               AND Amc.Ctpo_Apurc = Apc.Ctpo_Apurc
               AND Amc.Ccompt_Apurc = Apc.Ccompt_Apurc
               AND Amc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
               AND Amc.Ccompt_Prod = Apc.Ccompt_Prod
               AND Amc.Ctpo_Comis = Apc.Ctpo_Comis
               AND Amc.Ccrrtr = Apc.Ccrrtr
               AND Amc.Cund_Prod = Apc.Cund_Prod
               AND Amc.Csit_Estrn = Pc_Util_01.Var_Aprov_Rz);


  ---
  /*Apuração terminada*/
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                 Var_Irotna,
                                 Pc_Util_01.Var_Rotna_Po);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    Var_Log_Erro := Substr('Erro ao realizar a apuração do corretor como Paga. Competência:' ||
                           Intrcompetencia || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                   Var_Irotna,
                                   Pc_Util_01.Var_Rotna_Pe);
    COMMIT;
    RAISE;
END Sgpb0080_eu;
/

