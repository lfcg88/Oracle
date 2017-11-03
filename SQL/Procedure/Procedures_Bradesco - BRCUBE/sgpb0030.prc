CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0030
(
  VAR_IDTRIO_TRAB        varchar2,
  VAR_IARQ_TRAB          varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9030'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0030
  --      DATA            : 13/3/2006 10:46:29
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, da margem de contribuição.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          UTL_FILE.FILE_TYPE;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 1;
  ERRO EXCEPTION;
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB9030';
  VAR_IROTNA CONSTANT INT := 728;
  VAR_COMPT MARGM_CONTB_CRRTR.CCOMPT_MARGM%TYPE;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  --
  -- Verifica se a quantidade de registros é igual à informada
  --
  PROCEDURE TRAILER(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    VAR_QT_REGISTROS VARCHAR(20); --NUMBER;
  BEGIN
    BEGIN
      VAR_QT_REGISTROS := SUBSTR(VAR_REGISTRO_ARQUIVO,19,7);
    EXCEPTION
      WHEN OTHERS THEN
       --dbms_output.put_line('EXEC01');
        VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR A QUANTIDADE DE REGISTROS PARA VERIFICAÇÃO.' ||
                        ' -- LINHA: ' || VAR_COUNT || ' -- QUANTIDADE DE REGISTROS: ' ||
                        TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,19,7)) || ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM,1,120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
        RAISE;
    END;
     --dbms_output.put_line('VERIFICA REGS');
    IF VAR_QT_REGISTROS = VAR_COUNT THEN
       --dbms_output.put_line('BATEU');
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      COMMIT;
    ELSE
      VAR_LOG_ERRO := 'NÚMERO DE REGISTROS INSERIDOS NÃO CONFERE COM O NÚMERO DE REGISTROS DO ARQUIVO.' ||
                      ' -- REGISTROS DO ARQUIVO: ' || (VAR_QT_REGISTROS - 2) ||
                      ' -- REGISTROS INSERIDOS: ' || (VAR_COUNT - 2);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
       --dbms_output.put_line('NNNN BATEU');
      RAISE ERRO;
    END IF;
  END TRAILER;
  -- Fim
  -- Verifica se a quantidade de registros é igual à informada
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    V_PMARGM_CONTB   VARCHAR(100); --V_PMARGM_CONTB   MARGM_CONTB_CRRTR.PMARGM_CONTB%TYPE;
    V_CCPF_CNPJ_BASE VARCHAR(100); --V_CCPF_CNPJ_BASE MARGM_CONTB_CRRTR.CCPF_CNPJ_BASE%TYPE;
    V_CTPO_PSSOA     VARCHAR(100); --V_CTPO_PSSOA     MARGM_CONTB_CRRTR.CTPO_PSSOA%TYPE;
    SPONTO           VARCHAR2(5) := '#XXXX';
  BEGIN
    SPONTO           := '#0001';
    V_PMARGM_CONTB   := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               17,
                               1) || SUBSTR(VAR_REGISTRO_ARQUIVO,
                                            18,
                                            10) || ',' ||
                        SUBSTR(VAR_REGISTRO_ARQUIVO,
                               28,
                               4);
    SPONTO           := '#0002';
    V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               8,
                               9);
    SPONTO           := '#0003';
    V_CTPO_PSSOA     := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               1,
                               1);
    SPONTO           := '#0004';
    INSERT INTO MARGM_CONTB_CRRTR
      (CCOMPT_MARGM,
       PMARGM_CONTB,
       CCANAL_VDA_SEGUR,
       CCPF_CNPJ_BASE,
       CTPO_PSSOA)
      SELECT VAR_COMPT,
             V_PMARGM_CONTB,
             CV.CCANAL_VDA_SEGUR,
             V_CCPF_CNPJ_BASE,
             V_CTPO_PSSOA
        FROM CANAL_VDA_SEGUR CV;
