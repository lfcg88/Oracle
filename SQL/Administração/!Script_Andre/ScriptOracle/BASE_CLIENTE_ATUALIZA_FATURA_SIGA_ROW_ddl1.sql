-- Start of DDL Script for Trigger BASE_CLIENTE.ATUALIZA_FATURA_SIGA_ROW
-- Generated 30/11/2010 19:00:02 from BASE_CLIENTE@test2

CREATE OR REPLACE TRIGGER atualiza_fatura_siga_row
 BEFORE
   UPDATE OF nr_ano_fatura, dt_ocor_man_fatura, dt_emis_fatura, dt_ocor_fatura, vl_pago_fatura, nr_fatura, cd_conv_siga_fatura, cd_doccobr, cd_cgc_cpf_conv_fatura, cd_servico, cd_sitcobr, cd_ocor_banc_fatura, cd_local_siga_fatura
 ON fatura
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
    WRK_EXISTE      NUMBER(1);
    W_RODOU         NUMBER(1);

    CURSOR C_FORMPG  IS
      select NR_LOCKBOX_NUMBER_ERP
      from formpag
      where nvl(TP_FORMPAG, 'X') = 'W'
        and CD_FORMPAG           = NVL(:NEW.CD_FORMPAG, :OLD.CD_FORMPAG)
        and NM_BAND_FORMPAG is not null;
    W_NR_LOCKBOX  FORMA_PAGAMENTO.NR_LOCKBOX_NUMBER_ERP%TYPE  :=  NULL;

    cursor C_PAGTOMAN is
      select nr_lockbox_number_pagto_manual
       from locais_faturamento
       where org_id_erp = :old.nr_org_id_erp;
    W_PAGTOMAN locais_faturamento.nr_lockbox_number_pagto_manual%TYPE;
