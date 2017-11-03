CREATE OR REPLACE PROCEDURE geramrc_pet_ipas_1 AS

--Para catalogar 22/03/2011 INPI
--cat 24/04/2007 Bia
--comentado o

   -- Cursor do arquivo MRC_PET --
   CURSOR cSOLICITACAO_PET IS
      SELECT DISTINCT S.DATAHORA,
             P.NRPROTOCOLO,
             ds.despachointerno,
             S.IDSEQUENCIALPROCURADOR,
             S.IDSEQUENCIALESC,
             U.SIGLAPAIS,
             U.IDSEQUENCIAL U_IDSEQUENCIAL,
             UE.CODTIPOSITUACAO,
             UE.IDSEQUENCIAL UE_IDSEQUENCIAL,
             P.NRRPIGERADORA,
             S.NRGRU,
             P.TEXTOPETICAO,
             TD.CODSITUACAORPIPOSTERIOR,
             S.CODSOLICITACAO,
             EDS.CODTIPODESPACHO
          FROM SOLICITACAO S,
               despachosolicitacao ds,
               TIPOOBJETO T,
               SITUACAOSOLICITACAOWORKFLOW SSW,
               PETICAO P,
               ESPECIFICACAODESPACHOSOLICITAC EDS,
               TIPODESPACHO TD,
               USUARIO U,
               USUARIOEXTERNO UE
          WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
            and s.codsolicitacao = ds.codsolicitacao
            and to_char(ssw.datahora,'DD/MM/YYYY HH24:MI:SS')=to_char(ds.datahora,'DD/MM/YYYY HH24:MI:SS')
            and ds.codsolicitacao = eds.codsolicitacao
            and to_char(ds.datahora,'DD/MM/YYYY HH24:MI:SS') = to_char(eds.datahora,'DD/MM/YYYY HH24:MI:SS')
            AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
            AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
            AND S.CODSOLICITACAO = P.CODSOLICITACAO
            AND S.IDSEQUENCIALREQUERENTE = U.IDSEQUENCIAL
            AND U.IDSEQUENCIAL = UE.IDSEQUENCIAL
            AND EDS.CODSOLICITACAO = S.CODSOLICITACAO
            AND TD.CODTIPODESPACHO = EDS.CODTIPODESPACHO
            AND T.CODASSUNTO = 2
            AND SSW.CODSITUACAOWORKFLOW = 4
          --  AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
          --                  WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
              --                AND SSW1.CODSITUACAOWORKFLOW = 9)
          --  AND EDS.CODTIPODESPACHO IN (7,9,511,552)
          --  AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581);
            AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') ;  
            ----trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1;
            --to_date('13-05-2008', 'DD-MM-YYYY' ) - 1;

    CURSOR cESPECIFICACAO(pCODSOLICITACAO IN NUMBER,pCODTIPODESPACHO IN NUMBER) IS
       SELECT EDS.CODTIPODESPACHO,
              ETD.ESPECIFICACAO as ESPECIFICACAO,
              EDS.COMPLEMENTO as COMPLEMENTO,
              TD.CODSITUACAORPIPOSTERIOR
        FROM ESPECIFICACAODESPACHOSOLICITAC EDS,
             ESPECIFICACAOTIPODESPACHO ETD,
             TIPODESPACHO TD
        WHERE EDS.CODSOLICITACAO   = pCODSOLICITACAO;
      --  AND EDS.CODTIPODESPACHO = pCODTIPODESPACHO
         -- AND EDS.CODESPECIFICACAO = ETD.CODESPECIFICACAO
   --      AND EDS.CODTIPODESPACHO  = ETD.CODTIPODESPACHO
     --    AND TD.CODTIPODESPACHO   = ETD.CODTIPODESPACHO;
    -- Fim do cursor do arquivo MRC_PET --

    -- Cursor do arquivo MRC_PETDOC --
    CURSOR cSOLICITACAO_PETDOC IS
      SELECT DISTINCT P.NRPROTOCOLO,
                      AN.CODTIPOANEXO,
                      AN.CODOUTROTIPOANEXO,
                      S.CODSOLICITACAO
          FROM SOLICITACAO S,
               TIPOOBJETO T,
               SITUACAOSOLICITACAOWORKFLOW SSW,
               PETICAO P,
               ESPECIFICACAODESPACHOSOLICITAC EDS,
               ANEXO AN
          WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
            AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
            AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
            AND S.CODSOLICITACAO = P.CODSOLICITACAO
            AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
            AND AN.CODSOLICITACAO  = S.CODSOLICITACAO
          --  AND EDS.CODTIPODESPACHO IN (7, 9, 511, 552)
            AND T.CODASSUNTO = 2
         --   AND SSW.CODSITUACAOWORKFLOW = 4
         --   AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
          --                  WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
          --                    AND SSW1.CODSITUACAOWORKFLOW = 9)
          --  AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581)
           AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY');
           --to_date('13-05-2008', 'DD-MM-YYYY' ) - 1;
    -- Fim do cursor do arquivo MRC_PETDOC --

    -- Cursor consulta qtd de registros de uma petic?o no arquivo MRC_PETDOC --
    CURSOR cQTD_SOLICITACAO_PETDOC (pCODSOLICITACAO IN NUMBER) IS
      SELECT CODSOLICITACAO, COUNT(*) CONTA_PETICAO_PETDOC
      FROM (
      SELECT DISTINCT P.NRPROTOCOLO,
                      AN.CODTIPOANEXO,
                      AN.CODOUTROTIPOANEXO,
                      S.CODSOLICITACAO
          FROM SOLICITACAO S,
               TIPOOBJETO T,
               SITUACAOSOLICITACAOWORKFLOW SSW,
               PETICAO P,
               ESPECIFICACAODESPACHOSOLICITAC EDS,
               ANEXO AN
          WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
            AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
            AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
            AND S.CODSOLICITACAO = P.CODSOLICITACAO
            AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
            AND AN.CODSOLICITACAO  = S.CODSOLICITACAO
         --   AND EDS.CODTIPODESPACHO IN (7, 9, 511, 552)
            AND T.CODASSUNTO = 2
      --      AND SSW.CODSITUACAOWORKFLOW = 4
      --      AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
      --                      WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
       --                       AND SSW1.CODSITUACAOWORKFLOW = 9)
      --      AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581))
      AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY') )
      ----trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1)
      --to_date('13-05-2008', 'DD-MM-YYYY' ) - 1)
    --  WHERE CODSOLICITACAO = pCODSOLICITACAO
        GROUP BY CODSOLICITACAO;
    -- Fim do cursor do arquivo MRC_PETDOC --


    -- Cursor do arquivo MRC_PETPROC --
     CURSOR cSOLICITACAO_PETPROC IS
        SELECT DISTINCT
               P.NRPROTOCOLO,
               S.CODTIPOOBJETO,
               S.CODSOLICITACAO,
               P.CODSOLICITACAOCUMPRE ---ADICIONADO EM 29/09/06
            FROM SOLICITACAO S,
                 TIPOOBJETO T,
                 SITUACAOSOLICITACAOWORKFLOW SSW,
                 PETICAO P,
                 ESPECIFICACAODESPACHOSOLICITAC EDS
            WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
              AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
              AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
              AND S.CODSOLICITACAO = P.CODSOLICITACAO
              AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
       --       AND EDS.CODTIPODESPACHO IN (7, 9, 511, 552)
              AND T.CODASSUNTO = 2
       --       AND SSW.CODSITUACAOWORKFLOW = 4
         --     AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
         --                     WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
       --                         AND SSW1.CODSITUACAOWORKFLOW = 9)
        --      AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581);
              AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY' );
              ----trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1;
              --to_date('13-05-2008', 'DD-MM-YYYY' ) - 1;

     CURSOR cPETICAOPROCESSO(pCODSOLICITACAO IN NUMBER) IS
        SELECT P.NRPROCESSO, P.CODSOLICITACAO
          FROM PETICAOPROCESSO PP,
               PROCESSO P
         WHERE PP.CODSOLICITACAOPETICAO = pCODSOLICITACAO
           AND PP.CODSOLICITACAOPROCESSO = P.CODSOLICITACAO;

     CURSOR cPETICAOPROCESSOPS(pCODSOLICITACAO IN NUMBER) IS
        SELECT PP.NRPROCESSOPAPELOUSINPI
          FROM PETICAOPROCESSOPAPELOUSINPI PP
         WHERE PP.CODSOLICITACAO = pCODSOLICITACAO;
   -------ADICIONADO EM 29/09/06---------------------
    CURSOR cPETCUMPREPROCESSO(pCODSOLICITACAO IN NUMBER) IS
       SELECT DISTINCT
       -- PE.NRPROTOCOLO,
        PR.NRPROCESSO, PR.CODSOLICITACAO
       FROM
        PETICAO PE,
        PETICAOPROCESSO PP,
        PROCESSO PR
       WHERE PE.CODSOLICITACAOCUMPRE = PP.CODSOLICITACAOPETICAO AND
             PP.CODSOLICITACAOPROCESSO = PR.CODSOLICITACAO AND
             PE.CODSOLICITACAO = pCODSOLICITACAO;
     -- Fim do cursor do arquivo MRC_PETPROC --

    CURSOR cPETCUMPREPAPELPROC (pCODSOLICITACAO IN NUMBER) IS
      SELECT DISTINCT pp.nrprocessopapelousinpi
      from peticaoprocessopapelousinpi pp, peticao p
      where p.codsolicitacao = pcodsolicitacao and
            p.codsolicitacaocumpre = pp.codsolicitacao;

