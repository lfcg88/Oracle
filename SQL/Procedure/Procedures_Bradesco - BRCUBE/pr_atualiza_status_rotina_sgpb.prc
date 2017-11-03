CREATE OR REPLACE PROCEDURE SGPB_PROC.Pr_Atualiza_Status_Rotina_SGPB
(
	Param1 IN varCHAR2,
	Param2 IN NUMBER,
	Param3 IN varchar2
) IS
BEGIN
  BEGIN

    IF PC_UTIL_01.AMBIENTE = PC_UTIL_01.PRODUCAO THEN
      Pr_Atualiza_Status_Rotina(Param1, Param2, Param3);
    END IF;

    pc_util_01.Sgpb0028(Param3,Param1);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

	--
END Pr_Atualiza_Status_Rotina_SGPB;
/