Begin
  IF UPDATING THEN
      IF :NEW.CD_SITCOBR = 1 AND NVL(:NEW.VL_PAGO_FATURA,0) <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW-DOCUMENTO NÃO PODE TER VALOR DE PAGTO MENOR OU IGUAL A 0(zero)');
      END IF;
      IF :NEW.CD_SITCOBR = 1 AND (:NEW.CD_OCOR_BANC_FATURA IS NULL OR :NEW.VL_PAGO_FATURA IS NULL OR :NEW.DT_PAGO_CLI_FATURA IS NULL) THEN
         RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW:QUITACAO-DADOS NÃO PREENCHIDOS-'||:OLD.CD_SERVICO||':'||:OLD.NR_FATURA||':'||:OLD.NR_ANO_FATURA||':'||:OLD.CD_DOCCOBR);
      ELSIF :NEW.CD_SITCOBR = 1 AND :NEW.CD_OCOR_BANC_FATURA = 999 AND :NEW.DT_OCOR_MAN_FATURA IS NULL THEN
         RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW:QUITACAO-DADOS NÃO PREENCHIDOS-'||:OLD.CD_SERVICO||':'||:OLD.NR_FATURA||':'||:OLD.NR_ANO_FATURA||':'||:OLD.CD_DOCCOBR);
      ELSIF :NEW.CD_SITCOBR = 1 AND :NEW.CD_OCOR_BANC_FATURA = 6 AND :NEW.DT_OCOR_FATURA IS NULL THEN
         RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW:QUITACAO-DADOS NÃO PREENCHIDOS-'||:OLD.CD_SERVICO||':'||:OLD.NR_FATURA||':'||:OLD.NR_ANO_FATURA||':'||:OLD.CD_DOCCOBR);
      ELSIF :NEW.CD_SITCOBR IN (2,3,4,5) AND (:NEW.DT_OCOR_MAN_FATURA IS NULL OR :NEW.CD_OCOR_BANC_FATURA IS NULL) THEN
         RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW:CANCELAMENTO-DADOS NÃO PREENCHIDOS-'||:OLD.CD_SERVICO||':'||:OLD.NR_FATURA||':'||:OLD.NR_ANO_FATURA||':'||:OLD.CD_DOCCOBR);
      END IF;

     -- CRITICA CANCELAMENTO
     IF :OLD.CD_SITCOBR  = 0 AND :NEW.CD_SITCOBR IN(2,3,4,5) THEN -- CANCELAMENTO
       IF :NEW.DT_OCOR_MAN_FATURA IS NOT NULL THEN
          -- alterado para tratar faturamento do Lyceum
          IF TRUNC(:NEW.DT_OCOR_MAN_FATURA) < TRUNC(SYSDATE) AND :NEW.CD_DOCCOBR NOT IN (10,11,12,13,14) THEN
            RAISE_APPLICATION_ERROR(-20004,'TRIGGER ATUALIZA_FATURA_SIGA_ROW - DATA DE CANCELAMENTO NÃO PODE SER INFERIOR A DATA CORRENTE. '||SQLERRM);
          END IF;
          --
       END IF;

       -- novo (tratamento cobranca)
       IF  :OLD.cd_servico = 'FA' /*AND :OLD.CD_DOCCOBR IN('01','02','04')*/ THEN
           IF NVL(:OLD.DS_STATUS_COBRANCA,'CPU') = 'CPU' THEN
              NULL;
           ELSE
             if user not in('BASE_COBRANCA','LOGIN_COBRANCA','LOGIN_INTERF_LYCEUM','LOGIN_CLIENTE') THEN
              RAISE_APPLICATION_ERROR(-20004,'TRIGGER ATUALIZA_FATURA_SIGA_ROW - DOCUMENTO EM COBRANCA NÃO PODE SER CANCELADO.');
             END IF;
           END IF;
       END IF;

     END IF;
     --
     IF :OLD.CD_SITCOBR <> :NEW.CD_SITCOBR AND :OLD.CD_SITCOBR IN (1,2,3,4,5) THEN
        IF :OLD.CD_SERVICO = 'EL' AND :OLD.CD_SITCOBR = 1 AND :NEW.CD_SITCOBR IN(2,3,4,5) THEN
           BEGIN
             SELECT 1
               INTO W_RODOU
               FROM CONPROCERP
              WHERE TRUNC(DT_CONPROC) = TRUNC(:OLD.DT_EMIS_FATURA);
               RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW - TROCA DE SITUAÇÃO NÃO PERMITIDA. '||SQLERRM);
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 NULL;
           END;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 3 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL DIVULGADO P/ DOC/CONTROLADORIA/DITI/FGVONLINE
              :old.cd_servico = 'FA' and :old.nr_fatura in (137076,137077) and :old.nr_ano_fatura = 2005 and :old.cd_doccobr = '01' and trunc(sysdate) = '27-oct-05' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 56259 and :old.nr_ano_fatura = 2005 and :old.cd_doccobr = '01' and trunc(sysdate) = '23-dec-05' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 22145 and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '21-mar-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 22152 and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '21-mar-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 22366 and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '21-mar-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 66498  and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '24-apr-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 12842  and :old.nr_ano_fatura = 2001 and :old.cd_doccobr = '01' and trunc(sysdate) = '08-may-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO CONCEDIDA PELA TESOURARIA VIA EMAIL
              :old.cd_servico = 'FA' and :old.nr_fatura = 96434  and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '13-sep-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pelo Bruno on-line
              :old.cd_servico = 'FA' and :old.nr_fatura = 223468 and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '03-nov-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 3 and :new.cd_sitcobr = 0 and trunc(sysdate) = '23-oct-06' and user = 'LOGIN_CLIENTE' then
        -- alteração de faturas canceladas erroneamente pelo lyceum - 154 faturas
              null;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura = 166272 and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '26-dec-06' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura = 23070 and :old.nr_ano_fatura = 2007 and :old.cd_doccobr = '01' and trunc(sysdate) = '31-jan-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (26570,26566,26569)and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '01-MAR-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (27879,27880) and :old.nr_ano_fatura = 2007 and :old.cd_doccobr = '01' and trunc(sysdate) = '15-MAY-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (286978) and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '14-JUN-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (350148) and :old.nr_ano_fatura = 2006 and :old.cd_doccobr = '01' and trunc(sysdate) = '14-JUN-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (332836) and :old.nr_ano_fatura = 2007 and :old.cd_doccobr = '01' and trunc(sysdate) = '18-JUL-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (264207,377058) and :old.nr_ano_fatura = 2007 and :old.cd_doccobr = '01' and trunc(sysdate) = '03-oct-07' then
              NULL;
        ELSIF :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and  -- PERMISSÃO DE ALTERAÇÃO solicitada pela Marlucia - Tesouraria
              :old.cd_servico = 'FA' and :old.nr_fatura IN (32998) and :old.nr_ano_fatura = 2007 and :old.cd_doccobr = '01' and trunc(sysdate) = '03-oct-07' then
              NULL;
        elsif :old.cd_sitcobr = 3 and :new.cd_sitcobr = 0 and :old.cd_servico = 'FA' --NOVO
              and user = 'LOGIN_CLIENTE'  THEN
              NULL;
        elsif :old.cd_sitcobr = 1 and :new.cd_sitcobr = 0 and :old.cd_servico = 'FA' --NOVO
              and user = 'LOGIN_CLIENTE'  THEN
              NULL;
        ELSE
          RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW - TROCA DE SITUAÇÃO NÃO PERMITIDA. '||SQLERRM);
        END IF;--
     END IF;
     -- nova implementação

     IF :NEW.NR_ORG_ID_ERP = 83  AND  :NEW.NR_LOCKBOX_NUMBER_ERP IS NULL  AND
        :NEW.CD_SITCOBR = 1  AND  :OLD.CD_SITCOBR = 0  AND
        :NEW.CD_OCOR_BANC_FATURA = 999  THEN
          OPEN C_FORMPG;
          FETCH C_FORMPG INTO W_NR_LOCKBOX;
          CLOSE C_FORMPG;
          --
          IF (W_NR_LOCKBOX IS NOT NULL) THEN
             :NEW.NR_LOCKBOX_NUMBER_ERP := W_NR_LOCKBOX;
          ELSE

           --:NEW.NR_LOCKBOX_NUMBER_ERP := 'RJValAIdentif';

            OPEN C_PAGTOMAN;
            FETCH C_PAGTOMAN INTO W_PAGTOMAN;
            CLOSE C_PAGTOMAN;
            IF W_PAGTOMAN IS NOT NULL THEN
              :NEW.NR_LOCKBOX_NUMBER_ERP := W_PAGTOMAN;
            ELSE
              RAISE_APPLICATION_ERROR(-20004,'TRIGGER ATU_FAT_ROW - PAGTO MANUAL SEM PARAMETRO.');
            END IF;
          END IF;
        --
     ELSIF :NEW.NR_ORG_ID_ERP = 84  AND  :NEW.NR_LOCKBOX_NUMBER_ERP IS NULL  AND
        :NEW.CD_SITCOBR = 1  AND  :OLD.CD_SITCOBR = 0  AND
        :NEW.CD_OCOR_BANC_FATURA = 999  THEN
