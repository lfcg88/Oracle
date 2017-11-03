CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0124
(
  VAR_IDTRIO_TRAB            	varchar2,
  VAR_IARQ_TRAB              	varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9124'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0124
  --      DATA            : 14/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, do perfil de um corretor.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          UTL_FILE.FILE_TYPE;
  VAR_LOG_ARQUIVO      UTL_FILE.FILE_TYPE;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 0;
  ERRO EXCEPTION;
  ERRO_GRP_RAMO EXCEPTION;
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB9124';
  VAR_IROTNA CONSTANT INT := 0726;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  CRRTR_NOT_FOUND_EXCEPTION EXCEPTION; 
  --
  -- Verifica se a quantidade de registros é igual à informada
  --
  PROCEDURE TRAILER(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    VAR_QT_REGISTROS NUMBER;
  BEGIN
    BEGIN
      VAR_QT_REGISTROS := TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,16,8));
    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR A QUANTIDADE DE REGISTROS PARA VERIFICAÇÃO.' ||
                        ' -- LINHA: ' || VAR_COUNT || ' -- QUANTIDADE DE REGISTROS: ' ||
                        TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 16, 8)) || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
        PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
        commit;
        Raise_Application_Error(-20003,VAR_LOG_ERRO);
    END;
    IF VAR_QT_REGISTROS = VAR_COUNT THEN
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      COMMIT;
    ELSE
      VAR_LOG_ERRO := 'NÚMERO DE REGISTROS INSERIDOS NÃO BATE COM O NÚMERO DE REGISTROS DO ARQUIVO.' ||
                      ' -- REGISTROS DO ARQUIVO: ' || (VAR_QT_REGISTROS - 2) ||
                      ' -- REGISTROS INSERIDOS: ' || (VAR_COUNT - 2);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE ERRO;
    END IF;
  END TRAILER;
  -- RECUERA A DATA DE INÍCIO DA VIGÊNCIA
  --
  PROCEDURE getDataInicioVigencia(
  P_CANAL IN CARAC_CRRTR_CANAL.Ccanal_Vda_Segur%type,
  P_DINI_VIGENCIA OUT CARAC_CRRTR_CANAL.DINIC_VGCIA_PARM %TYPE)
  IS
  BEGIN
       SELECT PIC.DINIC_VGCIA_PARM
       INTO P_DINI_VIGENCIA
       FROM PARM_INFO_CAMPA PIC
       WHERE PIC.CCANAL_VDA_SEGUR = P_CANAL
       AND PIC.DFIM_VGCIA_PARM IS NULL;

  END getDataInicioVigencia;
  --
  -- VERIFICA SE O CORRETOR É EXISTENTE
  --
  PROCEDURE getExistenceCorretor(
  P_TPO_PESSOA IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
  P_CPF_CNPJ IN CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE %type,
  P_NUMBER_LINE OUT INTEGER)
  IS
  BEGIN
       SELECT COUNT(*)
       INTO P_NUMBER_LINE
       FROM CRRTR_UNFCA_CNPJ CUC
       WHERE CUC.CCPF_CNPJ_BASE = P_CPF_CNPJ
       AND CUC.CTPO_PSSOA = P_TPO_PESSOA;

  END getExistenceCorretor;
