CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0122
(
  VAR_IDTRIO_TRAB            	varchar2,
  VAR_IARQ_TRAB              	varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB9122'
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0122
  --      DATA            : 16/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, do objetivo de um corretor.
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
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB9122';
  VAR_IROTNA CONSTANT INT := 0724;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  SEM_VERSAO_EXCEPTION EXCEPTION;
  VAR_INDICA_ERRO CHAR(01) := 'N';
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
                        TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,16,8)) || ' -- ERRO ORACLE: ' ||
                        SUBSTR(SQLERRM,1,120);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
        PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
        COMMIT;
        RAISE;
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
  -- Fim
  --
  -- RECUERA O MAIOR SEQUENCIAL DA VERSÃO DO OBJETIVO
  --
  PROCEDURE getMaxVerObject(
    P_CCPF_CNPJ_BASE   IN objtv_prod_crrtr.ccpf_cnpj_base %type,
    P_CTPO_PSSOA       IN objtv_prod_crrtr.ctpo_pssoa %type,
    P_CCANAL_VDA_SEGUR IN objtv_prod_crrtr.ccanal_vda_segur %type,
    P_CGRP_RAMO_PLANO  IN objtv_prod_crrtr.cgrp_ramo_plano %type,
    P_CCOMPT_OBJTV     IN objtv_prod_crrtr.cano_mes_compt_objtv %type,
    P_MAX_VERSION      OUT objtv_prod_crrtr.cseq_objtv_crrtr %type)
  IS
  BEGIN
       SELECT
       MAX(OPC.CSEQ_OBJTV_CRRTR)
       INTO P_MAX_VERSION
       FROM OBJTV_PROD_CRRTR OPC
       WHERE OPC.CTPO_PSSOA         = P_CTPO_PSSOA
       AND OPC.CCPF_CNPJ_BASE       = P_CCPF_CNPJ_BASE
       AND OPC.CCANAL_VDA_SEGUR     = P_CCANAL_VDA_SEGUR
       AND OPC.CGRP_RAMO_PLANO      = P_CGRP_RAMO_PLANO
       AND OPC.CANO_MES_COMPT_OBJTV = P_CCOMPT_OBJTV;
  END getMaxVerObject;
  --
  -- VERIFICA SE O CORRETOR É EXISTENTE
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
         AND CUC.CTPO_PSSOA     = P_TPO_PESSOA;
  END getExistenceCorretor;