--        :NEW.NR_LOCKBOX_NUMBER_ERP := 'CredIdentificar';
          OPEN C_PAGTOMAN;
          FETCH C_PAGTOMAN INTO W_PAGTOMAN;
          CLOSE C_PAGTOMAN;
          IF W_PAGTOMAN IS NOT NULL THEN
            :NEW.NR_LOCKBOX_NUMBER_ERP := W_PAGTOMAN;
          ELSE
            RAISE_APPLICATION_ERROR(-20004,'TRIGGER ATU_FAT_ROW - PAGTO MANUAL SEM PARAMETRO.');
          END IF;
        --
     ELSIF :NEW.NR_ORG_ID_ERP in (83,84)  AND  :NEW.NR_LOCKBOX_NUMBER_ERP IS NULL  AND
           :NEW.CD_SITCOBR = 1  AND  :OLD.CD_SITCOBR = 0   AND
           :NEW.CD_OCOR_BANC_FATURA <> 999  THEN
             OPEN C_FORMPG;
             FETCH C_FORMPG INTO W_NR_LOCKBOX;
             CLOSE C_FORMPG;
             IF (W_NR_LOCKBOX IS NOT NULL) THEN
                 :NEW.NR_LOCKBOX_NUMBER_ERP := W_NR_LOCKBOX;
             ELSE
               BEGIN
                 SELECT MB.NR_LOCKBOX_NUMBER_ERP
                   INTO :NEW.NR_LOCKBOX_NUMBER_ERP
                   FROM MB_DADOS_BOLETO  MB,
                        BANCO            B
                  WHERE DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) = MB.CD_BANCO
    	            AND DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) = B.CD_BANCO
    	            AND NVL(:NEW.CD_AGEN_FATURA,0)  =  NVL( TO_NUMBER(MB.CD_AGENCIA),0 )
    	            AND :NEW.NR_CCOR_FATURA         =  MB.NU_CONTA_CORRENTE;
    	       EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   BEGIN
                    SELECT MB.NR_LOCKBOX_NUMBER_ERP
                      INTO :NEW.NR_LOCKBOX_NUMBER_ERP
                      FROM MB_DADOS_BOLETO  MB,
                           BANCO            B,
                           (  SELECT DISTINCT  CD_BANCO,
                                             CD_AGENCIA,
                                             NU_CONTA_CORRENTE
                                FROM  SERVBAN S
                               WHERE DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) = S.CD_BANCO
                                 AND LPAD(:NEW.CD_AGEN_FATURA, 5, '0')  =  LPAD(S.CD_AGBANCO, 5, '0')
                                 AND :NEW.NR_CCOR_FATURA                =  NR_CONT_CRED_SERVBAN
                           ) S
                     WHERE DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) =  MB.CD_BANCO
    		  	       AND DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) =  B.CD_BANCO
    			       AND DECODE(  NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409)  ) =  S.CD_BANCO
    			       AND ( :NEW.CD_AGEN_FATURA = MB.CD_AGENCIA  AND
                            :NEW.NR_CCOR_FATURA = MB.NU_CONTA_CORRENTE
               		          OR S.CD_AGENCIA = NVL(TO_NUMBER(MB.CD_AGENCIA),0)
                       AND S.NU_CONTA_CORRENTE = MB.NU_CONTA_CORRENTE     );
    	           EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       BEGIN
                          SELECT DISTINCT MB.NR_LOCKBOX_NUMBER_ERP
                            INTO :NEW.NR_LOCKBOX_NUMBER_ERP
                          FROM SERVBAN                              S,
                               BASE_SIGA.CONV_LIB_FATURAMENTO_SIGA  L,
                               MB_DADOS_BOLETO                      MB,
                               BANCO                                B
                          WHERE S.CD_SISTEMA           = L.CD_SISTEMA (+)
                            AND S.CD_BANCO             = L.CD_BANCO (+)
                            AND S.CD_AGBANCO           = L.CD_AGBANCO (+)
                            AND S.NR_CONT_CRED_SERVBAN = L.NR_CONT_CRED_SERVBAN (+)
                            AND S.CD_IDEN_SIST_SERVBAN = L.CD_IDEN_SIST_SERVBAN (+)
                            AND S.CD_SISTEMA           = :NEW.CD_SERVICO
                            AND S.cd_iden_sist_servban = decode(:NEW.CD_DOCCOBR,'01','04','10')
                            AND S.CD_AGENCIA           = MB.CD_AGENCIA
                            AND S.NU_CONTA_CORRENTE    = MB.NU_CONTA_CORRENTE
                            AND B.CD_BANCO             = MB.CD_BANCO
                            AND B.CD_BANCO             = DECODE( NVL(:NEW.CD_BANC_FATURA,409), 0, 237, nvl(:NEW.CD_BANC_FATURA,409) )
                            AND (     (:NEW.CD_CGC_CPF_CONV_FATURA IS NULL AND S.CD_CGC_CPF_CONV IS NULL)
                                  OR	(:NEW.CD_CGC_CPF_CONV_FATURA IS NOT NULL AND L.CONV_CD = :NEW.CD_CONV_SIGA_FATURA AND L.LOCAL_SQ = :NEW.CD_LOCAL_SIGA_FATURA)
                                )
                            AND S.ID_WEB_SERVBAN       = '0';
    			             EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             NULL;
                          WHEN TOO_MANY_ROWS THEN
                             NULL;
                       END;
                 END;
           END;
       END IF;

    END IF;
    /**/
    -- fim nova implementação
        --if USER NOT IN ('BASE_CLIENTE','OPERFAT') AND trunc(:NEW.DT_EMIS_FATURA) >= '27-jan-03' then
         --RAISE_APPLICATION_ERROR(-20004,'TITULO NÃO PODE SER EMITIDO - OPERAÇÃO DESABILITADA');
        --end if;
     IF ((:NEW.CD_SITCOBR <> :OLD.CD_SITCOBR)
       AND (:OLD.CD_CGC_CPF_CONV_FATURA IS NOT NULL OR :OLD.CD_CONV_SIGA_FATURA IS NOT NULL)
       AND :OLD.CD_SITCOBR <> '1' AND :OLD.CD_SERVICO = 'FA') THEN
         BEGIN
           SELECT 1
             INTO WRK_EXISTE
             FROM BASE_SIGA.CONV_LIB_FATURAMENTO_SIGA
            WHERE CONV_CD       = LTRIM(RTRIM(:OLD.CD_CONV_SIGA_FATURA))
              AND LOCAL_SQ      = :OLD.CD_LOCAL_SIGA_FATURA
              --AND CONV_CGC_CD = LTRIM(RTRIM(:OLD.CD_CGC_CPF_CONV_FATURA))
              AND ROWNUM  = 1;
              BEGIN
               INSERT INTO MUTTAB
               (NR_ROWID
               ,NM_TABLE
               ,OLD_CD_SITCOBR
               ,NEW_CD_SITCOBR
               ,CD_OCOR_BANC_FATURA
               ,VL_PAGO_FATURA
               ,DT_OCOR_FATURA
               ,DT_OCOR_MAN_FATURA
               ,DT_ATU)
              VALUES
               (:OLD.ROWID
               ,'FATURA'
               ,:OLD.CD_SITCOBR
               ,:NEW.CD_SITCOBR
               ,:NEW.CD_OCOR_BANC_FATURA
               ,:NEW.VL_PAGO_FATURA
               ,:NEW.DT_OCOR_FATURA
               ,:NEW.DT_OCOR_MAN_FATURA
               ,TRUNC(SYSDATE)
               );
             EXCEPTION
               WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20004,'ATUALIZA_FATURA_SIGA_ROW - ERRRO EM MUTATING_TABLE. '||SQLERRM);
             END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
             NULL;
       END;
    END IF;
  END IF;
END ATUALIZA_FATURA_SIGA_ROW;
/


-- End of DDL Script for Trigger BASE_CLIENTE.ATUALIZA_FATURA_SIGA_ROW

