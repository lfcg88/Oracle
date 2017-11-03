-- Start of DDL Script for Trigger BASE_CLIENTE.EMIT_FAT
-- Generated 30/11/10 19:34:05 from BASE_CLIENTE@test2

CREATE OR REPLACE TRIGGER emit_fat
 BEFORE
  INSERT
 ON fatura
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
  CURSOR C_CLIENTE IS
     SELECT DISTINCT
            CLI.CD_CGC_CPF_CLIENTE   CPF_CNPJ
           ,NVL(CLI.CD_ISENTO, 'N')  ISENTO
     FROM SERVCLI  SERV
         ,CLIENTE  CLI
     WHERE SERV.CD_SERVICO      =  :NEW.CD_SERVICO      -- \
       AND SERV.CD_EXT_SERVCLI  =  :NEW.CD_EXT_SERVCLI  -- /  parametros
       AND SERV.CD_CLIENTE      =  CLI.CD_CLIENTE
       AND SERV.CD_SEQ_CLIENTE  =  CLI.CD_SEQ_CLIENTE;
  RG_CLIENTE  C_CLIENTE%ROWTYPE;
  CURSOR C_USUAR IS
     SELECT DISTINCT
            USU.NR_IDEN_USUARIO    IDENTIDADE
           ,USU.CD_PA_RNE_USUARIO  PASSAPORTE
     FROM SERVCLI  SERV
         ,USUARIO  USU
     WHERE SERV.CD_SERVICO      =  :NEW.CD_SERVICO      -- \
       AND SERV.CD_EXT_SERVCLI  =  :NEW.CD_EXT_SERVCLI  -- /  parametros
       AND SERV.CD_CLIENTE      =  USU.CD_USUARIO
       AND SERV.CD_SEQ_CLIENTE  =  USU.CD_SEQ_USUARIO;
  RG_USUAR  C_USUAR%ROWTYPE;
  CURSOR C_FORMPG  IS
      select NR_LOCKBOX_NUMBER_ERP
      from formpag
      where nvl(TP_FORMPAG, 'X') = 'W'
        and CD_FORMPAG           = NVL(:NEW.CD_FORMPAG, :OLD.CD_FORMPAG)
        and NM_BAND_FORMPAG is not null;
  W_NR_LOCKBOX        FORMA_PAGAMENTO.NR_LOCKBOX_NUMBER_ERP%TYPE  :=  NULL;
  WRK_MSG_ERRO        VARCHAR2(250);
  E_ERRO              EXCEPTION;
  SERV_IMPRES         varchar2(1);
  USO_IMPRES          varchar2(1);
  JANELA_DIAS         number(3);
  CONTA_COMP          varchar2(1);
  ERRO_PROC           varchar2(80);
  w_cd_docum_erp      varchar2(5);
  w_lixo              varchar2(1);
  w_rowid             varchar2(500);
  W_IDENT             NUMBER;
  --
  w_valtiptrans  TIPTRANS_ERP.NAME%TYPE;
  -- RETENCAO
  W_DIAS_RETENCAO NUMBER;
  W_RETENCAO VARCHAR2(1);

  W_END_DATE_ACTIVE      VENDEDORES_ERP.END_DATE_ACTIVE%TYPE;
  W_START_DATE_ACTIVE    VENDEDORES_ERP.START_DATE_ACTIVE%TYPE;

  WRK_CD_CCFGV              VARCHAR2(14);
  W_NM_TIPTRANS_ERP         TIPTRANS_ERP.NAME%TYPE;
  WRK_CONCATENATED_SEGMENTS VARCHAR2(200);
  WRK_SEGMENTAUX1           VARCHAR2(100);
  WRK_SEGMENTAUX2           VARCHAR2(100);
  WRK_SEGMENTAUX3           VARCHAR2(100);
  WRK_SEGMENTAUX4           VARCHAR2(100);
  WRK_SEGMENT5              VARCHAR2(100);
  WRK_SEGMENT6              VARCHAR2(100);
  WRK_SEGMENT7              VARCHAR2(100);
  WRK_SEGMENT8              VARCHAR2(100);
  WRK_SEGMENTAUX9           VARCHAR2(100);
  WRK_SEGMENTAUX10          VARCHAR2(100);

----------------------
--      INICIO      --
----------------------
BEGIN
-- critica de documento ativo
IF :NEW.CD_DOCCOBR = '02' THEN
      WRK_MSG_ERRO :=  'Erro - Documento não disponível para faturamento';
      RAISE E_ERRO;
END IF;
--
-- CRITICA SE REGIÃO PERTENCE A CENTRO DE CUSTO
  BEGIN
    SELECT START_DATE_ACTIVE,
           END_DATE_ACTIVE
    INTO   W_START_DATE_ACTIVE,
           W_END_DATE_ACTIVE
    FROM   VENDEDORES_ERP
    WHERE  ORG_ID          = NVL(:NEW.NR_ORG_ID_ERP,83)
    AND    SALESREP_NUMBER = LPAD(:NEW.CD_CCFGV,14,'0');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      WRK_MSG_ERRO :=  'Erro - CENTRO DE CUSTO NÃO PERMITIDO PARA ESTA REGIÃO.';
      RAISE E_ERRO;
  END;

  IF W_END_DATE_ACTIVE IS NOT NULL THEN
    WRK_MSG_ERRO :=  'Erro - CENTRO DE CUSTO ESTÁ INATIVO.';
    RAISE E_ERRO;
  END IF;
