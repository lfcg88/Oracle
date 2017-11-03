CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0042(intrcompetencia IN vcameta_ag_bcria.cmes_dw%TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0042') IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0042
  --      DATA            : 15/3/2006 18:38:57
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de view do DW, da meta do canal Banco.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB0042';
  VAR_IROTNA CONSTANT INT := 0042;
  V_CMES_DW            VARCHAR(15);
  V_CCHAVE_AG_BCRIA    VARCHAR(15);
  V_VMETA_AG_BCRIA     VARCHAR(15);
  V_CCRRTR             VARCHAR(15);
  V_CCHAVE_LGADO_CRRTR VARCHAR(15);
  V_CURSOR             VARCHAR2(2000) := 'CREATE GLOBAL TEMPORARY TABLE TCAMETA_AG_BCRIA (CMES_DW VARCHAR(15), CCHAVE_AG_BCRIA VARCHAR(15), VMETA_AG_BCRIA VARCHAR(15), CCRRTR VARCHAR(15), CCHAVE_LGADO_CRRTR VARCHAR(15)) ON COMMIT PRESERVE ROWS';
  CURSOR_TEMP          SYS_REFCURSOR;
BEGIN
  --
  --
  -- Iniciando Execução
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            VAR_IROTNA,
                            PC_UTIL_01.VAR_ROTNA_PC);
  --
  --
  BEGIN
    --
    DELETE FROM META_AG T WHERE T.CCOMPT_META = INTRCOMPETENCIA;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      VAR_LOG_ERRO := 'ERRO AO TENTAR DELETAR OS REGISTROS DA TABELA META' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM,
                                                    1,
                                                    120);
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
    EXECUTE IMMEDIATE V_CURSOR;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF SQLCODE = -955 THEN
        --
        EXECUTE IMMEDIATE 'TRUNCATE TABLE TCAMETA_AG_BCRIA';
        EXECUTE IMMEDIATE 'DROP     TABLE TCAMETA_AG_BCRIA';
        EXECUTE IMMEDIATE V_CURSOR;
        --
      ELSE
        --
        VAR_LOG_ERRO := 'ERRO AO TENTAR CRIAR TABELA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM,
                               1,
                               120);
        --
        --
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);
        --
        --
        RAISE;
        --
      END IF;
  END;
  BEGIN
    --
    --
    EXECUTE IMMEDIATE 'INSERT INTO TCAMETA_AG_BCRIA SELECT CMES_DW, CCHAVE_AG_BCRIA, VMETA_AG_BCRIA, CCRRTR, CCHAVE_LGADO_CRRTR FROM VCAMETA_AG_BCRIA WHERE CMES_DW = ' ||
                      intrcompetencia;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      --
      VAR_LOG_ERRO := 'ERRO AO TENTAR INSERIR OS DADOS DA VIEW NA TEMPORÁRIA' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM,
                                                    1,
                                                    120);
      --
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      --
      --
      RAISE;
      --
  END;
  --
  --
  OPEN CURSOR_TEMP FOR 'SELECT CMES_DW, CCHAVE_AG_BCRIA, VMETA_AG_BCRIA, CCRRTR, CCHAVE_LGADO_CRRTR FROM TCAMETA_AG_BCRIA';
  --
  LOOP
    --
    --
    FETCH CURSOR_TEMP
      INTO V_CMES_DW, V_CCHAVE_AG_BCRIA, V_VMETA_AG_BCRIA, V_CCRRTR, V_CCHAVE_LGADO_CRRTR;
    --
    --
    EXIT WHEN CURSOR_TEMP%NOTFOUND;
    --
    -- Varrendo os registros dos arquivos
    BEGIN
      --
      INSERT INTO meta_ag
        (ccompt_meta,
         vmeta_ag,
         cbco,
         cag_bcria,
         cgrp_ramo_plano,
         qmin_item_apolc)
      VALUES
        (to_number(v_cmes_dw),
         0,
         TRUNC(TO_NUMBER(v_cchave_ag_bcria) / 10000),
         (TO_NUMBER(v_cchave_ag_bcria) / 10000 -
         TRUNC(TO_NUMBER(v_cchave_ag_bcria) / 10000)) * 10000,
         pc_util_01.AUTO,
         to_number(v_vmeta_ag_bcria));
      --
      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        --
        VAR_LOG_ERRO := 'DADOS:' || ' -- CCHAVE_AG_BCRIA: ' ||
                        V_CCHAVE_AG_BCRIA || ' -- CCHAVE_LGADO_CRRTR: ' ||
                        V_CCHAVE_LGADO_CRRTR || ' -- CAG_BCRIA: ' ||
                        TRUNC(TO_NUMBER(v_cchave_ag_bcria) / 10000) ||
                        ' -- CBCO: ' ||
                        (TO_NUMBER(v_cchave_ag_bcria) / 10000 -
                        TRUNC(TO_NUMBER(v_cchave_ag_bcria) / 10000)) * 10000 ||
                        ' -- CMES_DW: ' || V_CMES_DW || ' -- CCRRTR: ' ||
                        V_CCRRTR || ' -- VMETA_AG_BCRIA: ' || V_VMETA_AG_BCRIA ||
                        ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM,
                               1,
                               120);
        --
        --
        PC_UTIL_01.SGPB0028(VAR_LOG_ERRO, VAR_CROTNA);
        --
    END;
  END LOOP;
  --
  -- Execução terminada sem Erro
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            VAR_IROTNA,
                            PC_UTIL_01.VAR_ROTNA_PO);
  --
  --
  PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                         'PROCESSO EXECUTADO COM SUCESSO.',
                         PC_UTIL_01.VAR_LOG_PROCESSO,
                         NULL,
                         NULL);
  --
  --
  COMMIT;
  --
  --
  BEGIN
    --
    -- Deleta tebela temporária
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TCAMETA_AG_BCRIA';
    EXECUTE IMMEDIATE 'DROP TABLE TCAMETA_AG_BCRIA';
    --
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    --
    VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE METAS.' ||
                    ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM,
                                                  1,
                                                  120);
    --
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                           VAR_LOG_ERRO,
                           PC_UTIL_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    -- Processo executado com Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              VAR_IROTNA,
                              PC_UTIL_01.VAR_ROTNA_PE);
    --
  --
END SGPB0042;
/

