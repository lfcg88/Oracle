CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0070
(
	Curvrelat        OUT SYS_REFCURSOR,
	Intriniciocompet Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
	Intrfimcompet    Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
	Intrcanal        Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE
)
-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0070
	--      DATA            : 04/04/06 16:02:50
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : Procedure para buscar informações de pagamento de Banco e Finasa
	--      ALTERAÇÕES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
 IS
	Var_Crotna CONSTANT CHAR(8) := 'SGPB0070';
	Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
BEGIN
	OPEN Curvrelat FOR
	--
		SELECT MAX(Cr.Cund_Prod) AS Cund_Prod,
					 Up.Iund_Prod,
					 MAX(Ag.Cag_Bcria) AS Cod_Agencia,
					 Ag.Iag_Bcria,
					 MAX(Cu.Ccpf_Cnpj_Base) AS Cod_Corretor,
					 MAX(Cu.Ctpo_Pssoa) AS Tipo_Pessoa,
					 Cu.Iatual_Crrtr,
					 MAX(Gr.Cgrp_Ramo_Plano) AS Ramo,
					 Decode(Ap.Ctpo_Apurc,
									1,
									'Normal',
									'Extra') Igrp_Ramo_Plano,
					 SUM((Ap.Pbonus_Apurc * Pc.Vprod_Crrtr) / 100) AS Valor
			FROM Crrtr Cr
			JOIN Parm_Canal_Vda_Segur Pv ON Cr.Ccrrtr BETWEEN Pv.Cinic_Faixa_Crrtr AND
																			Pv.Cfnal_Faixa_Crrtr
			JOIN Und_Prod Up ON Cr.Cund_Prod = Up.Cund_Prod
			JOIN Ag_Bcria Ag ON Cr.Cbco = Ag.Cbco
													AND Cr.Cag_Bcria = Ag.Cag_Bcria
			JOIN Crrtr_Unfca_Cnpj Cu ON Cr.Ccpf_Cnpj_Base = Cu.Ccpf_Cnpj_Base
																	AND Cr.Ctpo_Pssoa = Cu.Ctpo_Pssoa
			JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
														AND Pc.Cund_Prod = Cr.Cund_Prod
			JOIN Apurc_Prod_Crrtr Ap ON Pc.Ccrrtr = Ap.Ccrrtr
																	AND Pc.Cund_Prod = Ap.Cund_Prod
																	AND Pc.Cgrp_Ramo_Plano = Ap.Cgrp_Ramo_Plano
																	AND Pc.Ccompt_Prod = Ap.Ccompt_Prod
																	AND Pc.Ccompt_Prod = Ap.Ccompt_Apurc
			JOIN Grp_Ramo_Plano Gr ON Ap.Cgrp_Ramo_Plano = Gr.Cgrp_Ramo_Plano
		 WHERE Pv.Ccanal_Vda_Segur = Intrcanal
					 AND Ap.Ccanal_Vda_Segur = Intrcanal
					 AND Pc.Ctpo_Comis = 'CN'
					 AND Ap.Ctpo_Comis = 'CN'
					 AND Ap.Csit_Apurc = 'PG'
					 AND Ap.Ccompt_Apurc BETWEEN Intriniciocompet AND Intrfimcompet
		 GROUP BY Up.Iund_Prod,
							Ag.Iag_Bcria,
							Cu.Iatual_Crrtr,
							Gr.Igrp_Ramo_Plano,
							Ap.Ctpo_Apurc
		 ORDER BY Up.Iund_Prod,
							Ag.Iag_Bcria,
							Cu.Iatual_Crrtr,
							Gr.Igrp_Ramo_Plano;
	--
	PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
															'Execução correta ao gerar massa de dados para o relatório.',
															Pc_Util_01.Var_Log_Processo,
															NULL,
															NULL);
EXCEPTION
	WHEN OTHERS THEN
		Var_Log_Erro := Substr('Erro ao gerar massa de dados para o relatório. Competência:' ||
													 Intrfimcompet || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		RAISE;
END Sgpb0070;
/