-- FIM CRITICA

---------- CRITICA DOCCOBR X ORG_ID X CD_SISDOC ( IDENTIF NUMERICO DO SISTEMA NO NOSSO NUMERO )
   BEGIN
     IF NVL(:new.cd_orig_fatura,'INTERNA') = 'EXTERNA' then
        SELECT 1 INTO W_IDENT FROM SISDOC WHERE CD_DOCCOBR = :NEW.CD_DOCCOBR AND CD_SISDOC = SUBSTR(:NEW.nr_noss_nro_fatura,1,2);
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       WRK_MSG_ERRO :=  'Erro - IDENTIFICADOR DO SISTEMA NO NOSSO NUMERO INVALIDO';
       RAISE E_ERRO;
   END;
----------

---------- INICIO DO TRATAMENTO DE CONTAS
   IF :new.cd_conv_siga_fatura is not null and
      :new.nr_ccor_fatura is null
   THEN
      WRK_MSG_ERRO :=  'Erro - CONTA CORRENTE OBRIGATÓRIA!! (Fatura ' ||
                       :NEW.NR_FATURA || '/' || :NEW.NR_ANO_FATURA || ')';
      RAISE E_ERRO;
   END IF;
   IF :NEW.CD_BANC_FATURA IN ( '409' ) AND
      :NEW.NR_CCOR_FATURA IS NULL          AND
      :NEW.CD_AGEN_FATURA IS NULL
   THEN
      :NEW.CD_AGEN_FATURA := '00272';
      :NEW.NR_CCOR_FATURA := 1111793;
   END IF;
   IF :NEW.CD_SERVICO <> 'EL' AND :NEW.CD_BANC_FATURA IN ( '0' ) AND
      :NEW.NR_CCOR_FATURA IS NULL          AND      :NEW.CD_AGEN_FATURA IS NULL
   THEN
      :new.cd_banc_fatura := 237;
      :NEW.CD_AGEN_FATURA := '3369';
      :NEW.NR_CCOR_FATURA := 18002;
   END IF;
   IF :NEW.CD_SERVICO <> 'EL' AND :NEW.CD_BANC_FATURA IN ( '0' ) AND
      :NEW.NR_CCOR_FATURA = 1111793         AND      :NEW.CD_AGEN_FATURA IS not NULL
   THEN
      :new.cd_banc_fatura := 409;
   end if;
   IF :NEW.CD_BANC_FATURA IS NULL AND
      :NEW.NR_CCOR_FATURA IS NULL AND
      :NEW.CD_AGEN_FATURA IS NULL
   THEN
      :NEW.CD_BANC_FATURA := 409;
      :NEW.CD_AGEN_FATURA := '00272';
      :NEW.NR_CCOR_FATURA := 1111793;
   END IF;
   IF :NEW.CD_AGEN_FATURA IS NULL AND
      :NEW.CD_BANC_FATURA IS NOT NULL AND
      :new.nr_ccor_fatura is null
   THEN
      --
      IF :NEW.CD_BANC_FATURA = 409 THEN
         :NEW.CD_AGEN_FATURA := '00272';
         :new.nr_ccor_fatura := '1111793';
      ELSIF :NEW.CD_BANC_FATURA = 356 THEN
         :NEW.CD_AGEN_FATURA := '01207';
      ELSIF :NEW.CD_BANC_FATURA IN ('1','001') THEN
         :NEW.CD_AGEN_FATURA := '02879';
      ELSIF :new.cd_banc_fatura = 237 then
         :new.cd_agen_fatura := '3369';
         :new.nr_ccor_fatura := '18002';
      elsif :new.cd_banc_fatura = 0 then
         :new.cd_agen_fatura := '3369';
         :new.nr_ccor_fatura := '18002';
      END IF;
   END IF;
   IF :NEW.CD_AGEN_FATURA IS NULL AND
      :NEW.CD_BANC_FATURA IS NOT NULL
   THEN
      --
      IF :NEW.CD_BANC_FATURA = 409 THEN
         :NEW.CD_AGEN_FATURA := '00272';
      ELSIF :NEW.CD_BANC_FATURA = 356 THEN
         :NEW.CD_AGEN_FATURA := '01207';
      ELSIF :NEW.CD_BANC_FATURA IN ('1','001') THEN
         :NEW.CD_AGEN_FATURA := '02879';
      ELSIF :new.cd_banc_fatura = 237 then
         :new.cd_agen_fatura := '3369';
      elsif :new.cd_banc_fatura = 0 then
         :new.cd_agen_fatura := '3369';
      END IF;
   END IF;
