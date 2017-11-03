CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0077
(
	Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
	Chrnomerotinascheduler VARCHAR2 := 'SGPB0077'
)
-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0077
	--      DATA            : 30/05/2006 10:50:14 AM
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : Aprovisionamento de Movimento Contabil
	--      ALTERAÇÕES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
 IS
	Var_Crotna CONSTANT CHAR(8) := 'SGPB0077';
	Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
	Var_Irotna CONSTANT INT := 833;
BEGIN
	PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
																 Var_Irotna,
																 Pc_Util_01.Var_Rotna_Pc);
	
  commit;
	-- Popula a tabela APURC_MOBTO_CTBIL com aprovisionamentos a serem feitos
	INSERT INTO Apurc_Movto_Ctbil
		(Ccompt_Apurc,
		 Ccanal_Vda_Segur,
		 Cgrp_Ramo_Plano,
		 Ccompt_Prod,
		 Ctpo_Comis,
		 Ctpo_Apurc,
		 Ccrrtr,
		 Cund_Prod,
		 Dincl_Reg,
		 Csit_Estrn,
		 Cind_Arq_Expor,
		 Ccompt_Movto_Ctbil)
		SELECT Apc.Ccompt_Apurc,
					 Apc.Ccanal_Vda_Segur,
					 Apc.Cgrp_Ramo_Plano,
					 Apc.Ccompt_Prod,
					 Apc.Ctpo_Comis,
					 Apc.Ctpo_Apurc,
					 Apc.Ccrrtr,
					 Apc.Cund_Prod,
					 SYSDATE,
					 Pc_Util_01.Var_Aprov_Ap,
					 0,
					 Intrcompetencia
			FROM Apurc_Prod_Crrtr Apc
		--
			LEFT JOIN Apurc_Movto_Ctbil Amc ON Amc.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
																							AND Amc.Ctpo_Apurc = Apc.Ctpo_Apurc
																							AND Amc.Ccompt_Apurc = Apc.Ccompt_Apurc
																							AND Amc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
																							AND Amc.Ccompt_Prod = Apc.Ccompt_Prod
																							AND Amc.Ctpo_Comis = Apc.Ctpo_Comis
																							AND Amc.Ccrrtr = Apc.Ccrrtr
																							AND Amc.Cund_Prod = Apc.Cund_Prod
																							AND Amc.Csit_Estrn = Pc_Util_01.Var_Aprov_Ap
		--
		 WHERE Apc.Ccompt_Apurc = Intrcompetencia
					 AND Apc.Csit_Apurc = Pc_Util_01.Var_Apurc_Ap;
					 --AND Amc.Ccanal_Vda_Segur IS NULL;
	  --
	PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
																 Var_Irotna,
																 Pc_Util_01.Var_Rotna_Po);
	--
  COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Var_Log_Erro := Substr('Erro ao gerar Aprovisionando para movimento contabil. Competência:' ||
													 Intrcompetencia || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,
																	 Var_Irotna,
																	 Pc_Util_01.Var_Rotna_Pe);
		COMMIT;
		RAISE;
END Sgpb0077;
/

