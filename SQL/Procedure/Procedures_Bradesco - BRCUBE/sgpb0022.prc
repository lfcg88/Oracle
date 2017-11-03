CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0022
(
	Intrcompetencia     Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
    Intcanal  			Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
	Chrnomerotinascheduler VARCHAR2 := 'SGPB9022'
) IS
	Chrestado tpo_apurc_canal_vda.csit_apurc_canal %TYPE;
	-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0022
	--      DATA            : 09/03/06 16:20:15
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : Procedure gerenciadora das rotinas de seleção e apuração do canal Banco e finasa
	--      ALTERAÇÕES      : COLOCADO LOG PASSO-A-PASSO, RETIRADO POSSIVEL PROBLEMA DE ABEND. ASS. WASSILY
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
	Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
	Var_Irotna CONSTANT INT := 727;
---------------------------------------------------------------------------------
procedure getLastDay (competencia in Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                      data out Parm_Info_Campa.Dinic_Vgcia_Parm %TYPE)is
begin
       data := Last_Day(To_Date(competencia,'YYYYMM'));
end getLastDay;
---------------------------------------------------------------------------------
BEGIN
    Var_Log_Erro := Substr('INICIO DE EXECUCAO.',1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    commit;  
	Pr_Atualiza_Status_Rotina(Chrnomerotinascheduler, Var_Irotna, Pc_Util_01.Var_Rotna_Pc); 
	commit;
	Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0001.',1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    commit;
	--Pc_Util_01.Sgpb0001(Chrestado,Intcanal,pc_util_01.Normal,Intrcompetencia);
	-- A crítica abaixo foi retirado pois o processo de SELEÇÃO pode estar indo em uma produção de uma CAMANHA já fechada.
    -- Ass. Wassily - 20/09/2007
    -- TEstar se o Canalç está ativo
	--IF Chrestado <> Pc_Util_01.Ativo
	--THEN
	--	Var_Log_Erro := Substr('Canal Finasa não ativo. Competência' || Intrcompetencia, 1,
	--					Pc_Util_01.Var_Tam_Msg_Erro);
	--	Pr_Grava_Msg_Log_Carga(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
	--	Pr_Atualiza_Status_Rotina(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pe);
	--	Raise_Application_Error(-20210,var_log_erro);
	--END IF;
	-- Zera o flag em crrtr
	Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0032.',1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    commit;
	Pc_Util_01.Sgpb0032(Intrcompetencia,Intcanal); -- faz update em todo mundo.
	COMMIT;
	--marca FLAG 1 em crrtr o publico inicial que: CN, periodo, tempo de relacionamento
	Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0008.',1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    commit;
	Sgpb0008(Intrcompetencia,Intcanal);
	COMMIT;
  --Excluir os corretores que já estão selecionados.
  Var_Log_Erro := Substr('Executando Pc_Util_01.sgpb0133.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  sgpb0133(Intrcompetencia,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  --Excluir os corretores que não tem objetivo
  Var_Log_Erro := Substr('Executando Pc_Util_01.SGPB0139.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  SGPB0139(Intrcompetencia,Intcanal);
  commit;
  --Remoção de Impedidos
  Var_Log_Erro := Substr('Executando Pc_Util_01.sgpb0134.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  sgpb0134(Intrcompetencia ,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  --LISTA NEGRA
  Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0140.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  Sgpb0140(Intrcompetencia, Intcanal); -- Retira conforme a margem de contribuição
  COMMIT;
  --Insere corretores que foram adicionados manualmente na campanha
  --banco
  --Var_Log_Erro := Substr('Executando Pc_Util_01.Sgpb0164.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  --Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  --commit;
  --Sgpb0164(Intrcompetencia,Intcanal);
  --COMMIT;
  Var_Log_Erro := Substr('Executando Pc_Util_01.sgpb0138.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  commit;
  -- INSERE OS SELECIONADOS NA TABELA DE SELECIONADOS
  sgpb0138(Intrcompetencia ,Intcanal,Chrnomerotinascheduler);
  COMMIT;
  Var_Log_Erro := Substr('TERMINO DE EXECUCAO.',1,Pc_Util_01.Var_Tam_Msg_Erro);
  Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  Pr_Atualiza_Status_Rotina(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Po);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao executar seleção no ccanal Banco e finasa. Competência ' ||
                           Intrcompetencia || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);    
    ROLLBACK;
    Pr_Grava_Msg_Log_Carga_Sgpb(Chrnomerotinascheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    Pr_Atualiza_Status_Rotina_Sgpb(Chrnomerotinascheduler,Var_Irotna,Pc_Util_01.Var_Rotna_Pe);
    commit;
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0022;
/