-- FIM TRATAMENTO DE CONTAS
-- INICIO TRATAMENTO DA GERAÇÃO DO NOSSO NUMERO - NOVO FORMATO
--IF NVL(:new.cd_orig_fatura,'INTERNA') = 'INTERNA' then
-- INICIO DO CALCULO DO NOSSO NUMERO - 13/06/08
DECLARE
  w_banco varchar2(5);
  w_agencia varchar2(5);
  w_conta varchar2(20);
  w_conv varchar2(10);
  w_local number(2);
  w_sistema varchar2(5);
  w_iden_sist varchar2(2);
  WRK_CARTEIRA  VARCHAR2(10);
  w_prox_nnro gercobr.nr_prox_noss_nro_gercobr%type;
BEGIN
  select cd_sistema into w_sistema from carserv where cd_servico = :NEW.CD_SERVICO;
  begin
IF NVL(:new.cd_orig_fatura,'INTERNA') = 'INTERNA' AND :NEW.CD_SERVICO = 'FA' then
    select S.cd_iden_sist_servban,M.CD_CARTEIRA,fl_retencao
      into w_iden_sist,WRK_CARTEIRA,W_RETENCAO
      from servban S, MB_DADOS_BOLETO M
     where S.NU_CONTA_CORRENTE = M.NU_CONTA_CORRENTE
       AND S.CD_BANCO = M.CD_BANCO
       AND S.cd_sistema = w_sistema
       and ((:NEW.CD_SITCOBR = '0' AND S.cd_banco = :new.cd_banc_fatura and (S.nr_cont_cred_servban = :new.nr_ccor_fatura OR S.NU_CONTA_CORRENTE = :new.nr_ccor_fatura))
            OR
            (:NEW.CD_SITCOBR <> 0 and (S.cd_banco,S.NU_CONTA_CORRENTE) IN ( SELECT cd_banco,NU_CONTA_CORRENTE FROM MB_DADOS_BOLETO WHERE FL_CONTA_PADRAO = 'S')))
       and :NEW.CD_DOCCOBR = S.CD_DOCCOBR
       AND ID_WEB_SERVBAN = 0;
    begin
      select nr_prox_noss_nro_gercobr,rowid
        into w_prox_nnro,w_rowid
        from gercobr
       where cd_sistema = w_sistema
         and cd_doccobr = :new.cd_doccobr
         for update;
      if w_prox_nnro > 99999999 then
         WRK_MSG_ERRO :=  'Geração de Fatura com problema na continuidade de NNro' ;
         RAISE E_ERRO;
      end if;
      :NEW.CD_IDTIT_NOSSNRO_FATURA := w_iden_sist||lpad(w_prox_nnro,8,'0');
    exception
      when others then
         WRK_MSG_ERRO :=  'Problema na geração do nosso numero - 1' ;
         RAISE E_ERRO;
    end;
ELSIF NVL(:new.cd_orig_fatura,'INTERNA') <> 'INTERNA' THEN -- 'externa'
    select S.cd_iden_sist_servban,M.CD_CARTEIRA,FL_RETENCAO
      into w_iden_sist,WRK_CARTEIRA,W_RETENCAO
      from servban S, MB_DADOS_BOLETO M
     where S.NU_CONTA_CORRENTE = M.NU_CONTA_CORRENTE
       AND S.CD_BANCO = M.CD_BANCO
       AND S.cd_sistema = w_sistema
       and ((:NEW.CD_SITCOBR = '0' AND S.cd_banco = :new.cd_banc_fatura and (S.nr_cont_cred_servban = :new.nr_ccor_fatura OR S.NU_CONTA_CORRENTE = :new.nr_ccor_fatura))
            OR
            (:NEW.CD_SITCOBR <> 0 and (S.cd_banco,S.NU_CONTA_CORRENTE) IN ( SELECT cd_banco,NU_CONTA_CORRENTE FROM MB_DADOS_BOLETO WHERE FL_CONTA_PADRAO = 'S')))
       and :NEW.CD_DOCCOBR = S.CD_DOCCOBR
       AND ID_WEB_SERVBAN = 0;

      :NEW.CD_IDTIT_NOSSNRO_FATURA := :NEW.nr_noss_nro_fatura;
      --if :new.cd_banc_fatura = 237 then
      --   :new.cd_compl_nossnro_fatura := '09';
      --end if;
ELSE --IF NVL(:new.cd_orig_fatura,'INTERNA') = 'INTERNA' AND :NEW.CD_SERVICO = 'FA' then
    IF :NEW.CD_SERVICO LIKE 'AS%' THEN
       :NEW.CD_IDTIT_NOSSNRO_FATURA := '01'||SUBSTR(:NEW.NR_ANO_FATURA,3,2)||LPAD(:NEW.NR_FATURA,6,'0');
    ELSIF  :NEW.CD_SERVICO LIKE 'IA%' THEN
       :NEW.CD_IDTIT_NOSSNRO_FATURA := '07'||SUBSTR(:NEW.NR_ANO_FATURA,3,2)||LPAD(:NEW.NR_FATURA,6,'0');
    ELSIF  :NEW.CD_SERVICO = 'EL' THEN
       :NEW.CD_IDTIT_NOSSNRO_FATURA := '20'||SUBSTR(:NEW.NR_ANO_FATURA,3,2)||LPAD(:NEW.NR_FATURA,6,'0');
    ELSE
       :NEW.CD_IDTIT_NOSSNRO_FATURA := :NEW.nr_noss_nro_fatura;
    end if;
    W_RETENCAO := 'N';
