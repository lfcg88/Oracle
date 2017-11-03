CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6603
( RES                     OUT SYS_REFCURSOR
, COD_RETORNO             OUT VARCHAR
, COD_MENSAGEM            OUT VARCHAR
, PAR_COD_FUNCIONALIDADE  IN NUMBER       -- Valor da opção selecionada na combo Funcionalidade
, PAR_COD_GRUPO           IN VARCHAR2     -- GRP_RGNAL_DSTAQ.CGRP_RGNAL
, PAR_COD_NOVO_GRUPO      IN VARCHAR2     -- GRP_RGNAL_DSTAQ.CGRP_RGNAL
, PAR_COD_REGIONAL        IN NUMBER       -- GRP_RGNAL_DSTAQ.CRGNAL
, PAR_CCAMPA_DSTAQ        IN NUMBER       -- Trimestre
)AS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB6603
--      DATA            : 08/04/2008
--      AUTOR           : THIAGO PELLEGRINO - JAPI INFORMÁTICA
--      OBJETIVO        : CADASTRO DE GRUPOS DE REGIONAIS
--                        CAMPANHA DESTAQUE DE PRODUÇÃO
--      ALTERAÇÕES      :
--                DATA  :
--                AUTOR :
--                OBS   :
-------------------------------------------------------------------------------------------------

--VAR_ROTINA	     VARCHAR2(10) := 'SGPB6603';

 VAR_VALIDA_FUNC             NUMBER(4) := 0;
 VAR_CIND_CAMPA_ATIVO        CHAR(1) := '';
 VAR_VALIDA_CCHAVE_DIR_RGNAL NUMBER(4) := 0;

