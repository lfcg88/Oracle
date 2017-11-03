CREATE OR REPLACE PROCEDURE SGPB_PROC.PR_IN_CRRTR_UNFCA
(
  -- DIRETORIO        VARCHAR2,
  INTERVALO_COMMIT INTEGER default 1000
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : PR_IN_CRRTR_UNFCA
  --      DATA            : 14/3/2006 20:23:40
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, de arquivo .txt, da produção no Ramo Bilhete.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO          UTL_FILE.FILE_TYPE;
  VAR_ARQUIVO_ERRO     UTL_FILE.FILE_TYPE;
  VAR_REGISTRO_ARQUIVO VARCHAR2(500);
  VAR_COUNT            INTEGER := 1;
  ERRO EXCEPTION;
  ERRO_GRP_RAMO EXCEPTION;
  ABRE_ARQUIVO_EXCEPTION EXCEPTION;
  --
  -- Verifica se a quantidade de registros é igual à informada
  --
  -- Fim
  -- Verifica se a quantidade de registros é igual à informada
  --
  --
  -- Insere conteúdo nas colunas
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    V_CCPF_CNPJ_BASE VARCHAR2(9);
    V_CTPO_PSSOA     VARCHAR2(1);
    V_IATUAL_CRRTR   VARCHAR2(80);
    V_POS              NUMBER(4) := 1;
    V_TAM              NUMBER(4) := 0;

  BEGIN
    BEGIN
      --
      --
      --CCRRTR  NUMBER(6) NOT NULL
      V_TAM            := 9;
      V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                 V_POS,
                                 V_TAM);
      V_POS            := V_POS + V_TAM;
      --
      --
      --CUND_PROD NUMBER(3) NOT NULL
      V_TAM        := 1;
      V_CTPO_PSSOA := SUBSTR(VAR_REGISTRO_ARQUIVO,
                             V_POS,
                             V_TAM);
      V_POS        := V_POS + V_TAM;
      --
      --
      --CCPF_CNPJ_CRRTR NUMBER(15)
      V_TAM          := 80;
      V_IATUAL_CRRTR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               V_POS,
                               V_TAM);
      -- :) insert
      update crrtr_unfca_cnpj
         set iatual_crrtr = v_iatual_crrtr
       where ctpo_pssoa = v_ctpo_pssoa
         and ccpf_cnpj_base = v_ccpf_cnpj_base;
      --
      if SQL%ROWCOUNT <= 0 then 
        INSERT INTO crrtr_unfca_cnpj -- cpvo.crrtr_unfca_cnpj@P003.BSEGUROS
          (ccpf_cnpj_base,
           ctpo_pssoa,
           iatual_crrtr)
        VALUES
          (v_ccpf_cnpj_base,
           v_ctpo_pssoa,
           v_iatual_crrtr);
      end if;

      --
      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        --pc_util_01.Sgpb0028('Erro: '||VAR_REGISTRO_ARQUIVO||' - '||SQLERRM, 'CARGA_CRRTR_UNFCA'); commit;
        utl_file.put(VAR_ARQUIVO_ERRO,
                     SQLERRM);
        utl_file.new_line(VAR_ARQUIVO_ERRO);
        utl_file.put(VAR_ARQUIVO_ERRO,
                     VAR_REGISTRO_ARQUIVO);
        utl_file.new_line(VAR_ARQUIVO_ERRO);
    END;
  END DETALHE;

BEGIN
  -- Iniciando Execução  
  --pc_util_01.Sgpb0028('Início. ', 'CARGA_CRRTR_UNIFICADO'); commit;
  BEGIN
    VAR_ARQUIVO      := UTL_FILE.FOPEN( '/x0205/P002/dwscheduler/scripts', -- '/x0205/P002/dwscheduler/scripts' ,   --'/x0305/D001/dwscheduler/entrada/processando',
                                       'PR_OUT_CRRTR_UNFCA_20070208.dat',
                                       'R');
    VAR_ARQUIVO_ERRO := UTL_FILE.FOPEN('/x0205/P002/dwscheduler/scripts',
                                       'PR_ERR_CRRTR_UNFCA_1_' || TO_CHAR(SYSDATE,'YYYYMMDD') || '.dat',
                                       'W');
  EXCEPTION
    WHEN OTHERS THEN
      --pc_util_01.Sgpb0028('Erro na Abertura do Arquivo', 'CARGA_CRRTR_UNIFICADO'); commit;
      RAISE ABRE_ARQUIVO_EXCEPTION;
  END;
  --
  --
  BEGIN
    -- Varrendo os registros dos arquivos
    VAR_COUNT := 0;
    LOOP
      --
      --
      UTL_FILE.GET_LINE(VAR_ARQUIVO,
                        VAR_REGISTRO_ARQUIVO);
      --
      --
      VAR_COUNT := VAR_COUNT + 1;
      DETALHE(VAR_REGISTRO_ARQUIVO);
      --
      --
      IF VAR_COUNT >= INTERVALO_COMMIT THEN
        VAR_COUNT := 0;
        COMMIT;
      END IF;
      --
      --
    END LOOP;
    --
    --
    COMMIT;
    --
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --
      --
      COMMIT;
  END;
  --
  --
  utl_file.fflush(VAR_ARQUIVO_ERRO);
  utl_file.fclose(VAR_ARQUIVO_ERRO);
  UTL_FILE.FCLOSE(VAR_ARQUIVO);
  --
  -- 
   --pc_util_01.Sgpb0028('Fim.', 'CARGA_CRRTR_UNIFICADO'); commit;
EXCEPTION
  --
  --
  WHEN ABRE_ARQUIVO_EXCEPTION THEN
    --pc_util_01.Sgpb0028('PROBLEMA NA ABERTURA ARQUIVO.', 'CARGA_CRRTR_UNIFICADO'); commit;
    Raise_Application_Error(-20003,'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
    --
  --
  WHEN OTHERS THEN
    RAISE;
    -- Execução terminada sem Erro
END PR_IN_CRRTR_UNFCA;
/