END IF;
   -- INICIO DO CALCULO DO DV DO NOSSO NUMERO - 13/06/08
   DECLARE
     NUM    NUMBER:= TO_NUMBER(:NEW.CD_IDTIT_NOSSNRO_FATURA);
     DIG1   CHAR(2);
     DIG2   CHAR(2);
     DIG3   CHAR(2);
     DIG4   CHAR(2);
     DIG5   CHAR(2);
     DIG6   CHAR(2);
     DIG7   CHAR(2);
     DIG8   CHAR(2);
     DIG9   CHAR(2);
     DIG10  CHAR(2);
     TOTDIG NUMBER(2);
     RESULT CHAR(15);
     DV     NUMBER(1);
     NUM_AUX VARCHAR2(11);
     W_ANO VARCHAR2(2);
     W_SIST VARCHAR2(2);
     W_DOC VARCHAR2(6);
     W_TESTE VARCHAR2(2);
     WRK_ANO_TESTE         NUMBER;
     WRK_SIST_TESTE        VARCHAR2(2);
     wrk_NR_FATURA_TESTE   NUMBER;
     NUM_AUX_TESTE         VARCHAR2(12);
     wrk_tam               number(3);
     wrk_contador          number;
     wrk_tot_dig           number;
     wrk_digito_teste      number;
     wrk_mod_11            number;
     DV_BRADESCO           varchar2(2);
     WRK_CAL_NOSSO_NUM     varchar2(15);
   BEGIN
     SELECT LPAD(NUM,11,0)
       INTO NUM_AUX_TESTE
       FROM DUAL;
     WRK_ANO_TESTE       :=  TO_NUMBER('20'||SUBSTR(NUM_AUX_TESTE,4,2));
     wrk_NR_FATURA_TESTE :=  TO_NUMBER(SUBSTR(NUM_AUX_TESTE,6,6));
     WRK_SIST_TESTE      :=  SUBSTR(NUM_AUX_TESTE,2,2);
     if wrk_carteira is null and :new.cd_banc_fatura = '237' then
        wrk_carteira := '09';
        :new.cd_compl_nossnro_fatura  := wrk_carteira;
     end if;

     IF :NEW.CD_BANC_FATURA = '237' THEN
        :NEW.CD_COMPL_NOSSNRO_FATURA := WRK_CARTEIRA;
        WRK_CAL_NOSSO_NUM:= WRK_CARTEIRA||NUM_AUX_TESTE; -- 13 POSIÇÕES
        wrk_tam          := length(WRK_CAL_NOSSO_NUM);
        wrk_contador     := 1;
        wrk_tot_dig      := 0;
        for i in reverse 1..wrk_tam loop
          if wrk_contador = 7 then
             wrk_contador:= 2;
          else
             wrk_contador:= wrk_contador+1;
          end if;
          wrk_tot_dig:= wrk_tot_dig + (substr(WRK_CAL_NOSSO_NUM,i,1)*wrk_contador);
        end loop;
        wrk_mod_11      := mod(wrk_tot_dig,11);
        BEGIN
          SELECT DECODE(wrk_mod_11,0,'0',1,'P',TO_CHAR(11- wrk_mod_11))
            INTO DV_BRADESCO
            FROM DUAL;
        END;
        RESULT := LPAD(NUM_AUX_TESTE,11,0)||DV_BRADESCO;
        :NEW.CD_DV_NOSSNRO_FATURA := DV_BRADESCO;
    ELSE -- NAO E BRADESCO
      SELECT LPAD(NUM,10,0)
        INTO NUM_AUX
        FROM DUAL;
      DIG10 := SUBSTR(NUM_AUX,10,1) * 2;
      DIG9  := SUBSTR(NUM_AUX,9,1) * 3;
      DIG8  := SUBSTR(NUM_AUX,8,1) * 4;
      DIG7  := SUBSTR(NUM_AUX,7,1) * 5;
      DIG6  := SUBSTR(NUM_AUX,6,1) * 6;
      DIG5  := SUBSTR(NUM_AUX,5,1) * 7;
      DIG4  := SUBSTR(NUM_AUX,4,1) * 8;
      DIG3  := SUBSTR(NUM_AUX,3,1) * 9;
      DIG2  := SUBSTR(NUM_AUX,2,1) * 2;
      DIG1  := SUBSTR(NUM_AUX,1,1) * 3;
      TOTDIG := MOD(NVL(DIG10,0) +
              NVL(DIG9,0) + NVL(DIG8,0) +
              NVL(DIG7,0) + NVL(DIG6,0) +
              NVL(DIG5,0) + NVL(DIG4,0) +
              NVL(DIG3,0) + NVL(DIG2,0) +
              NVL(DIG1,0),11);
      BEGIN
        SELECT DECODE(TOTDIG,0,0,1,0,TO_CHAR(11-TOTDIG))
          INTO DV
          FROM DUAL;
      END;
      RESULT := NUM_AUX||TO_CHAR(DV);
      :NEW.CD_DV_NOSSNRO_FATURA := TO_CHAR(DV);
    END IF;
  END;
