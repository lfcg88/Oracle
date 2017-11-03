CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0043(

  INTRCOMPETENCIA IN PROD_CRRTR.CCOMPT_PROD%TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0043') IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0043
  --      DATA            : 20/3/2006 15:19:00
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure de importação, do DW, da produção no Ramo Automóveis.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO VARCHAR2(2000);
  VAR_CROTNA CONSTANT CHAR(8) := 'SGPB0043';
  VAR_IROTNA CONSTANT INT := 0728;

  COMISSAOESPECIAL CONSTANT CHAR(2) := 'CE';
  COMISSAONORMAL   CONSTANT CHAR(2) := 'CN';

  FUNCTION FIRST_DAY(INTRCOMPETENCIA NUMBER) RETURN DATE AS
  BEGIN
    RETURN TO_DATE(INTRCOMPETENCIA, 'YYYYMM');
  END;

  FUNCTION LAST_DAY_MONTH(INTRCOMPETENCIA NUMBER) RETURN DATE AS
  BEGIN
    RETURN LAST_DAY(TO_DATE(INTRCOMPETENCIA, 'YYYYMM'));
  END;
  --
  -- Query para obter o valor da produção (EMITIDOS - CANCELADOS) e a quantidade de itens EMITIDOS
  --
  PROCEDURE PRODUCAO_VALOR_ITENS(INTRCOMPETENCIA IN PROD_CRRTR.CCOMPT_PROD%TYPE) IS

  BEGIN
    BEGIN

      EXECUTE IMMEDIATE 'INSERT INTO TPROD_CRRTR
        (CUND_PROD,
        CCRRTR,
        CTPO_COMIS,
        VPROD_CRRTR,
        QTOT_ITEM_PROD,
        CGRP_RAMO_PLANO,
        CCOMPT_PROD)
      SELECT SUBSTR(T3.CCHAVE_LGADO_CRRTR, 1, 3) CSUC,
             T3.CCRRTR CCRRTR,
             CASE
               WHEN T1.PCOMIS_CRRTG_AUTO > T4.VCOMIS_CRRTR THEN
                ' || COMISSAOESPECIAL || '
               ELSE
                ' || COMISSAONORMAL || '
             END AS CTPO_COMIS,
             SUM(T1.VPRMIO_LIQ_AUTO + T1.VPRMIO_LIQ_APP + T1.VPRMIO_LIQ_RCF) VPRMIO_LIQ,
             SUM(CASE
                   WHEN T2.CTPO_ENDSS_DW = 3 THEN
                    1
                   ELSE
                    0
                 END) AS QTDE_EMISS, ' ||
                        PC_UTIL_01.AUTO || ',' || INTRCOMPETENCIA || '

        FROM FT_PRMIO_EMTDO_AT T1,
             ENDSS_ITEM_APOLC  T2,
             CRRTR             T3,
             COMIS_CRRTR       T4

       WHERE T1.DEMIS_ENDSS_DW BETWEEN FIRST_DAY(' ||
                        INTRCOMPETENCIA || ') AND
             LAST_DAY_MONTH(' || INTRCOMPETENCIA || ')
         AND T2.CENDSS_ITEM_DW = T1.CENDSS_ITEM_DW
         AND T3.CCRRTR_DW = T2.CCRRTR_DW
         AND T4.CCRRTR_DW = T3.CCRRTR_DW
         AND T2.DINIC_VGCIA_ENDSS BETWEEN T4.DINIC_VGCIA AND
             NVL(T4.DFIM_VGCIA, T2.DINIC_VGCIA_ENDSS)

       GROUP BY SUBSTR(T3.CCHAVE_LGADO_CRRTR, 1, 3),
                T3.CCRRTR,
                CASE
                  WHEN T1.PCOMIS_CRRTG_AUTO > T4.VCOMIS_CRRTR THEN
                   ' || COMISSAOESPECIAL || '
                  ELSE
                   ' || COMISSAONORMAL || '
                END ';

    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'PROBLEMA AO OBTER O VALOR DA PRODUÇÃO E A QUANTIDADE DE ITENS EMITIDOS.' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);

        RAISE;
    END;
  END PRODUCAO_VALOR_ITENS;
  -- Fim
  -- Query para obter o valor da produção (EMITIDOS - CANCELADOS) e a quantidade de itens EMITIDOS
  --

  --
  -- Query para obter quantidade de itens CANCELADOS
  --
  PROCEDURE CANCELAMENTO_ITENS(INTRCOMPETENCIA IN PROD_CRRTR.CCOMPT_PROD%TYPE) IS
    TEMP_CURSOR      SYS_REFCURSOR;
    V_CCRRTR         PROD_CRRTR.CCRRTR%TYPE;
    V_CUND_PROD      PROD_CRRTR.CUND_PROD%TYPE;
    V_CTPO_COMIS     PROD_CRRTR.CTPO_COMIS%TYPE;
    V_QTOT_ITEM_PROD PROD_CRRTR.QTOT_ITEM_PROD%TYPE;
  BEGIN
    BEGIN

      OPEN TEMP_CURSOR FOR 'SELECT SUBSTR(T2.CCHAVE_LGADO_CRRTR, 1, 3) CSUC,
             T2.CCRRTR CCRRTR,
             CASE
               WHEN T1.PCOMIS_CRRTG_AUTO > T3.VCOMIS_CRRTR THEN
                ' || COMISSAOESPECIAL || '
               ELSE
                ' || COMISSAONORMAL || '
             END AS CTPO_COMIS,
             COUNT(*) AS QTOT_ITEM_PROD

        FROM (SELECT DISTINCT I.CITEM_APOLC_DW    CITEM_APOLC_DW,
                              E.CCRRTR_DW         CCRRTR_DW,
                              F.PCOMIS_CRRTG_AUTO PCOMIS_CRRTG_AUTO,
                              I.DINIC_VGCIA_ITEM  DINIC_VGCIA_ITEM
                FROM ENDSS_ITEM_APOLC E, ITEM_APOLC I, FT_PRMIO_EMTDO_AT F
               WHERE E.CITEM_APOLC_DW = I.CITEM_APOLC_DW
                 AND E.CTPO_ENDSS_DW = 6
                 AND E.DEMIS_ENDSS BETWEEN FIRST_DAY(' || INTRCOMPETENCIA || ') AND
                     LAST_DAY_MONTH(' || INTRCOMPETENCIA || ')
                 AND F.CENDSS_ITEM_DW = E.CENDSS_ITEM_DW
                 AND I.DINIC_VGCIA_ITEM = I.DFIM_VGCIA_ITEM
                 AND (I.DEMIS_ITEM_APOLC + 30) >= E.DEMIS_ENDSS) T1,
             CRRTR T2,
             COMIS_CRRTR T3

       WHERE T2.CCRRTR_DW = T1.CCRRTR_DW
         AND T3.CCRRTR_DW = T2.CCRRTR_DW
         AND T1.DINIC_VGCIA_ITEM BETWEEN T3.DINIC_VGCIA AND
             NVL(T3.DFIM_VGCIA, T1.DINIC_VGCIA_ITEM)

       GROUP BY SUBSTR(T2.CCHAVE_LGADO_CRRTR, 1, 3),
                T2.CCRRTR,
                CASE
                  WHEN T1.PCOMIS_CRRTG_AUTO > T3.VCOMIS_CRRTR THEN
                   ' || COMISSAOESPECIAL || '
                  ELSE
                   ' || COMISSAONORMAL || '
                END';
      LOOP

        FETCH TEMP_CURSOR
          INTO V_CUND_PROD, V_CCRRTR, V_CTPO_COMIS, V_QTOT_ITEM_PROD;

        EXIT WHEN TEMP_CURSOR%NOTFOUND;

        BEGIN
          EXECUTE IMMEDIATE 'UPDATE TPROD_CRRTR
             SET QTOT_ITEM_PROD - ' ||
                            V_QTOT_ITEM_PROD || '
              WHERE
             CCRRTR           = ' || V_CCRRTR ||
                            '      AND
              CUND_PROD        =' || V_CUND_PROD ||
                            '  AND
              CTPO_COMIS       =' ||
                            V_CTPO_COMIS;

        EXCEPTION
          WHEN OTHERS THEN
            VAR_LOG_ERRO := 'DADOS: -- QTOT_ITEM_PROD: ' ||
                            V_QTOT_ITEM_PROD || ' -- QTOT_ITEM_PROD: ' ||
                            V_QTOT_ITEM_PROD || ' -- CUND_PROD: ' ||
                            V_CUND_PROD || ' -- CTPO_COMIS: ' ||
                            V_CTPO_COMIS || ' -- ERRO ORACLE: ' ||
                            SUBSTR(SQLERRM, 1, 120);

            PC_UTIL_01.SGPB0028(VAR_LOG_ERRO, VAR_CROTNA);
        END;

      END LOOP;
      CLOSE TEMP_CURSOR;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'PROBLEMA AO OBTER A QUANTIDADE DE ITENS CANCELADOS.' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);

        RAISE;
    END;

  END CANCELAMENTO_ITENS;
  -- Fim
  -- Query para obter quantidade de itens CANCELADOS
  --
  PROCEDURE INSERIR_EFETIVO(INTRCOMPETENCIA IN PROD_CRRTR.CCOMPT_PROD%TYPE) IS
    TEMP_CURSOR      SYS_REFCURSOR;
    V_CCRRTR         PROD_CRRTR.CCRRTR%TYPE;
    V_CUND_PROD      PROD_CRRTR.CUND_PROD%TYPE;
    V_CTPO_COMIS     PROD_CRRTR.CTPO_COMIS%TYPE;
    V_QTOT_ITEM_PROD PROD_CRRTR.QTOT_ITEM_PROD%TYPE;
    V_VPROD_CRRTR    PROD_CRRTR.VPROD_CRRTR%TYPE;
  BEGIN
    OPEN TEMP_CURSOR FOR '
      SELECT QTOT_ITEM_PROD,
             CTPO_COMIS,
             CCRRTR,
             CGRP_RAMO_PLANO,
             CCOMPT_PROD,
             CUND_PROD,
             VPROD_CRRTR
        FROM TPROD_CRRTR';
    LOOP
      FETCH TEMP_CURSOR
        INTO V_QTOT_ITEM_PROD, V_CTPO_COMIS, V_CCRRTR, V_CUND_PROD, V_VPROD_CRRTR;

      BEGIN
        INSERT INTO PROD_CRRTR
          (QTOT_ITEM_PROD,
           CTPO_COMIS,
           CCRRTR,
           CGRP_RAMO_PLANO,
           CCOMPT_PROD,
           CUND_PROD,
           VPROD_CRRTR)
        VALUES
          (V_QTOT_ITEM_PROD,
           V_CTPO_COMIS,
           V_CCRRTR,
           PC_UTIL_01.AUTO,
           INTRCOMPETENCIA,
           V_CUND_PROD,
           V_VPROD_CRRTR);
      EXCEPTION
        WHEN OTHERS THEN
          VAR_LOG_ERRO := 'DADOS: -- CCRRTR: ' || V_CCRRTR ||
                          ' -- QTOT_ITEM_PROD: ' || V_QTOT_ITEM_PROD ||
                          ' -- CUND_PROD: ' || V_CUND_PROD ||
                          ' -- CTPO_COMIS: ' || V_CTPO_COMIS ||
                          ' -- VPROD_CRRTR: ' || V_VPROD_CRRTR ||
                          ' -- CCOMPT_PROD: ' || INTRCOMPETENCIA ||
                          ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

          PC_UTIL_01.SGPB0028(VAR_LOG_ERRO, VAR_CROTNA);
      END;
    END LOOP;

    CLOSE TEMP_CURSOR;

  END INSERIR_EFETIVO;
