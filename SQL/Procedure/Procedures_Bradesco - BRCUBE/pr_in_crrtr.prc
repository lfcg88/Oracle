CREATE OR REPLACE PROCEDURE SGPB_PROC.PR_IN_CRRTR
(
  -- DIRETORIO        VARCHAR2,
  INTERVALO_COMMIT INTEGER  DEFAULT 500
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : PR_IN_CRRTR
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
    V_CCRRTR           VARCHAR2(6);
    V_CCPF_CNPJ_CRRTR  VARCHAR2(15);
    V_CUND_PROD        VARCHAR2(3);
    V_ICRRTR           VARCHAR2(80);
    V_DCADTO_CRRTR     VARCHAR2(8);
    V_DINCL_REG        VARCHAR2(8);
    V_DALT_REG         VARCHAR2(8);
    V_CCPF_CNPJ_FLIAL  VARCHAR2(4);
    V_CTPO_PSSOA       VARCHAR2(1);
    V_CCPF_CNPJ_BASE   VARCHAR2(9);
    V_CCPF_CNPJ_DV     VARCHAR2(2);
    V_CBCO             VARCHAR2(4);
    V_CAG_BCRIA        VARCHAR2(4);
    V_CIND_CRRTR_SELEC VARCHAR2(1);
    V_POS              NUMBER(4) := 1;
    V_TAM              NUMBER(4) := 0;
  BEGIN
    BEGIN
      --
      --
      --CCRRTR  NUMBER(6) NOT NULL
      V_TAM    := 6;
      V_CCRRTR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                         V_POS,
                         V_TAM);
      V_POS    := V_POS + V_TAM;
      --
      --
      --CCPF_CNPJ_CRRTR NUMBER(15)
      V_TAM             := 15;
      V_CCPF_CNPJ_CRRTR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                  V_POS,
                                  V_TAM);
      V_POS             := V_POS + V_TAM;
      --
      --
      --CUND_PROD NUMBER(3) NOT NULL
      V_TAM       := 3;
      V_CUND_PROD := SUBSTR(VAR_REGISTRO_ARQUIVO,
                            V_POS,
                            V_TAM);
      V_POS       := V_POS + V_TAM;
      --
      --
      --ICRRTR  VARCHAR2(80)
      V_TAM    := 80;
      V_ICRRTR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                         V_POS,
                         V_TAM);
      V_POS    := V_POS + V_TAM;
      --
      --
      --DCADTO_CRRTR  DATE
      V_TAM          := 8;
      V_DCADTO_CRRTR := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               V_POS,
                               V_TAM);
      V_POS          := V_POS + V_TAM;
      --
      --
      --DINCL_REG DATE
      V_TAM       := 8;
      V_DINCL_REG := SUBSTR(VAR_REGISTRO_ARQUIVO,
                            V_POS,
                            V_TAM);
      V_POS       := V_POS + V_TAM;
      --
      --
      --DALT_REG  DATE
      V_TAM      := 8;
      V_DALT_REG := SUBSTR(VAR_REGISTRO_ARQUIVO,
                           V_POS,
                           V_TAM);
      V_POS      := V_POS + V_TAM;
      --
      --
      --CCPF_CNPJ_FLIAL NUMBER(4)
      V_TAM             := 4;
      V_CCPF_CNPJ_FLIAL := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                  V_POS,
                                  V_TAM);
      V_POS             := V_POS + V_TAM;
      --
      --
      --CTPO_PSSOA  VARCHAR2(1) NOT NULL
      V_TAM        := 1;
      V_CTPO_PSSOA := SUBSTR(VAR_REGISTRO_ARQUIVO,
                             V_POS,
                             V_TAM);
      V_POS        := V_POS + V_TAM;
      --
      --
      --CCPF_CNPJ_BASE  NUMBER(9) NOT NULL
      V_TAM            := 9;
      V_CCPF_CNPJ_BASE := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                 V_POS,
                                 V_TAM);
      V_POS            := V_POS + V_TAM;
      --
      --
      --CCPF_CNPJ_DV  NUMBER(2) NOT NULL
      V_TAM          := 2;
      V_CCPF_CNPJ_DV := SUBSTR(VAR_REGISTRO_ARQUIVO,
                               V_POS,
                               V_TAM);
      V_POS          := V_POS + V_TAM;
      --
      --
      --CBCO  NUMBER(4)
      V_TAM  := 4;
      V_CBCO := SUBSTR(VAR_REGISTRO_ARQUIVO,
                       V_POS,
                       V_TAM);
      V_POS  := V_POS + V_TAM;
      --
      --
      --CAG_BCRIA NUMBER(4)
      V_TAM       := 4;
      V_CAG_BCRIA := SUBSTR(VAR_REGISTRO_ARQUIVO,
                            V_POS,
                            V_TAM);
      V_POS       := V_POS + V_TAM;
      --
      --
      --CIND_CRRTR_SELEC  NUMBER(1) NOT NULL
      V_TAM              := 1;
      V_CIND_CRRTR_SELEC := SUBSTR(VAR_REGISTRO_ARQUIVO,
                                   V_POS,
                                   V_TAM);
      --
      --
      update crrtr
         set cund_prod = v_cund_prod,
             icrrtr = v_icrrtr,
             dcadto_crrtr = TO_DATE(CASE 
                                      WHEN v_dcadto_crrtr = '99991231' 
                                        THEN NULL
                                        ELSE v_dcadto_crrtr
                                      END, 
                                    'YYYYMMDD'),
             dincl_reg = TO_DATE(CASE WHEN v_dincl_reg = '99991231'
                                    THEN  NULL
                                    ELSE  v_dincl_reg
                                    END, 'YYYYMMDD'),
             dalt_reg = TO_DATE(CASE WHEN v_dalt_reg = '99991231'
                                    THEN  NULL
                                    ELSE  v_dalt_reg
                                    END, 'YYYYMMDD'),
             ccpf_cnpj_flial = v_ccpf_cnpj_flial,
             ctpo_pssoa = v_ctpo_pssoa,
             ccpf_cnpj_base = v_ccpf_cnpj_base,
             ccpf_cnpj_dv = v_ccpf_cnpj_dv,
             cbco = CASE WHEN v_cbco = '0000'
                THEN NULL
                ELSE v_cbco
                END,
             cag_bcria = CASE WHEN v_cag_bcria = '0000'
                THEN NULL
                ELSE v_cag_bcria
                END,
             cind_crrtr_selec = v_cind_crrtr_selec
             
       where ccrrtr = v_ccrrtr
         and cund_prod = v_cund_prod;

      if SQL%ROWCOUNT <= 0 then 
        INSERT INTO crrtr -- cpvo.crrtr@P003.BSEGUROS
          (ccrrtr,
           ccpf_cnpj_crrtr,
           cund_prod,
           icrrtr,
           dcadto_crrtr,
           dincl_reg,
           dalt_reg,
           ccpf_cnpj_flial,
           ctpo_pssoa,
           ccpf_cnpj_base,
           ccpf_cnpj_dv,
           cbco,
           cag_bcria,
           cind_crrtr_selec)
        VALUES
          (v_ccrrtr,
           v_ccpf_cnpj_crrtr,
           v_cund_prod,
           v_icrrtr,
           TO_DATE(CASE WHEN v_dcadto_crrtr = '99991231' THEN
                     NULL
                     ELSE
                     v_dcadto_crrtr
                     END, 'YYYYMMDD'),
           TO_DATE(CASE WHEN v_dincl_reg = '99991231'
                      THEN  NULL
                      ELSE  v_dincl_reg
                      END, 'YYYYMMDD'),
           TO_DATE(CASE WHEN v_dalt_reg = '99991231'
                      THEN  NULL
                      ELSE  v_dalt_reg
                      END, 'YYYYMMDD'),
           v_ccpf_cnpj_flial,
           v_ctpo_pssoa,
           v_ccpf_cnpj_base,
           v_ccpf_cnpj_dv,
           CASE WHEN v_cbco = '0000'
                THEN NULL
                ELSE v_cbco
                END,
           CASE WHEN v_cag_bcria = '0000'
                THEN NULL
                ELSE v_cag_bcria
                END,
           v_cind_crrtr_selec);
      end if;  

      --
      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        --pc_util_01.Sgpb0028('Erro: '||VAR_REGISTRO_ARQUIVO||' - '||SQLERRM, 'CARGA_CRRTR'); commit;
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
  --pc_util_01.Sgpb0028('Início.', 'CARGA_IN_CRRTR'); commit;
  BEGIN
    VAR_ARQUIVO      := UTL_FILE.FOPEN('/x0205/P002/dwscheduler/scripts', --dwscheduler/scripts', -- '/x0205/P002/dwscheduler/scripts', -- entrada/processando',
                                       'PR_OUT_CRRTR_20070208.dat', --'PR_OUT_CRRTR_20070118.dat',
                                       'R');
    VAR_ARQUIVO_ERRO := UTL_FILE.FOPEN('/x0205/P002/dwscheduler/scripts',
                                       'erro_1_' || TO_CHAR(SYSDATE,'YYYYMMDD') || '.dat',
                                       'W');
  EXCEPTION
    WHEN OTHERS THEN          
      --pc_util_01.Sgpb0028('Erro Na Abertura Do Arquivo', 'CARGA_IN_CRRTR'); commit;
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
    pc_util_01.Sgpb0028('PROBLEMA NA ABERTURA ARQUIVO', 'CARGA_CRRTR_UNIFICADO'); commit;
    Raise_Application_Error(-20003,
                            'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
    --
  --
  WHEN OTHERS THEN
    RAISE;
    -- Execução terminada sem Erro
END PR_IN_CRRTR;
/