-- Cursor consulta quantidade de registros de uma determinada petic?o - MRC_PETPROC --
    Cursor cQTD_PETICAOPROCESSO_E_PS (pCODSOLICITACAO IN NUMBER) IS    --ADICIONADO EM 29/09/06--
    SELECT PETICAO, COUNT(*)  conta_peticao_petproc
    FROM (
       SELECT PP.CODSOLICITACAOPETICAO PETICAO, P.NRPROCESSO
       FROM PETICAOPROCESSO PP,
            PROCESSO P
       WHERE PP.CODSOLICITACAOPETICAO = pCODSOLICITACAO
       AND PP.CODSOLICITACAOPROCESSO = P.CODSOLICITACAO
       union
       SELECT PP.CODSOLICITACAO PETICAO, PP.NRPROCESSOPAPELOUSINPI
       FROM PETICAOPROCESSOPAPELOUSINPI PP
       WHERE PP.CODSOLICITACAO = pCODSOLICITACAO
       union
       SELECT PE.CODSOLICITACAO PETICAO, PR.NRPROCESSO
       FROM PETICAO PE,
        PETICAOPROCESSO PP,
        PROCESSO PR
       WHERE PE.CODSOLICITACAOCUMPRE = PP.CODSOLICITACAOPETICAO AND
             PP.CODSOLICITACAOPROCESSO = PR.CODSOLICITACAO AND
             PE.CODSOLICITACAO = pCODSOLICITACAO
       union
       SELECT pp.codsolicitacao peticao, pp.nrprocessopapelousinpi
       from peticaoprocessopapelousinpi pp, peticao p
       where p.codsolicitacao = pcodsolicitacao and
            p.codsolicitacaocumpre = pp.codsolicitacao
       )
    GROUP BY PETICAO;

