CREATE OR REPLACE PROCEDURE SGPB_PROC.PR_OUT_CRRTR_UNFCA(DIRETORIO VARCHAR2)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : PR_OUT_CRRTR_UNFCA
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO PARA O SISTEMA SCRR
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColArquivo    NUMBER(3) := 95;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  --
  --
  chrLocalErro VARCHAR2(2) := '00';
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    FOR c IN (SELECT CASE
                       WHEN CTPO_PSSOA_DW = 3 THEN
                        TRUNC(CCPF_PSSOA / 100)
                       ELSE
                        CBASE_CNPJ_PSSOA
                     END CCPF_CNPJ_BASE,
                     CASE
                       WHEN CTPO_PSSOA_DW = 3 THEN
                        'F'
                       ELSE
                        'J'
                     END CTPO_PSSOA,
                     MAX(IPSSOA) ICRRTR
                FROM CRRTR_DW
               WHERE CTPO_PSSOA_DW IN (3, 4)
                 AND CASE WHEN CTPO_PSSOA_DW = 3 THEN TRUNC(CCPF_PSSOA / 100) ELSE CBASE_CNPJ_PSSOA END IS NOT NULL
               GROUP BY CASE
                          WHEN CTPO_PSSOA_DW = 3 THEN
                           TRUNC(CCPF_PSSOA / 100)
                          ELSE
                           CBASE_CNPJ_PSSOA
                        END,
                        CASE
                          WHEN CTPO_PSSOA_DW = 3 THEN
                           'F'
                          ELSE
                           'J'
                        END --
              ) LOOP
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      --
      --sucursal
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo,
                   lpad(NVL(c.CCPF_CNPJ_BASE,
                            0),
                        9,
                        '0'));
      --
      --codigo CPD
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   c.CTPO_PSSOA);
      --
      --CIA
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo,
                   rpad(NVL(c.ICRRTR,
                            ' '),
                        80,
                        ' '));
      --
      --trailler
      utl_file.put(var_arquivo,
                   lpad(' ',
                        intColArquivo - intColUtilizadas));
      --
      --nova linha
      utl_file.new_line(var_arquivo);
      --
    --
    END LOOP;
  END;

BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  --
  --
  chrLocalErro := '01';
  VAR_ARQUIVO  := UTL_FILE.FOPEN(DIRETORIO,
                                 'PR_OUT_CRRTR_UNFCA_'||TO_CHAR(SYSDATE,'YYYYMMDD') || '.dat',
                                 'W');
  --
  chrLocalErro := '03';
  geraDetail();
  --
  --
  chrLocalErro := '06';
  utl_file.fflush(VAR_ARQUIVO);
  --
  chrLocalErro := '07';
  utl_file.fclose(VAR_ARQUIVO);
  --
  --
  chrLocalErro := '08';
  --
  --
EXCEPTION
  --
  WHEN Utl_File.Invalid_Path THEN
    Raise_Application_Error(-20210,
                            'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
    -- the open_mode string was invalid
  WHEN Utl_File.Invalid_Mode THEN
    Raise_Application_Error(-20211,
                            'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID MODE');
    -- file could not be opened as requested
  WHEN Utl_File.Invalid_Operation THEN
    Raise_Application_Error(-20212,
                            'Invalid_Operation ' || SQLERRM);
    -- specified max_linesize is too large or too small
  WHEN Utl_File.Invalid_Maxlinesize THEN
    Raise_Application_Error(-20213,
                            'Invalid_Maxlinesize ' || SQLERRM);
END PR_OUT_CRRTR_UNFCA;
/

