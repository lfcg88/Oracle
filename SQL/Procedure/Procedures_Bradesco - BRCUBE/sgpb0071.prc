CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0071
(
	Intrcompetencia       Prod_Crrtr.Ccompt_Prod %TYPE,
	Intcodcanal_Vda_Segur Parm_Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
  Strnomecorretor       crrtr_unfca_cnpj.iatual_crrtr %type,
	c_Apuracoes           OUT SYS_REFCURSOR
)
-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0071
	--      DATA            : 10/3/2006
	--      AUTOR           : VICTOR H. BILOURO - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      OBJETIVO        : PROCEDURE PARA REALIZAR A LIBERAÇÃO AUTOMATICA DE APURAÇÕES QUE ULTRAPASSEM O MINIMO PARA TAL
	--      ALTERAÇÕES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
 IS
	/*CONTROLE DE PROCEDURE*/
	Var_Log_Erro VARCHAR2(1000);
	Chrlocalerro VARCHAR2(10) := '00';
	--
	Intqmes_Perdc_Pgto Parm_Per_Apurc_Canal.Qmes_Perdc_Pgto%TYPE;
	Intvmin_Librc_Pgto Parm_Canal_Vda_Segur.Vmin_Librc_Pgto%TYPE;
	--
	Intcomptemp Prod_Crrtr.Ccompt_Prod %TYPE;
