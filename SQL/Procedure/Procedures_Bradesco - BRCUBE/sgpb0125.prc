CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0125
(
Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
intrCanal              canal_vda_segur.ccanal_vda_segur%type,
Chrnomerotinascheduler VARCHAR2 := 'SGPB9125'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0125
  --      DATA            : 09/03/06 16:20:15
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure gerenciadora das rotinas de Apuração banco/Finasa
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------

  -- Nome da Rotina
  Var_Irotna INT := '000';

  Chrestado    tpo_apurc_canal_vda.csit_apurc_canal %TYPE;
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  pontoParada integer;
BEGIN

  --
  if (intrCanal = PC_UTIL_01.Banco) then
     Var_Irotna := 830;
  elsif (intrCanal = PC_UTIL_01.Finasa) then
    Var_Irotna := 831;
  end if;

  if (intrCanal not in (pc_util_01.Banco, pc_util_01.Finasa)) then
    raise pc_util_01.ParametrosInvalidos;
  end if;
  --
  --
  pontoParada := 0;
  -- Busca o status do canal
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                 Var_Irotna,
                                 Pc_Util_01.Var_Rotna_Pc);
  commit;
  --
  --
  pontoParada := 1;
  Pc_Util_01.Sgpb0001(Chrestado, IntRcanal, Pc_Util_01.Normal, Intrcompetencia);
  -- TEstar se o Canal está ativo
  IF Chrestado <> Pc_Util_01.Ativo THEN
    raise pc_util_01.CanalNaoAtivoException;
  END IF;
  --
  --
  pontoParada := 2;
  -- UPDATE NA TABELA DE CORRETORES (Zera o flag em corretor)
  Pc_Util_01.Sgpb0032(Intrcompetencia, IntRcanal);
  COMMIT;
  --
  --
  pontoParada := 3;
  --INSERE O PUBLICO INICIAL(marca os corretores)
  PC_APURACAO.inserePubicoInicial(intrcompetencia, intrCanal);
  COMMIT;
  --
  --
  pontoParada := 4;
  --verifica se bateu o objetivo auto(desmarca quem nao bateu)
  PC_APURACAO.delCrrtrProdAbxoObjBF(Intrcompetencia,  intrCanal,  pc_util_01.Auto, pc_util_01.Auto);
  COMMIT;
  --
  --
  pontoParada := 5;
  --verifica se bateu o objetivo re(desmarca quem nao bateu)
  if (intrCanal = pc_util_01.Banco) then
    --Banco
    PC_APURACAO.delCrrtrProdAbxoObjBF(Intrcompetencia,  intrCanal, pc_util_01.ReTodos, pc_util_01.Re);
  else
    --Finasa
    PC_APURACAO.delCrrtrProdAbxoObjBF(Intrcompetencia,  intrCanal, pc_util_01.Re, pc_util_01.Re);
  end if;
  COMMIT;
  --
  --
  pontoParada := 6;
  --verficia se tem margem adequada(desmarca quem nao bateu)
  pc_apuracao.delCorrtrProducaoAbaixoMargem(Intrcompetencia,  intrCanal);
  COMMIT;
  --
  --
  pontoParada := 7;
  --insere apuração na tabela de apurações Normal
  pc_apuracao.insereTabelaApuracao(
    pc_util_01.Normal, -- colocou 1
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap,  -- APURADA.
    pc_util_01.Auto);
  COMMIT;
  --
  --
  pontoParada := 8;
  --insere apuração na tabela de apurações Extra/Adicional
  pc_apuracao.insereTabelaApuracao(
    pc_util_01.Extra, -- colocou 1
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap, -- APURADA. ( 'ap'
    pc_util_01.RE);
  COMMIT;
  --
  --
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                 Var_Irotna,
                                 Pc_Util_01.Var_Rotna_Po);
  COMMIT;
EXCEPTION
  when pc_util_01.ParametrosInvalidos then
    RAISE_APPLICATION_ERROR(-20001,
                            'O Canal não esta ativo');

  WHEN pc_util_01.CanalNaoAtivoException then
      Var_Log_Erro := Substr('Canal Extra-Banco não ativo. Competência' ||
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

  WHEN OTHERS THEN
    ROLLBACK;
    Var_Log_Erro := Substr('Erro ao executar seleção e apuração no canal Extra-Banco. Competência ' ||
                                 Intrcompetencia ||
                                 ' Lin: ' || to_char(pontoParada) ||
                                 ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
--
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
--
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                   Var_Irotna,
                                   Pc_Util_01.Var_Rotna_Pe);
--
    commit; --OS INSERTS EM LOG. O ROLLBACK DA ESTA FEITO ACIMA
--
    IF PC_UTIL_01.AMBIENTE = PC_UTIL_01.DESENVOLVIMENTO THEN
      RAISE;
    END IF;
END Sgpb0125;
/

