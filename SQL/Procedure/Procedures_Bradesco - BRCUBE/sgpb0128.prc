CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0128
(
  intrDtEmissao          APOLC_PROD_CRRTR.DEMIS_APOLC %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0128'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0128
  --      DATA            : 17/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO PARA EXPORTAÇÃO DO SITE CORRETOR DIÁRIO DETALHADO.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColArquivo    NUMBER(3) := 145;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  --
  --
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  --


----------------------------------------------------------------------------------------geraDetail
----------------------------------------------------------------------------------------
PROCEDURE armazenarArquivo (P_CANAL CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
                            P_NOME_CANAL CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR %TYPE,
                            P_CPF_CPNJ CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE %type,
                            P_TIPO_PESSOA CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
                            P_TIPO_DOCT APOLC_PROD_CRRTR.CTPO_DOCTO %type,
                            P_RAMO PROD_CRRTR.CGRP_RAMO_PLANO %type,
                            P_CORRETOR APOLC_PROD_CRRTR.CCRRTR %type,
                            P_UND_PROD APOLC_PROD_CRRTR.CUND_PROD %type,
                            P_CIA APOLC_PROD_CRRTR.CCIA_SEGDR %type,
                            P_RAMO_APOLC APOLC_PROD_CRRTR.CRAMO_APOLC %type,
                            P_APOLICE APOLC_PROD_CRRTR.CAPOLC %type,
                            P_ITEM APOLC_PROD_CRRTR.CITEM_APOLC %type,
                            P_VALOR APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_DT_EMISSAO APOLC_PROD_CRRTR.DEMIS_APOLC %type,
                            P_LEGADO APOLC_PROD_CRRTR.CCHAVE_LGADO_APOLC %type,
                            P_ENDOSSO APOLC_PROD_CRRTR.CENDSS_APOLC %type,
                            P_DT_FIM_VGCIA APOLC_PROD_CRRTR.DFIM_VGCIA_APOLC %type)IS
BEGIN
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      --
      --tipo registro 1 detail
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   1);

      -- código do canal
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(P_CANAL,
                        1,
                        '0'));
      --
      --nome do canal
      intColUtilizadas := intColUtilizadas + 20;
      utl_file.put(var_arquivo,
                   rpad(P_NOME_CANAL,
                        20,
                        ' '));
      --
      --CPF/CNPJ
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(P_CPF_CPNJ,
                        14,
                        '0'));
      --
      --tipo pessoa
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(P_TIPO_PESSOA,
                        1,
                        '0'));

      --
      --OPERAÇÃO
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(P_TIPO_DOCT,
                        1,
                        '0'));
      --
      --RAMO
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(P_RAMO,
                        3,
                        '0'));

      --
      --CORRETOR
      intColUtilizadas := intColUtilizadas + 6;
      utl_file.put(var_arquivo,
                   lpad(P_CORRETOR,
                        6,
                        '0'));

      --
      --SUCURSAL
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(P_UND_PROD,
                        3,
                        '0'));

      --
      --CIA
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(P_CIA,
                        3,
                        '0'));

      --
      --RAMO DA APÓLICE
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(P_RAMO_APOLC,
                        3,
                        '0'));


      --
      --APÓLICE
      intColUtilizadas := intColUtilizadas + 7;
      utl_file.put(var_arquivo,
                   lpad(P_APOLICE,
                        7,
                        '0'));

      --
      --ITEM
      intColUtilizadas := intColUtilizadas + 4;
      utl_file.put(var_arquivo,
                   lpad(P_ITEM,
                        4,
                        '0'));

      --
      --VALOR DA APÓLICE
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_VALOR),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_VALOR - trunc(P_VALOR)) * 100),
                        2,
                        0)); --parte decimal


      --
      --DATA DA EMISSÃO
      intColUtilizadas := intColUtilizadas + 8;
      utl_file.put(var_arquivo,
                   lpad(P_DT_EMISSAO,
                        8,
                        '0'));


      --
      --CHAVE DO LEGADO
      intColUtilizadas := intColUtilizadas + 35;
      utl_file.put(var_arquivo,
                   lpad(P_LEGADO,
                        35,
                        ' '));

      --
      --CÓDIGO DO ENDOSSO
      intColUtilizadas := intColUtilizadas + 7;
      utl_file.put(var_arquivo,
                   lpad(P_ENDOSSO,
                        7,
                        '0'));

      --
      --DATA FIM DA VIGÊNCIA
      intColUtilizadas := intColUtilizadas + 8;
      utl_file.put(var_arquivo,
                   lpad(P_DT_FIM_VGCIA,
                        8,
                        '0'));

      --
      --trailler
      utl_file.put(var_arquivo,
                   lpad(' ',
                        intColArquivo - intColUtilizadas));

