CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6601
( P_CCAMPA_DSTAQ  IN NUMBER
, P_CVALOR IN NUMBER
, P_CUSUARIO  IN VARCHAR2
, P_CCODIGO IN NUMBER
, COD_RETORNO  OUT VARCHAR2
, COD_MENSAGEM  OUT VARCHAR2
) AS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB6601
--      DATA            : 14/03/2008
--      AUTOR           : THIAGO PELLEGRINO - JAPI
--      OBJETIVO        : MANUTENÇÃO DA PRODUÇÃO E META MINIMA DOS CORRETORE
--                        CAMPANHA DESTAQUE DE PRODUÇÃO
--      ALTERAÇÕES      : 
--                DATA  :
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
V_CIND_CAMPA_ATIVO CHAR(1) := '';
V_ICAMPA_DSTAQ     VARCHAR2(50) := '';
VAR_ROTINA		     VARCHAR2(10) := 'SGPB6601';
BEGIN

  BEGIN
  
    COD_RETORNO := '0';
    COD_MENSAGEM := 'Atualização efetuada com sucesso!!!';
  
    --
    --VALIDANDO CAMPOS DE ENTRADA
    IF P_CCAMPA_DSTAQ  IS NULL THEN
        COD_RETORNO  := 1;
    ELSIF P_CVALOR IS NULL THEN
        COD_RETORNO  := 1;
    ELSIF P_CUSUARIO IS NULL THEN
        COD_RETORNO  := 1;
    END IF;

    IF COD_RETORNO = 1 THEN
       COD_MENSAGEM := 'Campos de entrada são obrigatórios';
    ELSE
       COD_RETORNO := 0;
    END IF;
  
    --
    --VALIDANDO SE A CAMPANHA ESTA ATIVA
    SELECT CIND_CAMPA_ATIVO ,ICAMPA_DSTAQ
      INTO V_CIND_CAMPA_ATIVO,V_ICAMPA_DSTAQ
      FROM CAMPA_DSTAQ
     WHERE CCAMPA_DSTAQ = P_CCAMPA_DSTAQ;
  
      IF V_CIND_CAMPA_ATIVO <> 'S' THEN
         COD_RETORNO := 1;
         COD_MENSAGEM := 'Campanha ' || V_ICAMPA_DSTAQ || ' já encerrada.';
      ELSE
          UPDATE CAMPA_PARM_CARGA_DSTAQ
             SET CCONTD_PARM_CARGA = P_CVALOR,
                 IROTNA_ATULZ_PARM_CARGA = to_char(P_CUSUARIO),
                 DALT_REG = SYSDATE
           WHERE CCAMPA_DSTAQ = P_CCAMPA_DSTAQ 
             AND CPARM_CARGA_DSTAQ = P_CCODIGO;

             COMMIT;
      END IF;
    
   EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-99971,'PL ERRO MANUTENCAO PRODUCAO MINIMA' || SUBSTR(SQLERRM,1,100));
           ROLLBACK;
           PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||SUBSTR(SQLERRM,1,500),'P',NULL,NULL);
           COMMIT;
   END;

END;
/

