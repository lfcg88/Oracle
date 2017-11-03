CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0039
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  VAR_IDTRIO_TRAB            	varchar2,
  VAR_IARQ_TRAB              	varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0039'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0039
  --      DATA            : 14/3/2006 20:23:40
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, da produção no Ramo Bilhete.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          UTL_FILE.FILE_TYPE;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 1;
  ERRO EXCEPTION;
  ERRO_GRP_RAMO EXCEPTION;
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB0039';
  VAR_IROTNA CONSTANT INT := 0039;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  --
  -- Verifica se a quantidade de registros é igual à informada
  --
  PROCEDURE TRAILER(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    VAR_QT_REGISTROS NUMBER;
  BEGIN
    BEGIN
      VAR_QT_REGISTROS := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,
                                           16,
                                           8));
    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR A QUANTIDADE DE REGISTROS PARA VERIFICAÇÃO.' ||
                        ' -- LINHA: ' || VAR_COUNT || ' -- QUANTIDADE DE REGISTROS: ' ||
                        TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,
                                         16,
                                         8)) || ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM,
                               1,
                               120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);
        RAISE;
    END;
    IF VAR_QT_REGISTROS = VAR_COUNT THEN
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      COMMIT;
    ELSE
      VAR_LOG_ERRO := 'NÚMERO DE REGISTROS INSERIDOS NÃO BATE COM O NÚMERO DE REGISTROS DO ARQUIVO.' ||
                      ' -- REGISTROS DO ARQUIVO: ' || (VAR_QT_REGISTROS - 2) ||
                      ' -- REGISTROS INSERIDOS: ' || (VAR_COUNT - 2);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      RAISE ERRO;
    END IF;
  END TRAILER;

  -- Fim
  -- Verifica se a quantidade de registros é igual à informada
  --
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    v_qtot_item_prod  VARCHAR2(20);
    v_ctpo_comis      VARCHAR2(20);
    v_ccrrtr          VARCHAR2(20);
    v_cgrp_ramo_plano VARCHAR2(20);
    v_ccompt_prod     VARCHAR2(20);
    v_cund_prod       VARCHAR2(20);
    v_vprod_crrtr     prod_crrtr.vprod_crrtr %type;
  BEGIN
    BEGIN
      --
      -- Quantidade de itens de produção
      v_qtot_item_prod := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                 22,
                                 7);
      --
      -- Tipo de comissão
      v_ctpo_comis := SUBSTR(VAR_REGISTRO_ARQUIVO,
                             20,
                             2);
      --
      -- Código CPD do corretor
      v_ccrrtr := SUBSTR(VAR_REGISTRO_ARQUIVO,
                         11,
                         6);
      --
      -- Grupo de Ramos
      v_cgrp_ramo_plano := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                  17,
                                  3);
      --
      -- Competência
      v_ccompt_prod := SUBSTR(VAR_REGISTRO_ARQUIVO,
                              2,
                              6);
      --
      -- Unidade de produção
      v_cund_prod := SUBSTR(VAR_REGISTRO_ARQUIVO,
                            8,
                            3);
      --
      -- Valor da produção
      v_vprod_crrtr := (TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,
                              29,
                              17))/100);
      --
      --
      IF v_cgrp_ramo_plano <> PC_UTIL_01.RE THEN
        RAISE_APPLICATION_ERROR(-20009,
                                'ESTE PROCESSO ESPERA APENAS REGISTROS DE RE - BILHETE RESIDENCIAL');
      END IF;
      --
      -- :) insert
      INSERT INTO prod_crrtr
        (qtot_item_prod,
         ctpo_comis,
         ccrrtr,
         cgrp_ramo_plano,
         ccompt_prod,
         cund_prod,
         vprod_crrtr)
      VALUES
        (TO_NUMBER(v_qtot_item_prod),
         v_ctpo_comis,
         TO_NUMBER(v_ccrrtr),
         TO_NUMBER(v_cgrp_ramo_plano),
         TO_NUMBER(v_ccompt_prod),
         TO_NUMBER(v_cund_prod),
         TO_NUMBER(v_vprod_crrtr));
      --
      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        --
        VAR_LOG_ERRO := 'Erro inserindo na tabela prod_crrtr.' || ' -- LINHA: ' || VAR_COUNT ||
                        ' -- QTOT_ITEM_PROD: ' || v_qtot_item_prod || ' -- CTPO_COMIS: ' ||
                        v_ctpo_comis || ' -- CCRRTR: ' || v_ccrrtr || ' -- CGRP_RAMO_PLANO: ' ||
                        v_cgrp_ramo_plano || ' -- CCOMPT_PROD: ' || v_ccompt_prod ||
                        ' -- CUND_PROD: ' || v_cund_prod || ' -- VPROD_CRRTR: ' || v_vprod_crrtr ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM,
                                                      1,
                                                      120);
        --dbms_output.put_line('ERRO DETALHE');
        --
        --
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);
        --
        --
        PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,
                            VAR_CROTNA);
    END;
  END DETALHE;

  -- Fim
  -- Insere conteúdo nas colunas
  --