BEGIN

  BEGIN

    --
    --VALIDANDO SE A CAMPANHA ESTA ATIVA
    SELECT CIND_CAMPA_ATIVO
      INTO VAR_CIND_CAMPA_ATIVO
      FROM CAMPA_DSTAQ
     WHERE CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ;

    --
    -- CONDIÇÃO DE VALIDAÇÃO DAS FUNCIONALIDADES

    -- CASO FUNCINALIDADE IGUAL A 1:
    -- REALIZAR A CONSULTA COM OS GRUPOS E SUAS REGIONAIS

    OPEN RES FOR
    --QUERY PARA CONSULTA DOS GRUPOS E REGIONAIS
        SELECT DISTINCT
        'grupo',
        GRD.CGRP_RGNAL,
        'regional',
        GRD.CRGNAL
          FROM CAMPA_DSTAQ CPD,
               GRP_RGNAL_DSTAQ GRD
         WHERE GRD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
           AND CPD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
         ORDER
            BY GRD.CGRP_RGNAL
             , GRD.CRGNAL;

    --
    -- CASO FUNCINALIDADE IGUAL A 2:
    -- REALIZAR A INCERÇÃO DA REGIONAL NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO

    IF PAR_COD_FUNCIONALIDADE = 2 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

     SELECT COUNT(*)
      INTO VAR_VALIDA_FUNC
      FROM GRP_RGNAL_DSTAQ
      WHERE CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
      AND   CRGNAL       = PAR_COD_REGIONAL;

      IF VAR_VALIDA_FUNC > 0 THEN

          COD_RETORNO    := 1;
          COD_MENSAGEM   := 'Esta Regional pertence a outro Grupo.';
      ELSE

    --
    -- QUERY QUE VALIDA SE A REGIONAL EXISTE
        SELECT COUNT(*)
          INTO VAR_VALIDA_CCHAVE_DIR_RGNAL
          FROM DIR_RGNAL_SEGDR_DW DRW
         WHERE CCHAVE_DIR_RGNAL = PAR_COD_REGIONAL;

       IF VAR_VALIDA_CCHAVE_DIR_RGNAL = 1 THEN

         INSERT
          INTO GRP_RGNAL_DSTAQ
               (CCAMPA_DSTAQ
             ,  CRGNAL
             ,  CGRP_RGNAL
             ,  DINCL_REG
             ,  DALT_REG)
          VALUES (PAR_CCAMPA_DSTAQ
             ,  PAR_COD_REGIONAL
             ,  PAR_COD_GRUPO
             ,  SYSDATE
             ,  NULL);

          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Cadastro efetuado com sucesso!';

         ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Essa Regional é inválida.';

        END IF;

       END IF;

    --
    -- CASO FUNCINALIDADE IGUAL A 3:
    -- REALIZAR A ALTERAÇÃO DA REGIONAL NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO PARA O GRUPO NO TRIMESTRE DA CAMPANHA

    ELSIF PAR_COD_FUNCIONALIDADE = 3 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

  --
  -- QUERY QUE VERIFICA SE O GRUPO JÁ POSSUI PRODUÇÃO NESTE TRIMESTRE
      SELECT COUNT(*)
        INTO VAR_VALIDA_FUNC
        FROM HIERQ_PBLIC_ALVO HPA
         WHERE HPA.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
         AND   HPA.CGRP_RGNAL   = PAR_COD_GRUPO;

     IF VAR_VALIDA_FUNC > 0 THEN

          COD_RETORNO    := 1;
          COD_MENSAGEM   := 'Este Grupo já possui uma produção neste trimestre.';
      ELSE

    --
    -- QUERY QUE VERIFICA SE O GRUPO JÁ ESTÁ CADASTRADO
        SELECT COUNT(*)
         INTO VAR_VALIDA_FUNC
         FROM GRP_RGNAL_DSTAQ GRD
        WHERE  GRD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
         AND   GRD.CGRP_RGNAL   = PAR_COD_GRUPO;

        IF VAR_VALIDA_FUNC >= 1 THEN

          UPDATE GRP_RGNAL_DSTAQ GRD
           SET   GRD.CGRP_RGNAL   = PAR_COD_NOVO_GRUPO
          WHERE  GRD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
           AND   GRD.CGRP_RGNAL   = PAR_COD_GRUPO;

          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Alteração do Grupo efetuada com sucesso!';

        ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Este Grupo não está cadastrado';

        END IF;

      END IF;

    --
    -- CASO FUNCINALIDADE IGUAL A 4:
    -- REALIZAR A ALTERAÇÃO DA REGIONAL NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO PARA A REGIONAL NO TRIMESTRE DA CAMPANHA

    ELSIF PAR_COD_FUNCIONALIDADE = 4 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

    --
    -- QUERY QUE VERIFICA SE A REGIONAL JÁ POSSUI PRODUÇÃO NESTE TRIMESTRE
      SELECT COUNT(*)
       INTO VAR_VALIDA_FUNC
       FROM HIERQ_PBLIC_ALVO
       WHERE CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
         AND CRGNAL       = PAR_COD_REGIONAL;

     IF VAR_VALIDA_FUNC > 0 THEN

          COD_RETORNO    := 1;
          COD_MENSAGEM   := 'Este Regional já possui uma produção neste trimestre.';
      ELSE

    --
    -- QUERY QUE VERIFICA SE A REGIONAL JÁ ESTÁ CADASTRADA PARA UM DETERMINADO GRUPO
       SELECT COUNT(*)
          INTO VAR_VALIDA_FUNC
          FROM GRP_RGNAL_DSTAQ GRD
         WHERE GRD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
          AND GRD.CGRP_RGNAL   = PAR_COD_GRUPO
          AND GRD.CRGNAL       = PAR_COD_REGIONAL;

    --
    -- QUERY QUE VERIFICA SE A REGIONAL É VALIDA
       SELECT COUNT(*)
          INTO VAR_VALIDA_CCHAVE_DIR_RGNAL
          FROM DIR_RGNAL_SEGDR_DW DRW
         WHERE CCHAVE_DIR_RGNAL = PAR_COD_REGIONAL;

        IF VAR_VALIDA_FUNC = 1 AND VAR_VALIDA_CCHAVE_DIR_RGNAL = 1 THEN

          DELETE
           FROM GRP_RGNAL_DSTAQ GRD
          WHERE GRD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
            AND GRD.CGRP_RGNAL   = PAR_COD_GRUPO
            AND GRD.CRGNAL       = PAR_COD_REGIONAL;

          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Exclusão do Grupo efetuada com sucesso!';

        ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Este Grupo não esta cadastrado ou esta Regional não existe. ';

        END IF;

      END IF;

    ELSE

        COD_RETORNO    := 0;
        COD_MENSAGEM   := 'A Camapnha não está ativa para esta funcionalidade.';

    END IF;

  EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20001,'PL ERRO CADASTRO DE GRUPO DE REGIONAIS ' || SUBSTR(SQLERRM,1,100));
           ROLLBACK;
           --PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||SUBSTR(SQLERRM,1,500),'P',NULL,NULL);
           COMMIT;
   END;

END;
/