BEGIN
	--
	--
	Chrlocalerro := 01;
	Chrlocalerro := 02;
	Chrlocalerro := 04;
	-- ZERA A TABELA TEMPORÁRIA
	UPDATE Apurc_Prod_Crrtr SET Cind_Apurc_Selec = 0 WHERE Cind_Apurc_Selec = 1;
	COMMIT;
	Chrlocalerro := 05;
	--  BUSCA DE QUANTO EM QUANTO TEMPO PAGA-SE PARA O CANAL
	SELECT Qmes_Perdc_Pgto
		INTO Intqmes_Perdc_Pgto
		FROM Parm_Per_Apurc_Canal Ppac
	 WHERE Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
				 AND Ppac.Ctpo_Apurc = Pc_Util_01.Normal
				 AND Sgpb0016(Intrcompetencia) BETWEEN Ppac.Dinic_Vgcia_Parm AND
				 Nvl(Ppac.Dfim_Vgcia_Parm,
						 To_Date('99991231',
										 'YYYYMMDD'));
	--
	Chrlocalerro := 06;
	--  BUSCA O MINIMO PARA LIBERAR O PAGAMENTO PARA O CANAL
	SELECT Pcvs.Vmin_Librc_Pgto
		INTO Intvmin_Librc_Pgto
		FROM Parm_Canal_Vda_Segur Pcvs
	 WHERE Pcvs.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
				 AND Sgpb0016(Intrcompetencia) BETWEEN Pcvs.Dinic_Vgcia_Parm AND
				 Nvl(Pcvs.Dfim_Vgcia_Parm,
						 To_Date('99991231',
										 'YYYYMMDD'));
	--
	Chrlocalerro := 07;
	--
	Intcomptemp := Pc_Util_01.Sgpb0017(Intrcompetencia,
																		 Intqmes_Perdc_Pgto - 1); --OLHANDO PARA TRÁS
	--
	Chrlocalerro := 08;
	--
	--INSERE NA TEMPORARIA TODOS OS REGISTROS SELECIONADOS PARA TRABALHO
	UPDATE Apurc_Prod_Crrtr
		 SET Cind_Apurc_Selec = 1
	 WHERE (Ccanal_Vda_Segur, --
					Ctpo_Apurc, --
					Ccompt_Apurc, --
					Cgrp_Ramo_Plano, --
					Ccompt_Prod, --
					Ctpo_Comis, --
					Ccrrtr, --
					Cund_Prod --
				 ) --
				 IN --
				 ( --
					SELECT Apc.Ccanal_Vda_Segur,
									Apc.Ctpo_Apurc,
									Apc.Ccompt_Apurc,
									Apc.Cgrp_Ramo_Plano,
									Apc.Ccompt_Prod,
									Apc.Ctpo_Comis,
									Apc.Ccrrtr,
									Apc.Cund_Prod
						FROM Apurc_Prod_Crrtr Apc

            JOIN CRRTR C
              ON C.CCRRTR = APC.CCRRTR
             AND C.CUND_PROD = APC.CUND_PROD

            JOIN CRRTR_UNFCA_CNPJ CUC
              ON CUC.CTPO_PSSOA = C.CTPO_PSSOA
             AND CUC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
             AND ((Strnomecorretor IS NULL) OR (cuc.iatual_crrtr LIKE '%' || Strnomecorretor || '%'))

					 WHERE Apc.Ccompt_Apurc BETWEEN Intcomptemp AND Intrcompetencia
								 AND Apc.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
								 AND Apc.Csit_Apurc IN ('AP', 'BG', 'LM', 'LG', 'PR', 'PL', 'LP')
								 AND NOT EXISTS (SELECT 1
										FROM Papel_Apurc_Pgto Pap
									 WHERE Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
												 AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
												 AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
												 AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
												 AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
												 AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
												 AND Pap.Ccrrtr = Apc.Ccrrtr
												 AND Pap.Cund_Prod = Apc.Cund_Prod
												 AND Pap.Cindcd_Papel = 1 /*ELEICAO*/
									));
	COMMIT;
	--
	Chrlocalerro := 9.1;
	-- INSERE REGISTROS QUE JÁ ESTEJAM LIBERADOS PARA PAGAMENTO POREM ABAIXO DO MINIMO.
	-- INSERE REGISTROS QUE JÁ ESTEJAM LIBERADOS PARA PAGAMENTO POREM ABAIXO DO MINIMO.
	UPDATE Apurc_Prod_Crrtr
		 SET Cind_Apurc_Selec = 1
	 WHERE Cind_Apurc_Selec = 0
				 AND ( --
					Ccanal_Vda_Segur, --
					Ctpo_Apurc, --
					Ccompt_Apurc, --
					Cgrp_Ramo_Plano, --
					Ccompt_Prod, --
					Ctpo_Comis, --
					Ccrrtr, Cund_Prod --
				 ) --
				 IN --
				 ( --
							SELECT Apc.Ccanal_Vda_Segur,
											Apc.Ctpo_Apurc,
											Apc.Ccompt_Apurc,
											Apc.Cgrp_Ramo_Plano,
											Apc.Ccompt_Prod,
											Apc.Ctpo_Comis,
											Apc.Ccrrtr,
											Apc.Cund_Prod
								FROM Apurc_Prod_Crrtr Apc
							 WHERE Apc.Ccompt_Apurc < Intcomptemp
										 AND Apc.Csit_Apurc IN ('LM', 'BG', 'LP') --APENAS LIBERADO MAS MENOR Q O MINIMO
										--             AND APC.CTPO_APURC = TIPO
										 AND Apc.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
										 AND NOT EXISTS (SELECT 1
												FROM Papel_Apurc_Pgto Pap
											 WHERE Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
														 AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
														 AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
														 AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
														 AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
														 AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
														 AND Pap.Ccrrtr = Apc.Ccrrtr
														 AND Pap.Cund_Prod = Apc.Cund_Prod
														 AND Pap.Cindcd_Papel = 1) /*ELEICAO*/ --
							);
	COMMIT;
	--
	--
	Chrlocalerro := 10;
	--
	OPEN c_Apuracoes FOR
		SELECT Cuc.Ccpf_Cnpj_Base,
					 Cuc.Ctpo_Pssoa,
					 Cuc.Iatual_Crrtr,
					 Apc.Ccompt_Apurc,
					 Apc.Ccanal_Vda_Segur,
					 Apc.Cgrp_Ramo_Plano,
					 Apc.Ccompt_Prod,
					 Apc.Ctpo_Comis,
					 Apc.Csit_Apurc,
					 Apc.Ctpo_Apurc,
					 Apc.Ccrrtr,
					 Apc.Cund_Prod,
					 Apc.Pbonus_Apurc,
					 Pc.Vprod_Crrtr,
					 Pc.Qtot_Item_Prod,
					 CASE
						 WHEN Apc.Ccompt_Apurc BETWEEN Intcomptemp AND Intrcompetencia THEN
							'FALSE'
						 ELSE
							'TRUE'
					 END AS Retido,
					 Ssapc.Ultrapassaminimo,
					 Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100) Valorindividual,
					 Ssapc.Total
		--
		--
			FROM Apurc_Prod_Crrtr Apc
		--
		--
			JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
											AND c.Cund_Prod = Apc.Cund_Prod
		--
		--
			JOIN ( --
						SELECT c.Ccpf_Cnpj_Base,
										c.Ctpo_Pssoa,
										CASE
											WHEN SUM(Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)) >= Intvmin_Librc_Pgto THEN
											 'TRUE'
											ELSE
											 'FALSE'
										END AS Ultrapassaminimo,
										SUM(Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)) Total
						--
						--
							FROM Apurc_Prod_Crrtr Apc
							JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
															AND c.Cund_Prod = Apc.Cund_Prod
							JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
																		AND Pc.Cund_Prod = Apc.Cund_Prod
																		AND Pc.Ccrrtr = Apc.Ccrrtr
																		AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
																		AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
							LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
																								AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
																								AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
																								AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
																								AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
																								AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
																								AND Pap.Ccrrtr = Apc.Ccrrtr
																								AND Pap.Cund_Prod = Apc.Cund_Prod
																								AND Pap.Cindcd_Papel = 0
						 WHERE Apc.Cind_Apurc_Selec = 1
									 AND Pap.Ccrrtr IS NULL /* SÓ SOMA NO TOTAL E ALTERA SITUACAO DE QUEM NÃO FOI PAGO AINDA*/
						 GROUP BY c.Ccpf_Cnpj_Base,
											 c.Ctpo_Pssoa
						--
						) Ssapc ON Ssapc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
											 AND Ssapc.Ctpo_Pssoa = c.Ctpo_Pssoa
		--
		--
			JOIN Crrtr_Unfca_Cnpj Cuc ON Cuc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
																	 AND Cuc.Ctpo_Pssoa = c.Ctpo_Pssoa
		--
		--
			JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
														AND Pc.Cund_Prod = Apc.Cund_Prod
														AND Pc.Ccrrtr = Apc.Ccrrtr
														AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
														AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
		--
		--
			LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
																				AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
																				AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
																				AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
																				AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
																				AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
																				AND Pap.Ccrrtr = Apc.Ccrrtr
																				AND Pap.Cund_Prod = Apc.Cund_Prod
																				AND Pap.Cindcd_Papel = 0
		--
		--
		 WHERE Apc.Cind_Apurc_Selec = 1
					 AND Pap.Ccrrtr IS NULL /* SÓ SOMA NO TOTAL E ALTERA SITUACAO DE QUEM NÃO FOI PAGO AINDA*/
		--
		--
		 ORDER BY Ssapc.Ultrapassaminimo DESC,
							Cuc.Iatual_Crrtr       ASC,
							Apc.Ccompt_Apurc       DESC;
	COMMIT;
	--
	--
EXCEPTION
	WHEN OTHERS THEN
		--
		--
		ROLLBACK;
		--
		Var_Log_Erro := Substr('COD.ERRO: ' || Chrlocalerro || ' COMPET: ' || To_Char(Intrcompetencia) ||
													 ' CANAL: ' || To_Char(Intcodcanal_Vda_Segur) || ' # ' || SQLERRM,
													 1,
													 Pc_Util_01.Var_Tam_Msg_Erro);
		--
		--    DBMS_OUTPUT.PUT_LINE(VAR_LOG_ERRO);
		PR_GRAVA_MSG_LOG_CARGA('SGPB0071',
																Var_Log_Erro,
																Pc_Util_01.Var_Log_Processo,
																NULL,
																NULL);
		--
		--
		PR_ATUALIZA_STATUS_ROTINA('SGPB0071',
																	 708,
																	 Pc_Util_01.Var_Rotna_Pe);
		--
END Sgpb0071;
/