END;

  ----------------------------------------------------------------------------------------geraHeader
  ----------------------------------------------------------------------------------------
  PROCEDURE geraHeader IS
  BEGIN
    --zera contador
    intColUtilizadas := 0;
    --tipo registro 0 header
    intColUtilizadas := intColUtilizadas + 1;
    utl_file.put(var_arquivo,
                 0);
    --datahora inicio da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,
                 to_char(current_timestamp,
                         'YYYYMMDDHH24MISS'));
    --competencia da exportacao
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 intrDtEmissao || '01');
    --nome do programa que exportou
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 'SGPB0128');
    --trailler
    utl_file.put(var_arquivo,
                 lpad(' ',
                      intColArquivo - intColUtilizadas));
    --nova linha
    utl_file.new_line(var_arquivo);
  END;

  ----------------------------------------------------------------------------------------geraFooter
  ----------------------------------------------------------------------------------------
  PROCEDURE geraFooter IS
  BEGIN
    --zera contador
    intColUtilizadas := 0;
    --tipo registro 0 footer
    intColUtilizadas := intColUtilizadas + 1;
    utl_file.put(var_arquivo,
                 9);
    --datahora fim da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,
                 to_char(current_timestamp,
                         'YYYYMMDDHH24MISS'));
    --Quantidade de registros exportados
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 lpad(intQtdLinExp + 2,
                      8,
                      '0'));
    --trailler
    utl_file.put(var_arquivo,
                 lpad(' ',
                      intColArquivo - intColUtilizadas));
    --
    -- NÃO GERA NOVA LINHA
  END;

  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN

    FOR C IN (SELECT CVS.CCANAL_VDA_SEGUR AS CANAL,
                     CVS.ICANAL_VDA_SEGUR AS NOME_CANAL,
                     CEC.CCPF_CNPJ_BASE   AS CPF_CPNJ,
                     CEC.CTPO_PSSOA       AS TIPO_PESSOA,
                     APC.CTPO_DOCTO       AS TIPO_DOCT,
                     ARP.CGRP_RAMO_PLANO  AS RAMO,
                     APC.CCRRTR           AS CORRETOR,
                     APC.CUND_PROD        AS UND_PROD,
                     APC.CCIA_SEGDR       AS CIA,
                     APC.CRAMO_APOLC      AS RAMO_APOLC,
                     APC.CAPOLC           AS APOLICE,
                     APC.CITEM_APOLC      AS ITEM,
                     APC.VPRMIO_EMTDO_APOLC AS VALOR,
                     APC.DEMIS_APOLC        AS DT_EMISSAO,
                     APC.CCHAVE_LGADO_APOLC AS LEGADO,
                     APC.CENDSS_APOLC       AS ENDOSSO,
                     APC.DFIM_VGCIA_APOLC   AS DT_FIM_VGCIA


                FROM PARM_INFO_CAMPA PIC

                JOIN CRRTR_ELEIT_CAMPA CEC
                  ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                 AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM

                JOIN CRRTR C
                  ON C.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
                 AND C.CTPO_PSSOA     = CEC.CTPO_PSSOA

                JOIN APOLC_PROD_CRRTR APC
              	  ON C.CCRRTR    = APC.CCRRTR
              	 AND C.CUND_PROD = APC.CUND_PROD
                 AND APC.DEMIS_APOLC = intrDtEmissao

                JOIN AGPTO_RAMO_PLANO ARP
                  ON APC.CRAMO_APOLC = ARP.CRAMO

                JOIN CANAL_VDA_SEGUR CVS
                  ON CVS.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR

              	WHERE intrDtEmissao between PIC.DINIC_VGCIA_PARM and nvl(PIC.DFIM_VGCIA_PARM,to_date('31/12/9999','dd/MM/yyyy'))

               ORDER BY CANAL, RAMO, TIPO_DOCT

              ) LOOP

      --
      -- armazena em arquivo
      armazenarArquivo(C.CANAL, C.NOME_CANAL, C.CPF_CPNJ, C.TIPO_PESSOA, C.TIPO_DOCT,
                       C.RAMO, C.CORRETOR, C.UND_PROD, C.CIA, C.RAMO_APOLC, C.APOLICE, C.ITEM,
                       C.VALOR, C.DT_EMISSAO, C.LEGADO, C.ENDOSSO, C.DT_FIM_VGCIA);
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
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.Var_Rotna_Po);
    --
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(pc_util_01.diretorio_padrao,
                                   'SGPB0128_' || TO_CHAR(SYSDATE,
                                                          'YYYYMMDD') || '.dat',
                                   'W');
    --
    chrLocalErro := '02';
    geraHeader();
    --
    --
    chrLocalErro := '03';
    geraDetail();
    --
    --
    chrLocalErro := '04';
    geraFooter();
    --
    --
    chrLocalErro := '05';
    utl_file.fflush(VAR_ARQUIVO);
    --
    chrLocalErro := '06';
    utl_file.fclose(VAR_ARQUIVO);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.Var_Rotna_Pc);
    --
    --
    chrLocalErro := '07';
    COMMIT;
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
  END;
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrDtEmissao) ||
                           ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    --    dbms_output.put_line(var_log_erro);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0128',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0128;
/

