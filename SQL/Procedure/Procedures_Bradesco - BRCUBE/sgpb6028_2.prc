CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6028_2 (
PAR_CCAMPA_DSTAQ           IN NUMBER,
PAR_CCUPOM_PROML_DSTAQ_INI IN NUMBER,
PAR_CCUPOM_PROML_DSTAQ_FIM IN NUMBER,
PAR_NOME                   IN VARCHAR2,
PAR_SUCURSAL               IN NUMBER,
PAR_COD_RETORNO            OUT VARCHAR2,
PAR_DSC_MENSAGEM           OUT VARCHAR2
) IS

-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 12/10/2007
--      AUTOR           : EMMANUEL SILVA - VALUE TEAM SISTEMAS LTDA
--      PROGRAMA        : SGPB6028
--      OBJETIVO        : Esta procedure será utilizada pela intranet. Com o objetivo de verificar a
--                        disponibilidade das raspadinhas, ofertadas pelas sucursais e para o corretor,
--                        além de atualizar o saldo de raspadinhas para o mesmo.
--      ALTERAÇÕES      :
--                DATA  : 31/10/2007
--                AUTOR : ALEXANDRE CYSNE ESTEVES
--                OBS   : COMENTADO REGRA PARA FIM DA CAMPANHA QUE NAO SE APLICA NA DESTAQUE PLUS
--------------------------------------------------------------------------------------------------

   VAR_CRGNAL                   NUMBER;
   VAR_CCUPOM_PROML_DSTAQ_INI   NUMBER := PAR_CCUPOM_PROML_DSTAQ_INI;
   VAR_IND_CAMPA_ATIVO          CAMPA_DSTAQ.CIND_CAMPA_ATIVO%TYPE;
   VAR_ICAMPA_DSTAQ             CAMPA_DSTAQ.ICAMPA_DSTAQ%TYPE;
   VAR_DFIM_CAMPA_DSTAQ         CAMPA_DSTAQ.DFIM_CAMPA_DSTAQ%TYPE;
   VAR_CCAMPA_DSTAQ             CAMPA_DSTAQ.CCAMPA_DSTAQ%TYPE := 1;
   VAR_QTD_CUPOM                NUMBER;
   VAR_COD_ERRO                 NUMBER;
   VAR_DESC_ERRO                VARCHAR2(500);
   VAR_RANGE                    NUMBER(10) := 10000;
   ERRO_GERAL                   EXCEPTION;