----------------------------------------------------------------------------------------geraDetail
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
  -- variáveis da tabela OBJTV_PROD_CRRTR
    V_CCPF_CNPJ_BASE     VARCHAR2(20);
    V_CTPO_PSSOA         VARCHAR2(1);
    V_CCANAL_VDA_SEGUR   VARCHAR2(1);
    V_CGRP_RAMO_PLANO    VARCHAR2(3);
    V_CCOMPT_OBJTV       objtv_prod_crrtr.cano_mes_compt_objtv %type;
    V_OBJTV_PROD_ORIGN   objtv_prod_crrtr.vobjtv_prod_crrtr_orign %type;
    V_CRESP_ULT_ALT      VARCHAR2(20);
    V_DULT_ALT           date; -- VARCHAR2(20);
    V_CIND_REG_ATIVO     VARCHAR2(1);
    V_SEQ_VERSION        VARCHAR2(20);
    P_COUNT_REG INTEGER;
    P_MAX_VERSION INTEGER;
  BEGIN
    BEGIN
      --
      -- Código do canal
      V_CCANAL_VDA_SEGUR := SUBSTR(VAR_REGISTRO_ARQUIVO, 3, 1);
      --
      -- GRUPO RAMO
      V_CGRP_RAMO_PLANO := SUBSTR(VAR_REGISTRO_ARQUIVO, 5, 1);
      V_CGRP_RAMO_PLANO := CASE WHEN V_CGRP_RAMO_PLANO = 'A'
                             THEN PC_UTIL_01.Auto
                             ELSE PC_UTIL_01.Re
                           END;
      --
      -- CPF ou CNPJ base
      V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO, 7, 14);
      --
      -- Código do tipo de pessoa
      V_CTPO_PSSOA := SUBSTR(VAR_REGISTRO_ARQUIVO, 22, 1);
      --
      -- COMPETÊNCIA DO OBJETIVO
      V_CCOMPT_OBJTV := SUBSTR(VAR_REGISTRO_ARQUIVO, 24, 6);
      --
      -- VALOR DO OBJETIVO
      V_OBJTV_PROD_ORIGN := (TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO, 31, 17))/100);

      -- VERIFICA A EXISTÊNCIA DO CORRETOR
      getExistenceCorretor(V_CTPO_PSSOA,V_CCPF_CNPJ_BASE,P_COUNT_REG);
      --
      -- Número da sequência da versão do objetivo
      V_SEQ_VERSION   := 1;
      --
      -- Código de indicativo de objetivo ativo
      V_CIND_REG_ATIVO  := 'S';
      --
      -- Código do responsável pela última alteração
      V_CRESP_ULT_ALT  := 'CARGA';
      --
      -- Data e hora da última alteração
      V_DULT_ALT   := sysdate;
      --
      IF (P_COUNT_REG = 0) THEN
         VAR_LOG_ERRO := 'NÃO FOI ENCONTRADO O CORRETOR NO SISTEMA. -- LINHA: '|| VAR_COUNT||' REGISTRO: '||VAR_REGISTRO_ARQUIVO;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
         COMMIT;
         RAISE_APPLICATION_ERROR(-20030,VAR_LOG_ERRO);
      END IF;
      --
      -- :) insert
      INSERT INTO OBJTV_PROD_CRRTR
        (CTPO_PSSOA,
         CCPF_CNPJ_BASE,
         CSEQ_OBJTV_CRRTR,
         CGRP_RAMO_PLANO,
         CCANAL_VDA_SEGUR,
         vobjtv_prod_crrtr_alt,
         VOBJTV_PROD_CRRTR_ORIGN,
         CIND_REG_ATIVO,
         DULT_ALT,
         CRESP_ULT_ALT,
         CANO_MES_COMPT_OBJTV)
      VALUES
        (V_CTPO_PSSOA,
         TO_NUMBER(V_CCPF_CNPJ_BASE),
         TO_NUMBER(V_SEQ_VERSION),
         TO_NUMBER(V_CGRP_RAMO_PLANO),
         TO_NUMBER(V_CCANAL_VDA_SEGUR),
         TO_NUMBER(V_OBJTV_PROD_ORIGN), --
         TO_NUMBER(V_OBJTV_PROD_ORIGN), --
         V_CIND_REG_ATIVO,
         V_DULT_ALT,
         V_CRESP_ULT_ALT,
         TO_NUMBER(V_CCOMPT_OBJTV));
      --
      --
    EXCEPTION
      WHEN others THEN
          -- Duplicate unique key
          IF (pc_util_01.Unique_Constraint_violated = SQLCODE) THEN
             BEGIN
                  -- RECUPERA O NÚMERO DA MAIOR VERSÃO
                  getMaxVerObject(V_CCPF_CNPJ_BASE, V_CTPO_PSSOA, V_CCANAL_VDA_SEGUR,
                                  V_CGRP_RAMO_PLANO, V_CCOMPT_OBJTV, P_MAX_VERSION);
                  --INATIVANDO A VERSÃO ATUAL DO OBJETIVO
                  UPDATE OBJTV_PROD_CRRTR OPC
                  SET OPC.CIND_REG_ATIVO = 'N',
                      OPC.CRESP_ULT_ALT  = 'CARGA',
                      OPC.DULT_ALT       = SYSDATE
                  WHERE OPC.CTPO_PSSOA       = V_CTPO_PSSOA
                    AND OPC.CCPF_CNPJ_BASE   = TO_NUMBER(V_CCPF_CNPJ_BASE)
                    AND OPC.CCANAL_VDA_SEGUR = TO_NUMBER(V_CCANAL_VDA_SEGUR)
                    AND OPC.CGRP_RAMO_PLANO  = TO_NUMBER(V_CGRP_RAMO_PLANO)
                    AND OPC.CANO_MES_COMPT_OBJTV = TO_NUMBER(V_CCOMPT_OBJTV)
                    AND OPC.CSEQ_OBJTV_CRRTR = P_MAX_VERSION
                    AND OPC.CIND_REG_ATIVO = 'S';
                  --INSERT DO NOVO REGISTRO INCREMENTANDO A SUA VERSÃO
                INSERT INTO OBJTV_PROD_CRRTR
                  (CTPO_PSSOA,
                   CCPF_CNPJ_BASE,
                   CSEQ_OBJTV_CRRTR,
                   CGRP_RAMO_PLANO,
                   CCANAL_VDA_SEGUR,
                   vobjtv_prod_crrtr_alt,
                   VOBJTV_PROD_CRRTR_ORIGN,
                   CIND_REG_ATIVO,
                   DULT_ALT,
                   CRESP_ULT_ALT,
                   CANO_MES_COMPT_OBJTV)
                VALUES
                  (V_CTPO_PSSOA,
                   TO_NUMBER(V_CCPF_CNPJ_BASE),
                   TO_NUMBER(P_MAX_VERSION+1),
                   TO_NUMBER(V_CGRP_RAMO_PLANO),
                   TO_NUMBER(V_CCANAL_VDA_SEGUR),
                   TO_NUMBER(V_OBJTV_PROD_ORIGN),
                   TO_NUMBER(V_OBJTV_PROD_ORIGN),
                   V_CIND_REG_ATIVO,
                   V_DULT_ALT,
                   V_CRESP_ULT_ALT,
                   TO_NUMBER(V_CCOMPT_OBJTV));
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    VAR_LOG_ERRO := 'Erro pegando versao anterior do corretor (no_data_found)' || ' -- LINHA: ' || VAR_COUNT||
                                    ' REGISTRO: '||VAR_REGISTRO_ARQUIVO;
                    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
                    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);                    
                    PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
                    COMMIT;
                    RAISE_APPLICATION_ERROR(-20030,VAR_LOG_ERRO);
                    --armazena no arquivo log a linha que deu erro
                    --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
                    --nova linha
                    --utl_file.new_line(VAR_LOG_ARQUIVO);
                    --armazena o erro encontrado
                    --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
                    --nova linha
                    --utl_file.new_line(VAR_LOG_ARQUIVO);
             END;
           ELSE
               VAR_LOG_ERRO := 'Erro na tentativa de fazer insert' || ' -- LINHA: ' || VAR_COUNT || ' Registro: ' ||
                               VAR_REGISTRO_ARQUIVO||' Erro: '||SUBSTR(SQLERRM,1,120);
               PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
               PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);                    
               PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
               COMMIT;
               RAISE_APPLICATION_ERROR(-20030,VAR_LOG_ERRO);
           END IF;
    END;
  END DETALHE;
  -- Fim
  -- Insere conteúdo nas colunas
  --