----Fim do cursor quantidade de registros de uma determinada petic?o - MRC_PETPROC --

     -- Cursor do arquivo MRC_PETSERV --
     CURSOR cSOLICITACAO_PETSERV IS
      SELECT DISTINCT P.NRPROTOCOLO,
                      S.CODTIPOOBJETO,
                      S.CODSOLICITACAO
          FROM SOLICITACAO S,
               TIPOOBJETO T,
               SITUACAOSOLICITACAOWORKFLOW SSW,
               PETICAO P,
               ESPECIFICACAODESPACHOSOLICITAC EDS
          WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
            AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
            AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
            AND S.CODSOLICITACAO = P.CODSOLICITACAO
            AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
       --     AND EDS.CODTIPODESPACHO IN (7, 9, 511, 552)
            AND T.CODASSUNTO = 2
       --     AND SSW.CODSITUACAOWORKFLOW = 4
         --   AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
         --                   WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
       --                       AND SSW1.CODSITUACAOWORKFLOW = 9)
       --     AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581)
       AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY' ); 
       ---- - 1;
     -- Fim do cursor do arquivo MRC_PETSERV --


 -- Cursor consulta qtd de registros de uma petic?o no arquivo MRC_PETSERV --
     CURSOR cQTD_SOLICITACAO_PETSERV (pCODSOLICITACAO IN NUMBER) IS
     SELECT CODSOLICITACAO, COUNT(*) conta_peticao_PETSERV
     FROM (
      SELECT DISTINCT P.NRPROTOCOLO,
                      S.CODTIPOOBJETO,
                      S.CODSOLICITACAO
          FROM SOLICITACAO S,
               TIPOOBJETO T,
               SITUACAOSOLICITACAOWORKFLOW SSW,
               PETICAO P,
               ESPECIFICACAODESPACHOSOLICITAC EDS
          WHERE S.CODTIPOOBJETO = T.CODTIPOOBJETO
            AND TO_CHAR(S.DATAINICIOVIGENCIA,'DD/MM/YYYY')=TO_CHAR(T.DATAINICIOVIGENCIA,'DD/MM/YYYY')
            AND S.CODSOLICITACAO = SSW.CODSOLICITACAO
            AND S.CODSOLICITACAO = P.CODSOLICITACAO
            AND S.CODSOLICITACAO = EDS.CODSOLICITACAO
        --    AND EDS.CODTIPODESPACHO IN (7, 9, 511, 552)
            AND T.CODASSUNTO = 2
         --   AND SSW.CODSITUACAOWORKFLOW = 4
          --  AND NOT EXISTS (SELECT 1 FROM SITUACAOSOLICITACAOWORKFLOW SSW1
          --                  WHERE SSW1.CODSOLICITACAO = S.CODSOLICITACAO
         --                     AND SSW1.CODSITUACAOWORKFLOW = 9)
         --   AND S.CODTIPOOBJETO NOT IN (3471,3431,3441,3451,3461,8243,8253,3501,3502,3381,3571,3581))
         AND trunc(S.DATAHORA) = to_date('11-03-2011', 'DD-MM-YYYY'))
         ------trunc(S.DATAHORA) = to_date(SYSDATE, 'DD-MM-YYYY') - 1)
         --to_date('13-05-2008', 'DD-MM-YYYY' ) - 1)
  --  WHERE CODSOLICITACAO = pCODSOLICITACAO
        GROUP BY CODSOLICITACAO;