-- FIM DO CALCULO DO DV DO NOSSO NUMERO - 13/06/08
  exception
    when others then
         WRK_MSG_ERRO :=  'Problema na geração do nosso numero - 2. Conta: '||:new.nr_ccor_fatura ;
         RAISE E_ERRO;
  end;
END;
if :NEW.CD_IDTIT_NOSSNRO_FATURA is null then
         WRK_MSG_ERRO :=  'Problema na geração do nosso numero - 3' ;
         RAISE E_ERRO;
end if;
-- FIM DO CALCULO DO NOSSO NUMERO
----------------------
IF :new.cd_servico = 'FA' then
   /*  ** Bloquear faturas que não tenham identificação do cliente **  */
   OPEN C_CLIENTE;
   FETCH C_CLIENTE INTO RG_CLIENTE;
   CLOSE C_CLIENTE;
   IF (RG_CLIENTE.CPF_CNPJ IS NULL  AND  RG_CLIENTE.ISENTO <> 'S') THEN
      OPEN C_USUAR;
      FETCH C_USUAR INTO RG_USUAR;
      CLOSE C_USUAR;
      --
      IF (RG_USUAR.IDENTIDADE IS NULL  AND  RG_USUAR.PASSAPORTE IS NULL)
      THEN
         WRK_MSG_ERRO :=  'Cliente informado não possui identificação única !! ('||:new.cd_servico||'-'||:NEW.NR_FATURA || '/' || :NEW.NR_ANO_FATURA||')' ;
         RAISE E_ERRO;
      END IF;
      --
   END IF;
   /*  ___ FIM tratamento do bloqueio das faturas sem identificação ___  */
END IF;
   IF :NEW.NR_ORG_ID_ERP IS NULL THEN
      :NEW.NR_ORG_ID_ERP := 83;
   END IF;
   IF :new.cd_conv_siga_fatura is not null and
      :new.nr_ccor_fatura is null
   THEN
      WRK_MSG_ERRO :=  'Erro - CONTA CORRENTE OBRIGATÓRIA!! (Fatura ' ||
                                  :NEW.NR_FATURA || '/' || :NEW.NR_ANO_FATURA || ')';
      RAISE E_ERRO;
   END IF;
   -- TRATAMENTO PARA NOTA FISCAL EMITIDA NA CONTA 1111793
   IF :NEW.CD_BANC_FATURA = 0 AND :NEW.NR_CCOR_FATURA = '1111793' AND
      :NEW.CD_DOCCOBR = '02' THEN
        :new.CD_BANC_FATURA := '237';-- novo
        :NEW.CD_AGEN_FATURA := '3369';
        :NEW.NR_CCOR_FATURA := 18002;
   END IF;
   if length(:new.cd_ccfgv) <= 9 then
      WRK_MSG_ERRO :=  'Erro - CENTRO DE CUSTO INVÁLIDO!! (Fatura ' ||
                                  :NEW.NR_FATURA || '/' || :NEW.NR_ANO_FATURA || ')';
      RAISE E_ERRO;
   end if;
   -- Novo controle de tratamento para impressão de boletos no banco baseado no cd_gera_las_fatura
   if :new.cd_conv_siga_fatura is null and :new.cd_tipcobr = 'NM' then
      :new.cd_gera_las_fatura := 1;
   end if;
   -- Novo tratamento de controle de registro do titulo no banco
   :new.cd_gera_banc_fatura := 0;
   -- TRATAMENTO COBRANCA: ACORDO EXTERNO
   IF :NEW.DS_STATUS_COBRANCA='AE' THEN
       :new.cd_gera_banc_fatura := 1;
   END IF;
--
-- tratamento para retenção de faturas
  IF W_RETENCAO = 'S' THEN -- CONTA COM RETENCAO
    BEGIN
     SELECT NVL(NR_DIAS_RETENCAO,0),CD_DOCUM_ERP
       INTO W_DIAS_RETENCAO, W_CD_DOCUM_ERP
       FROM DOCCOBR
      WHERE CD_DOCCOBR = :NEW.CD_DOCCOBR;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       W_DIAS_RETENCAO := 0;
    END;
    IF W_DIAS_RETENCAO > 0 AND W_CD_DOCUM_ERP = 'FS'
       AND trunc(:new.dt_venc_fatura) > trunc(sysdate) + W_DIAS_RETENCAO
       AND NVL(:NEW.CD_CLASERV,'X') <> 'EXPR'  -- FATURA EXPRESSA
       AND :new.cd_gera_las_fatura = 0 then -- alterado por Luciana em 11/05/10 por solicitação do Jorge todos os titulos com "Impressão FGV" não serão retidos.
          :NEW.CD_GERA_BANC_FATURA := 9;
       IF :NEW.DS_STATUS_COBRANCA='AE' THEN
          :new.cd_gera_banc_fatura := 1;
       END IF;
    END IF;
  END IF;