--    --dbms_output.put_line(VAR_COUNT);
  EXCEPTION
    WHEN OTHERS THEN
       --dbms_output.put_line('EXEC02');
      VAR_LOG_ERRO := 'DADOS:' || ' -- LINHA: ' || VAR_COUNT || ' -- LINHA SPONTO COM ERRO: ' ||
                      SPONTO || ' -- CCOMPT_MARGM: ' || VAR_COMPT || ' -- PMARGM_CONTB: ' ||
                      V_PMARGM_CONTB || ' -- CTPO_PSSOA: ' || V_CTPO_PSSOA ||
                      ' -- CCPF_CNPJ_BASE: ' || V_CCPF_CNPJ_BASE || ' -- ERRO ORACLE: ' ||
                      SUBSTR(SQLERRM,
                             1,
                             120);
      --
      PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
  END DETALHE;
  -- Fim
  -- Insere conteúdo nas colunas
  --
BEGIN
  -- Iniciando Execução
    --dbms_output.put_line('01');
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PC);
  BEGIN

    BEGIN
    --dbms_output.put_line('02');
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'R');
    EXCEPTION
      WHEN OTHERS THEN
       --dbms_output.put_line('EXEC03');
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
    --dbms_output.put_line('03');
    UTL_FILE.GET_LINE(VAR_ARQUIVO,
                      VAR_REGISTRO_ARQUIVO);
    IF SUBSTR(VAR_REGISTRO_ARQUIVO,1,8) = '*HEADER;' THEN
      -- Competência
      BEGIN
       --dbms_output.put_line('04');
        VAR_COMPT := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,18,6));
       --dbms_output.put_line('05');
        DELETE MARGM_CONTB_CRRTR WHERE CCOMPT_MARGM = VAR_COMPT;
      EXCEPTION
        WHEN OTHERS THEN
       --dbms_output.put_line('EXEC04');
          VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR A COMPETÊNCIA DOS REGISTROS.' || ' -- LINHA: ' ||
                          VAR_COUNT || ' -- COMPETÊNCIA: ' ||
                          SUBSTR(VAR_REGISTRO_ARQUIVO,1,8) || ' -- DATA DE GERAÇÃO DO ARQUIVO: ' ||
                          SUBSTR(VAR_REGISTRO_ARQUIVO,25,8) || ' -- ERRO ORACLE: ' ||
                          SUBSTR(SQLERRM,1,120);
          PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
          RAISE;
      END;
    ELSE
       --dbms_output.put_line('06');
      VAR_LOG_ERRO := 'PROBLEMA AO INICIAR O CARREGAMENTO DOS REGISTROS.' || ' -- LINHA: ' ||
                      VAR_COUNT || ' -- COMPETÊNCIA: ' ||
                      SUBSTR(VAR_REGISTRO_ARQUIVO,1,8) || ' -- DATA DE GERAÇÃO DO ARQUIVO: ' ||
                      SUBSTR(VAR_REGISTRO_ARQUIVO,25,8);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      RAISE ERRO;
    END IF;
    BEGIN
      -- Varrendo os registros dos arquivos
       --dbms_output.put_line('07');
      LOOP
        UTL_FILE.GET_LINE(VAR_ARQUIVO,
                          VAR_REGISTRO_ARQUIVO);
        VAR_COUNT := VAR_COUNT + 1;
        BEGIN
          CASE
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        1) IN ('J',
                               'F') THEN
              DETALHE(VAR_REGISTRO_ARQUIVO);
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        9) = '*TRAILER;' THEN
              TRAILER(VAR_REGISTRO_ARQUIVO);
              --dbms_output.put_line('08');
              EXIT;
            ELSE
              VAR_LOG_ERRO := 'DADOS:' || ' -- LINHA: ' || VAR_COUNT || ' -- PESSOA INDEFINIDA: ' ||
                              SUBSTR(VAR_REGISTRO_ARQUIVO,1,1);
              PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
          END CASE;
         IF ((VAR_COUNT mod 100) = 0) THEN
            COMMIT;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --dbms_output.put_line('EXEC05');
           --dbms_output.put_line('09');
            RAISE;
        END;
      END LOOP;
       --dbms_output.put_line('10');

    EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('EXEC06');
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        RAISE;
    END;
    -- Execução terminada sem Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA, PC_UTIL_01.VAR_ROTNA_PO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'PROCESSO EXECUTADO COM SUCESSO.',PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
       --dbms_output.put_line('DEPOIS DO COMMIT');
  EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('EXEC07');
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE MARGENS DE CONTRIBUIÇÃO.' ||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      -- Processo executado com Erro
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      raise;
  END;
END SGPB0030;
/

