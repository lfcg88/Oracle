CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0011
(
	Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
	Intrcanal       Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
	Intrtpapurc     Tpo_Apurc.Ctpo_Apurc %TYPE,
	Intrgpramo      Grp_Ramo_Plano.Cgrp_Ramo_Plano %TYPE
)
-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0011
	--      DATA            : 8/3/2006 16:26:37
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : Procedure para deletar corretores da tabela temporaria que não apresentem produção mínima nos canais Banco e Finasa em Automóveis ou Bilhete
	--      ALTERAÇÕES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
 IS
	Intinicialfaixa   Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
	Intfinalfaixa     Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
	Intqtmesanlse     Parm_Per_Apurc_Canal. Qmes_Anlse %TYPE;
	Intqtdmin         Parm_Prod_Min_Crrtr . Qitem_Min_Prod_Crrtr %TYPE;
	Intmesinicioanali Prod_Crrtr.Ccompt_Prod %TYPE := Intrcompetencia;
	Dblvalmin         Parm_Prod_Min_Crrtr . Vmin_Prod_Crrtr %TYPE;
	Var_Log_Erro      Pc_Util_01.Var_Log_Erro %TYPE;
	Var_Crotna        VARCHAR2(8) := 'SGPB0011';
BEGIN
	Pc_Util_01.Sgpb0003(Intinicialfaixa,
											Intfinalfaixa,
											Intrcanal,
											Intrcompetencia);
	Pc_Util_01.Sgpb0004(Dblvalmin,
											Intqtdmin,
											Intrcanal,
											Intrcompetencia,
											Intrgpramo,
											Pc_Util_01.Mensal,
											NULL);
	Pc_Util_01.Sgpb0005(Intqtmesanlse,
											Intrcanal,
											Intrcompetencia,
											Intrtpapurc);
	IF Intqtmesanlse > 1
	THEN
		Intmesinicioanali := Pc_Util_01.Sgpb0017(Intrcompetencia,
																						 Intqtmesanlse);
	END IF;
	UPDATE Crrtr Cr
		 SET Cr.Cind_Crrtr_Selec = 0
	 WHERE Cr.Cind_Crrtr_Selec = 1
				 AND (Ccrrtr, Cund_Prod) NOT IN
				 (SELECT Cori.Ccrrtr,
										 Cori.Cund_Prod
								FROM Crrtr Cori
								JOIN Ag_Bcria Ab ON Ab.Cag_Bcria = Cori.Cag_Bcria
								JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = Cori.Ccrrtr
																			AND Pc.Cund_Prod = Cori.Cund_Prod
																			AND Pc.Cgrp_Ramo_Plano = Intrgpramo
																			AND Pc.Ctpo_Comis = 'CN'
								LEFT JOIN Meta_Ag Ma ON Ma.Cag_Bcria = Ab.Cag_Bcria
																				AND Ma.Ccompt_Meta = Pc.Ccompt_Prod
																				AND Ma.Cgrp_Ramo_Plano =
																				Pc.Cgrp_Ramo_Plano
							 WHERE Cori.Cind_Crrtr_Selec = 1
										 AND Pc.Ccompt_Prod BETWEEN Intmesinicioanali AND
										 Intrcompetencia
										 AND ((
										 -- Se o itens parametrizavel for 0
										 -- ou se o itens de meta de uma agencia for 0
										 -- não avaliar por esse metodo colocando FALSO
											(Nvl(Ma.Qmin_Item_Apolc,
																Intqtdmin) > 0) AND
										 -- Se ele for avaliado
										 -- seu itens de produção deve ser maior que o valor de meta
										 -- ou parametrizado(se a agência for nova)
											((Pc.Qtot_Item_Prod >
											Nvl(Ma.Qmin_Item_Apolc,
																 Intqtdmin)) AND (Pc.Vprod_Crrtr > 0)))
										 -- Ou ele bate quantidade de itens ou valor total de itens
										 OR (
										 -- Se o valor parametrizavel for 0
										 -- ou se o valor de meta de uma agencia for 0
										 -- não avaliar por esse metodo colocando FALSO
											(Nvl(Ma.Vmeta_Ag,
																	 Dblvalmin) > 0) AND
										 -- Se ele for avaliado
										 -- seu valor de produção deve ser maior que o valor de meta
										 -- ou parametrizado(se a agência for nova)
											(Pc.Vprod_Crrtr >
											Nvl(Ma.Vmeta_Ag,
																	 Dblvalmin))))
							 GROUP BY Cori.Ccrrtr,
												Cori.Cund_Prod
							HAVING COUNT(*) = Intqtmesanlse);
	--
EXCEPTION
	WHEN No_Data_Found THEN
		Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
													 Intrcompetencia || ' canal: ' || Intrcanal ||
													 ' Ramo: ' || Intrgpramo || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		RAISE;
	WHEN Too_Many_Rows THEN
		Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
													 Intrcompetencia || ' canal: ' || Intrcanal ||
													 ' Ramo: ' || Intrgpramo || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		RAISE;
	WHEN OTHERS THEN
		Var_Log_Erro := Substr('Erro ao retirar corretores que não apresentem produção.Competência:' ||
													 Intrcompetencia || ' Ramo: ' || Intrgpramo ||
													 ' canal: ' || Intrcanal || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		RAISE;
END Sgpb0011;
/