--
/*   begin
     select cd_docum_erp,nr_dias_retencao
       into w_cd_docum_erp,W_NR_DIAS_RETENCAO
       from doccobr
      where cd_doccobr = :new.cd_doccobr;
   exception
     when no_data_found then
        WRK_MSG_ERRO :=  'Erro - Documento não encontrado !!';
        RAISE E_ERRO;
   end;
--     IF :new.cd_banc_fatura = 237 and :new.dt_venc_fatura > trunc(sysdate) +30 and :new.cd_gera_las_fatura = 0 then --:new.cd_tipcobr <> 'NM' then
     IF :new.cd_banc_fatura = 237 and :new.dt_venc_fatura > trunc(sysdate) +W_NR_DIAS_RETENCAO and :new.cd_gera_las_fatura = 0 then --:new.cd_tipcobr <> 'NM' then
        IF w_cd_docum_erp = 'FS' then -- faturas
           P_IMPRESSAO_CONTA ( :new.nr_ccor_fatura, SERV_IMPRES, USO_IMPRES,JANELA_DIAS, CONTA_COMP, ERRO_PROC);
           IF erro_proc is null then
              IF conta_comp = 'N' then -- só contas FGV
                 :new.cd_gera_banc_fatura := 9;
              END IF;
              -- TRATAMENTO COBRANCA: ACORDO EXTERNO
              IF :NEW.DS_STATUS_COBRANCA='AE' THEN
                 :new.cd_gera_banc_fatura := 1;
              END IF;
           ELSE
             WRK_MSG_ERRO :=  'Erro - '||erro_proc;
             RAISE E_ERRO;
           END IF;
        END IF;
     END IF;*/
-- fim da alteração de tratamento de retenção
   IF INSERTING   THEN
      if :new.nr_ano_fatura <> to_char(sysdate,'yyyy') then
         WRK_MSG_ERRO :=  'Erro - ANO DA FATURA DEVE SER O ATUAL.';
         RAISE E_ERRO;
      end if;
      IF :NEW.nm_tiptrans_erp IS NULL THEN
         WRK_MSG_ERRO :=  'Erro - FATURA TEM QUE TER NATUREZA.';
         RAISE E_ERRO;
      ELSE
         BEGIN
           SELECT distinct 'a' INTO w_valtiptrans FROM tiptrans_erp WHERE org_id = :NEW.nr_org_id_erp
           and name = :NEW.nm_tiptrans_erp;
         EXCEPTION
           WHEN no_data_found THEN
            wrk_msg_erro := 'Erro - NATUREZA/TIPO TRANSACAO NÃO CADASTRADO !!';
            RAISE E_ERRO;
           WHEN OTHERS THEN
            WRK_MSG_ERRO := 'Erro - '||sqlerrm;
            RAISE E_ERRO;
         END;
      end if;
      if trunc(:new.dt_venc_fatura) < trunc(:new.dt_emis_fatura) then
         WRK_MSG_ERRO :=  'Erro - FATURA NÃO PODE TER DATA DE VENCIMENTO MENOR DO QUE A DATA DE EMISSÃO.';
         RAISE E_ERRO;
      end if;
      -- NOVO
      -- INCLUIDO PARA NÃO RECUSAR OS TITULOS DE FUNDO DE BOLSA
       if :NEW.CD_DOCCOBR NOT IN (15,16) AND trunc(:new.dt_venc_fatura) - trunc(:new.dt_emis_fatura) > 1461  then -- RETIRADO O TEXTO "730 then" POR SOLICITAÇÃO DO OCARIO EM 16/08/2004
         WRK_MSG_ERRO :=  'Erro - FATURA NÃO PODE TER DATA DE VENCIMENTO SUPERIOR A 4 ANOS.';
         RAISE E_ERRO;
      end if;

/*    if nvl(:new.vl_vig_fatura,0) < 1 and :new.cd_doccobr in('01','02') then
         WRK_MSG_ERRO :=  'Erro - FATURA/NOTA FISCAL NÃO PODE TER VALOR MENOR QUE 1.';
         RAISE E_ERRO;
      elsif nvl(:new.vl_vig_fatura,0) < 0 then
         WRK_MSG_ERRO :=  'Erro - DOCUMENTO NÃO PODE TER VALOR MENOR QUE 0(zero).';
         RAISE E_ERRO;
      end if;*/
