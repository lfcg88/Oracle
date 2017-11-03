CREATE OR REPLACE PROCEDURE GERAMRC_PED_IPAS IS

  --Para catalogar 20/05/2011 INPI

  -- cat 20/04/2007 Bia

  ----- CURSOR DO ARQUIVO MRC_PED -----
  CURSOR cSOLICITACAO_PED IS
    SELECT DISTINCT *
      FROM (SELECT TO_CHAR(A.DATAHORA, 'DD-MM-YYYY') DATAENVIO,
                   TO_CHAR(A.DATAHORA, 'HH24:MI') HORAENVIO,
                   A.CODSOLICITACAO SOLICITACAO,
                   LPAD(B.NRPROCESSO, 9, 0) PROCESSO,
                   NVL(D.SIGLAPAIS, ' ') SIGLAPAISTITULAR,
                   A.IDSEQUENCIALPROCURADOR SEQUENCIALPROCURADOR,
                   A.IDSEQUENCIALESC,
                   A.IDSEQUENCIALREQUERENTE SEQUENCIALTITULAR,
                   CASE
                     WHEN H.APRESENTACAO = 'N' THEN
                      1
                     WHEN H.APRESENTACAO = 'M' THEN
                      2
                     WHEN H.APRESENTACAO = 'F' THEN
                      3
                     WHEN H.APRESENTACAO = 'T' THEN
                      4
                     ELSE
                      NULL
                   END AS APRESEN,
                   H.CODMARCA MARCA,
                   H.SERVICOCERTIFICACAO, --SS45936/SM145734 - Claudio Pinheiro
                   A.CODTIPOOBJETO, --SS45936/SM145734 - Claudio Pinheiro
                   A.DATAHORA,
                   CASE
                     WHEN H.NATUREZA = 'P' THEN
                      1
                     WHEN H.NATUREZA = 'S' THEN
                      2
                     WHEN H.NATUREZA = 'C' THEN
                      3
                     WHEN H.NATUREZA = 'E' THEN
                      4
                     ELSE
                      NULL
                   END AS NATUREZA,
                   H.ELEMENTONOMINATIVOMARCA NOMEMARCA,
                   LPAD(A.NRGRU, 16, 0) GRU,
                   SUBSTR(TO_CHAR(A.CODTIPOOBJETO), 1, 3) TIPOOBJETO,
                   SUBSTR(TO_CHAR(A.CODTIPOOBJETO), 4, 5) RAMIFICACAO
              FROM SOLICITACAO                    A,
                   PROCESSO                       B,
                   USUARIO                        D,
                   MARCA                          H,
                   TIPOOBJETO                     K,
                   SITUACAOSOLICITACAOWORKFLOW    W,
                   ESPECIFICACAODESPACHOSOLICITAC Y
             WHERE A.CODTIPOOBJETO = K.CODTIPOOBJETO
               AND TO_CHAR(A.DATAINICIOVIGENCIA, 'DD-MM-YYYY') =
                   TO_CHAR(K.DATAINICIOVIGENCIA, 'DD-MM-YYYY')
               AND K.CODASSUNTO = 1
               AND A.CODSOLICITACAO = W.CODSOLICITACAO
               AND W.CODSITUACAOWORKFLOW = 2
               ----AND A.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')

               -- trunc(A.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') 
               AND trunc(A.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
               --    to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1

                 -----TO_CHAR(SYSDATE,'YYMMDD')||'
                 -----to_date(SYSDATE, 'DD-MM-YYYY') - 1
              /*  AND A.CODSOLICITACAO NOT IN
                    (SELECT CODSOLICITACAO
                      FROM SITUACAOSOLICITACAOWORKFLOW
                     WHERE CODSITUACAOWORKFLOW in (9, 14))   */
               AND A.CODSOLICITACAO = Y.CODSOLICITACAO
               AND Y.CODTIPODESPACHO = 3
               AND A.CODSOLICITACAO = B.CODSOLICITACAO
               AND B.CODMARCA = H.CODMARCA
               AND D.IDSEQUENCIAL = A.IDSEQUENCIALREQUERENTE

--------ESTAPA ACIMA OK --- CONFERENCIA LEANDRO E LEONEL

            UNION ----ADICIONANDO REGRA PARA BUSCA DE PEDIDOS APROVADOS AUTOMATIC APOS A PET CUMP EXIG FORM TER SIDO APROVADA

            SELECT TO_CHAR(A.DATAHORA, 'DD-MM-YYYY') DATAENVIO,
                   TO_CHAR(A.DATAHORA, 'HH24:MI') HORAENVIO,
                   A.CODSOLICITACAO SOLICITACAO,
                   LPAD(B.NRPROCESSO, 9, 0) PROCESSO,
                   NVL(D.SIGLAPAIS, ' ') SIGLAPAISTITULAR,
                   A.IDSEQUENCIALPROCURADOR SEQUENCIALPROCURADOR,
                   A.IDSEQUENCIALESC,
                   A.IDSEQUENCIALREQUERENTE SEQUENCIALTITULAR,
                   CASE
                     WHEN H.APRESENTACAO = 'N' THEN
                      1
                     WHEN H.APRESENTACAO = 'M' THEN
                      2
                     WHEN H.APRESENTACAO = 'F' THEN
                      3
                     WHEN H.APRESENTACAO = 'T' THEN
                      4
                     ELSE
                      NULL
                   END AS APRESEN,
                   H.CODMARCA MARCA,
                   H.SERVICOCERTIFICACAO, --SS45936/SM145734 - Claudio Pinheiro
                   A.CODTIPOOBJETO, --SS45936/SM145734 - Claudio Pinheiro
                   A.DATAHORA,
                   CASE
                     WHEN H.NATUREZA = 'P' THEN
                      1
                     WHEN H.NATUREZA = 'S' THEN
                      2
                     WHEN H.NATUREZA = 'C' THEN
                      3
                     WHEN H.NATUREZA = 'E' THEN
                      4
                     ELSE
                      NULL
                   END AS NATUREZA,
                   H.ELEMENTONOMINATIVOMARCA NOMEMARCA,
                   LPAD(A.NRGRU, 16, 0) GRU,
                   SUBSTR(TO_CHAR(A.CODTIPOOBJETO), 1, 3) TIPOOBJETO,
                   SUBSTR(TO_CHAR(A.CODTIPOOBJETO), 4, 5) RAMIFICACAO
              FROM SOLICITACAO                 A,
                   PROCESSO                    B,
                   USUARIO                     D,
                   MARCA                       H,
                   TIPOOBJETO                  K,
                   SITUACAOSOLICITACAOWORKFLOW W,
                   PETICAOPROCESSO             PP,
                   PETICAOCUMPRIMENTOFORMAL    PCF
             WHERE A.CODTIPOOBJETO = K.CODTIPOOBJETO
               AND TO_CHAR(A.DATAINICIOVIGENCIA, 'DD/MM/YYYY') =
                   TO_CHAR(K.DATAINICIOVIGENCIA, 'DD/MM/YYYY')
               AND K.CODASSUNTO = 1
               AND A.CODSOLICITACAO = W.CODSOLICITACAO
               AND W.CODSITUACAOWORKFLOW = 13

               --trunc(A.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') 
               AND trunc(A.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
               --    to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1

               /* AND A.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY') */

               ----AND Trunc(A.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

               /* AND To_Date(A.DATAHORA, 'DD-MM-YYYY') <
               -----Alterado RJ 10-01-2011
                   to_date('08-06-2009' ,'DD-MM-YYYY' ) - 1
               ---- 1
                   ----To_Date (SYSDATE, 'DD-MM-YYYY') - 1 */
               AND A.CODSOLICITACAO NOT IN
                   (SELECT CODSOLICITACAO
                      FROM SITUACAOSOLICITACAOWORKFLOW
                     WHERE CODSITUACAOWORKFLOW = 14)
               AND A.CODSOLICITACAO = B.CODSOLICITACAO
               AND B.CODMARCA = H.CODMARCA
               AND D.IDSEQUENCIAL = A.IDSEQUENCIALREQUERENTE
               AND A.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
               AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO )
     ORDER BY PROCESSO;

  CURSOR cESPECIFICACAODESPACHO(pSOLICITACAO IN NUMBER) IS
    SELECT DISTINCT Y.CODSOLICITACAO,
                    NVL(ETD.ESPECIFICACAO, ' ') AS ESPECIFICACAO,
                    NVL(Y.COMPLEMENTO, ' ') AS COMPLEMENTO
      FROM ESPECIFICACAODESPACHOSOLICITAC Y, ESPECIFICACAOTIPODESPACHO ETD
     WHERE Y.CODESPECIFICACAO = ETD.CODESPECIFICACAO
       AND Y.CODTIPODESPACHO = ETD.CODTIPODESPACHO
       AND Y.CODTIPODESPACHO = 3
       AND Y.CODSOLICITACAO = pSOLICITACAO;

  CURSOR cESPECIFICACAOMARCA(pSOLICITACAO IN NUMBER) IS
    SELECT DISTINCT P.CODSOLICITACAO,
                    P.CODMARCA,
                    E.CODESPECIFICACAO,
                    E.DESCRICAO,
                    E.CODCLASSE,
                    E.EDICAO
      FROM PROCESSO P, MARCAESPECIFICACAO ME, ESPECIFICACAO E
     WHERE P.CODSOLICITACAO = pSOLICITACAO
       AND P.CODMARCA = ME.CODMARCA
       AND ME.CODESPECIFICACAO = E.CODESPECIFICACAO;

  CURSOR cTIPOSERVICO(pSOLICITACAO IN NUMBER, pCODESPECIFICACAO IN NUMBER) IS
    SELECT DISTINCT me.indicativotiposervico
      FROM PROCESSO P, MARCAESPECIFICACAO ME, ESPECIFICACAO E
     WHERE P.CODSOLICITACAO = pSOLICITACAO
       AND P.CODMARCA = ME.CODMARCA
       AND ME.CODESPECIFICACAO = E.CODESPECIFICACAO
       AND E.CODESPECIFICACAO = pCODESPECIFICACAO;

  -------------FIM DO CURSOR DO ARQUIVO MRC_PED---------------------------

  -------------CURSOR DO ARQUIVO MRC_PEDDOC-----------------------------------
  CURSOR cSOLICITACAO_PEDDOC IS
    SELECT DISTINCT NRPROCESSO,
                    CODTIPOANEXO,
                    CODOUTROTIPOANEXO,
                    CODSOLICITACAO
      FROM (SELECT P.NRPROCESSO,
                   AN.CODTIPOANEXO,
                   AN.CODOUTROTIPOANEXO,
                   S.CODSOLICITACAO
              FROM SOLICITACAO                    S,
                   TIPOOBJETO                     T,
                   SITUACAOSOLICITACAOWORKFLOW    SSW,
                   PROCESSO                       P,
                   ESPECIFICACAODESPACHOSOLICITAC EDS,
                   ANEXO                          AN
             WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
               AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                   to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
             --  AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
               AND S.CODSOLICITACAO = P.CODSOLICITACAO
               AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
               AND AN.CODSOLICITACAO = S.CODSOLICITACAO
               AND EDS.CODTIPODESPACHO = 3
               AND T.CODASSUNTO = 1
              -- AND SSW.CODSITUACAOWORKFLOW = 2

               --AND  trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
               AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
               --    to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


               /* AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY') */
               ----AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

               /* AND TO_date(S.DATAHORA, 'DD-MM-YYYY') <
              -----Alterado RJ 10-01-2011
                   to_date('08-06-2009','DD-MM-YYYY' )  - 1
              -------- - 1
              ------     To_Date (SYSDATE, 'DD-MM-YYYY') - 1 */

               ---AND
               /* NOT EXISTS
             (SELECT 1
                      FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                     WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                   ----    AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
               AND S.CODSOLICITACAO NOT IN
                   (SELECT S.CODSOLICITACAO
                      FROM SOLICITACAO                 S,
                           TIPOOBJETO                  T,
                           SITUACAOSOLICITACAOWORKFLOW SSW,
                           PROCESSO                    P,
                           ANEXO                       AN,
                           PETICAOPROCESSO             PP,
                           PETICAOCUMPRIMENTOFORMAL    PCF
                     WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
                       AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                           to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
                       --AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
                       AND S.CODSOLICITACAO = P.CODSOLICITACAO
                       AND T.CODASSUNTO = 1
             --          AND SSW.CODSITUACAOWORKFLOW = 13

                       --AND  trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
                       AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
                       --to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


                       ----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
                       -----AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

                       /* AND TO_date(S.DATAHORA, 'DD-MM-YYYY') <
                       -----Alterado RJ 10-01-2011
                           to_date('08-06-2009', 'DD-MM-YYYY') -1
                       ------ 1
                       --------    To_Date (SYSDATE, 'DD-MM-YYYY') - 1 */

                       ----AND
                       /* NOT EXISTS
                     (SELECT 1
                              FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                             WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                              ---- AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
                       AND S.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
                       AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO
                       AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO)

            UNION

            SELECT P.NRPROCESSO,
                   -- PCF.CODSOLICITACAO,
                   AN.CODTIPOANEXO,
                   AN.CODOUTROTIPOANEXO,
                   S.CODSOLICITACAO
              FROM SOLICITACAO                 S,
                   TIPOOBJETO                  T,
                   SITUACAOSOLICITACAOWORKFLOW SSW,
                   PROCESSO                    P,
                   ANEXO                       AN,
                   PETICAOPROCESSO             PP,
                   PETICAOCUMPRIMENTOFORMAL    PCF
             WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
               AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                   to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
               --AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
               AND S.CODSOLICITACAO = P.CODSOLICITACAO
               AND T.CODASSUNTO = 1
           --    AND SSW.CODSITUACAOWORKFLOW = 13

               --AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')  
               AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
               --    to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


               ----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
               -----AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

               /* and TO_date(S.DATAHORA, 'DD-MM-YYYY') <
               -----Alterado RJ 10-01-2011
                  to_date('08-09-2009', 'DD-MM-YYYY') - 1
               ------ - 1
               ------To_Date (SYSDATE, 'DD-MM-YYYY') - 1 */

               ---AND
              /*  NOT EXISTS
             (SELECT 1
                      FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                     WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                      ---- AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
               AND S.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
               AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO
               AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO

            UNION

            SELECT P.NRPROCESSO,
                   -- PCF.CODSOLICITACAO,
                   AN2.CODTIPOANEXO,
                   AN2.CODOUTROTIPOANEXO,
                   S.CODSOLICITACAO
              FROM SOLICITACAO                 S,
                   TIPOOBJETO                  T,
                   SITUACAOSOLICITACAOWORKFLOW SSW,
                   PROCESSO                    P,
                   ANEXO                       AN,
                   ANEXO                       AN2,
                   PETICAOPROCESSO             PP,
                   PETICAOCUMPRIMENTOFORMAL    PCF
             WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
               AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                   to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
              -- AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
               AND S.CODSOLICITACAO = P.CODSOLICITACAO
               AND T.CODASSUNTO = 1
             --  AND SSW.CODSITUACAOWORKFLOW = 2
               -----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')

               AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') 
               ----trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
               --    to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


               -----AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

               /* and TO_date(S.DATAHORA, 'DD-MM-YYYY') <
               -----Alterado RJ 10-01-2011
                   to_date('08-06-2009', 'DD-MM-YYYY') - 1
               ---------- 1
               ------    To_Date (SYSDATE, 'DD-MM-YYYY') - 1 */

               -----AND
               /*NOT EXISTS
              ( SELECT 1
                      FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                     WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                       -----AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
               AND S.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
               AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO
               AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO
               AND AN2.CODSOLICITACAO = S.CODSOLICITACAO
               AND AN.CODSOLICITACAO <> AN2.CODSOLICITACAO
               )
     ORDER BY 1;

  -----------------FIM DO CURSOR DO ARQUIVO MRC_PEDDOC------------------------------------------------------

  ---------cursor conta linha por processo MRC_PEDDOC---------------------------------MODIFICA
  CURSOR cQTDPEDDOC(pcodsolicitacao in number) IS
    SELECT codsolicitacao, count(*) AS contalinha
      FROM (SELECT DISTINCT NRPROCESSO,
                            CODTIPOANEXO,
                            CODOUTROTIPOANEXO,
                            CODSOLICITACAO
              FROM (SELECT P.NRPROCESSO,
                           AN.CODTIPOANEXO,
                           AN.CODOUTROTIPOANEXO,
                           S.CODSOLICITACAO
                      FROM SOLICITACAO                    S,
                           TIPOOBJETO                     T,
                           SITUACAOSOLICITACAOWORKFLOW    SSW,
                           PROCESSO                       P,
                           ESPECIFICACAODESPACHOSOLICITAC EDS,
                           ANEXO                          AN
                     WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
                       AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                           to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
                    --   AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
                       AND S.CODSOLICITACAO = P.CODSOLICITACAO
                       AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
                       AND AN.CODSOLICITACAO = S.CODSOLICITACAO
                       AND EDS.CODTIPODESPACHO = 3
                       AND T.CODASSUNTO = 1
                      -- AND SSW.CODSITUACAOWORKFLOW = 2

                       --AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
                       AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
                       -- to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


                       ----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
                       -------AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

                       /* and TO_date(S.DATAHORA, 'DD-MM-YYYY') <
                           --------to_date('08-06-2009') - 1
                       -----Alterado RJ 10-01-2011
                           to_date('08-06-2009', 'DD-MM-YYYY') - 1
                       ------ 1
                       -----to_date(SYSDATE, 'DD-MM-YYYY') - 1 */

                       /*AND NOT EXISTS
                     (SELECT 1
                              FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                             WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                              ----- AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
                       AND S.CODSOLICITACAO NOT IN
                           (SELECT S.CODSOLICITACAO
                              FROM SOLICITACAO                 S,
                                   TIPOOBJETO                  T,
                                   SITUACAOSOLICITACAOWORKFLOW SSW,
                                   PROCESSO                    P,
                                   ANEXO                       AN,
                                   PETICAOPROCESSO             PP,
                                   PETICAOCUMPRIMENTOFORMAL    PCF
                             WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
                               AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                                   to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
                           --    AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
                               AND S.CODSOLICITACAO = P.CODSOLICITACAO
                               AND T.CODASSUNTO = 1
                             --  AND SSW.CODSITUACAOWORKFLOW = 13

                               --AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') 
                               AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
                               -- to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


                               ----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
                               -------AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

                               /* and TO_date(S.DATAHORA, 'DD-MM-YYYY') <
                               -----Alterado RJ 10-01-2011
                                   to_date('08-06-2009', 'DD-MM-YYYY') - 1
                                   ------to_date(SYSDATE, 'DD-MM-YYYY') - 1 */

                               ----AND
                               /* NOT EXISTS
                             (SELECT 1
                                      FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                                     WHERE SSW1.CODSOLICITACAO =
                                           S.CODSOLICITACAO
                                      ----- AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
                               AND S.CODSOLICITACAO =
                                   PP.CODSOLICITACAOPROCESSO
                               AND PP.CODSOLICITACAOPETICAO =
                                   PCF.CODSOLICITACAO
                               AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO)

                    UNION

                    SELECT P.NRPROCESSO,
                           AN.CODTIPOANEXO,
                           AN.CODOUTROTIPOANEXO,
                           S.CODSOLICITACAO
                      FROM SOLICITACAO                 S,
                           TIPOOBJETO                  T,
                           SITUACAOSOLICITACAOWORKFLOW SSW,
                           PROCESSO                    P,
                           ANEXO                       AN,
                           PETICAOPROCESSO             PP,
                           PETICAOCUMPRIMENTOFORMAL    PCF
                     WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
                       AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                           to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
                    --   AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
                       AND S.CODSOLICITACAO = P.CODSOLICITACAO
                       AND T.CODASSUNTO = 1
            --           AND SSW.CODSITUACAOWORKFLOW = 13

                       --AND  trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
                       AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
                       --  to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1


                       ----AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
                       ------AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

                       /* AND TO_date(S.DATAHORA, 'DD-MM-YYYY') <
                      -----Alterado RJ 10-01-2011
                           to_date('08-06-2009', 'DD-MM-YYYY') - 1
                      ------- 1
                      -------   to_date(SYSDATE, 'DD-MM-YYYY') - 1 */

                       ----AND
                       /* NOT EXISTS
                     (SELECT 1
                              FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                             WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                              -------AND SSW1.CODSITUACAOWORKFLOW in (9, 14))   */
                       AND S.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
                       AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO
                       AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO )

                    UNION

                    SELECT P.NRPROCESSO,
                           AN2.CODTIPOANEXO,
                           AN2.CODOUTROTIPOANEXO,
                           S.CODSOLICITACAO
                      FROM SOLICITACAO                 S,
                           TIPOOBJETO                  T,
                           SITUACAOSOLICITACAOWORKFLOW SSW,
                           PROCESSO                    P,
                           ANEXO                       AN,
                           ANEXO                       AN2,
                           PETICAOPROCESSO             PP,
                           PETICAOCUMPRIMENTOFORMAL    PCF
                     WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
                       AND to_char(S.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                           to_char(T.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
                      -- AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
                       AND S.CODSOLICITACAO = P.CODSOLICITACAO
                       AND T.CODASSUNTO = 1
                --       AND SSW.CODSITUACAOWORKFLOW = 13

                       --AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
                       AND trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
                       --  to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1

                      ---- AND S.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY')
                       -------AND Trunc(S.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY' )

                       /* and TO_date(S.DATAHORA, 'DD-MM-YYYY') <
                           -----Alterado RJ 10-01-2011
                           to_date('08-06-2009','DD-MM-YYYY') -1
                           ------ 1
                           -------to_date(SYSDATE, 'DD-MM-YYYY') - 1 */

                       -----AND
                       /* NOT EXISTS
                     (SELECT 1
                              FROM SITUACAOSOLICITACAOWORKFLOW SSW1
                             WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
                               AND SSW1.CODSITUACAOWORKFLOW in (9, 14)) */
                       AND S.CODSOLICITACAO = PP.CODSOLICITACAOPROCESSO
                       AND PP.CODSOLICITACAOPETICAO = PCF.CODSOLICITACAO
                       AND AN.CODSOLICITACAO = PCF.CODSOLICITACAO
                       AND AN2.CODSOLICITACAO = S.CODSOLICITACAO
                       AND AN.CODSOLICITACAO <> AN2.CODSOLICITACAO)
     WHERE CODSOLICITACAO = pcodsolicitacao
     GROUP BY codsolicitacao;

  --------fim do cursor conta MRC_PEDDOC-----------------------

  -----------------IN¿CIO DO CURSOR DO ARQUIVO MRC_PEDVIENNA--------------------------------
  CURSOR cPEDVIENNA IS
    SELECT DISTINCT processo.codsolicitacao solicitacao,
                    processo.nrprocesso processo,
                    categoria.codcategoria || '.' ||
                    decode(divisao.nrdivisao, null, ' ', divisao.nrdivisao) || '.' ||
                    decode(secao.nrsecao, null, ' ', secao.nrsecao) as codviena
      FROM categoria,
           divisao,
           secao,
           marcasecao,
           processo,
           solicitacao,
           especificacaodespachosolicitac,
           TIPOOBJETO,
           SITUACAOSOLICITACAOWORKFLOW
     WHERE categoria.codcategoria = divisao.codcategoria
       and categoria.edicao = divisao.edicao
       and divisao.coddivisao = secao.coddivisao
       and marcasecao.codsecao = secao.codsecao
       and processo.codmarca = marcasecao.codmarca
       and solicitacao.codsolicitacao = processo.codsolicitacao
       and solicitacao.CODTIPOOBJETO = TIPOOBJETO.CODTIPOOBJETO
       AND to_char(solicitacao.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
           to_char(TIPOOBJETO.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
       AND TIPOOBJETO.CODASSUNTO = 1
       AND solicitacao.CODSOLICITACAO =
           SITUACAOSOLICITACAOWORKFLOW.CODSOLICITACAO
           ------(
       AND (SITUACAOSOLICITACAOWORKFLOW.CODSITUACAOWORKFLOW = 4

       --AND trunc(SOLICITACAO.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY')
       AND trunc(SOLICITACAO.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1
       --   to_date('13-05-2008' ,'DD-MM-YYYY' ) - 1

       ------AND SITUACAOSOLICITACAOWORKFLOW.DATAHORA BETWEEN Trunc(TO_date('01-04-2009', 'DD-MM-YYYY'))  AND TO_date('07-04-2009', 'DD-MM-YYYY') and
       -------AND Trunc(SITUACAOSOLICITACAOWORKFLOW.DATAHORA) =  to_date('01-04-2009' ,'DD-MM-YYYY') AND

       /*------to_date(SITUACAOSOLICITACAOWORKFLOW.DATAHORA, 'dd-mm-yyyy') =
           To_date(SITUACAOSOLICITACAOWORKFLOW.DATAHORA, 'dd-mm-yyyy') <
           -----Alterado RJ 10-01-2011
           to_date('08-06-2009', 'dd-mm-yyyy') + 1 AND
           ----to_date(SYSDATE, 'DD-MM-YYYY') + 1 AND */


            /*solicitacao.CODSOLICITACAO
           NOT IN
           (SELECT CODSOLICITACAO
                FROM SITUACAOSOLICITACAOWORKFLOW
               WHERE CODSITUACAOWORKFLOW in (9, 14))) OR */
     --      AND (SITUACAOSOLICITACAOWORKFLOW.CODSITUACAOWORKFLOW = 13
           /*AND to_date(SITUACAOSOLICITACAOWORKFLOW.DATAHORA, 'dd-mm-yyyy') <
          -----Alterado RJ 10-01-2011
           to_date('08-06-2009', 'dd-mm-yyyy') + 1 AND
           -----to_date(SYSDATE, 'DD-MM-YYYY') + 1 */ AND

           solicitacao.CODSOLICITACAO NOT IN
           (SELECT CODSOLICITACAO
                FROM SITUACAOSOLICITACAOWORKFLOW
               WHERE CODSITUACAOWORKFLOW = 14))
               --)
       AND solicitacao.CODSOLICITACAO =
           especificacaodespachosolicitac.CODSOLICITACAO
       AND especificacaodespachosolicitac.CODTIPODESPACHO = 3
     ORDER BY 1, 2;

  ------------------------FIM DO CURSOR DO ARQUIVO MRC_PEDVIENNA---------------------------

  ----------cursor conta linha por processo MRC_PEDVIENNA----------------------------MODIFICA
  CURSOR cQTDPEDVIENNA(pcodsolicitacao in number) IS
    SELECT SOLICITACAO, COUNT(*) CONTALINHAPROC_MRCPEDVIENNA
      FROM (SELECT DISTINCT processo.codsolicitacao solicitacao,
                            processo.nrprocesso processo,
                            categoria.codcategoria || '.' ||
                            decode(divisao.nrdivisao,
                                   null,
                                   ' ',
                                   divisao.nrdivisao) || '.' ||
                            decode(secao.nrsecao, null, ' ', secao.nrsecao) as codviena
              FROM categoria,
                   divisao,
                   secao,
                   marcasecao,
                   processo,
                   solicitacao,
                   especificacaodespachosolicitac,
                   TIPOOBJETO,
                   SITUACAOSOLICITACAOWORKFLOW
             WHERE categoria.codcategoria = divisao.codcategoria
               and categoria.edicao = divisao.edicao
               and divisao.coddivisao = secao.coddivisao
               and marcasecao.codsecao = secao.codsecao
               and processo.codmarca = marcasecao.codmarca
               and solicitacao.codsolicitacao = processo.codsolicitacao
               and solicitacao.CODTIPOOBJETO = TIPOOBJETO.CODTIPOOBJETO
               AND to_char(solicitacao.DATAINICIOVIGENCIA, 'dd/mm/yyyy') =
                   to_char(TIPOOBJETO.DATAINICIOVIGENCIA, 'dd/mm/yyyy')
               AND TIPOOBJETO.CODASSUNTO = 1
               AND solicitacao.CODSOLICITACAO =
                   SITUACAOSOLICITACAOWORKFLOW.CODSOLICITACAO
                    -----(
               AND
               (SITUACAOSOLICITACAOWORKFLOW.CODSITUACAOWORKFLOW = 2
               /*
                   to_date(SITUACAOSOLICITACAOWORKFLOW.DATAHORA,'dd-mm-yyyy') <
                             -----Alterado RJ 10-01-2011
                   to_date('08-06-2009', 'dd-mm-yyyy') + 1 ---AND
                   ------to_date(SYSDATE, 'DD-MM-YYYY') + 1 AND
                  /* solicitacao.CODSOLICITACAO NOT IN
                   (SELECT CODSOLICITACAO
                        FROM SITUACAOSOLICITACAOWORKFLOW
                       WHERE CODSITUACAOWORKFLOW in (9, 14))) OR  */ /*AND
                   (SITUACAOSOLICITACAOWORKFLOW.CODSITUACAOWORKFLOW = 13 and
                   to_date(SITUACAOSOLICITACAOWORKFLOW.DATAHORA,'dd-mm-yyyy') <
                             -----Alterado RJ 10-01-2011
                   to_date('08-06-2009', 'dd-mm-yyyy') + 1 */
                   -------to_date(SYSDATE, 'DD-MM-YYYY') + 1

                   AND  solicitacao.CODSOLICITACAO NOT IN
                   (SELECT CODSOLICITACAO
                        FROM SITUACAOSOLICITACAOWORKFLOW
                       WHERE CODSITUACAOWORKFLOW = 14))--)
               AND solicitacao.CODSOLICITACAO =
                   especificacaodespachosolicitac.CODSOLICITACAO
               AND especificacaodespachosolicitac.CODTIPODESPACHO = 3
             ORDER BY 1, 2)
     WHERE SOLICITACAO = pcodsolicitacao
     GROUP BY solicitacao;

  --------------------Fim do cursor conta linha por processo MRC_PEDVIENNA--------------------------

  ----tempor¿ria----
  CURSOR cTEMP IS
    SELECT DISTINCT CODSOLICITACAO FROM TMP_WORKFLOW2;
  ------------------

  FILEID  UTL_FILE.FILE_TYPE;
  NOMEARQ VARCHAR2(50);
  NRLINHA NUMBER(5);

  vSOLICITACAO_PED       cSOLICITACAO_PED%ROWTYPE;
  vESPECIFICACAODESPACHO cESPECIFICACAODESPACHO%ROWTYPE;
  vESPECIFICACAOMARCA    cESPECIFICACAOMARCA%ROWTYPE; --teste comentar essa linha se houver erro!!!!!
  vTEXTO                 VARCHAR2(4000);
  vTEXTO2                clob;
  vtexto_parte1          clob;
  vtexto_parte2          clob;
  vtexto_parte3          clob;
  vbranco                clob;
  vNUMDOCTIT             VARCHAR2(18);
  vSITUACAO              NUMBER(3);
  vIDUSU                 VARCHAR2(18);
  vTIPOPROC              CHAR(1);
  vIDSEQUENCIAL          NUMBER(38); -----(5)
  vAPI                   VARCHAR2(18);
  vOAB                   VARCHAR2(18);
  vSIGLAUFPROC           CHAR(2);
  VCONTAESC              NUMBER(38); ---number
  VCONTAPU               NUMBER;
  VCONTASOLCUMPFORMALUN  NUMBER;
  VCONTASOLCUMPFORMAL    NUMBER(38); ---number
  vREGISTRO              VARCHAR2(27);
  --vedicao number;    -- SS45936/SM145734 - Claudio Pinheiro
  vedicao             VARCHAR2(2); -- SS45936/SM145734 - Claudio Pinheiro
  vclasse             number;
  dif_tam             number;
  vtiposervico        varchar2(50);
  vtiposervico1       NUMBER;
  err_code            number(38);  ---number
  emesg               VARCHAR2(300);---250
  vnomemarcapetformal varchar2(300);
  vcontapetformal     number;
  vnomemarca          varchar2(300);
  CONTASITWORKFLOW    NUMBER;
  CONTASITWORKFLOW2   NUMBER;

  vNUMEROPROCESSO NUMBER(9);
  vCODDOCUMENTO   NUMBER(2);
  vDESCDOCUMENTO  VARCHAR2(255);

  vQTDPEDDOC       cQTDPEDDOC%rowtype;
  vqtd             number;
  vQTDPEDVIENNA    cQTDPEDVIENNA%rowtype;
  vqtd2            number;
  vCODVIENNA       varchar2(100);----10
  vDESPACHOINTERNO VARCHAR2(1000);
  wkgPathArq       Varchar2(50) := 'BDMARCAS_GERATXTS_PRC_DIR';
  -----wkgPathArq       Varchar2(50) := 'd:/gera_txt_ipas';

  /*vari¿veis para impress¿o de clob*/
  l_amt    NUMBER DEFAULT 32000;
  l_offset NUMBER DEFAULT 1;
  l_length NUMBER;
  x        varchar2(32760);

  vLOCATOR number(2) := 0; --claudio

BEGIN
  BEGIN
    ---------*********ESCREVE ARQUIVO MRC_PET**************--------------------------
    NOMEARQ := 'MRC_PED_IPAS_' || TO_CHAR(SYSDATE, 'YYMMDD') || '.txt';
    fileID  := UTL_FILE.FOPEN(wkgPathArq, nomearq, 'wb', 32760);
    NRLINHA := 1;
    OPEN cSOLICITACAO_PED;
    FETCH cSOLICITACAO_PED
      INTO vSOLICITACAO_PED;
    WHILE cSOLICITACAO_PED%FOUND LOOP

      ------------BUSCA DO DOCUMENTO DO TITULAR-----------------------------
      IF vSOLICITACAO_PED.SIGLAPAISTITULAR <> 'BR' THEN
        BEGIN
          vLOCATOR := 1; --claudio
          SELECT DISTINCT NRDOCUMENTO
            INTO vNUMDOCTIT
            FROM DOCUMENTOUSUARIO
           WHERE CODTIPODOCUMENTO = 3
             AND IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALTITULAR;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vNUMDOCTIT := ' ';
        END;
      END IF;

      IF vSOLICITACAO_PED.SIGLAPAISTITULAR = 'BR' THEN
        vLOCATOR := 2; --claudio
        SELECT CODTIPOSITUACAO
          INTO vSITUACAO
          FROM USUARIOEXTERNO
         WHERE IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALTITULAR;

        IF vSITUACAO in (1, 3, 4, 5, 6, 7, 8, 9, 10) THEN
          BEGIN
            vLOCATOR := 3; --claudio
            SELECT DISTINCT NRDOCUMENTO
              INTO vNUMDOCTIT
              FROM DOCUMENTOUSUARIO
             WHERE CODTIPODOCUMENTO = 2
               AND IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALTITULAR;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vNUMDOCTIT := ' ';
          END;
        ELSIF vSITUACAO = 2 THEN
          BEGIN
            vLOCATOR := 4; --claudio
            SELECT DISTINCT NRDOCUMENTO
              INTO vNUMDOCTIT
              FROM DOCUMENTOUSUARIO
             WHERE CODTIPODOCUMENTO = 1
               AND IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALTITULAR;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vNUMDOCTIT := ' ';
          END;
        ELSE
          vNUMDOCTIT := ' ';
        END IF;

      END IF;

      IF vSOLICITACAO_PED.SIGLAPAISTITULAR = ' ' THEN
        vNUMDOCTIT := ' ';
      END IF;

      -------------BUSCA CNPJ OU CPF DE PROCURADOR, CONFORME SEJA AGENTE OU ESCRIT¿RIO------***
      IF vSOLICITACAO_PED.SEQUENCIALPROCURADOR IS NOT NULL THEN

        IF vSOLICITACAO_PED.IDSEQUENCIALESC IS NOT NULL THEN
          BEGIN
            vLOCATOR := 5; --claudio
            SELECT DISTINCT CNPJ
              INTO vIDUSU
              FROM ESCRITORIO
             WHERE IDSEQUENCIALESC = vSOLICITACAO_PED.IDSEQUENCIALESC;

            vTIPOPROC := 'E';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vIDUSU    := ' ';
              vTIPOPROC := ' ';
          END;
        ELSE
          BEGIN
            vLOCATOR := 6; --claudio
            SELECT DISTINCT NRDOCUMENTO
              INTO vIDUSU
              FROM DOCUMENTOUSUARIO
             WHERE IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALPROCURADOR
               AND CODTIPODOCUMENTO = 1;

            vTIPOPROC := 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vIDUSU    := ' ';
              vTIPOPROC := ' ';
          END;
        END IF;
      ELSE
        vIDUSU    := ' ';
        vTIPOPROC := ' ';
      END IF;

      -------------------------BUSCA DO OAB E API DO PROCURADOR----------------
      IF vSOLICITACAO_PED.SEQUENCIALPROCURADOR IS NOT NULL THEN
        BEGIN
          vLOCATOR := 7; --claudio
          SELECT DISTINCT NRDOCUMENTO
            INTO vAPI
            FROM DOCUMENTOUSUARIO
           WHERE IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALPROCURADOR
             AND CODTIPODOCUMENTO = 4;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vAPI := ' ';
        END;

        BEGIN
          vLOCATOR := 8; --claudio
          SELECT DISTINCT substr(NRDOCUMENTO, 1, length(nrdocumento) - 2)
            INTO vOAB
            FROM DOCUMENTOUSUARIO
           WHERE IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALPROCURADOR
             AND CODTIPODOCUMENTO = 5;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vOAB := ' ';
        END;

        BEGIN
          vLOCATOR := 9; --claudio
          SELECT DISTINCT substr(NRDOCUMENTO,
                                 length(nrdocumento) - 1,
                                 length(nrdocumento))
            INTO vSIGLAUFPROC
            FROM DOCUMENTOUSUARIO
           WHERE IDSEQUENCIAL = vSOLICITACAO_PED.SEQUENCIALPROCURADOR
             AND CODTIPODOCUMENTO = 5;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vSIGLAUFPROC := ' ';
        END;
      ELSE
        vAPI         := ' ';
        vOAB         := ' ';
        vSIGLAUFPROC := ' ';
      END IF;

      --------- VERIFICA SE EXISTE PRIORIDADE UNIONISTA P/ processo ou p/ peticao de cumprimento formal (se o processo estiver associado)---
      --------- PARA os QUE TIVEREM, BUSCA os dados de PU para A MENOR DATA UNIONISTA, CASO N¿O TENHA PU, IMPRIME BRANCO-----------
      SELECT COUNT(*)
        INTO VCONTASOLCUMPFORMALUN
        FROM PRIORIDADEUNIONISTA      PU,
             PETICAOCUMPRIMENTOFORMAL PCF,
             PETICAOPROCESSO          PP
       WHERE PU.CODSOLICITACAOCUMPFORMAL = PCF.CODSOLICITACAO
         AND PCF.CODSOLICITACAO = PP.CODSOLICITACAOPETICAO
         AND PP.CODSOLICITACAOPROCESSO = vSOLICITACAO_PED.SOLICITACAO;

      SELECT COUNT(*)
        INTO VCONTAPU
        FROM PRIORIDADEUNIONISTA PU
       WHERE vSOLICITACAO_PED.MARCA = PU.CODMARCA;

      IF VCONTASOLCUMPFORMALUN > 0 THEN
        BEGIN
          vLOCATOR := 10; --claudio
          SELECT distinct RPAD(NVL(TO_CHAR(PU.NRREGISTRO), ' '), 15, ' ') ||
                          RPAD(TO_CHAR(PU.SIGLAPAIS), 2, ' ') ||
                          RPAD(TO_CHAR(PU.DATA, 'DD-MM-YYYY'), 10, ' ')
            INTO VREGISTRO
            FROM PRIORIDADEUNIONISTA      PU,
                 PETICAOCUMPRIMENTOFORMAL PCF,
                 PETICAOPROCESSO          PP
           WHERE PU.CODSOLICITACAOCUMPFORMAL = PCF.CODSOLICITACAO
             AND PCF.CODSOLICITACAO = PP.CODSOLICITACAOPETICAO
             AND PP.CODSOLICITACAOPROCESSO = vSOLICITACAO_PED.SOLICITACAO
             AND PU.DATA =
                 (SELECT MIN(PRIO.DATA)
                    FROM PRIORIDADEUNIONISTA PRIO,
                         SOLICITACAO         SOL,
                         PETICAOPROCESSO     PP
                   WHERE PRIO.CODSOLICITACAOCUMPFORMAL =
                         PU.CODSOLICITACAOCUMPFORMAL
                     AND SOL.CODSOLICITACAO = PP.CODSOLICITACAOPETICAO
                     AND PP.CODSOLICITACAOPETICAO =
                         PRIO.CODSOLICITACAOCUMPFORMAL
                     AND PP.CODSOLICITACAOPROCESSO =
                         vSOLICITACAO_PED.SOLICITACAO);
          -- dbms_output.put_line ('registro1: '||vREGISTRO);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vREGISTRO := NULL;
        END;

      ELSIF VCONTAPU > 0 THEN
        BEGIN
          vLOCATOR := 11; --claudio
          SELECT distinct RPAD(NVL(TO_CHAR(PU.NRREGISTRO), ' '), 15, ' ') ||
                          RPAD(TO_CHAR(PU.SIGLAPAIS), 2, ' ') ||
                          RPAD(TO_CHAR(PU.DATA, 'DD-MM-YYYY'), 10, ' ')
            INTO VREGISTRO
            FROM PRIORIDADEUNIONISTA PU, PROCESSO PROC
           WHERE PU.CODMARCA = PROC.CODMARCA
             AND PROC.CODSOLICITACAO = vSOLICITACAO_PED.SOLICITACAO
             AND PU.DATA = (SELECT MIN(PRIO.DATA)
                              FROM PRIORIDADEUNIONISTA PRIO
                             WHERE PRIO.CODMARCA = PROC.CODMARCA);
          --   dbms_output.put_line ('registro2: '||vREGISTRO);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vREGISTRO := NULL;
          WHEN TOO_MANY_ROWS THEN
            -- Claudio 29/01/09
            -- PEGA APENAS O PRIMEIRO REGISTRO      -- Claudio 29/01/09
            SELECT REG_UNICO
              INTO VREGISTRO
              FROM ( -- Claudio 29/01/09
                    SELECT distinct RPAD(NVL(TO_CHAR(PU.NRREGISTRO), ' '),
                                          15,
                                          ' ') ||
                                     RPAD(TO_CHAR(PU.SIGLAPAIS), 2, ' ') ||
                                     RPAD(TO_CHAR(PU.DATA, 'DD-MM-YYYY'),
                                          10,
                                          ' ') REG_UNICO -- Claudio 29/01/09
                      FROM PRIORIDADEUNIONISTA PU, PROCESSO PROC -- Claudio 29/01/09
                     WHERE PU.CODMARCA = PROC.CODMARCA
                       AND -- Claudio 29/01/09
                           PROC.CODSOLICITACAO = vSOLICITACAO_PED.SOLICITACAO
                       AND -- Claudio 29/01/09
                           PU.DATA =
                           (SELECT MIN(PRIO.DATA) -- Claudio 29/01/09
                              FROM PRIORIDADEUNIONISTA PRIO -- Claudio 29/01/09
                             WHERE PRIO.CODMARCA = PROC.CODMARCA) -- Claudio 29/01/09
                    )
             WHERE ROWNUM = 1; -- Claudio 29/01/09
        END;

      ELSE
        vREGISTRO := NULL;

      END IF;
      --dbms_output.put_line ('solicitaca¿¿o: '||vSOLICITACAO_PED.SOLICITACAO);

      ----------------------------REALIZA CONCATENA¿¿O DA ESPECIFICA¿¿O COM O COMPLEMENTO DO TIPO DE DESPACHO DA SOLICITA¿¿O-----------------------------------

      OPEN cESPECIFICACAODESPACHO(vSOLICITACAO_PED.SOLICITACAO);
      FETCH cESPECIFICACAODESPACHO
        INTO vESPECIFICACAODESPACHO;
      vTEXTO  := '';
      vTEXTO2 := '';
      WHILE cESPECIFICACAODESPACHO%FOUND LOOP

        IF vESPECIFICACAODESPACHO.ESPECIFICACAO <> ' ' THEN
          vTEXTO := vTEXTO || replace(vESPECIFICACAODESPACHO.ESPECIFICACAO,
                                      'Sem Especifica¿¿o.',
                                      ' ') || '|';
        END IF;

        IF vESPECIFICACAODESPACHO.COMPLEMENTO <> ' ' THEN
          vTEXTO := vTEXTO || vESPECIFICACAODESPACHO.COMPLEMENTO || '|';
        END IF;

        FETCH cESPECIFICACAODESPACHO
          INTO vESPECIFICACAODESPACHO;

      END LOOP;
      CLOSE cESPECIFICACAODESPACHO;

      IF SUBSTR(vTEXTO, 1, LENGTH(vTEXTO)) LIKE '%|' THEN
        vTEXTO := SUBSTR(vTEXTO, 1, LENGTH(vTEXTO) - 1);
      END IF;

      IF vtexto IS NULL THEN
        VTEXTO := ' ';
      END IF;

      --------------------------REALIZA A CONCATENA¿¿O DAS DESCRI¿¿ES DE ESPECIFICA¿¿O DA MARCA DO PROCESSO/PEDIDO CORRENTE-----------------------
      FOR rteste IN cESPECIFICACAOMARCA(vSOLICITACAO_PED.SOLICITACAO) LOOP
        vtiposervico  := '';
        vtiposervico1 := 0;
        BEGIN
          FOR rtiposervico IN cTIPOSERVICO(rteste.codsolicitacao,
                                           rteste.codespecificacao) LOOP

            IF rtiposervico.indicativotiposervico = 'A' THEN
              vtiposervico := vtiposervico || ' Assessoria,';
              --dbms_output.put_line ('Acessoria: '||vtiposervico);
            END IF;

            IF rtiposervico.indicativotiposervico = 'C' THEN
              vtiposervico := vtiposervico || ' Consultoria,';
              --dbms_output.put_line ('Acessoria: '||vtiposervico);
            END IF;

            IF rtiposervico.indicativotiposervico = 'I' THEN
              vtiposervico := vtiposervico || ' Informa¿¿o,';
              --dbms_output.put_line ('Acessoria: '||vtiposervico);
            END IF;

            IF rtiposervico.indicativotiposervico = 'O' THEN
              vtiposervico1 := 1;
              --vtiposervico:= vtiposervico || '';
            END IF;

          END LOOP;

          IF vtiposervico1 = 1 then
            vTEXTO2 := vTEXTO2 || rteste.DESCRICAO || ';';
          END IF;

          IF vtiposervico IS NOT NULL THEN
            --dbms_output.put_line ('tiposervico: '|| vtiposervico);
            vTEXTO2 := vTEXTO2 || rteste.DESCRICAO || '[' ||
                       substr(vtiposervico, 1, length(vtiposervico) - 1) ||
                       ' ];';
            --dbms_output.put_line ('vTEXTO2: '|| substr(vTEXTO2,1,100));
          END IF;

          vclasse := rteste.CODCLASSE;
          vedicao := rteste.EDICAO;
        END;
      END LOOP;

      IF SUBSTR(vTEXTO2, 1, LENGTH(vTEXTO2)) LIKE '%;' THEN
        vTEXTO2 := SUBSTR(vTEXTO2, 1, LENGTH(vTEXTO2) - 1);
      END IF;

      IF vtexto2 IS NULL THEN
        vtexto2 := ' ';
      END IF;

      OPEN cESPECIFICACAOMARCA(vSOLICITACAO_PED.SOLICITACAO);
      FETCH cESPECIFICACAOMARCA
        INTO vESPECIFICACAOMARCA;

      IF cESPECIFICACAOMARCA%NOTFOUND THEN
        -- SS45936/SM145734 - Claudio Pinheiro
        IF vSOLICITACAO_PED.NATUREZA = 4 AND
           ((vSOLICITACAO_PED.CODTIPOOBJETO = 3041) OR
           (vSOLICITACAO_PED.CODTIPOOBJETO = 3051) OR
           (vSOLICITACAO_PED.CODTIPOOBJETO = 3061) OR
           (vSOLICITACAO_PED.CODTIPOOBJETO = 3071)) THEN
          BEGIN
            vclasse  := 42;
            vTEXTO2  := vSOLICITACAO_PED.SERVICOCERTIFICACAO;
            vLOCATOR := 12; --claudio
            SELECT to_number(EDICAO)
              INTO vedicao
              FROM VIGENCIACLASSENICE
            --WHERE To_char(vSOLICITACAO_PED.datahora,'DD/MM/YYYY HH24:MI:SS') between To_char(DATAINICIOVIGENCIA,'DD/MM/YYYY HH24:MI:SS') and To_char(DATAFINALVIGENCIA,'DD/MM/YYYY HH24:MI:SS');
             WHERE To_DATE(vSOLICITACAO_PED.datahora,
                           'DD/MM/YYYY hh24:mi:ss') between
                   To_DATE(DATAINICIOVIGENCIA, 'DD/MM/YYYY hh24:mi:ss') and
                   To_DATE(DATAFINALVIGENCIA, 'DD/MM/YYYY hh24:mi:ss');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vedicao := ' ';
          END;
        ELSE
          BEGIN
            vTEXTO2 := ' ';
            vclasse := ' ';
            vedicao := ' ';
          END;

          --vTEXTO2 := ' ';       -- SS45936/SM145734
          --vclasse := ' ';       -- SS45936/SM145734
          --vedicao := ' ';       -- SS45936/SM145734

        END IF;
        ------------ FIM SS45936/SM145734
      END IF;

      /*Busca despacho interno  */
      --dbms_output.put_line ('solicitacao: '||vSOLICITACAO_PED.SOLICITACAO);
      vLOCATOR := 13; --claudio
      BEGIN
        SELECT DISTINCT NVL(d.despachointerno, ' ')
          INTO vdespachointerno
          FROM despachosolicitacao d, especificacaodespachosolicitac e
         WHERE d.codsolicitacao = vSOLICITACAO_PED.SOLICITACAO
           and d.codsolicitacao = e.codsolicitacao
           and to_char(d.datahora, 'dd/mm/yyyy hh24:mi:ss') =
               to_char(e.datahora, 'dd/mm/yyyy hh24:mi:ss')
           and e.codtipodespacho = 3;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          --pegando apenas a informa¿¿o do registro mais recente, caso mais de um despacho seja selecionado
          select NVL(despachointerno, ' ')
            INTO vdespachointerno
            from (SELECT *
                    FROM despachosolicitacao            d,
                         especificacaodespachosolicitac e
                   WHERE d.codsolicitacao = 789758
                     and d.codsolicitacao = e.codsolicitacao
                     and to_char(d.datahora, 'dd/mm/yyyy hh24:mi:ss') =
                         to_char(e.datahora, 'dd/mm/yyyy hh24:mi:ss')
                     and e.codtipodespacho = 3
                     and rownum = 1
                   ORDER BY d.datahora DESC);
      END;
      /*fim Busca despacho interno*/

      /*Concatena a vari¿vel vtexto2 referente ¿ concatena¿¿o das especifica¿¿es com branco - ' '*/
      vbranco := ' ';
      IF DBMS_LOB.getlength(vtexto2) < 50000 then
        BEGIN
          dif_tam := 50000 - DBMS_LOB.getlength(vtexto2);
          WHILE dbms_lob.getlength(vbranco) < dif_tam loop
            vbranco := vbranco || ' ';
          END LOOP;
          vtexto2 := vtexto2 || vbranco;
        END;
      END IF;
      /* fim da concatena¿¿o de vtexto2 com branco*/

      -- dbms_output.put_line ('solicitacao: '||vSOLICITACAO_PED.SOLICITACAO);
      -- dbms_output.put_line ('vtexto2: '||vTEXTO2);
      CLOSE cESPECIFICACAOMARCA;

      ------------busca o elemento nominativo da marca, se o processo possui uma peti¿¿o de cump formal atrelada,
      ----buscar o elementnom desta peti¿¿o, sen¿o o do pr¿prio processo--

      SELECT count(pcf.elementonominativomarca)
        into vcontapetformal
        FROM PETICAOCUMPRIMENTOFORMAL PCF, PETICAOPROCESSO PP
       WHERE PCF.CODSOLICITACAO = PP.CODSOLICITACAOPETICAO
         AND PP.CODSOLICITACAOPROCESSO = vSOLICITACAO_PED.SOLICITACAO;

      IF vcontapetformal > 0 THEN
        vLOCATOR := 14; --claudio
        SELECT distinct pcf.elementonominativomarca
          into vnomemarcapetformal
          FROM PETICAOCUMPRIMENTOFORMAL PCF, PETICAOPROCESSO PP
         WHERE PCF.CODSOLICITACAO = PP.CODSOLICITACAOPETICAO
           AND PP.CODSOLICITACAOPROCESSO = vSOLICITACAO_PED.SOLICITACAO;

        vnomemarca := vnomemarcapetformal;
        --dbms_output.put_line ('petformalmarca: '||vnomemarca);
      ELSE
        vnomemarca := vSOLICITACAO_PED.NOMEMARCA;
        --dbms_output.put_line ('processomarca: '||vnomemarca);
      END IF;

      -------------busca qtd de linha da consulta do peddoc e pedvienna por processo vinculada com mrc_ped---------------------------
      OPEN cQTDPEDDOC(vSOLICITACAO_PED.SOLICITACAO);
      FETCH cQTDPEDDOC
        INTO vQTDPEDDOC;

      IF cQTDPEDDOC%NOTFOUND THEN
        vqtd := 0;
        -- dbms_output.put_line( 'solicitacao vqtd 0 '||vSOLICITACAO_PED.SOLICITACAO);
      ELSE
        vqtd := vQTDPEDDOC.contalinha;
        -- dbms_output.put_line( 'solicitacao vqtd diferente de 0: '||vSOLICITACAO_PED.SOLICITACAO);
        -- dbms_output.put_line( 'vqtd : '||vqtd );
      END IF;

      OPEN cQTDPEDVIENNA(vSOLICITACAO_PED.SOLICITACAO);
      FETCH cQTDPEDVIENNA
        INTO vQTDPEDVIENNA;

      IF cQTDPEDVIENNA%NOTFOUND THEN
        vqtd2 := 0;
        -- dbms_output.put_line( 'solicitacao vqtd2 0 '||vSOLICITACAO_PED.SOLICITACAO);
      ELSE
        vqtd2 := vQTDPEDVIENNA.CONTALINHAPROC_MRCPEDVIENNA;
        -- dbms_output.put_line( 'solicitacao vqtd2 diferente de 0: '||vSOLICITACAO_PED.SOLICITACAO);
        -- dbms_output.put_line( 'vqtd2 : '||vqtd2 );
      END IF;

      ----------------------IMPRIME OS DADOS NO ARQUIVO TXT-----------------------------------------
      /*Procedimento para gravar o campo clob e resolver problema de estouro de buffer*/
      l_offset := 1;

      vtexto_parte1 := RPAD(TO_CHAR(NRLINHA), 5, ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.DATAENVIO), ' '),
                            10,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.HORAENVIO), ' '),
                            5,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.PROCESSO), ' '),
                            9,
                            ' ') || RPAD(TO_CHAR(vSOLICITACAO_PED.SIGLAPAISTITULAR),
                                         2,
                                         ' ') ||
                       LPAD(nvl(TO_CHAR(vclasse), ' '), 2, '0') ||
                       RPAD(nvl(TO_CHAR(vedicao), ' '), 2, ' ') ||
                       RPAD(TO_CHAR(vIDUSU), 14, ' ') ||
                       RPAD(TO_CHAR(vTIPOPROC), 1, ' ') ||
                       RPAD(TO_CHAR(vNUMDOCTIT), 14, ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.APRESEN), ' '),
                            1,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vREGISTRO), ' '), 27, ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.DATAHORA,
                                        'DD-MM-YYYY'),
                                ' '),
                            10,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.NATUREZA), ' '),
                            1,
                            ' ') ||
                       RPAD(TO_CHAR(replace(NVL(vnomemarca, ' '),
                                            chr(13) || chr(10),
                                            chr(35) || chr(36) || chr(37) ||
                                            chr(38))),
                            300,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.GRU), ' '),
                            16,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.TIPOOBJETO), ' '),
                            3,
                            ' ') ||
                       RPAD(NVL(TO_CHAR(vSOLICITACAO_PED.RAMIFICACAO), ' '),
                            2,
                            ' ') || RPAD(TO_CHAR(vAPI), 10, ' ') ||
                       RPAD(TO_CHAR(vOAB), 10, ' ') ||
                       RPAD(TO_CHAR(vSIGLAUFPROC), 2, ' ') ||
                       RPAD(TO_CHAR(REPLACE(vTEXTO,
                                            chr(13) || chr(10),
                                            chr(35) || chr(36) || chr(37) ||
                                            chr(38))),
                            4000,
                            ' ');

      l_length := NVL(DBMS_LOB.getlength(vtexto_parte1), 0);

      WHILE (l_offset < l_length) LOOP
        --dbms_output.put_line('vtexto3a: '||substr(vtexto3,1,200));
        dbms_lob.read(vtexto_parte1, l_amt, l_offset, x);
        -- dbms_output.put_line('l_amt: '||l_amt);
        -- dbms_output.put_line('l_offset: '||l_offset);
        UTL_FILE.put_raw(FILEID, utl_raw.cast_to_raw(x), FALSE);
        --UTL_FILE.fflush (FILEID);
        l_offset := l_offset + l_amt;
        --dbms_output.put_line('l_offset2: '||l_offset);
      END LOOP;

      l_offset      := 1;
      vtexto_parte2 := REPLACE(vTEXTO2,
                               chr(13) || chr(10),
                               chr(35) || chr(36) || chr(37) || chr(38));
      l_length      := NVL(DBMS_LOB.getlength(vtexto_parte2), 0);

      WHILE (l_offset < l_length) LOOP
        --dbms_output.put_line('vtexto3a: '||substr(vtexto3,1,200));
        dbms_lob.read(vtexto_parte2, l_amt, l_offset, x);
        -- dbms_output.put_line('l_amt: '||l_amt);
        -- dbms_output.put_line('l_offset: '||l_offset);
        UTL_FILE.put_raw(FILEID, utl_raw.cast_to_raw(x), FALSE);
        --UTL_FILE.fflush (FILEID);
        l_offset := l_offset + l_amt;
        --dbms_output.put_line('l_offset2: '||l_offset);
      END LOOP;

      --dbms_output.put_line ('vtexto_parte2: '||substr(vTEXTO2,1,10));

      l_offset      := 1;
      vtexto_parte3 := RPAD(TO_CHAR(replace(vdespachointerno,
                                            chr(13) || chr(10),
                                            chr(35) || chr(36) || chr(37) ||
                                            chr(38))),
                            4000,
                            ' ') || RPAD(TO_CHAR(vqtd), 5, ' ') ||
                       RPAD(TO_CHAR(vqtd2), 5, ' ');
      l_length      := NVL(DBMS_LOB.getlength(vtexto_parte3), 0);

      WHILE (l_offset < l_length) LOOP
        --dbms_output.put_line('vtexto3a: '||substr(vtexto3,1,200));
        dbms_lob.read(vtexto_parte3, l_amt, l_offset, x);
        -- dbms_output.put_line('l_amt: '||l_amt);
        -- dbms_output.put_line('l_offset: '||l_offset);
        UTL_FILE.put_raw(FILEID, utl_raw.cast_to_raw(x), FALSE);
        --UTL_FILE.fflush (FILEID);
        l_offset := l_offset + l_amt;
        --dbms_output.put_line('l_offset2: '||l_offset);
      END LOOP;

      /*dbms_output.put_line ('vtexto_parte3: '||substr(vtexto_parte3,48447,9));
      dbms_output.put_line ('despacho interno: '||substr(vsolicitacao_ped.despachointerno,1,10));
      dbms_output.put_line ('vqtd: '||vqtd);
      dbms_output.put_line ('vqtd2: '||vqtd2);*/

      UTL_FILE.PUT_raw(FILEID, utl_raw.cast_to_raw(chr(10)), FALSE);
      /*fim de Procedimento para gravar o campo clob*/

      BEGIN
        INSERT INTO TMP_WORKFLOW2
          (codsolicitacao)
        VALUES
          (vSOLICITACAO_PED.SOLICITACAO);
      EXCEPTION
        WHEN OTHERS THEN

          dbms_output.put_line('Erro: Oracle : GERAMRC_PED_IPAS : INSERT codsolicitacao ' || vSOLICITACAO_PED.SOLICITACAO ||
                               TO_CHAR(SQLCODE) || ' : ' || SQLERRM);
      END;

      FETCH cSOLICITACAO_PED
        INTO vSOLICITACAO_PED;

      vTEXTO  := '';
      vTEXTO2 := '';
      NRLINHA := NRLINHA + 1;
      CLOSE cQTDPEDDOC;
      CLOSE cQTDPEDVIENNA;
    END LOOP;

    UTL_FILE.FCLOSE(FILEID);
    CLOSE cSOLICITACAO_PED;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Oracle : GERAMRC_PED_IPAS : codsolicitacao ' ||
                           TO_CHAR(SQLCODE) || ' : ' || SQLERRM);
      dbms_output.put_line('LOCATOR = ' || TO_CHAR(vLOCATOR)); --claudio
      dbms_output.put_line('SOLICITACAO = ' ||
                           TO_CHAR(vSOLICITACAO_PED.SOLICITACAO)); --claudio
      dbms_output.put_line('SEQUENCIALTITULAR = ' ||
                           TO_CHAR(vSOLICITACAO_PED.SEQUENCIALTITULAR)); --claudio
      dbms_output.put_line('IDSEQUENCIALESC = ' ||
                           TO_CHAR(vSOLICITACAO_PED.IDSEQUENCIALESC)); --claudio
      dbms_output.put_line('SEQUENCIALPROCURADOR = ' ||
                           TO_CHAR(vSOLICITACAO_PED.SEQUENCIALPROCURADOR)); --claudio
      dbms_output.put_line('DATAHORA = ' ||
                           TO_CHAR(vSOLICITACAO_PED.DATAHORA,
                                   'DD/MM/YYYY hh24:mi:ss')); --claudio
  END;

  -------******************FIM DO ARQUIVO MRC_PED******************************-----------------

  BEGIN
    --------**************ESCREVE O ARQUIVO MRC_PEDDOC******************--------------

    nomearq := 'MRC_PEDDOC_IPAS_' || to_char(sysdate, 'YYMMDD') || '.txt';
    --fileID := UTL_FILE.FOPEN ('/home/oracle/arqstxt', nomearq, 'W');

    fileID := UTL_FILE.FOPEN(wkgPathArq, nomearq, 'W', 32767);

    /* Quick and dirty construction here! */
    NRLINHA := 1;

    FOR rSOLICITACAO IN cSOLICITACAO_PEDDOC LOOP

      vNUMEROPROCESSO := rSOLICITACAO.NRPROCESSO;
      vCODDOCUMENTO   := rSOLICITACAO.CODTIPOANEXO;

      IF rSOLICITACAO.CODTIPOANEXO <> 11 THEN
        SELECT DESCRICAOANEXO
          INTO vDESCDOCUMENTO
          FROM TIPOANEXO
         WHERE CODTIPOANEXO = rSOLICITACAO.CODTIPOANEXO;
      ELSIF rSOLICITACAO.CODTIPOANEXO = 11 AND
            rSOLICITACAO.CODOUTROTIPOANEXO IS NOT NULL THEN
        SELECT DESCRICAO
          INTO vDESCDOCUMENTO
          FROM OUTROTIPOANEXO
         WHERE CODOUTROTIPOANEXO = rSOLICITACAO.CODOUTROTIPOANEXO;
      ELSE
        vDESCDOCUMENTO := NULL;
      END IF;

      UTL_FILE.PUT_LINE(fileID,
                        RPAD(TO_CHAR(NRLINHA), 5, ' ') ||
                        LPAD(TO_CHAR(vNUMEROPROCESSO), 9, '0') ||
                        RPAD(TO_CHAR(vCODDOCUMENTO), 2, ' ') ||
                        RPAD(TO_CHAR(replace(NVL(vDESCDOCUMENTO, ' '),
                                             chr(13) || chr(10),
                                             chr(35) || chr(36) || chr(37) ||
                                             chr(38))),
                             255,
                             ' '));

      BEGIN
        INSERT INTO TMP_WORKFLOW2

          (codsolicitacao)
        VALUES
          (rSOLICITACAO.CODSOLICITACAO);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro: Oracle : GERAMRC_PEDDOC_IPAS: Insert rsolicitacao' || rSOLICITACAO.CODSOLICITACAO ||
                               TO_CHAR(SQLCODE) || ' : ' || SQLERRM);
      END;

      NRLINHA := NRLINHA + 1;
    END LOOP;

    UTL_FILE.FCLOSE(fileID);

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Oracle : GERAMRC_PEDDOC_IPAS : '  ||
                           TO_CHAR(SQLCODE) || ' : ' || SQLERRM);

  END;

  --------------**************FIM DO ARQUIVO MRC_PEDDOC**************---------------------

  BEGIN
    ----****************INC¿CIO DO ARQUIVO MRC_PEDVIENNA**************------------------

    nomearq := 'MRC_PEDVIENNA_IPAS_' || to_char(sysdate, 'YYMMDD') || '.txt';
    --fileID := UTL_FILE.FOPEN ('/home/oracle/arqstxt', nomearq, 'W');
    fileID := UTL_FILE.FOPEN(wkgPathArq, nomearq, 'W', 32767);
    /* Quick and dirty construction here! */
    NRLINHA := 1;
    FOR arqrec IN cPEDVIENNA LOOP
      UTL_FILE.PUT_LINE(fileID,
                        RPAD(TO_CHAR(NRLINHA), 5, ' ') ||
                        LPAD(TO_CHAR(arqrec.processo), 9, '0') ||
                        RPAD(TO_CHAR(replace(arqrec.codviena, '.0', ' ')),
                             10,
                             ' '));
      BEGIN
        INSERT INTO TMP_WORKFLOW2
          (codsolicitacao)
        VALUES
          (arqrec.SOLICITACAO);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro: Oracle : GERAMRC_PEDVIENNA_IPAS: INSERT  ' ||
                               TO_CHAR(SQLCODE) || ' : ' || SQLERRM);
      END;

      NRLINHA := NRLINHA + 1;
    END LOOP;

    UTL_FILE.FCLOSE(fileID);

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Oracle : GERAMRC_PEDVIENNA_IPAS: ' ||
                           TO_CHAR(SQLCODE) || ' : ' || SQLERRM);
  END;
  -----------***************FIM DO ARQUIVO MRC_PEDVIENNA*************------------

  BEGIN
    ----------****************EXECUTA A PROCEDURE PARA GRAVA¿¿O DAS IMAGENS NO DIRET¿RIO---******
    IMAGEM_MARCA_IPAS;

  END;
  -------****FIM DA EXECU¿¿O DA PROCEDURE PARA GRAVA¿¿O DAS IMAGENS---*********

  BEGIN
    --------*********ATUALIZA A TABELA SITUACAOSOLICITACAOWORKFLOW COM A NOVA SITUA¿¿*********---

    FOR rTEMP IN cTEMP LOOP

      SELECT COUNT(*)
        INTO CONTASITWORKFLOW
        FROM SITUACAOSOLICITACAOWORKFLOW A
       WHERE A.CODSOLICITACAO = rTEMP.CODSOLICITACAO
         AND EXISTS (SELECT B.CODSOLICITACAO
                FROM SITUACAOSOLICITACAOWORKFLOW B
               WHERE A.CODSOLICITACAO = B.CODSOLICITACAO
                 AND B.CODSITUACAOWORKFLOW = 4)
        AND NOT EXISTS (SELECT C.CODSOLICITACAO
                FROM SITUACAOSOLICITACAOWORKFLOW C
               WHERE A.CODSOLICITACAO = C.CODSOLICITACAO
                 AND C.CODSITUACAOWORKFLOW = 13);

      SELECT COUNT(*)
        INTO CONTASITWORKFLOW2
        FROM SITUACAOSOLICITACAOWORKFLOW
       WHERE CODSOLICITACAO = rTEMP.CODSOLICITACAO
         AND CODSITUACAOWORKFLOW = 13;

      IF CONTASITWORKFLOW > 0 THEN
        INSERT INTO SITUACAOSOLICITACAOWORKFLOW
          (CODSOLICITACAO, CODSITUACAOWORKFLOW, DATAHORA)
        VALUES
          (rTEMP.CODSOLICITACAO, 9, SYSDATE);
      END IF;

      IF CONTASITWORKFLOW2 > 0 THEN
        INSERT INTO SITUACAOSOLICITACAOWORKFLOW
          (CODSOLICITACAO, CODSITUACAOWORKFLOW, DATAHORA)
        VALUES
          (rTEMP.CODSOLICITACAO, 14, SYSDATE);
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Ao registrar Situacao Solicitacao WorkFlow : ' ||
                           TO_CHAR(SQLCODE) || ' : ' || SQLERRM);

  END;

  COMMIT;

END GERAMRC_PED_IPAS;
/
