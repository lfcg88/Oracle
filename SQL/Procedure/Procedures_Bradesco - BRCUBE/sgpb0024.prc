CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0024(Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
                                     Chrnomerotinascheduler VARCHAR2 := 'SGPB9024') IS
  Var_Irotna CONSTANT INT := 727;
  Intcanal     Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE := Pc_Util_01.Extra_Banco;
  Chrestado    tpo_apurc_canal_vda.csit_apurc_canal %TYPE;
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0024
  --      DATA            : 09/03/06 16:20:15
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure gerenciadora das rotinas de seleção e apuração do canal Extra-Banco
  --      ALTERAÇÕES      : COLOCADO LOG PASSO-A-PASSO, RETIRADO POSSIVEL PROBLEMA DE ABEND. ASS. WASSILY
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
---------------------------------------------------------------------------------
BEGIN
  Var_Log_Erro := Substr('INICIO DE EXECUCAO.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit; 
  Pr_Atualiza_Status_Rotina_Sgpb(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pc);
  Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0001.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  --Pc_Util_01.Sgpb0001(Chrestado, Intcanal, Pc_Util_01.Normal, Intrcompetencia);
  -- A crítica abaixo foi retirado pois o processo de SELEÇÃO pode estar indo em uma produção de uma CAMANHA já fechada.
  -- Ass. Wassily - 20/09/2007
  -- TEstar se o Canalç está ativo
  --IF Chrestado <> Pc_Util_01.Ativo
  --THEN
  --  Var_Log_Erro := Substr('Canal Extra-Banco não ativo. Competência' ||Intrcompetencia,1,Pc_Util_01.Var_Tam_Msg_Erro);
  --  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo, NULL, NULL);
  --  Pr_Atualiza_Status_Rotina_Sgpb(Chrnomerotinascheduler,  Var_Irotna, Pc_Util_01.Var_Rotna_Pe);
  --  Raise_Application_Error(-20210,var_log_erro);
  --END IF;
  -- Deleta informações da tabela temporaria
  -- Zera o flag em corretor
  Var_Log_Erro := Substr('Executando Sgpb0032.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Pc_Util_01.Sgpb0032(Intrcompetencia, Intcanal); -- faz update em todos mundo.
  COMMIT;
  --INSERE O PUBLICO INICIAL, CN, TEMPO RELACIONAMENTO, FAIXA E 33441
  Var_Log_Erro := Substr('Executando Sgpb0020.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Sgpb0020(Intrcompetencia, Intcanal); -- Insere os corretores na tabela
  COMMIT;  
  Var_Log_Erro := Substr('Executando Sgpb0020_tr.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Sgpb0020_tr(Intrcompetencia, Intcanal); -- retira os corretores na tabela que tenham a idade menor do que 6 meses
  COMMIT;  --
  --Excluir os corretores que já estão selecionados.    
  Var_Log_Erro := Substr('Executando sgpb0133.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  sgpb0133(Intrcompetencia,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  --Remoção de Impedidos
  Var_Log_Erro := Substr('Executando sgpb0134.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  sgpb0134(Intrcompetencia ,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  --LISTA NEGRA
  Var_Log_Erro := Substr('Executando Sgpb0010.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Sgpb0010(Intrcompetencia,Intcanal); -- Retira conforme a margem de contribuição
  COMMIT;
  --EXCLUI QUEM NÃO TEM PROD. TOTAL NO PERIODO MAIOR Q A META DO PERIODO
  Var_Log_Erro := Substr('Executando Sgpb0013.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Sgpb0013(Intrcompetencia); -- Retira conforme a produção periodica do Ramo Auto
  COMMIT;
  -- INSERE OS SELECIONADOS NA TABELA DE SELECIONADOS
  Var_Log_Erro := Substr('Executando sgpb0138.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  sgpb0138(Intrcompetencia ,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  Var_Log_Erro := Substr('TERMINO DE EXECUCAO.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  Pr_Atualiza_Status_Rotina_Sgpb(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Po);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao executar seleção no canal Extra-Banco. Competência ' ||
                           Intrcompetencia || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);    
    ROLLBACK;
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    Pr_Atualiza_Status_Rotina_Sgpb(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pe);
    commit;
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0024;
/