-- novas criticas de emissão
      IF NVL (:NEW.vl_vig_fatura, 0) <= 0  THEN
         wrk_msg_erro := 'Documento não pode ter valor menor ou igual a zero.';
         RAISE e_erro;
      END IF;

      IF :NEW.CD_SITCOBR = 1 AND NVL(:NEW.VL_PAGO_FATURA,0) <= 0 THEN
         wrk_msg_erro := 'Documento não pode ter valor de pagto menor ou igual a zero.';
         RAISE e_erro;
      END IF;
      IF :NEW.CD_SITCOBR = 1 AND (:NEW.CD_OCOR_BANC_FATURA IS NULL OR :NEW.VL_PAGO_FATURA IS NULL OR :NEW.DT_PAGO_CLI_FATURA IS NULL) THEN
         wrk_msg_erro := 'QUITACAO: Não possui dados preenchidos';
         RAISE e_erro;
      ELSIF :NEW.CD_SITCOBR = 1 AND :NEW.CD_OCOR_BANC_FATURA = 999 AND :NEW.DT_OCOR_MAN_FATURA IS NULL THEN
         wrk_msg_erro := 'QUITACAO: Não possui dados preenchidos';
         RAISE e_erro;
      ELSIF :NEW.CD_SITCOBR = 1 AND :NEW.CD_OCOR_BANC_FATURA = 6 AND :NEW.DT_OCOR_FATURA IS NULL THEN
         wrk_msg_erro := 'QUITACAO: Não possui dados preenchidos';
         RAISE e_erro;
      END IF;
--
   END IF;
-- nova implementação - BUSCA LOCKBOX NUMBER
   IF :NEW.NR_ORG_ID_ERP in ( 83 , 84 )  AND
      :NEW.NR_LOCKBOX_NUMBER_ERP IS NULL AND
      :NEW.CD_SITCOBR = 1                AND
      :NEW.CD_OCOR_BANC_FATURA = 999
   THEN
      OPEN C_FORMPG;
      FETCH C_FORMPG INTO W_NR_LOCKBOX;
      CLOSE C_FORMPG;
      --
      IF (W_NR_LOCKBOX IS NOT NULL) THEN
         :NEW.NR_LOCKBOX_NUMBER_ERP := W_NR_LOCKBOX;
      ELSE
        begin
        select nr_lockbox_number_pagto_manual
          into W_NR_LOCKBOX
          from locais_faturamento where org_id_erp = :NEW.NR_ORG_ID_ERP;
