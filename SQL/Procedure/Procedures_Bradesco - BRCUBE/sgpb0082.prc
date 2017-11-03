CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0082
(
  Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
  Intrcanal              Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9082'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0082
  --      DATA            : 02/06/2006 9:34:22 AM
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Estorno do valor que foi aprovisionado erroniamente(Esperando que se fosse pago)
  --                        INSERE NO APRUC_MOV_CONTABIL
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  Var_Irotna int := 000;  -- COLOCADO PARA INT. ASS. WASSILY (ESTAVA DANDO ABEND)
  Var_Log_Erro    Pc_Util_01.Var_Log_Erro %TYPE;
  Sponto          CHAR(5) := '#XXXX';
  Intqtmespgto    Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc %TYPE;
  Intrangeinicest Margm_Contb_Crrtr.Ccompt_Margm %TYPE;
  Intrangefinaest Margm_Contb_Crrtr.Ccompt_Margm %TYPE;
  Intultapuaval   Margm_Contb_Crrtr.Ccompt_Margm %TYPE;
BEGIN

  --
  Sponto          := '#1';
  if (Intrcanal = PC_UTIL_01.Banco) then
     Var_Irotna := 845;
  elsif (Intrcanal = PC_UTIL_01.Finasa) then
    Var_Irotna := 846;
  elsif (Intrcanal = PC_UTIL_01.Extra_Banco) then
    Var_Irotna := 847;
  end if;  
  --
  Sponto          := '#2';
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pc);
  commit;
  --
  -- Busca parametrização de pagamento
  FOR Tipoapuracao IN Pc_Util_01.Normal .. Pc_Util_01.Extra LOOP
    --
    Sponto          := '#3';
    Pc_Util_01.Sgpb0069(Intqtmespgto,
                        Intrcanal,
                        Intrcompetencia,
                        Tipoapuracao);
    Sponto          := '#4';
    --
    IF Intqtmespgto > 1 THEN  -- Se o pgto é mensal não há estorno, pq não tem necessidade de consecutividade
      --
      Intultapuaval   := Pc_Util_01.Sgpb0017(Intrcompetencia,
                                             Intqtmespgto - 1);
      Sponto          := '#5';
      Intrangeinicest := Pc_Util_01.Sgpb0017(Intrcompetencia,
                                             ((Intqtmespgto * 2) - 2));
      Sponto          := '#6';
      Intrangefinaest := Pc_Util_01.Sgpb0017(Intrcompetencia,
                                             Intqtmespgto);
      Sponto          := '#7';
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
               Pc_Util_01.Var_Aprov_Es,
               0,
               Intrcompetencia
        --
          FROM Apurc_Prod_Crrtr Apc
        --
         WHERE Apc.Ccompt_Apurc BETWEEN Intrangeinicest -- tempo máximo para se avaliar se uma apuração é estornavel
               AND Intrangefinaest -- inicio da avaliaçã se uma apuração é estornavel
           AND Apc.Csit_Apurc = Pc_Util_01.Var_Apurc_Ap
           AND Apc.Ccanal_Vda_Segur = Intrcanal
           AND APC.CTPO_APURC = Tipoapuracao
           AND NOT EXISTS ( --
                SELECT 1
                  FROM Apurc_Prod_Crrtr T1
                 WHERE T1.Ccompt_Apurc = Intultapuaval -- Ultima apuração que não será avaliada quanto ao seu estorno
                   AND T1.Ccrrtr = Apc.Ccrrtr
                   AND T1.Cund_Prod = Apc.Cund_Prod
                   AND T1.Ctpo_Apurc = Apc.Ctpo_Apurc
                   AND T1.Csit_Apurc IN ('AP')
                   AND T1.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                   AND T1.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano --
                )
           AND NOT EXISTS ( --
                SELECT 1
                  FROM Apurc_Movto_Ctbil Amc
                 WHERE Amc.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                   AND Amc.Ctpo_Apurc = Apc.Ctpo_Apurc
                   AND Amc.Ccompt_Apurc = Apc.Ccompt_Apurc
                   AND Amc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                   AND Amc.Ccompt_Prod = Apc.Ccompt_Prod
                   AND Amc.Ctpo_Comis = Apc.Ctpo_Comis
                   AND Amc.Ccrrtr = Apc.Ccrrtr
                   AND Amc.Cund_Prod = Apc.Cund_Prod
                   AND Amc.Csit_Estrn = Pc_Util_01.Var_Aprov_Es --
                );
      --
    END IF;
    Sponto          := '#8';
  END LOOP;
  --
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Po);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    Sponto          := '#9';
    Var_Log_Erro := Substr('Erro ao gerar estorno das apurações não pagas. Competência:' || Intrcompetencia || ' #' || Sponto || '# ' ||
                           SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
    Sponto          := '#10';
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,  --Var_Crotna,  -- Alterado a pedido do Vitor. Ass. Wassily ( 2007/05/14 )
                                Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    Sponto          := '#11';
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pe);
    COMMIT;
    RAISE;
END Sgpb0082;
/

