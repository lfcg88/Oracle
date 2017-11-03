CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6035 (
PAR_CCUPOM_PROML_DSTAQ_INI IN NUMBER,
PAR_CCUPOM_PROML_DSTAQ_FIM IN NUMBER,
PAR_REGIONAL               IN NUMBER,
PAR_COD_RETORNO            OUT VARCHAR2,
PAR_DSC_MENSAGEM           OUT VARCHAR2
) IS

-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 07/11/2007
--      AUTOR           : ALEXANDRE CYSNE ESTEVES
--      PROGRAMA        : SGPB6035
--      OBJETIVO        : Procedure utilizada para entrega das raspadinhas por regional
--                        onde a carga inicial foi feito todo em uma determinada regional
--                        e com esse procedimento a gestora estara direcionando as raspadinhas
--                        para outras regionais
--
--      ALTERA��ES      :
--                DATA  :
--                AUTOR :
--                OBS   :
--------------------------------------------------------------------------------------------------

   VAR_IND_CAMPA_ATIVO          CAMPA_DSTAQ.CIND_CAMPA_ATIVO%TYPE;
   VAR_ICAMPA_DSTAQ             CAMPA_DSTAQ.ICAMPA_DSTAQ%TYPE;
   VAR_DFIM_CAMPA_DSTAQ         CAMPA_DSTAQ.DFIM_CAMPA_DSTAQ%TYPE;
   VAR_CCAMPA_DSTAQ             CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE := 1;
   VAR_QTD_CUPOM                NUMBER;
   VAR_RANGE                    NUMBER(10) := 10000;
   ERRO_GERAL                   EXCEPTION;

BEGIN
   --------------------------- VALIDA PAR�METROS DE ENTRADA --------------------------------------------
   -----------------------------------------------------------------------------------------------------   
   IF PAR_REGIONAL IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'C�digo da regional � obrigat�rio';
      RETURN;
   --
   ELSIF PAR_CCUPOM_PROML_DSTAQ_INI IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'C�digo do cupom promocional inicial � obrigat�rio';
      RETURN;
   --
   ELSIF PAR_CCUPOM_PROML_DSTAQ_FIM IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'C�digo do cupom promocional final � obrigat�rio';
      RETURN;
   --
   ELSIF (PAR_CCUPOM_PROML_DSTAQ_FIM - PAR_CCUPOM_PROML_DSTAQ_INI) > VAR_RANGE THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Intervalo acima do valor m�ximo permitido de 10000 ';
      RETURN;
   --
   END IF;
   ----------------------- VERIFICA SE CAMPANHA EM CONDI��ES DE PROCESSAMENTO --------------------------
   -----------------------------------------------------------------------------------------------------
   BEGIN
     SELECT CD.CIND_CAMPA_ATIVO,
            CD.ICAMPA_DSTAQ,
            CD.DFIM_CAMPA_DSTAQ
       INTO VAR_IND_CAMPA_ATIVO,
            VAR_ICAMPA_DSTAQ,
            VAR_DFIM_CAMPA_DSTAQ
       FROM CAMPA_DSTAQ CD
      WHERE CD.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         PAR_COD_RETORNO  := SQLCODE;
         PAR_DSC_MENSAGEM := 'SGPB6035 - ERRO AO RECUPERAR INDICATIVO DE CAMPANHA ATIVA. '||SQLERRM;
         RETURN;
   END;
   --

   IF VAR_IND_CAMPA_ATIVO <> 'S' THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Campanha '||VAR_ICAMPA_DSTAQ||' n�o est� ATIVA! Favor reativar a campanha para efetuar as retiradas.';
      RETURN;
   END IF;
   --
   ----------------------------- VERIFICA SE EXISTE RASPADINHAS ----------------------------------------
   -----------------------------------------------------------------------------------------------------
   BEGIN

    SELECT COUNT(*)
       INTO VAR_QTD_CUPOM
       FROM ESTOQ_CUPOM_PROML_DSTAQ EC 
      WHERE EC.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
        AND EC.CCUPOM_PROML_DSTAQ BETWEEN PAR_CCUPOM_PROML_DSTAQ_INI AND PAR_CCUPOM_PROML_DSTAQ_FIM
        AND ( EC.CCPF_CNPJ_BASE IS NOT NULL OR EC.CTPO_PSSOA IS NOT NULL );

     EXCEPTION
       WHEN OTHERS THEN
         PAR_COD_RETORNO  := 1;
         PAR_DSC_MENSAGEM := 'J� existe cupom retirado no range informado.';
         RETURN;
   END;
   --

   IF VAR_QTD_CUPOM > 0 then
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Campanha '||VAR_ICAMPA_DSTAQ||' j� possui um ou mais cupons resgatado para o intervalo informado de '||
                          PAR_CCUPOM_PROML_DSTAQ_INI|| ' at� '|| PAR_CCUPOM_PROML_DSTAQ_FIM||'.';
      RETURN;
   END IF;
   ------------------------- ATUALIZA A RASPADINHA PARA CADA N�MERO INFORMADO NO INTERVALO -------------
   -----------------------------------------------------------------------------------------------------
    BEGIN                     
       UPDATE ESTOQ_CUPOM_PROML_DSTAQ EC 
          SET EC.CRGNAL = PAR_REGIONAL, 
              EC.DALT_REG = SYSDATE
        WHERE EC.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
          AND EC.CCUPOM_PROML_DSTAQ BETWEEN PAR_CCUPOM_PROML_DSTAQ_INI AND PAR_CCUPOM_PROML_DSTAQ_FIM;
        
        --VALIDANDO SE EXISTE RASPADINHA PARA O UPDATE        
        IF (SQL%ROWCOUNT = 0) THEN
           PAR_COD_RETORNO  := 1;
           PAR_DSC_MENSAGEM := 'N�o existe raspadinha para este range.';
           RETURN;
        END IF;

       EXCEPTION
          WHEN OTHERS THEN
             PAR_COD_RETORNO  := SQLCODE;
             PAR_DSC_MENSAGEM := 'SGPB6035 - ERRO AO ALTERAR NA TABELA ESTOQ_CUPOM_PROML_DSTAQ. '||SQLERRM;
             RETURN;
    END;

   COMMIT;
   PAR_COD_RETORNO := 0;

   EXCEPTION
     WHEN OTHERS THEN
       PAR_COD_RETORNO  := SQLCODE;
       PAR_DSC_MENSAGEM := 'ERRO AO EXECUTAR A PROCEDURE SGPB6035. '||SQLERRM;

END SGPB6035;
/