BEGIN
  -- Iniciando Execução
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PC);
  COMMIT;
  BEGIN
    BEGIN
      VAR_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'R');
      --VAR_LOG_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB || '_log_erro.dat', 'W');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
/*    --
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
    END IF;*/
    --
    --
    BEGIN
      -- Varrendo os registros dos arquivos
      LOOP
        UTL_FILE.GET_LINE(VAR_ARQUIVO,VAR_REGISTRO_ARQUIVO);
        VAR_COUNT := VAR_COUNT + 1;
        BEGIN
          IF ((VAR_COUNT mod 100) = 0) THEN
            COMMIT;
          END IF;
/*          CASE
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        1) = 1 THEN
              DETALHE(VAR_REGISTRO_ARQUIVO);
            WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,
                        1,
                        1) = 9 THEN
              TRAILER(VAR_REGISTRO_ARQUIVO);
              EXIT;
          END CASE;*/
          DETALHE(VAR_REGISTRO_ARQUIVO);
        EXCEPTION
          WHEN OTHERS THEN
            --
            VAR_LOG_ERRO:='ERRO NA LINHA: '||VAR_COUNT||' REGISTRO: '||VAR_REGISTRO_ARQUIVO||' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,120);
            --armazena no arquivo log a linha que deu erro
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --armazena o erro encontrado
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);            
            PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
            PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);            
            COMMIT;            
            Raise_Application_Error(-20003,VAR_LOG_ERRO);
         END;
      END LOOP;
      COMMIT;
    EXCEPTION
      --
      WHEN NO_DATA_FOUND THEN
           UTL_FILE.FCLOSE(VAR_ARQUIVO);
           --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
           COMMIT;
      WHEN OTHERS THEN
           UTL_FILE.FCLOSE(VAR_ARQUIVO);
           VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE OBJETIVO DE PRODUÇÃO DO CORRETOR.'||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
           PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
           --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
           COMMIT;
           Raise_Application_Error(-20003,VAR_LOG_ERRO);
    END;
    -- Execução terminada sem Erro
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'PROCESSO EXECUTADO COM SUCESSO. QUANTIDAE DE REGISTROS PROCESSADOS: '||VAR_COUNT,
                           PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
    UTL_FILE.FCLOSE(VAR_ARQUIVO);
    commit;
    --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
  EXCEPTION
    WHEN ABRE_ARQUIVO_EXCEPTION THEN      
      VAR_LOG_ERRO := 'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH. VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                      ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      commit;
      Raise_Application_Error(-20003,VAR_LOG_ERRO);
    WHEN OTHERS THEN
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE OBJETIVO DE PRODUÇÃO DO CORRETOR.' ||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      commit;
      raise;
  END;
END SGPB0122;
/