BEGIN
  BEGIN

    -- Iniciando Execução
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              VAR_IROTNA,
                              PC_UTIL_01.VAR_ROTNA_PC);

    -- Cria tabela temporária
    BEGIN
      EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TPROD_CRRTR
                          (QTOT_ITEM_PROD  NUMBER(7),
                           CTPO_COMIS      VARCHAR2(2),
                           CCRRTR          NUMBER(6),
                           CGRP_RAMO_PLANO NUMBER(3),
                           CCOMPT_PROD     NUMBER(6),
                           CUND_PROD       NUMBER(3),
                           VPROD_CRRTR     NUMBER(17,2))
                        ON COMMIT PRESERVE ROWS';

    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -955
        THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE TPROD_CRRTR';
          EXECUTE IMMEDIATE 'DROP     TABLE TPROD_CRRTR';
          EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TPROD_CRRTR
                              (QTOT_ITEM_PROD  NUMBER(7),
                               CTPO_COMIS      VARCHAR2(2),
                               CCRRTR          NUMBER(6),
                               CGRP_RAMO_PLANO NUMBER(3),
                               CCOMPT_PROD     NUMBER(6),
                               CUND_PROD       NUMBER(3),
                               VPROD_CRRTR     NUMBER(17,2))
                            ON COMMIT PRESERVE ROWS';
        ELSE
          VAR_LOG_ERRO := 'ERRO AO TENTAR CRIAR TABELA TEMPORÁRIA' ||
                          ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

          PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                                 VAR_LOG_ERRO,
                                 PC_UTIL_01.VAR_LOG_PROCESSO,
                                 NULL,
                                 NULL);

          RAISE;
        END IF;
    END;

    -- Inserindo registros na temporária
    BEGIN
      PRODUCAO_VALOR_ITENS(INTRCOMPETENCIA);

    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'ERRO AO TENTAR INSERIR OS DADOS DA VIEW NA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);

        RAISE;
    END;

    -- retirar registros cancelados da temporária
    BEGIN
      CANCELAMENTO_ITENS(INTRCOMPETENCIA);

    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'ERRO AO TENTAR RETIRAR REGISTROS CANCELADOS NA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);

        RAISE;
    END;

    -- Repasar informações da temporaria para a tabela efetiva
    BEGIN
      INSERIR_EFETIVO(INTRCOMPETENCIA);

    EXCEPTION
      WHEN OTHERS THEN
        VAR_LOG_ERRO := 'ERRO AO TENTAR RETIRAR REGISTROS CANCELADOS NA TEMPORÁRIA' ||
                        ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                               VAR_LOG_ERRO,
                               PC_UTIL_01.VAR_LOG_PROCESSO,
                               NULL,
                               NULL);

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
    COMMIT;
  EXCEPTION

    WHEN OTHERS THEN
      VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE PRODUÇÃO NO RAMO AUTO.' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);

      -- Processo executado com Erro
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                VAR_IROTNA,
                                PC_UTIL_01.VAR_ROTNA_PE);

      ROLLBACK;
  END;

  BEGIN
    -- Deleta tebela temporária
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TPROD_CRRTR';
    EXECUTE IMMEDIATE 'DROP TABLE TPROD_CRRTR';

  EXCEPTION
    WHEN OTHERS THEN
      VAR_LOG_ERRO := 'ERRO AO TENTAR TRUNCAR E DROPAR TABELAS TEMPORARIAS' ||
                      ' -- ERRO ORACLE: ' || SUBSTR(SQLERRM, 1, 120);

      PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,
                             VAR_LOG_ERRO,
                             PC_UTIL_01.VAR_LOG_PROCESSO,
                             NULL,
                             NULL);

      RAISE;
  END;

END SGPB0043;
/