BEGIN
   --------------------------- VALIDA PARÂMETROS DE ENTRADA --------------------------------------------
   -----------------------------------------------------------------------------------------------------
   IF PAR_CCAMPA_DSTAQ IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Código da campanha é obrigatório';
      RETURN;
   --
   ELSIF PAR_CCUPOM_PROML_DSTAQ_INI IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Código do cupom promocional inicial é obrigatório';
      RETURN;
   --
   ELSIF PAR_CCUPOM_PROML_DSTAQ_FIM IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Código do cupom promocional final é obrigatório';
      RETURN;
   --
   ELSIF PAR_NOME IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Nome do cupom promocional é obrigatório';
      RETURN;
   --
   ELSIF PAR_SUCURSAL IS NULL THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Código da sucursal é obrigatório';
      RETURN;
   --
   ELSIF (PAR_CCUPOM_PROML_DSTAQ_FIM - PAR_CCUPOM_PROML_DSTAQ_INI) > VAR_RANGE THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Intervalo acima do valor máximo permitido de 10000 ';
      RETURN;
   --
   END IF;
   ----------------------- VERIFICA SE CAMPANHA EM CONDIÇÕES DE PROCESSAMENTO --------------------------
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
         PAR_DSC_MENSAGEM := 'SGPB6028 - ERRO AO RECUPERAR INDICATIVO DE CAMPANHA ATIVA. '||SQLERRM;
         RETURN;
   END;
   --

   IF VAR_IND_CAMPA_ATIVO <> 'S' THEN
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Campanha '||VAR_ICAMPA_DSTAQ||' não está ATIVA! Favor reativar a campanha para efetuar as retiradas.';
      RETURN;
   END IF;
   --

   --NAO SE APLICA A CAMPANHA DESTAQUES PLUS
   --ALEXANDRE CYSNE 31/10/2007
   --IF VAR_DFIM_CAMPA_DSTAQ IS NOT NULL THEN
   --   PAR_COD_RETORNO  := 1;
   --   PAR_DSC_MENSAGEM := 'Campanha '||VAR_ICAMPA_DSTAQ||' já encerrada.';
   --   RETURN;
   --END IF;
   ----------------------------- VERIFICA SE EXISTE RASPADINHAS ----------------------------------------
   -----------------------------------------------------------------------------------------------------
   BEGIN

     SELECT COUNT(*)
       INTO VAR_QTD_CUPOM
       FROM ESTOQ_CUPOM_PROML_DSTAQ EC
      WHERE EC.CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ
        AND EC.CCUPOM_PROML_DSTAQ BETWEEN PAR_CCUPOM_PROML_DSTAQ_INI AND PAR_CCUPOM_PROML_DSTAQ_FIM;

     EXCEPTION

       WHEN NO_DATA_FOUND THEN
         NULL;

       WHEN OTHERS THEN
         PAR_COD_RETORNO  := SQLCODE;
         PAR_DSC_MENSAGEM := 'SGPB6028 - ERRO AO RECUPERAR QUANTIDADE DE CUPOM CADASTRADO PARA O INTERVALO. '||SQLERRM;

         RETURN;
   END;
   --

   IF VAR_QTD_CUPOM > 0 then
      PAR_COD_RETORNO  := 1;
      PAR_DSC_MENSAGEM := 'Campanha '||VAR_ICAMPA_DSTAQ||' já possui um ou mais cupons cadastrados para o intervalo informado de '||
                          PAR_CCUPOM_PROML_DSTAQ_INI|| ' até '|| PAR_CCUPOM_PROML_DSTAQ_FIM||'.';
      RETURN;
   END IF;
   ------------------------- INSERIR PARA CADA NÚMERO INFORMADO NO INTERVALO ---------------------------
   -----------------------------------------------------------------------------------------------------

   --Dada uma sucursal de emissão, referentes as apólices do Auto/RE, retornar o código
   SGPB6220( PAR_SUCURSAL,
             VAR_CRGNAL,
             VAR_COD_ERRO,
             VAR_DESC_ERRO );


   IF VAR_CRGNAL IS NULL THEN
      PAR_COD_RETORNO  := VAR_COD_ERRO;
      PAR_DSC_MENSAGEM := 'SGPB6028 - '||VAR_DESC_ERRO;
      RETURN;
   END IF;

   --LOOP PARA INSERT
   WHILE VAR_CCUPOM_PROML_DSTAQ_INI <= PAR_CCUPOM_PROML_DSTAQ_FIM  LOOP
   --
      BEGIN
         INSERT INTO ESTOQ_CUPOM_PROML_DSTAQ
                     ( CCAMPA_DSTAQ,
                       CCUPOM_PROML_DSTAQ,
                       CRGNAL,
                       RCUPOM,
                       DINCL_REG )
                VALUES
                      ( PAR_CCAMPA_DSTAQ,
                        VAR_CCUPOM_PROML_DSTAQ_INI,
                        VAR_CRGNAL,
                        UPPER(PAR_NOME),
                        SYSDATE );

         VAR_CCUPOM_PROML_DSTAQ_INI := VAR_CCUPOM_PROML_DSTAQ_INI + 1;

         EXCEPTION

            WHEN OTHERS THEN
               PAR_COD_RETORNO  := SQLCODE;
               PAR_DSC_MENSAGEM := 'SGPB6028 - ERRO AO INSERIR NA TABELA ESTOQ_CUPOM_PROML_DSTAQ. '||SQLERRM;
               RETURN;
      END;
   END LOOP;

   COMMIT;
   PAR_COD_RETORNO := 0;

   EXCEPTION

     WHEN OTHERS THEN
       PAR_COD_RETORNO  := SQLCODE;
       PAR_DSC_MENSAGEM := 'ERRO AO EXECUTAR A PROCEDURE SGPB6028. '||SQLERRM;

END SGPB6028_2;
/