----------------------------------------------------------------------------------------geraDetail
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS

  -- variáveis da tabela CARAC_CRRTR_CANAL
    V_CPRFIL_CRRTR_ORIGN CARAC_CRRTR_CANAL.CPRFIL_CRRTR_ORIGN %TYPE;
    V_CCPF_CNPJ_BASE     VARCHAR2(20);
    V_CTPO_PSSOA         VARCHAR2(20);
    V_CCANAL_VDA_SEGUR   VARCHAR2(20);
    V_DINIC_VGCIA_PARM   parm_info_campa.dinic_vgcia_parm%type;
    V_CIND_PRFIL_ATIVO   VARCHAR2(20);
    V_CIND_PERC_ATIVO    VARCHAR2(20);
    V_CRESP_ULT_ALT      VARCHAR2(20);
    V_DULT_ALT           parm_info_campa.dult_alt%type;
    P_COUNT_REG INTEGER;

  BEGIN
    BEGIN
      --
      -- código do perfil original
      V_CPRFIL_CRRTR_ORIGN := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                 22,
                                 1);
      --
      -- CPF ou CNPJ base
      V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO,
                             5,
                             14);
      --
      -- Código do tipo de pessoa
      V_CTPO_PSSOA := SUBSTR(VAR_REGISTRO_ARQUIVO,
                         20,
                         1);
      --
      -- Código do canal
      V_CCANAL_VDA_SEGUR := SUBSTR(VAR_REGISTRO_ARQUIVO, 3, 1);
      --
      -- Data de início da Cometência
      getDataInicioVigencia(V_CCANAL_VDA_SEGUR, V_DINIC_VGCIA_PARM);
      -- VERIFICA A EXISTÊNCIA DO CORRETOR
      getExistenceCorretor(V_CTPO_PSSOA,V_CCPF_CNPJ_BASE,P_COUNT_REG);
      --
      -- Código de indicativo de perfil ativo
      V_CIND_PRFIL_ATIVO  := 'S';
      --
      -- Código de indicativo de percentual ativo
      V_CIND_PERC_ATIVO  := 'N';
      --
      -- Código do responsável pela última alteração
      V_CRESP_ULT_ALT  := 'CARGA';
      --
      -- Data e hora da última alteração
      V_DULT_ALT   := sysdate;
      --
      IF (P_COUNT_REG = 0) THEN

              RAISE CRRTR_NOT_FOUND_EXCEPTION;

      END IF;
      --
      -- :) insert
      INSERT INTO CARAC_CRRTR_CANAL
        (CTPO_PSSOA,
         CCPF_CNPJ_BASE,
         CCANAL_VDA_SEGUR,
         DINIC_VGCIA_PARM,
         PCRSCT_PROD_ORIGN,
         PCRSCT_PROD_ALT,
         CPRFIL_CRRTR_ORIGN,
         CPRFIL_CRRTR_ALT,
         CIND_PRFIL_ATIVO,
         CIND_PERC_ATIVO,
         DULT_ALT,
         CRESP_ULT_ALT)
      VALUES
        (V_CTPO_PSSOA,
         TO_NUMBER(V_CCPF_CNPJ_BASE),
         TO_NUMBER(V_CCANAL_VDA_SEGUR),
         V_DINIC_VGCIA_PARM,
         NULL,
         NULL,
         V_CPRFIL_CRRTR_ORIGN,
         V_CPRFIL_CRRTR_ORIGN,
         V_CIND_PRFIL_ATIVO,
         V_CIND_PERC_ATIVO,
         V_DULT_ALT,
         V_CRESP_ULT_ALT);
      --
      --
    EXCEPTION
      WHEN others THEN

          -- Duplicate unique key
          IF (pc_util_01.Unique_Constraint_violated = SQLCODE) THEN
              --
              --atualizar o registro
              UPDATE CARAC_CRRTR_CANAL
              SET CPRFIL_CRRTR_ORIGN = V_CPRFIL_CRRTR_ORIGN,
                  CPRFIL_CRRTR_ALT   = V_CPRFIL_CRRTR_ORIGN,
                  CIND_PRFIL_ATIVO   = 'S',
                  CRESP_ULT_ALT      = 'CARGA',
                  DULT_ALT           = SYSDATE
              WHERE CTPO_PSSOA       = V_CTPO_PSSOA
                AND CCPF_CNPJ_BASE   = TO_NUMBER(V_CCPF_CNPJ_BASE)
                AND CCANAL_VDA_SEGUR = TO_NUMBER(V_CCANAL_VDA_SEGUR)
                AND DINIC_VGCIA_PARM = V_DINIC_VGCIA_PARM;

           ELSE
               VAR_LOG_ERRO :='PROBLEMA NO INSERT/UPDATE -- LINHA: '||VAR_COUNT ||' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,120);
               PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
               PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
               commit;
               RAISE;
           END IF;
    END;
  END DETALHE;
  -- Fim
  --
