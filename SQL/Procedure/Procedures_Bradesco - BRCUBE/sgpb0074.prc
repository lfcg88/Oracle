CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0074
(
	Curvrelat        OUT SYS_REFCURSOR,
	Intriniciocompet Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
	Intrfimcompet    Margm_Contb_Crrtr.Ccompt_Margm %TYPE
)
-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0074
	--      DATA            : 06/04/06 14:39:18
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : Procedure para buscar informações de pagamento de Extra Banco
	--      ALTERAÇÕES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
 IS
	Var_Crotna CONSTANT CHAR(8) := 'SGPB0074';
	Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
	Intcanal     Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE := Pc_Util_01.Extra_Banco;
BEGIN
	--
	OPEN Curvrelat FOR
	--
		SELECT MAX(Cr.Cund_Prod) AS Cund_Prod,
					 Up.Iund_Prod,
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
			JOIN Und_Prod Up ON Cr.Cund_Prod = Up.Cund_Prod
			JOIN Crrtr_Unfca_Cnpj Cu ON Cr.Ccpf_Cnpj_Base = Cu.Ccpf_Cnpj_Base
																	AND Cr.Ctpo_Pssoa = Cu.Ctpo_Pssoa
			JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cr.Ccrrtr
														AND Pc.Cund_Prod = Cr.Cund_Prod
														AND Pc.Ctpo_Comis = 'CN'
			JOIN Apurc_Prod_Crrtr Ap ON Pc.Ccrrtr = Ap.Ccrrtr
																	AND Pc.Cund_Prod = Ap.Cund_Prod
																	AND Pc.Cgrp_Ramo_Plano = Ap.Cgrp_Ramo_Plano
																	AND Pc.Ccompt_Prod = Ap.Ccompt_Prod
																	AND Ap.Ctpo_Comis = 'CN'
			JOIN Grp_Ramo_Plano Gr ON Ap.Cgrp_Ramo_Plano = Gr.Cgrp_Ramo_Plano
		 WHERE Ap.Ccanal_Vda_Segur = Intcanal
					 AND Ap.Csit_Apurc = 'PG'
					 AND Ap.Ccompt_Apurc BETWEEN Intriniciocompet AND Intrfimcompet
		 GROUP BY Up.Iund_Prod,
							Cu.Iatual_Crrtr,
							Gr.Igrp_Ramo_Plano,
							Ap.Ctpo_Apurc
		 ORDER BY Up.Iund_Prod,
							Cu.Iatual_Crrtr,
							Gr.Igrp_Ramo_Plano;
	--
	PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
															'Execução correta ao trazer as informações de pagamentodo Canal Extra Banco.',
															Pc_Util_01.Var_Log_Processo,
															NULL,
															NULL);
EXCEPTION
	WHEN OTHERS THEN
		Var_Log_Erro := Substr('Erro ao trazer as informações de pagamentodo Canal Extra Banco. Competência:' ||
													 Intriniciocompet || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		RAISE;
END Sgpb0074;
/

