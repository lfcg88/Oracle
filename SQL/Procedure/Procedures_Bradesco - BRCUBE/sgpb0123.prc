CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0123
(
  VAR_IDTRIO_TRAB            	varchar2,
  VAR_IARQ_TRAB              	varchar2,
  chrNomeRotinaScheduler        VARCHAR2 := 'SGPB9123'
) IS
  -----------------------------------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0123
  --      DATA            : 15/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, do percentual de crescimento esperado de um corretor.
  --                        Processo de carga de Planilha de percentuais de corretores extra-banco (que são usados para gerar objetivo). 
  --      ALTERAÇÕES      : Em 22/05/2007 - Foram colocadas para teste e depois em producao as seguintes alteracoes vindas da Stefanini.
  --                         - O processo de carga deveria ser alterado para: sempre que for chamado remover os corretores anteriores. 
  --                         - Lembrando como será o fluxo: 
  --                           1) gestor upload a planilha 
  --                           2) sistema zera tabela de perfis e importa (ISSO É O QUE FOI IMPLEMENTADO NESSA VERSAO)
  --                           3) sistema usa a tabela de perfis para gerar obj 
  --                         - Duas ações devem ser tomadas: 
  --                           1) tirar do ar via menu-intranet a tela de manutenção de perfil 
  --                           2) compilar a procedure SGPB0123 em suas bases de desenvolvimento e produção. 
  --                         Ass. Wassily (O texto acima foi retirado do próprio email enviado e fica como documentação).
 ------------------------------------------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          UTL_FILE.FILE_TYPE;
  VAR_LOG_ARQUIVO      UTL_FILE.FILE_TYPE;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 0;
  ERRO EXCEPTION;
  ERRO_GRP_RAMO EXCEPTION;
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CHAR(8) := 'SGPB9123';
  VAR_IROTNA CONSTANT INT := 0725;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  CRRTR_NOT_FOUND_EXCEPTION EXCEPTION;
  VAR_INDICA_ERRO CHAR(01) := 'N';
  --
  V_CCANAL_VDA_SEGUR   VARCHAR2(20); 							-- campos novos
  V_DINIC_VGCIA_PARM   parm_info_campa.dinic_vgcia_parm%type;	-- campos novos
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
        commit;
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
      commit;
      RAISE ERRO;
    END IF;
  END TRAILER;
  --
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
         AND CUC.CTPO_PSSOA     = P_TPO_PESSOA;

  END getExistenceCorretor;

