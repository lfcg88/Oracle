CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0227
(
Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
intrCanal              canal_vda_segur.ccanal_vda_segur%type,
Chrnomerotinascheduler VARCHAR2 := 'SGPB9227'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0227
  --      DATA            : 13/03/06 16:20:15
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure gerenciadora das rotinas de Apurac?o extra-banco
  --      ALTERAC?ES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------

  -- Nome da Rotina
  Var_Irotna CONSTANT INT := '832';

  Chrestado    tpo_apurc_canal_vda.csit_apurc_canal %TYPE;
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  pontoParada integer;
  int_count   integer;
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
  -- TEstar se o Canal esta ativo
  IF Chrestado <> Pc_Util_01.Ativo THEN
    raise pc_util_01.CanalNaoAtivoException;
  END IF;
  --
  --
  pontoParada := 2;
  -- UPDATE NA TABELA DE CORRETORES (Zera o flag em corretor)
  Pc_Util_01.Sgpb0032(Intrcompetencia, IntRcanal);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 3;
  --INSERE O PUBLICO INICIAL(marca os corretores)
  PC_APURACAO_GE.inserePubicoInicial(intrcompetencia, intrCanal, 1); -- 1 igual a marcar como selecionado
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 5;
  --verifica se bateu o objetivo auto(desmarca quem nao bateu)
  PC_APURACAO_GE.delCrrtrProdAbxoObjEB(Intrcompetencia,  intrCanal,  pc_util_01.Auto);--, pc_util_01.Auto);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 6;
  --NAO MAIS EXECUTADO POIS A VERICACAO DE MINIMO ESTE SENDO REALIZADA JUNTAMENTE COM A PRODUCAO ABAIXO DO ESPERADO.
        --verficia se tem produc?o maior que 30.000
        --PC_APURACAO_GE.delCrrtrProdAbxoEsperado(Intrcompetencia, intrCanal );
        --COMMIT;
  --
  --
  pontoParada := 7;
  --verficia se tem margem adequada(desmarca quem nao bateu)
  PC_APURACAO_GE.delCorrtrProducaoAbaixoMargem(Intrcompetencia,  intrCanal);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 8;
  --insere apurac?o na tabela de apurac?es Normal
  PC_APURACAO_GE.insereTabelaApuracao(
    pc_util_01.Normal,
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap,
    pc_util_01.Auto);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 9;
  --verifica se bateu o objetivo RE(desmarca quem nao bateu)
  PC_APURACAO_GE.delCrrtrProdAbxoObjEB(Intrcompetencia,  intrCanal, pc_util_01.RE);--, pc_util_01.RE);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  pontoParada := 10;
  --insere apurac?o na tabela de apurac?es Extra/adicional
  PC_APURACAO_GE.insereTabelaApuracao(
    pc_util_01.Extra,
    Intrcompetencia,
    Intrcanal,
    pc_util_01.Var_Rotna_Ap,
    pc_util_01.AUTO);
  COMMIT;
  select count(1) into int_count from crrtr c where c.cind_crrtr_selec = 1;
  --
  --
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
                                 Var_Irotna,
                                 Pc_Util_01.Var_Rotna_Po);
  COMMIT;
EXCEPTION
  when pc_util_01.ParametrosInvalidos then
    RAISE_APPLICATION_ERROR(-20001,
                            'O Canal n?o esta ativo');

  WHEN pc_util_01.CanalNaoAtivoException then
      Var_Log_Erro := Substr('Canal Extra-Banco n?o ativo. Competencia' ||
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
    Var_Log_Erro := Substr('Erro ao executar selec?o e apurac?o no canal Extra-Banco. Competencia ' ||
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
END Sgpb0227;

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