-- Fim do cursor cQTD_SOLICITACAO_PETSERV --


   FILEID             UTL_FILE.FILE_TYPE;
   NOMEARQ            VARCHAR2(50);
   FILEID1             UTL_FILE.FILE_TYPE;
   NOMEARQ1            VARCHAR2(50);
   FILEID2             UTL_FILE.FILE_TYPE;
   NOMEARQ2            VARCHAR2(50);
   FILEID3             UTL_FILE.FILE_TYPE;
   NOMEARQ3            VARCHAR2(50);
   vESPECIFICACAO     cESPECIFICACAO%ROWTYPE;
   vQTD_SOLICITACAO_PETDOC cQTD_SOLICITACAO_PETDOC%ROWTYPE;
   vQTD_SOLICITACAO_PETSERV cQTD_SOLICITACAO_PETSERV%ROWTYPE;
   vQTD_PETICAOPROCESSO_E_PS cQTD_PETICAOPROCESSO_E_PS%ROWTYPE;
   rprocura1 cPETCUMPREPROCESSO%ROWTYPE;
   vDATAHORAENVIO     DATE;
   vNUMEROPROTOCOLO   NUMBER(12);
   vIDPROCURADOR      VARCHAR2(18);
   vIDTIPOPROCURADOR  VARCHAR2(1);
   vIDTITULAR         VARCHAR2(18);
   vCONTAESC          NUMBER(2);
   vNRRPI             NUMBER(12);
   vNRGRU             VARCHAR2(16);
   vTEXTOPETICAO      VARCHAR2(2500);
   vCODDESPACHO       NUMBER(3);
   vSITDESPACHO       NUMBER(3);
   vTEXTO             VARCHAR2(4000);
   vNRLINHA           NUMBER(5);
   vCODDOCUMENTO      NUMBER(2);
   vDESCDOCUMENTO     VARCHAR2(255);
   vCODSERVICO        VARCHAR2(3);
   vCODRAMIFICACAO    VARCHAR2(2);
   vqtd number;
   vqtd2 number;
   vqtd3 number;
   vDESCRICAOOUTRAPETICAO VARCHAR2(100);
   vprocessoenviado CHAR(1); vcontaprocnaoenviado number;
   wkgPathArq       Varchar2(50) := 'BDMARCAS_GERATXTS_PRC_DIR';


BEGIN
  BEGIN
    -- Escreve arquivo MRC_PET --
    NOMEARQ := 'MRC_PET_IPAS_'||TO_CHAR(SYSDATE,'YYMMDD')||'.txt';
    --FILEID  := UTL_FILE.FOPEN ('/home/oracle/arqstxt', NOMEARQ, 'W',32767);
    fileID := UTL_FILE.FOPEN (wkgPathArq, nomearq, 'W',32767);
    
    vNRLINHA := 1;

     FOR rSOLICITACAO IN cSOLICITACAO_PET LOOP

         -- Verifica se o Procurador esta vinculado a algum escritorio --
    /*  IF rSOLICITACAO.IDSEQUENCIALPROCURADOR IS NOT NULL THEN

         IF rSOLICITACAO.IDSEQUENCIALESC IS NOT NULL THEN
           BEGIN
             SELECT distinct CNPJ
             INTO vIDPROCURADOR
             FROM SOLICITACAO SOL,
                  ESCRITORIO E
             WHERE SOL.IDSEQUENCIALESC = E.IDSEQUENCIALESC
               AND SOL.IDSEQUENCIALPROCURADOR = rSOLICITACAO.IDSEQUENCIALPROCURADOR;

            SELECT distinct CNPJ
            INTO vIDPROCURADOR
            FROM ESCRITORIO
           WHERE IDSEQUENCIALESC = rSOLICITACAO.IDSEQUENCIALESC;

             vIDTIPOPROCURADOR := 'E';
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               vIDPROCURADOR := ' ';
               vIDTIPOPROCURADOR := ' ';
           END;
         ELSE
           BEGIN
             SELECT distinct NRDOCUMENTO
             INTO vIDPROCURADOR
             FROM DOCUMENTOUSUARIO
             WHERE IDSEQUENCIAL = rSOLICITACAO.IDSEQUENCIALPROCURADOR
              AND CODTIPODOCUMENTO = 1;

             vIDTIPOPROCURADOR := 'A';
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               vIDPROCURADOR := ' ';
               vIDTIPOPROCURADOR := ' ';
           END;
         END IF;

     ELSE
       vIDPROCURADOR := ' ';
       vIDTIPOPROCURADOR := ' ';
     END IF;


       IF rSOLICITACAO.SIGLAPAIS <> 'BR' THEN
        BEGIN
          SELECT distinct NRDOCUMENTO
          INTO vIDTITULAR
          FROM DOCUMENTOUSUARIO DU
          WHERE DU.CODTIPODOCUMENTO = 3
            AND DU.IDSEQUENCIAL = rSOLICITACAO.U_IDSEQUENCIAL;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         vIDTITULAR:=' ';
        END;
       END IF;

     /*  IF rSOLICITACAO.SIGLAPAIS = 'BR' THEN
          IF rSOLICITACAO.CODTIPOSITUACAO IN (1,3,4,5,6,7,8) THEN
           BEGIN
            SELECT distinct NRDOCUMENTO
            INTO vIDTITULAR
            FROM DOCUMENTOUSUARIO DU
            WHERE DU.CODTIPODOCUMENTO = 2
              AND DU.IDSEQUENCIAL = rSOLICITACAO.UE_IDSEQUENCIAL;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           vIDTITULAR:=' ';
           END;

          ELSIF rSOLICITACAO.CODTIPOSITUACAO = 2 THEN
           BEGIN
            SELECT distinct NRDOCUMENTO
            INTO vIDTITULAR
            FROM DOCUMENTOUSUARIO DU
            WHERE DU.CODTIPODOCUMENTO = 1
              AND DU.IDSEQUENCIAL = rSOLICITACAO.UE_IDSEQUENCIAL;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           vIDTITULAR:=' ';
           END;
          ELSE
           vIDTITULAR:=' ';
          END IF;
       END IF;

       IF rSOLICITACAO.SIGLAPAIS IS NULL THEN
          vIDTITULAR:=' ';
       END IF;

       vNRGRU         := rSOLICITACAO.NRGRU; */


       /* ABRE O CURSOR cESPECIFICACAO PARA CONCATENAR TEXTO */
    /*   OPEN cESPECIFICACAO(rSOLICITACAO.CODSOLICITACAO,rSOLICITACAO.CODTIPODESPACHO); /*retirado o parametro , vSOLICITACAO_TP1.DATA_DOC
       FETCH cESPECIFICACAO INTO vESPECIFICACAO;

       WHILE cESPECIFICACAO%FOUND LOOP
          vCODDESPACHO :=vESPECIFICACAO.CODTIPODESPACHO ;
          vSITDESPACHO := vESPECIFICACAO.CODSITUACAORPIPOSTERIOR;

          IF NOT vESPECIFICACAO.ESPECIFICACAO IS NULL THEN
             vTEXTO := vTEXTO || replace(vESPECIFICACAO.ESPECIFICACAO,'Sem Especificac?o.',' ') || '|';
          END IF;
          IF NOT vESPECIFICACAO.COMPLEMENTO IS NULL THEN
             vTEXTO := vTEXTO || vESPECIFICACAO.COMPLEMENTO || '|';
          END IF;
          FETCH cESPECIFICACAO INTO vESPECIFICACAO;
       END LOOP;

       CLOSE cESPECIFICACAO;

       IF vTEXTO IS NOT NULL THEN
         vTEXTO := SUBSTR(vTEXTO, 1, LENGTH(vTEXTO) - 1);
       END IF; */