--         :NEW.NR_LOCKBOX_NUMBER_ERP := 'RJValAIdentif';
         :NEW.NR_LOCKBOX_NUMBER_ERP := W_NR_LOCKBOX;
        exception
          when no_data_found then
            wrk_msg_erro := 'QUITACAO: lockbox não encontrado.';
            RAISE e_erro;
        end;
      END IF;
      --
   ELSIF :NEW.NR_ORG_ID_ERP in ( 83 , 84 )   AND
         :NEW.NR_LOCKBOX_NUMBER_ERP IS NULL  AND
         :NEW.CD_SITCOBR = 1                 AND
         :NEW.CD_OCOR_BANC_FATURA <> 999
   THEN
      IF (W_NR_LOCKBOX IS NOT NULL)
      THEN
          :NEW.NR_LOCKBOX_NUMBER_ERP := W_NR_LOCKBOX;
      ELSE
          BEGIN
             SELECT MB.NR_LOCKBOX_NUMBER_ERP
               INTO :NEW.NR_LOCKBOX_NUMBER_ERP
             FROM MB_DADOS_BOLETO  MB,
                  BANCO            B
             WHERE DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = MB.CD_BANCO
               AND DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = B.CD_BANCO
               AND NVL(:NEW.CD_AGEN_FATURA,0)                                   = NVL(TO_NUMBER(MB.CD_AGENCIA),0)
               AND :NEW.NR_CCOR_FATURA                                          = MB.NU_CONTA_CORRENTE;
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
                           WHERE DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = S.CD_BANCO
                             AND LPAD(:NEW.CD_AGEN_FATURA,5,'0')                              = LPAD(S.CD_AGBANCO,5,'0')
                             AND :NEW.NR_CCOR_FATURA                                          = NR_CONT_CRED_SERVBAN
                        ) S
                   WHERE DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = MB.CD_BANCO
                     AND DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = B.CD_BANCO
                     AND DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA) = S.CD_BANCO
                     AND ( :NEW.CD_AGEN_FATURA = MB.CD_AGENCIA             AND
                           :NEW.NR_CCOR_FATURA = MB.NU_CONTA_CORRENTE      OR
                           S.CD_AGENCIA = NVL(TO_NUMBER(MB.CD_AGENCIA),0)  AND
                           S.NU_CONTA_CORRENTE = MB.NU_CONTA_CORRENTE
                         );
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      BEGIN
                         SELECT DISTINCT MB.NR_LOCKBOX_NUMBER_ERP
                            INTO :NEW.NR_LOCKBOX_NUMBER_ERP
                         FROM SERVBAN                              S,
                              BASE_SIGA.CONV_LIB_FATURAMENTO_SIGA  L,
                              MB_DADOS_BOLETO MB,BANCO             B
                         WHERE S.CD_SISTEMA           = L.CD_SISTEMA (+)
                           AND S.CD_BANCO             = L.CD_BANCO (+)
                           AND S.CD_AGBANCO           = L.CD_AGBANCO (+)
                           AND S.NR_CONT_CRED_SERVBAN = L.NR_CONT_CRED_SERVBAN (+)
                           AND S.CD_IDEN_SIST_SERVBAN = L.CD_IDEN_SIST_SERVBAN (+)
                           AND S.CD_SISTEMA           = :NEW.CD_SERVICO
                           AND S.CD_DOCCOBR           = :NEW.CD_DOCCOBR
                           AND S.CD_AGENCIA           = MB.CD_AGENCIA
                           AND S.NU_CONTA_CORRENTE    = MB.NU_CONTA_CORRENTE
                           AND B.CD_BANCO             = MB.CD_BANCO
                           AND B.CD_BANCO             = DECODE(NVL(:NEW.CD_BANC_FATURA,0),0,409,:NEW.CD_BANC_FATURA)
                           AND (    (:NEW.CD_CGC_CPF_CONV_FATURA IS NULL  AND  S.CD_CGC_CPF_CONV IS NULL)
                                 OR (:NEW.CD_CGC_CPF_CONV_FATURA IS NOT NULL  AND  L.CONV_CD = :NEW.CD_CONV_SIGA_FATURA  AND  L.LOCAL_SQ = :NEW.CD_LOCAL_SIGA_FATURA)
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
-- fim da nova implementação - BUSCA LOCKBOX NUMBER
   update gercobr
      set nr_prox_noss_nro_gercobr = nr_prox_noss_nro_gercobr+1
    where w_rowid = rowid;
-- Formatação do número do título
   Begin
     select cd_local||'-'||
            decode(substr(:new.cd_servico,1,2),'FA',cd_orig_erp,substr(:new.cd_servico,1,2))||'00-'||
            cd_docum_erp||'-'||
            to_char(to_date(:new.nr_ano_fatura,'yyyy'),'yy')||
            lpad(to_char(:new.nr_fatura),7,'0')
       into :new.nr_trx_number_erp
       from doccobr
      where cd_doccobr = :new.cd_doccobr;
   Exception
     when others then
       wrk_msg_erro :=  'Erro formtação título - '||sqlerrm;
       raise e_erro;
   End;
--

--- Início da validação do CENTRO DE CUSTO com a NATUREZA
/*
WRK_CD_CCFGV := LPAD(:NEW.CD_CCFGV,14,'0');
BEGIN
  SELECT CONCATENATED_SEGMENTS
  INTO   WRK_CONCATENATED_SEGMENTS
  FROM   APELIDO_ERP
  WHERE  ALIAS_NAME = WRK_CD_CCFGV;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    WRK_MSG_ERRO := 'Erro - ' ||WRK_CD_CCFGV||' não encontrado em APELIDO_ERP.';
    RAISE E_ERRO;
  WHEN OTHERS THEN
    WRK_MSG_ERRO := 'Erro - ' ||WRK_CD_CCFGV||' - falha na consulta a APELIDO_ERP.';
    RAISE E_ERRO;
END;

P_LER_SPLIT(WRK_CONCATENATED_SEGMENTS,WRK_SEGMENTAUX1,WRK_SEGMENTAUX2,WRK_SEGMENTAUX3,
            WRK_SEGMENTAUX4,WRK_SEGMENT5,WRK_SEGMENT6,WRK_SEGMENT7,WRK_SEGMENT8,
            WRK_SEGMENTAUX9,WRK_SEGMENTAUX10,'-');

BEGIN
  SELECT A.NAME
  INTO   W_NM_TIPTRANS_ERP
  FROM   TIPTRANS_ERP A
  WHERE  WRK_SEGMENT5 >= A.ATTRIBUTE2
  AND    WRK_SEGMENT5 <= A.ATTRIBUTE3
  AND    A.ORG_ID     = NVL(:NEW.NR_ORG_ID_ERP,83)
  AND    A.NAME       = :NEW.NM_TIPTRANS_ERP
  AND    ROWNUM       = 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    WRK_MSG_ERRO := 'Erro - Natureza não aestá associada ao centro de custo - ' ||WRK_CD_CCFGV||'.';
    RAISE E_ERRO;
  WHEN OTHERS THEN
    WRK_MSG_ERRO := 'Erro - ' ||:NEW.NM_TIPTRANS_ERP||' - falha na consulta a TIPTRANS_ERP.';
    RAISE E_ERRO;
END;
*/
--- Fim da validação do CENTRO DE CUSTO com a NATUREZA

EXCEPTION
   WHEN E_ERRO THEN
      RAISE_APPLICATION_ERROR(-20004, WRK_MSG_ERRO);
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004, 'Erro não identificado. ' || SQLERRM);

END EMIT_FAT;
/


-- End of DDL Script for Trigger BASE_CLIENTE.EMIT_FAT

