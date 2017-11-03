CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0127
(
Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
intrCanal              canal_vda_segur.ccanal_vda_segur%type,
Chrnomerotinascheduler VARCHAR2 := 'SGPB9127'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0127
  --      DATA            : 09/03/06 16:20:15
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure gerenciadora das rotinas de Apuração extra-banco
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------

  -- Nome da Rotina
  Var_Irotna CONSTANT INT := '832';

  Chrestado    tpo_apurc_canal_vda.csit_apurc_canal %TYPE;
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  pontoParada integer;
BEGIN
  if (intrCanal not in (pc_util_01.Extra_Banco)) then
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
  Pc_Util_01 .Sgpb0001(Chrestado, IntRcanal, Pc_Util_01.Normal, Intrcompetencia);
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
  pontoParada := 33;
  --
  --REMOVE O PUBLICO INICIAL dos corretores de grupo economico, (PROCESSADO SEPARADAMENTE)
  PC_APURACAO_GE.inserePubicoInicial(intrcompetencia, intrCanal, 0); -- 0 igual a marcar como selecionado
  COMMIT;
  --
  --
  pontoParada := 4;
  --Popula a tabela de objetivos com o calculo do ano passado(zera antes)
  -- As duas linhas abaixo foram comentadas a pedido do Vitor. (wassily).
  -- PC_APURACAO.insereObjetivoExtraBanco(Intrcompetencia);
  -- COMMIT;
  --
  --
  pontoParada := 5;
  --verifica se bateu o objetivo auto(desmarca quem nao bateu)
  PC_APURACAO.delCrrtrProdAbxoObjEB(Intrcompetencia,  intrCanal,  pc_util_01.Auto, pc_util_01.Auto);
  COMMIT;
  --
  --
  pontoParada := 6;
  --verficia se tem produção maior que 30.000
  pc_apuracao.delCrrtrProdAbxoEsperado(Intrcompetencia, intrCanal );
  COMMIT;
  --
  --
  pontoParada := 7;
  --verficia se tem margem adequada(desmarca quem nao bateu)
  pc_apuracao.delCorrtrProducaoAbaixoMargem(Intrcompetencia,  intrCanal);
  COMMIT;
  --
  --
  pontoParada := 8;
  --insere apuração na tabela de apurações Normal
  pc_apuracao.insereTabelaApuracao(
    pc_util_01.Normal,
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap,
    pc_util_01.Auto);
  COMMIT;
  --
  --
  pontoParada := 9;
  --verifica se bateu o objetivo RE(desmarca quem nao bateu)
  PC_APURACAO.delCrrtrProdAbxoObjEB(Intrcompetencia,  intrCanal, pc_util_01.RE, pc_util_01.RE);
  COMMIT;
  --
  --
  pontoParada := 10;
  --insere apuração na tabela de apurações Extra/adicional
  pc_apuracao.insereTabelaApuracao(
    pc_util_01.Extra,
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap,
    pc_util_01.AUTO);
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
END Sgpb0127;

  --processo separado (extra-banco)
      --INSERE O PUBLICO INICIAL(marca os corretores)
      --popula objetivo com o calculo do ano anterior(insere em objetivo(apaga antes))
      --verifica se bateu o objetivo (auto) (desmarca quem nao bateu)
                 --canal = extra
                 --auto = objcalc(populado)
                 --grupo = 120

      --verifica se tem mais que 30.0000 (desmarca quem nao bateu)
      --verficia se tem margem adequada (desmarca quem nao bateu)
      --apura normal (insere em apuracao)
      --verifica se bateu o objetivo (RE) (desmarca quem nao bateu)
                 --canal = extra
                 --auto = parametrizacao(9000)
                 --grupo = 810
      --apura adicional (insere em apuracao)
/