-------------busca qtd de linha da consulta do petdoc, petserv e petproc por peticao vinculada com mrc_pet---------------------------
      OPEN cQTD_SOLICITACAO_PETDOC(rSOLICITACAO.CODSOLICITACAO);
      FETCH cQTD_SOLICITACAO_PETDOC INTO vQTD_SOLICITACAO_PETDOC;

      if cQTD_SOLICITACAO_PETDOC%NOTFOUND then
      vqtd :=0;
   --   dbms_output.put_line( 'solicitacao vqtd 0 '||rSOLICITACAO.CODSOLICITACAO);
      else
      vqtd := vQTD_SOLICITACAO_PETDOC.CONTA_PETICAO_PETDOC;
   --   dbms_output.put_line( 'solicitacao vqtd diferente de 0: '||rSOLICITACAO.CODSOLICITACAO);
   --   dbms_output.put_line( 'vqtd : '||vqtd );
      end if;


      OPEN cQTD_PETICAOPROCESSO_E_PS(rSOLICITACAO.CODSOLICITACAO);
      FETCH cQTD_PETICAOPROCESSO_E_PS INTO vQTD_PETICAOPROCESSO_E_PS;

      if cQTD_PETICAOPROCESSO_E_PS%NOTFOUND then
      vqtd2 :=0;
   --   dbms_output.put_line( 'solicitacao vqtd2 0 '||rSOLICITACAO.CODSOLICITACAO);
      else
      vqtd2 := vQTD_PETICAOPROCESSO_E_PS.CONTA_PETICAO_PETPROC;
   --   dbms_output.put_line( 'solicitacao vqtd2 diferente de 0: '||rSOLICITACAO.CODSOLICITACAO);
   --   dbms_output.put_line( 'vqtd2 : '||vqtd2 );
      end if;

      OPEN cQTD_SOLICITACAO_PETSERV(rSOLICITACAO.CODSOLICITACAO);
      FETCH cQTD_SOLICITACAO_PETSERV INTO vQTD_SOLICITACAO_PETSERV;

      if cQTD_SOLICITACAO_PETSERV%NOTFOUND then
      vqtd3 :=0;
    --  dbms_output.put_line( 'solicitacao vqtd3 0 '||rSOLICITACAO.CODSOLICITACAO);
      else
      vqtd3 := vQTD_SOLICITACAO_PETSERV.conta_peticao_PETSERV;
    --  dbms_output.put_line( 'solicitacao vqtd3 diferente de 0: '||rSOLICITACAO.CODSOLICITACAO);
    --  dbms_output.put_line( 'vqtd3 : '||vqtd3 );
      end if;

         --------Verifica se existe processo associado a petic?o que n?o foi enviado para o SINPI,
         --------caso exista n?o permite a gravac?o dos dados-----------
  -- FOR rSOL IN cSOLICITACAO_PETPROC LOOP
     vprocessoenviado:='S';
    for rprocura1 in cPETCUMPREPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura1.codsolicitacao and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /* and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14)*/) ;
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;
      for rprocura2 in  cPETICAOPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into  vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura2.codsolicitacao 
        and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsituacaoworkflow <> 14 /*or b.codsituacaoworkflow = 14)*/);
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;
    --  dbms_output.put_line('peticao:'||rSOLICITACAO.CODSOLICITACAO);
    --  dbms_output.put_line('qtd pedido:'|| vprocessoenviado);
    --  dbms_output.put_line('vprocessoenviado1:'|| vprocessoenviado);
