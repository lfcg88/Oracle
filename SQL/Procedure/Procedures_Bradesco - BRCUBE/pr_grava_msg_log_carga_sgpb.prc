CREATE OR REPLACE PROCEDURE SGPB_PROC.Pr_Grava_Msg_Log_Carga_SGPB
(
  Var_Crotna       IN varchar2,
  Var_Log          IN VARCHAR2,
  Var_Log_Processo IN varchar2,
  Var_Linha        IN NUMBER := 0,
  Var_Chave_Oltp   IN VARCHAR2
) IS
BEGIN
  BEGIN
    IF PC_UTIL_01.AMBIENTE = PC_UTIL_01.PRODUCAO THEN
	    Pr_Grava_Msg_Log_Carga(Var_Crotna,
	                           Var_Log,
	                           Var_Log_Processo,
	                           Var_Linha,
	                           Var_Chave_Oltp);
    END IF;

    pc_util_01.Sgpb0028(SUBSTR(Var_Log,1,1999), Var_Crotna );

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
END Pr_Grava_Msg_Log_Carga_SGPB;
/

