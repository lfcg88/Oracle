CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0202_teste IS
  -------------------------------------------------------------------------------------------------------------------
  --      Bradesco Seguros s.a.
  --      procedure       : SGPB0202
  --      data            : 23/08/2007
  --      autor           : WASSILY CHUK SEIBLITZ GUANAES
  --      objetivo        : Realiza Consulta, Insert, Delete e Update na PARM_CALC_FAIXA_OBJTV_PROD
  --                        p_operacao = 'C' => FAZ CONSULTA E RETORNA O CURSOR.
  --                        p_operacao = 'U' => Deleta toda as Faixas para o CANAL e o GRUPO e insere o CURSOR passado
  --                        p_status_retorno = 'E' => ERRO (Vide mensagem de erro em p_msg_retorno).
  --						p_status_retorno = null => OK
  ---------------------------------------------------------------------------------------------------------------------
  VAR_FLAG	INTEGER := 0;
  reg_faixa PARM_CALC_FAIXA_OBJTV_PROD%ROWTYPE;
  CURSOR P_Cursor_Faixa IS SELECT * FROM PARM_CALC_FAIXA_OBJTV_PROD
                        			where CCANAL_VDA_SEGUR = 1 and
                              			  CGRP_RAMO_PLANO = 120;
  p_msg_retorno 		VARCHAR2(1000);
  p_status_retorno      VARCHAR2(1000);
  P_Cursor_Faixa_REF    SYS_REFCURSOR;
  --PARM_CALC_FAIXA_OBJTV_PROD%ROWTYPE; 
BEGIN
  OPEN P_Cursor_Faixa;
  --P_Cursor_Faixa_REF := P_Cursor_Faixa;
  SGPB0202(1,120,P_Cursor_Faixa,'U',p_msg_retorno,p_status_retorno);
  commit;
END SGPB0202_teste;
/