--------Imprime dados do mrc_pet-----------------------------------------------------------------
    IF  vprocessoenviado = 'S' THEN
     UTL_FILE.PUT_LINE(FILEID,
                    TO_CHAR(vNRLINHA)||
                    TO_CHAR(rSOLICITACAO.DATAHORA, 'DD/MM/YYYY')|| /* Data do documento */
                    TO_CHAR(rSOLICITACAO.DATAHORA, 'HH24:MI')|| /* Hora do documento */
                    rSOLICITACAO.NRPROTOCOLO|| /*Numero do protocolo*/
                    vIDPROCURADOR|| /*Numero do procurador*/
                    vIDTIPOPROCURADOR|| /*Tipo do procurador*/
                    vIDTITULAR|| /*Numero do requerente*/
                    RPAD(NVL(TO_CHAR(rSOLICITACAO.NRRPIGERADORA), ' '),4,' ')||
                   -- rSOLICITACAO.NRRPIGERADORA|| /*Numero da RPI Geradora*/
                    vNRGRU || /*Numero da GRU*/
                    RPAD(TO_CHAR(NVL(rSOLICITACAO.TEXTOPETICAO,' ')),25,' ')||
                   -- rSOLICITACAO.TEXTOPETICAO||/*Texto da Petic?o*/
                    vCODDESPACHO|| /* Codigo de despacho */
                    vSITDESPACHO ||   /* Situacao */
                    --vTEXTO||
                    RPAD(TO_CHAR(NVL(vTEXTO,' ')),900,' ')||/* Texto */
                    rSOLICITACAO.despachointerno||
                    vqtd3||
                    vqtd||
                    vqtd2);
      UTL_FILE.NEW_LINE(FILEID, 0);
    --  INSERT INTO TMP_WORKFLOW VALUES (rSOLICITACAO.CODSOLICITACAO, 9);
      vNRLINHA := vNRLINHA + 1;

      END IF;
      vTEXTO := '';


     CLOSE cQTD_SOLICITACAO_PETDOC;
     CLOSE cQTD_PETICAOPROCESSO_E_PS;
     CLOSE cQTD_SOLICITACAO_PETSERV;

     END LOOP;

     UTL_FILE.FCLOSE(FILEID);

     -- Fim do arquivo MRC_PET --
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Oracle : GERAMRC_PET_IPAS : '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
  END;

  BEGIN
  -- Escreve arquivo MRC_PETDOC --
   NOMEARQ1 := 'MRC_PETDOC_IPAS_'||TO_CHAR(SYSDATE,'YYMMDD')||'.txt';
   --FILEID  := UTL_FILE.FOPEN ('/home/oracle/arqstxt', NOMEARQ, 'W',32767);
    fileID1 := UTL_FILE.FOPEN (wkgPathArq, nomearq1, 'W',32767);
   vNRLINHA := 1;

   FOR rSOLICITACAO IN cSOLICITACAO_PETDOC LOOP
     vNUMEROPROTOCOLO := rSOLICITACAO.NRPROTOCOLO;
     vCODDOCUMENTO    := rSOLICITACAO.CODTIPOANEXO;

   /*  IF rSOLICITACAO.CODTIPOANEXO <> 11 THEN
       SELECT DESCRICAOANEXO
       INTO vDESCDOCUMENTO
       FROM TIPOANEXO
       WHERE CODTIPOANEXO = rSOLICITACAO.CODTIPOANEXO;
     ELSIF rSOLICITACAO.CODTIPOANEXO = 11 and rSOLICITACAO.CODOUTROTIPOANEXO is not null then
       SELECT DESCRICAO
       INTO vDESCDOCUMENTO
       FROM OUTROTIPOANEXO
      WHERE CODOUTROTIPOANEXO = rSOLICITACAO.CODOUTROTIPOANEXO;
     ELSE
        vDESCDOCUMENTO := NULL;
     END IF;*/

    --------Verifica se existe processo associado a petic?o que n?o foi enviado para o SINPI, caso exista n?o permite a gravac?o dos dados-----------
     vprocessoenviado:='S';
     for rprocura1 in cPETCUMPREPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura1.codsolicitacao ;
       /*   and    not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /* and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14));
      /*   if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N'
         end if;*/

      end loop;
      for rprocura2 in  cPETICAOPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into  vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura2.codsolicitacao ;
        /*and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao  and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14));
     /*    if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;*/

      end loop;
   IF vprocessoenviado = 'S' then
    UTL_FILE.PUT_LINE
         (fileID1,
                 RPAD(TO_CHAR (vNRLINHA),5,' ')||
                 RPAD(TO_CHAR (vNUMEROPROTOCOLO),12,' ')||
                 RPAD(TO_CHAR (vCODDOCUMENTO),2,' ')||
                 RPAD(TO_CHAR(replace(NVL(vDESCDOCUMENTO,' '),chr(13)||chr(10),chr(35)||chr(36)||chr(37)||chr(38))),255,' '));
    INSERT INTO TMP_WORKFLOW VALUES (rSOLICITACAO.CODSOLICITACAO, 9);
    UTL_FILE.NEW_LINE(FILEID1, 0);
    vNRLINHA := vNRLINHA + 1;
   END IF;
   END LOOP;

   UTL_FILE.FCLOSE(FILEID1);
   -- Fim do arquivo MRC_PET --
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Oracle : GERAMRC_PETDOC_IPAS : '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
  END;

  BEGIN
    -- Escreve arquivo MRC_PETPROC --
    NOMEARQ2 := 'MRC_PETPROC_IPAS_'||TO_CHAR(SYSDATE,'YYMMDD')||'.txt';
    --FILEID  := UTL_FILE.FOPEN ('/home/oracle/arqstxt', NOMEARQ, 'W',32767);
    fileID2 := UTL_FILE.FOPEN (wkgPathArq, nomearq2, 'W',32767);
    vNRLINHA := 1;

     FOR rSOLICITACAO IN cSOLICITACAO_PETPROC LOOP
       --------Verifica se existe processo associado a petic?o que n?o foi enviado para o SINPI, caso exista n?o permite a gravac?o dos dados-----------
     vprocessoenviado:='S';
     for rprocura1 in cPETCUMPREPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura1.codsolicitacao and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /* and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14 )*/);
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;
      for rprocura2 in  cPETICAOPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into  vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura2.codsolicitacao and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /*and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14)*/);
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;
 --   end loop;
      IF  vprocessoenviado = 'S' THEN
        IF rSOLICITACAO.CODSOLICITACAOCUMPRE IS NOT NULL THEN  --ADICIONADO EM 29/09/2006
         BEGIN
           FOR rPETCUMPREPROCESSO IN cPETCUMPREPROCESSO(rSOLICITACAO.CODSOLICITACAO) LOOP
             UTL_FILE.PUT_LINE(FILEID2,
                              RPAD(TO_CHAR (vNRLINHA),5,' ')||
                              RPAD(TO_CHAR(rSOLICITACAO.NRPROTOCOLO),12,' ') || /* Numero protocolo */
                              LPAD(TO_CHAR(rPETCUMPREPROCESSO.NRPROCESSO),9, '0'));/* Codigo Processo */
            UTL_FILE.NEW_LINE(FILEID2, 0);
           -- dbms_output.put_line ('protoc:' || rSOLICITACAO.NRPROTOCOLO);
           -- dbms_output.put_line ('process:' || rPETCUMPREPROCESSO.NRPROCESSO);
           -- dbms_output.put_line ('linha:' || vNRLINHA);
            vNRLINHA := vNRLINHA + 1;
           END LOOP;

           FOR rPETCUMPREPAPELPROC IN cPETCUMPREPAPELPROC(rSOLICITACAO.CODSOLICITACAO) LOOP
             UTL_FILE.PUT_LINE(FILEID2,
                              RPAD(TO_CHAR (vNRLINHA),5,' ')||
                              RPAD(TO_CHAR(rSOLICITACAO.NRPROTOCOLO),12,' ') || /* Numero protocolo */
                              LPAD(TO_CHAR(rPETCUMPREPAPELPROC.nrprocessopapelousinpi),9, '0'));/* Codigo Processo */
            UTL_FILE.NEW_LINE(FILEID2, 0);
          --  dbms_output.put_line ('protoc:' || rSOLICITACAO.NRPROTOCOLO);
          --  dbms_output.put_line ('process:' || rPETCUMPREPAPELPROC.nrprocessopapelousinpi);
          --  dbms_output.put_line ('linha:' || vNRLINHA);
            vNRLINHA := vNRLINHA + 1;
           END LOOP;

         END;
        ELSE  --ADICIONADO EM 29/09/2006
         BEGIN
            /* Grava Registros de Processo Eletronico */
          FOR rPETICAOPROCESSO IN cPETICAOPROCESSO(rSOLICITACAO.CODSOLICITACAO) LOOP
            UTL_FILE.PUT_LINE(FILEID2,
                              RPAD(TO_CHAR (vNRLINHA),5,' ')||
                              RPAD(TO_CHAR(rSOLICITACAO.NRPROTOCOLO),12,' ') || /* Numero protocolo */
                              LPAD(TO_CHAR(rPETICAOPROCESSO.NRPROCESSO),9, '0'));/* Codigo Processo */
            UTL_FILE.NEW_LINE(FILEID2, 0);
          --   dbms_output.put_line ('protoc:' || rSOLICITACAO.NRPROTOCOLO);
          --  dbms_output.put_line ('process:' || rPETICAOPROCESSO.NRPROCESSO);
           -- dbms_output.put_line ('linha:' || vNRLINHA);
            vNRLINHA := vNRLINHA + 1;
          END LOOP;
        /* Grava Registros de Processo Papel ou Sinpi */
         FOR rPETICAOPROCESSOPS IN cPETICAOPROCESSOPS(rSOLICITACAO.CODSOLICITACAO) LOOP
            UTL_FILE.PUT_LINE(FILEID2,
                              RPAD(TO_CHAR (vNRLINHA),5,' ')||
                              RPAD(TO_CHAR(rSOLICITACAO.NRPROTOCOLO),12,' ') || /* Numero protocolo */
                              LPAD(TO_CHAR(rPETICAOPROCESSOPS.NRPROCESSOPAPELOUSINPI),9,'0')); /* Codigo Processo */
            UTL_FILE.NEW_LINE(FILEID2, 0);
           --  dbms_output.put_line ('protoc:' || rSOLICITACAO.NRPROTOCOLO);
           -- dbms_output.put_line ('process:' || rPETICAOPROCESSOPS.NRPROCESSOPAPELOUSINPI);
           -- dbms_output.put_line ('linha:' || vNRLINHA);
            vNRLINHA := vNRLINHA + 1;
         END LOOP;
        END;
      END IF;

      -- vNRLINHA := vNRLINHA + 1;
       INSERT INTO TMP_WORKFLOW VALUES (rSOLICITACAO.CODSOLICITACAO, 9);
     END IF;
     END LOOP;

     UTL_FILE.FCLOSE(FILEID2);
     -- Fim do arquivo MRC_PETPROC --
  EXCEPTION
      WHEN OTHERS THEN
           dbms_output.put_line('Erro: Oracle : GERAMRC_PETPROC_IPAS : '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
  END;

  BEGIN
    -- Escreve arquivo MRC_PETSERV --
    NOMEARQ3 := 'MRC_PETSERV_IPAS_'||TO_CHAR(SYSDATE,'YYMMDD')||'.txt';
    --FILEID  := UTL_FILE.FOPEN ('/home/oracle/arqstxt', NOMEARQ, 'W',32767);
    fileID3 := UTL_FILE.FOPEN (wkgPathArq, nomearq3, 'W',32767);
    vNRLINHA := 1;

     FOR rSOLICITACAO IN cSOLICITACAO_PETSERV LOOP
        vNUMEROPROTOCOLO := rSOLICITACAO.NRPROTOCOLO;
        vCODSERVICO      := SUBSTR(rSOLICITACAO.CODTIPOOBJETO,1,3);
        vCODRAMIFICACAO  := SUBSTR(rSOLICITACAO.CODTIPOOBJETO,4,2);
        --------Verifica se existe processo associado a petic?o que n?o foi enviado para o SINPI, caso exista n?o permite a gravac?o dos dados-----------
     vprocessoenviado:='S';
     for rprocura1 in cPETCUMPREPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura1.codsolicitacao and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /*and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14)*/);
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;
      for rprocura2 in  cPETICAOPROCESSO(rSOLICITACAO.CODSOLICITACAO) loop
        select count(a.codsolicitacao) into  vcontaprocnaoenviado
        from situacaosolicitacaoworkflow a
        where a.codsolicitacao = rprocura2.codsolicitacao and
              not exists (select b.codsolicitacao
                          from situacaosolicitacaoworkflow b
                           where b.codsolicitacao = a.codsolicitacao /* and
                           (b.codsituacaoworkflow = 9 or b.codsituacaoworkflow = 14)*/);
         if  vcontaprocnaoenviado > 0 then
                   vprocessoenviado := 'N';
         end if;

      end loop;

       IF  vprocessoenviado = 'S' THEN
        IF rSOLICITACAO.CODTIPOOBJETO=36326 OR rSOLICITACAO.CODTIPOOBJETO=3394 THEN
           begin
           SELECT DESCRICAOOUTRAPETICAO INTO vDESCRICAOOUTRAPETICAO
           FROM OUTRAPETICAO
           WHERE CODSOLICITACAO = rSOLICITACAO.CODSOLICITACAO;
           EXCEPTION
           WHEN OTHERS THEN
           dbms_output.put_line('Erro: Oracle : GERAMRC_PETSERV_IPAS OUTRAPETICAO  : '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
           end;
           UTL_FILE.PUT_LINE(FILEID3,
                          RPAD(TO_CHAR(vNRLINHA),5,' ') ||
                          RPAD(TO_CHAR(vNUMEROPROTOCOLO),12,' ') || /* Numero protocolo */
                          RPAD(vCODSERVICO, 3, ' ') || /* Codigo Servico */
                          RPAD(vCODRAMIFICACAO, 2, ' ') ||
                          RPAD(replace(NVL(vDESCRICAOOUTRAPETICAO,' '),chr(13)||chr(10),chr(35)||chr(36)||chr(37)||chr(38)),100,' ')); /*Descric?o complementar do servico*/

           UTL_FILE.NEW_LINE(FILEID3, 0);

        ELSE
           UTL_FILE.PUT_LINE(FILEID3,
                          RPAD(TO_CHAR(vNRLINHA),5,' ') ||
                          RPAD(TO_CHAR(vNUMEROPROTOCOLO),12,' ') || /* Numero protocolo */
                          RPAD(vCODSERVICO, 3, ' ') || /* Codigo Servico */
                          RPAD(vCODRAMIFICACAO, 2, ' ') ||
                          RPAD(TO_CHAR(' '),100,' '));
           UTL_FILE.NEW_LINE(FILEID3, 0);
       END IF;

       vNRLINHA := vNRLINHA + 1;
       INSERT INTO TMP_WORKFLOW VALUES (rSOLICITACAO.CODSOLICITACAO, 9);
      END IF;
     END LOOP;

     UTL_FILE.FCLOSE(FILEID3);
     -- Fim do arquivo MRC_PETSERV --
  EXCEPTION
      WHEN OTHERS THEN
           dbms_output.put_line('Erro: Oracle : GERAMRC_PETSERV_IPAS : '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
  END;

  BEGIN
    INSERT INTO SITUACAOSOLICITACAOWORKFLOW (CODSITUACAOWORKFLOW, CODSOLICITACAO, DATAHORA)
    SELECT DISTINCT CODSITUACAOWORKFLOW, CODSOLICITACAO, SYSDATE FROM TMP_WORKFLOW;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: Ao registrar Situac?o Solicitac?o WorkFlow Petic?o: '||TO_CHAR(SQLCODE)||' : '||SQLERRM);
  END;
 COMMIT;
END GERAMRC_PET_IPAS_1;
/
