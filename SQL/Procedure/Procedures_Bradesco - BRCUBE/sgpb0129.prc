CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0129
(
  intrDtEmissao          APOLC_PROD_CRRTR.DEMIS_APOLC %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0129'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0129
  --      DATA            : 17/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO PARA EXPORTAÇÃO DO SITE CORRETOR DIÁRIO.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColArquivo    NUMBER(3) := 185;
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
                            P_GRUPO_RAMO PROD_CRRTR.CGRP_RAMO_PLANO %type,
                            P_PRODUCAO APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_FALTA_PRODUZIR APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_TOT_VR_PROD_ENDOSSO APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_TOT_QTD_ENDOSSO APOLC_PROD_CRRTR.CITEM_APOLC %type,
                            P_TOT_VR_PROD_EMISSAO APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_TOT_QTD_EMISSAO APOLC_PROD_CRRTR.CITEM_APOLC %type,
                            P_TOT_VR_PROD_CANC APOLC_PROD_CRRTR.VPRMIO_EMTDO_APOLC %type,
                            P_TOT_QTD_CANC APOLC_PROD_CRRTR.CITEM_APOLC %type)IS

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
      --GRUPO RAMO
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(P_GRUPO_RAMO,
                        3,
                        '0'));

      --
      --VALOR DA PRODUÇÃO
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_PRODUCAO),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_PRODUCAO - trunc(P_PRODUCAO)) * 100),
                        2,
                        0)); --parte decimal


      --
      --VALOR DO QUE FALTA PRODUZIR
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_FALTA_PRODUZIR),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_FALTA_PRODUZIR - trunc(P_FALTA_PRODUZIR)) * 100),
                        2,
                        0)); --parte decimal

      --
      --VALOR TOTAL DA PRODUÇÃO DO ENDOSSO
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_TOT_VR_PROD_ENDOSSO),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_TOT_VR_PROD_ENDOSSO - trunc(P_TOT_VR_PROD_ENDOSSO)) * 100),
                        2,
                        0)); --parte decimal

      --
      --QTD. TOTAL DA PRODUÇÃO DO ENDOSSO
      intColUtilizadas := intColUtilizadas + 10;
      utl_file.put(var_arquivo,
                   lpad(P_TOT_QTD_ENDOSSO,
                        10,
                        '0'));

      --
      --VALOR TOTAL DA PRODUÇÃO DA EMISSÃO
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_TOT_VR_PROD_EMISSAO),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_TOT_VR_PROD_EMISSAO - trunc(P_TOT_VR_PROD_EMISSAO)) * 100),
                        2,
                        0)); --parte decimal

      --
      --QTD. TOTAL DA PRODUÇÃO DA EMISSÃO
      intColUtilizadas := intColUtilizadas + 10;
      utl_file.put(var_arquivo,
                   lpad(P_TOT_QTD_EMISSAO,
                        10,
                        '0'));

      --
      --VALOR TOTAL DA PRODUÇÃO DE CANCELAMENTO
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(P_TOT_VR_PROD_CANC),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((P_TOT_VR_PROD_CANC - trunc(P_TOT_VR_PROD_CANC)) * 100),
                        2,
                        0)); --parte decimal

      --
      --QTD. TOTAL DA PRODUÇÃO DE CANCELAMENTO
      intColUtilizadas := intColUtilizadas + 10;
      utl_file.put(var_arquivo,
                   lpad(P_TOT_QTD_CANC,
                        10,
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
                 'SGPB0129');
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

    FOR C IN (SELECT CVS.CCANAL_VDA_SEGUR CANAL,
                    CVS.ICANAL_VDA_SEGUR NOME_CANAL,
                    C.CCPF_CNPJ_BASE CPF_CNPJ,
                    C.CTPO_PSSOA TIPO_PESSOA,
                    PC.CGRP_RAMO_PLANO GRUPO_RAMO,
                    ((TOT_VR_PROD_ENDOSSO + TOT_VR_PROD_EMISSAO)- TOT_VR_PROD_CANC) PRODUCAO,

--understand this part,
                    ((CASE WHEN CVS.CCANAL_VDA_SEGUR = 1 THEN
                           VL_OBJETIVO
                      ELSE OPC.VOBJTV_PROD_CRRTR_ALT
                      END) - ((TOT_VR_PROD_ENDOSSO + TOT_VR_PROD_EMISSAO)- TOT_VR_PROD_CANC)) FALTA_PRODUZIR,

                    TOT_VR_PROD_ENDOSSO,
                    TOT_QTD_ENDOSSO,
                    TOT_VR_PROD_EMISSAO,
                    TOT_QTD_EMISSAO,
                    TOT_VR_PROD_CANC,
                    TOT_QTD_CANC

                    FROM OBJTV_PROD_CRRTR OPC   

                    JOIN CANAL_VDA_SEGUR CVS
                      ON OPC.CCANAL_VDA_SEGUR = CVS.CCANAL_VDA_SEGUR

                    JOIN CRRTR C
                      ON OPC.CTPO_PSSOA     = C.CTPO_PSSOA
                     AND OPC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE

                    left JOIN PROD_CRRTR PC
                      ON C.CCRRTR    = PC.CCRRTR
                     AND C.CUND_PROD = PC.CUND_PROD

                    JOIN (SELECT APC.CCRRTR AS CORRETOR,
                            	   APC.CUND_PROD AS UNID_PROD,
                                 ARP.CGRP_RAMO_PLANO AS GRUPO_RAMO,
                            	   SUM (   
                                   CASE WHEN APC.CTPO_DOCTO = 'D'
                            		     THEN APC.VPRMIO_EMTDO_APOLC
                            			   ELSE 0
                            		   END
                            		 ) TOT_VR_PROD_ENDOSSO,
                            	   SUM (   
                                   CASE WHEN APC.CTPO_DOCTO = 'M'
                            		     THEN APC.VPRMIO_EMTDO_APOLC
                            			   ELSE 0
                            		   END
                            		 ) TOT_VR_PROD_EMISSAO,
                            	   SUM (   
                                   CASE WHEN APC.CTPO_DOCTO = 'C'
                            		     THEN APC.VPRMIO_EMTDO_APOLC
                            			   ELSE 0
                            		   END
                            		 ) TOT_VR_PROD_CANC,

                                  SUM ( 
                                    CASE WHEN APC.CTPO_DOCTO = 'D'
                                      THEN 1
                                      ELSE 0
                                    END
                                  ) TOT_QTD_ENDOSSO,
                                  SUM ( 
                                    CASE WHEN APC.CTPO_DOCTO = 'M'
                                      THEN 1
                                      ELSE 0
                                    END
                                  ) TOT_QTD_EMISSAO,
                                  SUM ( 
                                    CASE WHEN APC.CTPO_DOCTO = 'C'
                                      THEN 1
                                      ELSE 0
                                    END
                                  ) TOT_QTD_CANC

                             FROM APOLC_PROD_CRRTR APC

                             JOIN AGPTO_RAMO_PLANO ARP
                               ON ARP.CRAMO = APC.CRAMO_APOLC
 
                            WHERE APC.DEMIS_APOLC = intrDtEmissao
                            GROUP 
                               BY APC.CCRRTR, APC.CUND_PROD, ARP.CGRP_RAMO_PLANO
                          ) XX


                    ON C.CCRRTR = xx.CORRETOR
                   AND C.CUND_PROD = xx.UNID_PROD


                   JOIN (SELECT CEC.CCANAL_VDA_SEGUR AS CANAL,
                                CEC.CCPF_CNPJ_BASE AS CPF_CNPJ,
                                CEC.CTPO_PSSOA AS TIPO_PESSOA,
                                (NVL(PC.VPROD_CRRTR,0) * NVL(CCC.PCRSCT_PROD_ALT, PCVS.PCRSTC_PROD_ANO)) VL_OBJETIVO

                                FROM CRRTR_ELEIT_CAMPA CEC

                                JOIN  PARM_INFO_CAMPA PIC
                                  ON PIC.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR
                                AND PIC.DINIC_VGCIA_PARM = CEC.DINIC_VGCIA_PARM

                                LEFT JOIN CARAC_CRRTR_CANAL CCC
                                  ON CCC.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR
                                 AND CCC.DINIC_VGCIA_PARM = CEC.DINIC_VGCIA_PARM
                                 AND CCC.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
                                 AND CCC.CTPO_PSSOA = CEC.CTPO_PSSOA

                                JOIN CRRTR C
                                  ON C.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
                                AND C.CTPO_PSSOA = CEC.CTPO_PSSOA

                                LEFT JOIN PROD_CRRTR PC
                                  ON PC.CCRRTR = C.CCRRTR
                                 AND PC.CUND_PROD = C.CUND_PROD
                                 AND PC.CTPO_COMIS = 'CN'
                                 AND PC.CCOMPT_PROD = TO_NUMBER(TO_DATE(intrDtEmissao,'YYYYMM'))

                                JOIN PARM_CANAL_VDA_SEGUR PCVS
                                  ON PCVS.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR
                                 AND PCVS.DINIC_VGCIA_PARM = CEC.DINIC_VGCIA_PARM

                                WHERE intrDtEmissao BETWEEN PIC.DINIC_VGCIA_PARM 
                                AND NVL(PIC.DFIM_VGCIA_PARM,TO_DATE('31/12/9999','dd/MM/yyyy'))
                                AND PC.CGRP_RAMO_PLANO IN (PC_UTIL_01.Auto, PC_UTIL_01.ReTodos)
                                AND CEC.CCANAL_VDA_SEGUR = 1)


                   ON OPC.CCPF_CNPJ_BASE   = CPF_CNPJ
                  AND OPC.CTPO_PSSOA       = TIPO_PESSOA
                  AND OPC.CCANAL_VDA_SEGUR = CANAL


                  WHERE PC.CCOMPT_PROD = TO_NUMBER(TO_DATE(intrDtEmissao,'YYYYMM'))
                    AND OPC.CIND_REG_ATIVO = 'S'

                  ORDER BY CVS.CCANAL_VDA_SEGUR,
                    			 PC.CGRP_RAMO_PLANO


              ) LOOP

      --
      -- armazena em arquivo
      armazenarArquivo(C.CANAL, C.NOME_CANAL, C.CPF_CNPJ, C.TIPO_PESSOA, C.GRUPO_RAMO,
                       C.PRODUCAO, C.FALTA_PRODUZIR, C.TOT_VR_PROD_ENDOSSO, C.TOT_QTD_ENDOSSO,
                       C.TOT_VR_PROD_EMISSAO, C.TOT_QTD_EMISSAO,  C.TOT_VR_PROD_CANC, C.TOT_QTD_CANC);
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
                                   'SGPB0129_' || TO_CHAR(SYSDATE,
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
    PR_GRAVA_MSG_LOG_CARGA('SGPB0129',
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
END SGPB0129;
/

