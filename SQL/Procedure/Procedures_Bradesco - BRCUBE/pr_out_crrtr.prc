CREATE OR REPLACE PROCEDURE SGPB_PROC.PR_OUT_CRRTR(DIRETORIO VARCHAR2)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : PR_OUT_CRRTR
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
  intColArquivo    NUMBER(3) := 180;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  --
  --
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    FOR c IN (SELECT
              /*CCRRTR*/
               SUBSTR(LPAD(c.CCHAVE_LGADO_CRRTR,
                           9,
                           0),
                      4) CCRRTR,
               /*CUND_PROD*/
               SUBSTR(LPAD(c.CCHAVE_LGADO_CRRTR,
                           9,
                           0),
                      1,
                      3) CUND_PROD,
               /*CCPF_CNPJ_CRRTR*/
               c.CCNPJ_CPF_PSSOA CCPF_CNPJ_CRRTR,
               /*ICRRTR*/
               c.IPSSOA ICRRTR,
               /*DCADTO_CRRTR*/
               c.DCADTO_CRRTR DCADTO_CRRTR,
               /*DINCL_REG*/
               c.DINCL_REG DINCL_REG,
               /*DALT_REG*/
               NVL(c.DALT_REG,
                   c.DINCL_REG) DALT_REG,
               /*CCPF_CNPJ_FLIAL*/
               c.CFLIAL_CNPJ_PSSOA CCPF_CNPJ_FLIAL,
               /*CTPO_PSSOA*/
               CASE
                 WHEN c.CTPO_PSSOA_DW = 3 THEN
                  'F'
                 ELSE
                  'J'
               END CTPO_PSSOA,
               /*CCPF_CNPJ_BASE*/
               CASE
                 WHEN c.CTPO_PSSOA_DW = 3 THEN
                  TRUNC(c.CCPF_PSSOA / 100)
                 ELSE
                  c.CBASE_CNPJ_PSSOA
               END CCPF_CNPJ_BASE,
               /*CCPF_CNPJ_DV*/
               CASE
                 WHEN c.CTPO_PSSOA_DW = 3 THEN
                  c.CCPF_PSSOA - TRUNC(c.CCPF_PSSOA / 100) * 100 /*EX.: 08806064797 - 08806064700 = 97 */
                 ELSE
                  c.CDV_CNPJ_PSSOA
               END CCPF_CNPJ_DV,
               /*CBCO*/
               CASE
                 WHEN ab.CAG_BCRIA = 0 THEN
                  NULL
                 ELSE
                  b.CBCO
               END CBCO,
               /*CAG_BCRIA*/
               CASE
                 WHEN ab.CAG_BCRIA = 0 THEN
                  NULL
                 ELSE
                  ab.CAG_BCRIA
               END CAG_BCRIA,
               /*CIND_CRRTR_SELEC*/
               0 CIND_CRRTR_SELEC
              --
                FROM CRRTR_DW C
              --
                JOIN AG_BCRIA_DW AB ON AB.CAG_BCRIA_DW = C.CAG_BCRIA_DW
              --
                JOIN BCO_DW B ON B.CBCO_DW = AB.CBCO_DW
              --
               WHERE c.CTPO_PSSOA_DW IN (3, 4)
                 AND CASE WHEN c.CTPO_PSSOA_DW = 3 THEN TRUNC(c.CCPF_PSSOA / 100) ELSE c.CBASE_CNPJ_PSSOA END IS NOT NULL --
              ) LOOP
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      --
      --CCRRTR  NUMBER(6)
      intColUtilizadas := intColUtilizadas + 6; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Ccrrtr,
                            0),
                        6,
                        '0'));
      --
      --
      --CCPF_CNPJ_CRRTR NUMBER(15)
      intColUtilizadas := intColUtilizadas + 15; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Ccpf_Cnpj_Crrtr,
                            0),
                        15,
                        '0'));
      --
      --
      --CUND_PROD NUMBER(3)
      intColUtilizadas := intColUtilizadas + 3; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Cund_Prod,
                            0),
                        3,
                        '0'));
      --
      --
      --ICRRTR  VARCHAR2(80)
      intColUtilizadas := intColUtilizadas + 80; --C
      utl_file.put(var_arquivo,
                   Rpad(NVL(c.Icrrtr,
                            ' '),
                        80,
                        ' '));
      --
      --
      --DCADTO_CRRTR  DATE
      intColUtilizadas := intColUtilizadas + 8; --DT
      utl_file.put(var_arquivo,
                   NVL(TO_CHAR(c.Dcadto_Crrtr,
                               'YYYYMMDD'),
                       '99991231'));
      --
      --
      --DINCL_REG DATE
      intColUtilizadas := intColUtilizadas + 8; --DT
      utl_file.put(var_arquivo,
                   NVL(TO_CHAR(c.Dincl_Reg,
                               'YYYYMMDD'),
                       '99991231'));
      --
      --
      --DALT_REG  DATE
      intColUtilizadas := intColUtilizadas + 8; --DT
      utl_file.put(var_arquivo,
                   NVL(TO_CHAR(c.Dalt_Reg,
                               'YYYYMMDD'),
                       '99991231'));
      --
      --
      --CCPF_CNPJ_FLIAL NUMBER(4)
      intColUtilizadas := intColUtilizadas + 4; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Ccpf_Cnpj_Flial,
                            0),
                        4,
                        '0'));
      --
      --
      --CTPO_PSSOA  VARCHAR2(1)
      intColUtilizadas := intColUtilizadas + 1; --C
      utl_file.put(var_arquivo,
                   NVL(c.Ctpo_Pssoa,
                       ' '));
      --
      --
      --CCPF_CNPJ_BASE  NUMBER(9)
      intColUtilizadas := intColUtilizadas + 9; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Ccpf_Cnpj_Base,
                            0),
                        9,
                        '0'));
      --
      --
      --CCPF_CNPJ_DV  NUMBER(2)
      intColUtilizadas := intColUtilizadas + 2; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Ccpf_Cnpj_Dv,
                            0),
                        2,
                        '0'));
      --
      --
      --CBCO  NUMBER(4)
      intColUtilizadas := intColUtilizadas + 4; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Cbco,
                            0),
                        4,
                        '0'));
      --
      --
      --CAG_BCRIA NUMBER(4)
      intColUtilizadas := intColUtilizadas + 4; --N
      utl_file.put(var_arquivo,
                   lpad(NVL(c.Cag_Bcria,
                            0),
                        4,
                        '0'));
      --
      --
      --CIND_CRRTR_SELEC  NUMBER(1)
      intColUtilizadas := intColUtilizadas + 1; --N
      utl_file.put(var_arquivo,
                   NVL(c.Cind_Crrtr_Selec,
                       0));
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
  BEGIN
    --
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(DIRETORIO,
                                   'PR_OUT_CRRTR_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.dat',
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
                              END;
  END PR_OUT_CRRTR;
/

