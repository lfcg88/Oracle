CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6604
( RES                     OUT SYS_REFCURSOR
, COD_RETORNO             OUT VARCHAR
, COD_MENSAGEM            OUT VARCHAR
, PAR_COD_FUNCIONALIDADE  IN NUMBER
, PAR_COD_GRUPO           IN VARCHAR2
, PAR_COD_NOVO_GRUPO      IN VARCHAR2
, PAR_COD_RAMO            IN NUMBER
, PAR_CCAMPA_DSTAQ        IN NUMBER
)AS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB6604
--      DATA            : 09/04/2008
--      AUTOR           : THIAGO PELLEGRINO - JAPI INFORMÁTICA
--      OBJETIVO        : CADASTRO DE GRUPOS DE RAMOS
--                        CAMPANHA DESTAQUE DE PRODUÇÃO
--      ALTERAÇÕES      :
--                DATA  :
--                AUTOR :
--                OBS   :
-------------------------------------------------------------------------------------------------

--VAR_ROTINA	     VARCHAR2(10) := 'SGPB6604';

 VAR_VALIDA_FUNC             NUMBER(4) := 0;
 VAR_CIND_CAMPA_ATIVO        CHAR(1) := '';
 VAR_VALIDA_RAMO           NUMBER(4) := 0;

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

         SELECT DISTINCT
           'grupo',
           GRM.CGRP_RAMO_DSTAQ,
           'ramo',
           GRM.CRAMO
            FROM CAMPA_DSTAQ          CPD
               , GRP_RAMO_CAMPA_DSTAQ GRM
           WHERE CPD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
             AND CPD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
           ORDER
              BY GRM.CGRP_RAMO_DSTAQ
               , GRM.CRAMO;


    --
    -- CASO FUNCINALIDADE IGUAL A 2:
    -- REALIZAR A INCERÇÃO DO RAMO NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO

    IF PAR_COD_FUNCIONALIDADE = 2 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

    SELECT COUNT(*)
     INTO VAR_VALIDA_FUNC
     FROM GRP_RAMO_CAMPA_DSTAQ
     WHERE CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
     AND   CRAMO        = PAR_COD_RAMO;


      IF VAR_VALIDA_FUNC > 0 THEN

          COD_RETORNO    := 1;
          COD_MENSAGEM   := 'Este Ramo pertence a outro Grupo.';
      ELSE

    --
    -- QUERY QUE VALIDA SE O RAMO EXISTE
        SELECT COUNT(*)
          INTO VAR_VALIDA_RAMO
          FROM RAMO
         WHERE CRAMO = PAR_COD_RAMO;

       IF VAR_VALIDA_RAMO = 1 THEN

        INSERT
          INTO GRP_RAMO_CAMPA_DSTAQ
               (CCAMPA_DSTAQ
             ,  CRAMO
             ,  CGRP_RAMO_DSTAQ
             ,  DINCL_REG
             ,  DALT_REG)
        VALUES (PAR_CCAMPA_DSTAQ
             ,  PAR_COD_RAMO
             ,  PAR_COD_GRUPO
             ,  SYSDATE
             ,  NULL);

          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Cadastro efetuado com sucesso!';

         ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Esse Ramo é inválido.';

        END IF;

       END IF;

    --
    -- CASO FUNCINALIDADE IGUAL A 3:
    -- REALIZAR A ALTERAÇÃO DO RAMO NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO PARA O GRUPO NO TRIMESTRE DA CAMPANHA

    ELSIF PAR_COD_FUNCIONALIDADE = 3 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

    --
    -- QUERY QUE VERIFICA SE O GRUPO JÁ ESTÁ CADASTRADO
        SELECT COUNT(*)
         INTO VAR_VALIDA_FUNC
         FROM GRP_RAMO_CAMPA_DSTAQ GRD
        WHERE  GRD.CCAMPA_DSTAQ    = PAR_CCAMPA_DSTAQ
         AND   GRD.CGRP_RAMO_DSTAQ = PAR_COD_GRUPO;

        IF VAR_VALIDA_FUNC >= 1 THEN

         UPDATE GRP_RAMO_CAMPA_DSTAQ GRM
          SET   GRM.CGRP_RAMO_DSTAQ = PAR_COD_NOVO_GRUPO
         WHERE  GRM.CCAMPA_DSTAQ    = PAR_CCAMPA_DSTAQ
          AND   GRM.CGRP_RAMO_DSTAQ = PAR_COD_GRUPO;


          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Alteração do Grupo efetuado com sucesso!';

        ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Este Grupo não está cadastrado';

      END IF;

    --
    -- CASO FUNCINALIDADE IGUAL A 4:
    -- REALIZAR A ALTERAÇÃO DO RAMO NO GRUPO INDICADO
    -- SE NÃO HOUVER PRODUÇÃO PARA O RAMO NO TRIMESTRE DA CAMPANHA

    ELSIF PAR_COD_FUNCIONALIDADE = 4 AND VAR_CIND_CAMPA_ATIVO = 'S' THEN

    --
    -- QUERY QUE VERIFICA SE O RAMO JÁ ESTÁ CADASTRADOA PARA UM DETERMINADO GRUPO
       SELECT COUNT(*)
          INTO VAR_VALIDA_FUNC
          FROM GRP_RAMO_CAMPA_DSTAQ GRD
         WHERE GRD.CCAMPA_DSTAQ   = PAR_CCAMPA_DSTAQ
          AND GRD.CGRP_RAMO_DSTAQ = PAR_COD_GRUPO
          AND GRD.CRAMO           = PAR_COD_RAMO;

    --
    -- QUERY QUE VERIFICA SE O RAMO É VALIDO
       SELECT COUNT(*)
          INTO VAR_VALIDA_RAMO
          FROM RAMO
         WHERE CRAMO = PAR_COD_RAMO;

        IF VAR_VALIDA_FUNC = 1 AND VAR_VALIDA_RAMO = 1 THEN

         DELETE
          FROM GRP_RAMO_CAMPA_DSTAQ GRM
         WHERE GRM.CCAMPA_DSTAQ    = PAR_CCAMPA_DSTAQ
           AND GRM.CGRP_RAMO_DSTAQ = PAR_COD_GRUPO
           AND GRM.CRAMO           = PAR_COD_RAMO;

          COMMIT;

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Exclusão do Grupo efetuado com sucesso!';

        ELSE

          COD_RETORNO    := 0;
          COD_MENSAGEM   := 'Este Grupo não está cadastrado ou este Ramo não existe. ';

        END IF;

    ELSE

        COD_RETORNO    := 0;
        COD_MENSAGEM   := 'A Camapnha não está ativa para esta funcionalidade.';

    END IF;

  EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20001,'PL ERRO CADASTRO DE GRUPO DE RAMOS ' || SUBSTR(SQLERRM,1,100));
           ROLLBACK;
           --PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||SUBSTR(SQLERRM,1,500),'P',NULL,NULL);
           COMMIT;
   END;

END;
/

