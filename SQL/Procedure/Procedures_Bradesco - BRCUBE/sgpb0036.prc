CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0036
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  VAR_IDTRIO_TRAB            	varchar2,
  VAR_IARQ_TRAB              	varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9036'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0036
  --      DATA            : 14/3/2006 18:21:01
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, da Lista Negra.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          utl_file.file_type;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 1;
  ERRO EXCEPTION;
  VAR_LOG_ERRO   VARCHAR2(2000);
  VER_ERRO_ATUAL VARCHAR2(150);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB9036'; -- estava errado, estava sgpb0036, não era a rotina do dwscheduler. ass. wassily.
  VAR_IROTNA CONSTANT INT := 0727;
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
     --dbms_output.put_line('QTD INFORMADA = '||VAR_QT_REGISTROS);
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
     --dbms_output.put_line('QTD CONTADA =' || VAR_COUNT);

    IF VAR_QT_REGISTROS = VAR_COUNT THEN
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      COMMIT;
    ELSE
      /*12/04  Alteração: Comentado comandos*/
      --ROLLBACK;
      --Temporariamente a procedure irá confirmar o processamento mesmo que o numero de registros não bata.
      --Solicitação feita pelos Srs. A.Bispo e Felipe.
      /*12/04*/

      VAR_LOG_ERRO := 'NÚMERO DE REGISTROS INSERIDOS NÃO BATE COM O NÚMERO DE REGISTROS DO ARQUIVO.' ||
                      ' -- REGISTROS DO ARQUIVO: ' || (VAR_QT_REGISTROS) ||
                      ' -- REGISTROS INSERIDOS: ' || (VAR_COUNT);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      /*12/04 Alteração: inclusao de dois comandos*/
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      COMMIT;
      /*12/04*/

      /*12/04 Alteração: comentado comando*/
      --RAISE ERRO;
      /*12/04*/
    END IF;
  END TRAILER;

  -- Fim
  -- Verifica se a quantidade de registros é igual à informada
  --
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    v_ccpf_cnpj_base   VARCHAR(15);
    v_ccompt_sit_crrtr VARCHAR(15);
    v_csit_crrtr_bdsco VARCHAR(15);
    v_ctpo_pssoa       VARCHAR(15);
  BEGIN
    BEGIN
      --
      -- CPF/CNPJ Raiz do Corretor
      VER_ERRO_ATUAL   := 'PROBLEMA AO CARREGAR CPF/CNPJ RAIZ DO REGISTRO.';
      v_ccpf_cnpj_base := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                 9,
                                 9);
      --
      -- Competência
      VER_ERRO_ATUAL     := 'PROBLEMA AO CARREGAR A COMPETÊNCIA DO REGISTRO.';
      v_ccompt_sit_crrtr := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                   2,
                                   6);
      --
      -- Situação do Corretor
      VER_ERRO_ATUAL     := 'PROBLEMA AO CARREGAR A SITUAÇÃO DO REGISTRO.';
      v_csit_crrtr_bdsco := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                   18,
                                   2);
      --
      -- Tipo Pessoa
      VER_ERRO_ATUAL := 'PROBLEMA AO CARREGAR O TIPO PESSOA DO REGISTRO.';
      v_ctpo_pssoa   := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               8,
                               1);
      --
      -- Faz insert
      VER_ERRO_ATUAL := 'PROBLEMA AO INSERIR O REGISTRO NA TABELA INFO_LISTA_NEGRA_CRRTR.';
      INSERT INTO info_lista_negra_crrtr
        (ccpf_cnpj_base,
         ccompt_sit_crrtr,
         csit_crrtr_bdsco,
         ctpo_pssoa)
      VALUES
        (v_ccpf_cnpj_base,
         v_ccompt_sit_crrtr,
         v_csit_crrtr_bdsco,
         v_ctpo_pssoa);
    EXCEPTION
      WHEN OTHERS THEN
        --
        --
        VAR_LOG_ERRO := VER_ERRO_ATUAL || ' -- LINHA: ' || VAR_COUNT || ' -- CCPF_CNPJ_BASE: ' ||
                        v_ccpf_cnpj_base || ' -- CCOMPT_SIT_CRRTR: ' || V_ccompt_sit_crrtr ||
                        ' -- CSIT_CRRTR_BDSCO: ' || v_csit_crrtr_bdsco || ' -- CTPO_PSSOA: ' ||
                        v_ctpo_pssoa || ' -- ERRO ORACLE: ' ||
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
        PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,
                            VAR_CROTNA);
        --
      --
    END;
  END DETALHE;

BEGIN
  -- Iniciando Execução
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                            VAR_IROTNA,
                            PC_UTIL_01.VAR_ROTNA_PC);
  BEGIN
    BEGIN
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB, 'R');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
    --
    --
    BEGIN
      DELETE FROM info_lista_negra_crrtr t WHERE T.CCOMPT_SIT_CRRTR = intrCompetencia;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,
                                'ERRO DELETANDO A COMPETENCIA DA TABELA info_lista_negra_crrtr');
    END;
    --
    --
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
      --dbms_output.put_line('01');
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
          WHEN ERRO THEN
            NULL;
          WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
        END;
      END LOOP;
    EXCEPTION
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
        ROLLBACK;
	      VAR_LOG_ERRO := 'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH.' || 
					      ' -- DIR: ' || VAR_IDTRIO_TRAB ||
					      ' -- ARQ: ' || VAR_IARQ_TRAB ||
					      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);
	
	      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
	                             VAR_LOG_ERRO,
	                             PC_UTIL_01.VAR_LOG_PROCESSO,
	                             NULL,
	                             NULL);
	                             
	      -- Processo executado com Erro
	      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,
	                                VAR_IROTNA,	                                
	                                PC_UTIL_01.VAR_ROTNA_PE);
	      COMMIT;     
    WHEN OTHERS THEN
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE LISTA NEGRA.' || ' -- LINHA: ' ||
                      VAR_COUNT || ' -- ERRO ORACLE: ' ||
                      SUBSTR(SQLERRM,
                             1,
                             120);
                             
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);
      -- Processo executado com Erro
      PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,
                                VAR_IROTNA,
                                PC_UTIL_01.VAR_ROTNA_PE);
     COMMIT;
  END;
END SGPB0036;
/

