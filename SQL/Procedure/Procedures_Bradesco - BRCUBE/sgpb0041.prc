CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0041(INTRCOMPETENCIA IN CLASF_AG.CCOMPT_CLASF%TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0041') IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : sgpb0041
  --      DATA            : 15/3/2006 16:25:30
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de view do DW, da classificação do canal Banco.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA  varCHAR2(08) := 'sgpb0041';
  V_CAG_BCRIA        VARCHAR2(15);
  V_CBCO             VARCHAR2(15);
  V_CMES_COMPT_CLASF VARCHAR2(15);
  V_CCLASF_AG_BCRIA  VARCHAR2(100);
  CURSOR_TEMP        SYS_REFCURSOR;
  V_CURSOR           VARCHAR2(2000) := 'CREATE GLOBAL TEMPORARY TABLE TBACLASF_AG_BCRIA (CAG_BCRIA VARCHAR2(15), CBCO VARCHAR2(15), CMES_COMPT_CLASF VARCHAR2(15), CCLASF_AG_BCRIA VARCHAR2(100)) ON COMMIT PRESERVE ROWS';
  chrLinhaErro       varchar2(2);
BEGIN
  --
  -- Iniciando Execução
  chrLinhaErro := '01';
  dbms_output.put_line('NM ROTINA');
  dbms_output.put_line(chrNomeRotinaScheduler);
  dbms_output.put_line('SIT');
  dbms_output.put_line(PC_UTIL_01.VAR_ROTNA_PC);

      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            708,
                            PC_UTIL_01.VAR_ROTNA_PC);
  --
  --
  BEGIN
    --
  chrLinhaErro := '02';
    DELETE FROM CLASF_AG T WHERE T.CCOMPT_CLASF = INTRCOMPETENCIA;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      VAR_LOG_ERRO := 'ERRO AO TENTAR DELETAR OS REGISTROS DA TABELA AGENCIA' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
      --
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      --
      RAISE;
      --
  END;
  --
  -- Cria tabela temporária
  BEGIN
    --
  chrLinhaErro := '03';
    EXECUTE IMMEDIATE V_CURSOR;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -955
      THEN
  chrLinhaErro := '04';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE TBACLASF_AG_BCRIA';
  chrLinhaErro := '05';
        EXECUTE IMMEDIATE 'DROP     TABLE TBACLASF_AG_BCRIA';
  chrLinhaErro := '06';
        EXECUTE IMMEDIATE V_CURSOR;
        --
        VAR_LOG_ERRO := 'ERRO AO TENTAR CRIAR TABELA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
        --
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);
        --
      ELSE
        --
        VAR_LOG_ERRO := 'ERRO AO TENTAR CRIAR TABELA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
        --
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);
        --
        RAISE;
        --
      END IF;
  END;
  --
  --
  BEGIN
    --
  chrLinhaErro := '07';
    EXECUTE IMMEDIATE 'INSERT INTO TBACLASF_AG_BCRIA ( CAG_BCRIA, CBCO, CMES_COMPT_CLASF, CCLASF_AG_BCRIA ) SELECT CAG_BCRIA, CBCO, CMES_COMPT_CLASF, CCLASF_AG_BCRIA FROM VBACLASF_AG_BCRIA WHERE CMES_COMPT_CLASF = ' ||
                      INTRCOMPETENCIA;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      VAR_LOG_ERRO := 'ERRO AO TENTAR INSERIR OS DADOS DA VIEW NA TEMPORÁRIA' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
      --
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      --
      RAISE;
      --
  END;
  --
  --
  chrLinhaErro := '08';
  OPEN CURSOR_TEMP FOR 'SELECT CAG_BCRIA, CBCO, CMES_COMPT_CLASF, CCLASF_AG_BCRIA FROM TBACLASF_AG_BCRIA';
  --
  --
  --dbms_output.put_line('entrei no maudito loop');
  LOOP
    --
    chrLinhaErro := '09';
    FETCH CURSOR_TEMP
      INTO V_CAG_BCRIA, V_CBCO, V_CMES_COMPT_CLASF, V_CCLASF_AG_BCRIA;


    chrLinhaErro := '10';
    EXIT WHEN CURSOR_TEMP%NOTFOUND;

    --dbms_output.put_line(V_CAG_BCRIA);

    --
    -- Varrendo os registros dos arquivos
    BEGIN
      --
  chrLinhaErro := '11';
      INSERT INTO CLASF_AG
        (CCOMPT_CLASF,
         CCLASF_AG,
         CBCO,
         CAG_BCRIA)
      VALUES
        (TO_NUMBER(V_CMES_COMPT_CLASF),
--         UPPER(TRIM(BOTH ' ' FROM V_CCLASF_AG_BCRIA)),
         V_CCLASF_AG_BCRIA,
         TO_NUMBER(V_CBCO),
         TO_NUMBER(V_CAG_BCRIA));
      --
      --
    EXCEPTION
      WHEN OTHERS THEN
        --dbms_output.put_line('ERRRRO');
        --dbms_output.put_line(SQLERRM);
        --
        VAR_LOG_ERRO := 'DADOS:' || ' -- CAG_BCRIA: ' || V_CAG_BCRIA ||
                        ' -- CBCO: ' || V_CBCO || ' -- CMES_COMPT_CLASF: ' ||
                        V_CMES_COMPT_CLASF || ' -- CCLASF_AG_BCRIA: ' ||
                        V_CCLASF_AG_BCRIA || ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM, 1, 120);
        --
        PC_UTIL_01.SGPB0028(VAR_LOG_ERRO, VAR_CROTNA);
        --
      --
    END;
  END LOOP;
      --dbms_output.put_line('sai do maudito loop');
--
  --
  chrLinhaErro := '12';
  CLOSE CURSOR_TEMP;
  --
  -- Execução terminada sem Erro
  chrLinhaErro := '13';
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            708,
                            PC_UTIL_01.VAR_ROTNA_PO);
  --
  chrLinhaErro := '14';
  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                         'PROCESSO EXECUTADO COM SUCESSO.',
                         PC_UTIL_01.VAR_LOG_PROCESSO,
                         NULL,
                         NULL);
  --
  --
  chrLinhaErro := '15';
  COMMIT;
  --dbms_output.put_line('comiit nesta droga');
  --
  --
  BEGIN
    --
    -- Deleta tebela temporária
  chrLinhaErro := '16';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TBACLASF_AG_BCRIA';
  chrLinhaErro := '17';
    EXECUTE IMMEDIATE 'DROP TABLE TBACLASF_AG_BCRIA';
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      NULL;
      --
  END;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --dbms_output.put_line('ROLLLLLLLLBACK');

    ROLLBACK;
    --
    VAR_LOG_ERRO := 'linha: '||chrLinhaErro||' PROBLEMA AO CARREGAR OS REGISTROS DE CLASSIFICAÇÃO DA AGÊNCIA.' ||
                    ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
    --
    --
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                           VAR_LOG_ERRO,
                           PC_UTIL_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    -- Processo executado com Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.VAR_ROTNA_PE);
    --
  --
END SGPB0041;
/