BEGIN
  -- Iniciando Execução
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PC);
  COMMIT;
  BEGIN
    BEGIN
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB,VAR_IARQ_TRAB,'R');
      --VAR_LOG_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB,VAR_IARQ_TRAB ||'_log_erro.dat','W');      
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
    --
    UTL_FILE.GET_LINE(VAR_ARQUIVO,VAR_REGISTRO_ARQUIVO);
    --
    -- Verifica se o arquivo tem header
    IF SUBSTR(VAR_REGISTRO_ARQUIVO,1,1) <> 0 THEN
      --
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'ERRO O ARQUIVO NÃO TEM HEADER'||VAR_IARQ_TRAB||'. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'), 
                          'P', NULL, NULL);      
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20002,'ERRO O ARQUIVO NÃO TEM HEADER');
      --
    END IF;
    --
    --
    BEGIN
      -- Varrendo os registros dos arquivos
      LOOP
        UTL_FILE.GET_LINE(VAR_ARQUIVO,VAR_REGISTRO_ARQUIVO);
        VAR_COUNT := VAR_COUNT + 1;
        BEGIN
          IF ((VAR_COUNT mod 100) = 0) THEN COMMIT; END IF;
          CASE
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,1,1) = 1 THEN
              DETALHE(VAR_REGISTRO_ARQUIVO);
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,1,1) = 9 THEN
              TRAILER(VAR_REGISTRO_ARQUIVO);
              EXIT;
          END CASE;
        EXCEPTION
          WHEN CRRTR_NOT_FOUND_EXCEPTION THEN
            VAR_LOG_ERRO := 'Corretor não encontrado. CPF/CNPJ: ' ||SUBSTR(VAR_REGISTRO_ARQUIVO,3,14) ||
                            '. Tipo Pessoa: ' || SUBSTR(VAR_REGISTRO_ARQUIVO,17,1)||
                            '. -- LINHA: ' || VAR_COUNT || ' ' || VAR_REGISTRO_ARQUIVO;
            --armazena no arquivo log a linha que deu erro
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --armazena o erro encontrado
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
            PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
            PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
            RAISE_APPLICATION_ERROR(-20002,VAR_LOG_ERRO);
          WHEN OTHERS THEN
            --
            --
            VAR_LOG_ERRO := 'Erro inserindo na tabela carac_crrtr_canal.' || ' -- LINHA: ' || VAR_COUNT || ' Registro: ' ||
                            VAR_REGISTRO_ARQUIVO|| ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
            --armazena no arquivo log a linha que deu erro
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --armazena o erro encontrado
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
            PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
            PC_UTIL_01.SGPB0028(VAR_LOG_ERRO, VAR_CROTNA);
            RAISE_APPLICATION_ERROR(-20002,VAR_LOG_ERRO);
        END;
      END LOOP;
    EXCEPTION
      --
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
        RAISE;
    END;
    -- Execução terminada sem Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'PROCESSO EXECUTADO COM SUCESSO. REGISTROS PROCESSADOS '||VAR_COUNT,
                           PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
    UTL_FILE.FCLOSE(VAR_ARQUIVO);
    COMMIT;
    --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
  EXCEPTION
    WHEN ABRE_ARQUIVO_EXCEPTION THEN
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH. VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                      ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      Raise_Application_Error(-20003,'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH. VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                      ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB);
      --
    WHEN OTHERS THEN
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE PERFIL DE CORRETOR.' ||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20002,VAR_LOG_ERRO);
      raise;
  END;
END SGPB0124;
/

