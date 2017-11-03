CREATE OR REPLACE FUNCTION SGPB_PROC.Sgpb0016(Intvvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE) RETURN DATE AS
	-------------------------------------------------------------------------------------------------
	--      BRADESCO SEGUROS S.A.
	--      PROCEDURE       : SGPB0016
	--      DATA            : 7/3/2006 09:03:55
	--      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
	--      PROGRAMA        : PC_UTIL_01.SQL
	--      OBJETIVO        : Fun��o que converte uma compet�ncia para a ultima data do m�s de competencia
	--      ALTERA��ES      :
	--                DATA  : -
	--                AUTOR : -
	--                OBS   : -
	-------------------------------------------------------------------------------------------------
		Retorno    DATE;
		Var_Crotna VARCHAR2(8) := 'SGPB0016';
    Var_Log_Erro varchar2(2000);
	BEGIN
		Retorno := Last_Day(To_Date(Intvvigencia,'YYYYMM'));
		RETURN Retorno;
	EXCEPTION
		WHEN OTHERS THEN
			Var_Log_Erro := Substr('Erro ao converter competencia em data no �ltimo dia.Compet�ncia:' || Intvvigencia || ' # ' || SQLERRM,
														 1,Pc_Util_01.Var_Tam_Msg_Erro);
			PR_GRAVA_MSG_LOG_CARGA_SGPB(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
	END Sgpb0016;
/