BEGIN
  -- Iniciando Execução
--dbms_output.put_line('01');
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            VAR_IROTNA,
                            PC_UTIL_01.VAR_ROTNA_PC);
  BEGIN
    BEGIN
      --dbms_output.put_line('02');

--      VAR_ARQUIVO := UTL_FILE.FOPEN('/x0205/P002/sgpb/arquivo',
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'R');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
    --
    --
    BEGIN
--dbms_output.put_line('03');
      DELETE FROM prod_crrtr t
       WHERE T.Ccompt_Prod = intrCompetencia
         AND t.cgrp_ramo_plano = PC_UTIL_01.RE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,
                                'ERRO DELETANDO A COMPETENCIA DA TABELA prod_crrtr');
    END;
    --
    --
--dbms_output.put_line('04');
    UTL_FILE.GET_LINE(VAR_ARQUIVO,
                      VAR_REGISTRO_ARQUIVO);
    --
    -- Verifica se o arquivo tem header
    IF SUBSTR(VAR_REGISTRO_ARQUIVO,
              1,
              1) <> 0 THEN
      --
      RAISE_APPLICATION_ERROR(-20002,
                              'ERRO O ARQUIVO NÃO TEM HEADER');
      --
    END IF;
    --
    --
    BEGIN
      -- Varrendo os registros dos arquivos
      LOOP
        UTL_FILE.GET_LINE(VAR_ARQUIVO,
                          VAR_REGISTRO_ARQUIVO);
        VAR_COUNT := VAR_COUNT + 1;
        BEGIN
          CASE
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        1) = 1 THEN
              DETALHE(VAR_REGISTRO_ARQUIVO);
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        1) = 9 THEN
              TRAILER(VAR_REGISTRO_ARQUIVO);
              EXIT;
          END CASE;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE;
        END;
      END LOOP;
    EXCEPTION
      --
      --
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE;
    END;
    -- Execução terminada sem Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              VAR_IROTNA,
                              PC_UTIL_01.VAR_ROTNA_PO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                           'PROCESSO EXECUTADO COM SUCESSO.',
                           PC_UTIL_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
  EXCEPTION
    WHEN ABRE_ARQUIVO_EXCEPTION THEN
      --dbms_output.put_line('PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
      --dbms_output.put_line(pc_util_01.diretorio_padrao);
      --dbms_output.put_line('SGPB0039_' || intrCompetencia || '01.dat');

      Raise_Application_Error(-20003,
                              'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
      --
    WHEN OTHERS THEN
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE PRODUÇÃO NO RAMO BILHETE.' ||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||
                      SUBSTR(SQLERRM,
                             1,
                             120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      -- Processo executado com Erro
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                VAR_IROTNA,
                                PC_UTIL_01.VAR_ROTNA_PE);
  END;
END SGPB0039;
/