----------------------------------------------------------------------------------------geraDetail
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
  -- variáveis da tabela CARAC_CRRTR_CANAL
    V_PCRSCT_PROD_ORIGN CARAC_CRRTR_CANAL.PCRSCT_PROD_ORIGN %TYPE;
    V_CCPF_CNPJ_BASE     VARCHAR2(20);
    V_CTPO_PSSOA         VARCHAR2(20);
    V_CIND_PRFIL_ATIVO   VARCHAR2(20);
    V_CIND_PERC_ATIVO    VARCHAR2(20);
    V_CRESP_ULT_ALT      VARCHAR2(20);
    V_DULT_ALT           parm_info_campa.dult_alt%type;
    P_COUNT_REG INTEGER;
  BEGIN
    BEGIN
      --
      -- percentual de crescimento esperado para o corretor
      V_PCRSCT_PROD_ORIGN := (TO_NUMBER(SUBSTR(VAR_REGISTRO_ARQUIVO,
                              34, --22,
                              14))/10000);
      --
      -- CPF ou CNPJ base
      V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO,
                             7, --5,
                             14);
      --
      -- Código do tipo de pessoa
      V_CTPO_PSSOA := SUBSTR(VAR_REGISTRO_ARQUIVO,
                         22, --20,
                         1);
      --
      -- Código do canal
      V_CCANAL_VDA_SEGUR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                  3,
                                  1);
      --
      -- Data de início da Cometência
      getDataInicioVigencia(V_CCANAL_VDA_SEGUR, V_DINIC_VGCIA_PARM);
      -- VERIFICA A EXISTÊNCIA DO CORRETOR
      getExistenceCorretor(V_CTPO_PSSOA,V_CCPF_CNPJ_BASE,P_COUNT_REG);
      --
      -- Código de indicativo de perfil ativo
      V_CIND_PRFIL_ATIVO  := 'N';
      --
      -- Código de indicativo de percentual ativo
      V_CIND_PERC_ATIVO  := 'S';
      --
      -- Código do responsável pela última alteração
      V_CRESP_ULT_ALT  := 'CARGASGPB0123';
      --
      -- Data e hora da última alteração
      V_DULT_ALT   := sysdate;

      --
      IF (P_COUNT_REG = 0) THEN
              VAR_LOG_ERRO := 'Corretor não encontrado. CPF/CNPJ: ' ||SUBSTR(VAR_REGISTRO_ARQUIVO,3,14) ||
                            '. Tipo Pessoa: ' || SUBSTR(VAR_REGISTRO_ARQUIVO,17,1)||
                            '. -- LINHA: ' || VAR_COUNT || ' ' || VAR_REGISTRO_ARQUIVO;
            -- Retirada a instrução abaixo porque não pode rodar se for com o dwscheduler
            -- Ass. Wassily, 11/04/2007
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
            RAISE_APPLICATION_ERROR(-20001,VAR_LOG_ERRO);
      --END IF;
      --
      -- :) insert
      ELSE
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
         V_PCRSCT_PROD_ORIGN,
         V_PCRSCT_PROD_ORIGN,
         NULL,
         NULL,
         V_CIND_PRFIL_ATIVO,
         V_CIND_PERC_ATIVO,
         V_DULT_ALT,
         V_CRESP_ULT_ALT);
      END IF;
      --
    EXCEPTION
       when dup_val_on_index then -- clausula criada para tratar a chave duplicada, como estava nao iria funcionar. 
       							  -- ass. wassily (22/05/2007)
            UPDATE CARAC_CRRTR_CANAL
              SET PCRSCT_PROD_ORIGN  = V_PCRSCT_PROD_ORIGN,
                  PCRSCT_PROD_ALT    = V_PCRSCT_PROD_ORIGN,
                  CIND_PERC_ATIVO    = 'S',
                  CRESP_ULT_ALT      = 'CARGASGPB0123',
                  DULT_ALT           = SYSDATE
              WHERE CTPO_PSSOA       = V_CTPO_PSSOA
                AND CCPF_CNPJ_BASE   = TO_NUMBER(V_CCPF_CNPJ_BASE)
                AND CCANAL_VDA_SEGUR = TO_NUMBER(V_CCANAL_VDA_SEGUR)
                AND DINIC_VGCIA_PARM = V_DINIC_VGCIA_PARM;
       WHEN others THEN  -- foram documentadas as linhas abaixo, o IF abaixo nao iria executar. ass. wassily (22/05/2007)
            -- Duplicate unique key
            --IF DUP_VAL_ON_INDEX then -- (pc_util_01.Unique_Constraint_violated = SQLCODE) THEN
            --    --atualizar o registro
            --    UPDATE CARAC_CRRTR_CANAL
            --    SET PCRSCT_PROD_ORIGN  = V_PCRSCT_PROD_ORIGN,
            --        PCRSCT_PROD_ALT    = V_PCRSCT_PROD_ORIGN,
            --        CIND_PERC_ATIVO    = 'S',
            --        CRESP_ULT_ALT      = 'CARGA',
            --        DULT_ALT           = SYSDATE
            --    WHERE CTPO_PSSOA       = V_CTPO_PSSOA
            --      AND CCPF_CNPJ_BASE   = TO_NUMBER(V_CCPF_CNPJ_BASE)
            --      AND CCANAL_VDA_SEGUR = TO_NUMBER(V_CCANAL_VDA_SEGUR)
            --      AND DINIC_VGCIA_PARM = V_DINIC_VGCIA_PARM;
            -- ELSE
               rollback;
               VAR_LOG_ERRO :='PROBLEMA NO INSERT/UPDATE -- LINHA: '||VAR_COUNT ||' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,120);
               PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
               PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
               COMMIT;
               RAISE_APPLICATION_ERROR(-20002,VAR_LOG_ERRO);
          -- END IF;      
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
      -- Isso não pode. ass. Wassily 10/04/2007
      -- VAR_LOG_ARQUIVO := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB ||'_log_erro.dat', 'W');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ABRE_ARQUIVO_EXCEPTION;
    END;
    --
    BEGIN
      -- codigo novo. entregue nessa nova versao ---------------------------------------------------------
      getDataInicioVigencia(1, V_DINIC_VGCIA_PARM);
      -- limpa a tabela 
      update carac_crrtr_canal ccc
         set CIND_PERC_ATIVO    = 'N',
             CRESP_ULT_ALT      = 'CARGASGPB0123',
             DULT_ALT           = SYSDATE             
       where CCANAL_VDA_SEGUR = 1
         AND DINIC_VGCIA_PARM = V_DINIC_VGCIA_PARM;
      -- final do codigo novo entregue ---------------------------------------------------------------------       
      -- Varrendo os registros dos arquivos
      LOOP
        UTL_FILE.GET_LINE(VAR_ARQUIVO,VAR_REGISTRO_ARQUIVO);
        VAR_COUNT := VAR_COUNT + 1;
        -- IMPLANTAÇÃO
        --IF VAR_COUNT = 52 THEN
            -- Tirei essa linha ai em baixo tava errada, não era para ter isso
            -- Wassily (11/04/2007)
            -- VAR_LOG_ERRO := 'Fim da Carga de Implantação. Quantidade de linhas Incluidas: '||VAR_COUNT;

            -- As linhas abaixo foram retiradas porque não vão rodar via dwscheduler.
            -- ass. wassily 11/04/2007
            --armazena no arquivo log a linha que deu erro
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --armazena o erro encontrado
            --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
            --nova linha
            --utl_file.new_line(VAR_LOG_ARQUIVO);
            --
            --PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
            --
            --
        --    PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
        --end if;
        BEGIN
          IF ((VAR_COUNT mod 10) = 0) 
          		THEN COMMIT; 
          END IF;
          --CASE
          -- WHEN SUBSTR(VAR_REGISTRO_ARQUIVO,1,1) = 1 THEN
          if SUBSTR(VAR_REGISTRO_ARQUIVO,1,1) = 1 THEN
             DETALHE(VAR_REGISTRO_ARQUIVO);
          end if;
          --END CASE;
        EXCEPTION
           WHEN CRRTR_NOT_FOUND_EXCEPTION THEN
                VAR_LOG_ERRO := 'Corretor não encontrado. CPF/CNPJ: ' ||SUBSTR(VAR_REGISTRO_ARQUIVO,3,14) ||
                                '. Tipo Pessoa: ' || SUBSTR(VAR_REGISTRO_ARQUIVO,17,1)||
                                '. -- LINHA: ' || VAR_COUNT || ' ' || VAR_REGISTRO_ARQUIVO;
                -- As linhas abaixo foram retiradas. Pelo scheduler isso não roda.
                -- ass. Wassily - 11/04/2007
                --armazena no arquivo log a linha que deu erro
                --utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
                --nova linha
                --utl_file.new_line(VAR_LOG_ARQUIVO);
                --armazena o erro encontrado
                --utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
                --nova linha
                --utl_file.new_line(VAR_LOG_ARQUIVO);
                --
                rollback;
                PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
                PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
                PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
               COMMIT;
               RAISE_APPLICATION_ERROR(-20003,VAR_LOG_ERRO);
           WHEN OTHERS THEN
            	--            
            	VAR_LOG_ERRO := 'PROBLEMA NO INSERT DO PERCENTUAL DE CRESCIMENTO DO CORRETOR.' ||
                            ' -- LINHA: '||VAR_COUNT||' -- REGISTRO: '||VAR_REGISTRO_ARQUIVO||
                            ' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,120);
            	-- As linhas abaixo foram retiradas. Pelo scheduler isso não roda.
            	-- ass. Wassily - 11/04/2007
            	--armazena no arquivo log a linha que deu erro
            	--utl_file.put(VAR_LOG_ARQUIVO,VAR_REGISTRO_ARQUIVO);
            	--nova linha
            	--utl_file.new_line(VAR_LOG_ARQUIVO);
            	--armazena o erro encontrado
            	--utl_file.put(VAR_LOG_ARQUIVO,VAR_LOG_ERRO);
            	--nova linha
            	--utl_file.new_line(VAR_LOG_ARQUIVO);
            	--
            	rollback;
            	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
            	PC_UTIL_01.SGPB0028(VAR_LOG_ERRO,VAR_CROTNA);
            	PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
            	COMMIT;
            	RAISE_APPLICATION_ERROR(-20004,VAR_LOG_ERRO);
         	END;
      END LOOP;
    EXCEPTION
      --
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(VAR_ARQUIVO);
        -- A linha abaixo foi retirada. Pelo scheduler isso não roda.
        -- ass. Wassily - 11/04/2007
        --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
        RAISE;
    END;
    -- Execução terminada sem Erro
    UTL_FILE.FCLOSE(VAR_ARQUIVO);
    -- A linha abaixo foi retirada. Pelo scheduler isso não roda.
    -- ass. Wassily - 11/04/2007
    --UTL_FILE.FCLOSE(VAR_LOG_ARQUIVO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'PROCESSO EXECUTADO COM SUCESSO. REGISTROS PROCESSADOS '||VAR_COUNT,
                           PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
    commit;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      UTL_FILE.FCLOSE(VAR_ARQUIVO);
      VAR_LOG_ERRO := 'TERMINO DA CARGA DO PERCENTUAL DE CRESCIMENTO DO CORRETOR.' ||
                      ' -- REGISTROS PROCESSADOS: ' || VAR_COUNT ;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
      commit;
      Raise_Application_Error(-20005,VAR_LOG_ERRO);
    WHEN ABRE_ARQUIVO_EXCEPTION THEN
      rollback;
      VAR_LOG_ERRO := 'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH. VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                      ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB;
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      commit;
      Raise_Application_Error(-20006,VAR_LOG_ERRO);
    WHEN OTHERS THEN
      ROLLBACK;
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE PERCENTUAL DE CRESCIMENTO DO CORRETOR.' ||
                      ' -- LINHA: ' || VAR_COUNT || ' -- ERRO ORACLE: ' ||SUBSTR(SQLERRM,1,120);
      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
      commit;
      RAISE_APPLICATION_ERROR(-20007,VAR_LOG_ERRO);
  END;
END SGPB0123;
/

