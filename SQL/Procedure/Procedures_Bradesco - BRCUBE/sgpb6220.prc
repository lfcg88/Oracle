CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6220 (PAR_ENTRADA          IN NUMBER ,
							  PAR_CDIR_RGNAL_SEGDR OUT NUMBER,
							  PAR_COD_ERRO         OUT NUMBER,
							  PAR_DESC_ERRO        OUT VARCHAR2) IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 12/10/2007
--      AUTOR           : EMMANUEL SILVA - VALUE TEAM SISTEMAS LTDA
--      PROGRAMA        : PR_RET_RGNAL_DSTAQ
--      OBJETIVO        : Retorna a regional a partir de um código de sucursal, ou seja, dada uma
--                        sucursal de emissão, referentes as apólices do Auto/RE, retornar o código
--                        da diretoria regional.
--      ALTERAÇÕES      : Estava retornando o codigo DW da Regional, foi alterado para voltar o codigo "REAL".
--						  ass. wassily ( 17/11/2007 )
--------------------------------------------------------------------------------------------------
VAR_ORIGE_HIERQ_PROD   NUMBER(10)  := 2;
VAR_DSTNO_HIERQ_PROD   NUMBER(10)  := 19;
VAR_COD_DW_HIERQ_PROD  NUMBER(10);
BEGIN
   IF PAR_ENTRADA IS NULL THEN
      PAR_COD_ERRO  := 1;
      PAR_DESC_ERRO := 'CAMPO DE ENTRADA OBRIGATÓRIO';
      RETURN;
   END IF;
   BEGIN
     SELECT CHIERQ_PROD_DW
       		INTO VAR_COD_DW_HIERQ_PROD
       		FROM DPARA_HIERQ_PROD
      		WHERE CORIGE_DADO    =  VAR_ORIGE_HIERQ_PROD
        	AND CDMSAO_DSTNO     =  VAR_DSTNO_HIERQ_PROD
        	AND CUND_PROD        =  PAR_ENTRADA
        	AND CIND_ESTRT_ATUAL = 'A' ;
  EXCEPTION
       WHEN NO_DATA_FOUND THEN 
            PAR_CDIR_RGNAL_SEGDR := 4201;
            RETURN;
       WHEN OTHERS THEN
         PAR_COD_ERRO  := SQLCODE;
         PAR_DESC_ERRO := 'SGPB6220 - ERRO AO RECUPERAR A CHAVE DW NA TABELA DPARA_HIERQ_PROD. '||SQLERRM;
         RETURN;
  END;
  BEGIN
     SELECT dr.CCHAVE_DIR_RGNAL
       		INTO PAR_CDIR_RGNAL_SEGDR
       		FROM HIST_HIERQ_PROD_DW HH, DIR_RGNAL_SEGDR_DW DR
      		WHERE HH.CDIR_RGNAL_DW  = DR.CDIR_RGNAL_DW
        	AND HH.CHIERQ_PROD_DW = VAR_COD_DW_HIERQ_PROD;
      IF PAR_CDIR_RGNAL_SEGDR = 0 THEN
         PAR_CDIR_RGNAL_SEGDR := 4201;
         RETURN;
      END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN 
           PAR_CDIR_RGNAL_SEGDR := 4201;
           RETURN;
      WHEN OTHERS THEN
           PAR_COD_ERRO  := SQLCODE;
           PAR_DESC_ERRO := 'SGPB6220 - ERRO AO RECUPERAR O CÓDIGO DA DIRETORIA REGIONAL. '||SQLERRM;
           RETURN;
  END;
EXCEPTION
  WHEN OTHERS THEN
  	   PAR_COD_ERRO  := SQLCODE;
       PAR_DESC_ERRO := 'ERRO AO EXECUTAR A PROCEDURE SGPB6220. '||SQLERRM;
END SGPB6220;
/

