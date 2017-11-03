CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6039
( PAR_CCAMPA_DSTAQ             IN  NUMBER,
  PAR_CCUPOM_PROML_DSTAQ       IN  NUMBER,
  PAR_USUARIO                  IN  VARCHAR2,
  PAR_COD_RETORNO              OUT VARCHAR2,
  PAR_COD_MENSAGEM             OUT VARCHAR2
 ) IS
-------------------------------------------------------------------------------------------------
--      bradesco seguros s.a.
--      procedure       : SGPB6039
--      data            : 11/12/2007
--      autor           : ALEXANDRE CYSNE ESTEVES
--      objetivo        : ESTORNO DAS RASPADINHAS RETIRADA PELOS CORRETORES
-------------------------------------------------------------------------------------------------

--***************  VARIAVEIS DE TRABALHO
VAR_ENCERRA                  NUMBER(1)  :=0; -- SE VAR_ENCERRA = 0 (OK), 1 (ERRO)
VAR_DALTR_REG                DATE;
VAR_ICAMPA_DSTAQ             VARCHAR2(50);
VAR_DFIM_CAMPA_DSTAQ         DATE;
VAR_CIND_CAMPA_ATIVO         VARCHAR2(1);
VAR_DAPURC_DSTAQ             DATE;
VAR_CCAMPA_DSTAQ             NUMBER(3);
VAR_FIM_PROCESSO_ERRO        EXCEPTION;
VAR_TIPO_PESSOA              VARCHAR2(1);
VAR_CCPF_CNPJ_BASE           NUMBER(15);


  --
  -- VERIFICA_PARM
  -- VERIFICA SE PARÂMETROS DE ENTRADA SÃO VÁLIDOS
  --
  PROCEDURE VERIFICA_PARM IS

  BEGIN

    IF PAR_CCAMPA_DSTAQ  IS NULL THEN
        VAR_ENCERRA  := 1;
    ELSIF PAR_CCUPOM_PROML_DSTAQ IS NULL THEN
        VAR_ENCERRA  := 1;
    ELSIF PAR_USUARIO IS NULL THEN
        VAR_ENCERRA  := 1;
    END IF;

    IF VAR_ENCERRA = 1 THEN
       PAR_COD_MENSAGEM := 'Campos de entrada são obrigatórios';
    ELSE
       VAR_ENCERRA := 0;
    END IF;

  END VERIFICA_PARM;

  --
  -- VERIFICA_CONDICOES
  -- VERIFICA SE CAMPANHA ESTÁ EM CONDIÇÃO DE PROCESSAMENTO
  --
  PROCEDURE VERIFICA_CONDICOES IS

  BEGIN
     BEGIN
     SELECT CD.ICAMPA_DSTAQ,
            CD.DFIM_CAMPA_DSTAQ,
            CD.CIND_CAMPA_ATIVO,
            CD.CCAMPA_DSTAQ,
            CD.DAPURC_DSTAQ
     INTO   VAR_ICAMPA_DSTAQ,
            VAR_DFIM_CAMPA_DSTAQ,
            VAR_CIND_CAMPA_ATIVO,
            VAR_CCAMPA_DSTAQ,
            VAR_DAPURC_DSTAQ
     FROM   CAMPA_DSTAQ CD
     WHERE  CD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Código da Campanha informado '|| PAR_CCAMPA_DSTAQ ||
         ' não existe.'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
     END;

     --VERIFICA RETORNO DA CONDICAO DE PROCESSAMENTO
      IF VAR_CIND_CAMPA_ATIVO <> 'S' THEN
         VAR_ENCERRA := 1;
         PAR_COD_MENSAGEM := 'Campanha '|| VAR_ICAMPA_DSTAQ ||
         ' encerrada.' ;
      END IF;

  END VERIFICA_CONDICOES;

  --
  -- VERIFICA_SE_CUPOM_RETIRADO
  -- VERIFICA SE O CORRETOR JA FOI RETIRADO
  --
  PROCEDURE VERIFICA_SE_CUPOM_RETIRADO IS

  BEGIN
    BEGIN     
      SELECT ECPD.CTPO_PSSOA, 
             ECPD.CCPF_CNPJ_BASE, 
             ECPD.DALT_REG
        INTO VAR_TIPO_PESSOA,
             VAR_CCPF_CNPJ_BASE,
             VAR_DALTR_REG
        FROM ESTOQ_CUPOM_PROML_DSTAQ ECPD
       WHERE ECPD.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ
         AND ECPD.CCUPOM_PROML_DSTAQ = PAR_CCUPOM_PROML_DSTAQ
         AND ECPD.CTPO_PSSOA IS NOT NULL
         AND ECPD.CCPF_CNPJ_BASE IS NOT NULL;
     
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;                  
         PAR_COD_MENSAGEM := 'Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
         ' não disponivel para estorno - ' || sysdate || '!!!'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
    END ;

  END VERIFICA_SE_CUPOM_RETIRADO;

  --
  -- ATUALIZA_POSIC_CRRTR_DSTAQ
  -- ATUALIZA ESTORNO DA RASPADINHA NA TABELA ESTOQ_CUPOM_PROML_DSTAQ
  --
  PROCEDURE  ATUALIZA_POSIC_CRRTR_DSTAQ IS

  BEGIN

     UPDATE POSIC_CRRTR_DSTAQ PCD
        SET PCD.QCUPOM_RETRD   = (PCD.QCUPOM_RETRD - 1),
            PCD.DALT_REG       = SYSDATE
      WHERE PCD.DAPURC_DSTAQ   = VAR_DAPURC_DSTAQ
        AND PCD.CCAMPA_DSTAQ   = PAR_CCAMPA_DSTAQ
        AND PCD.CTPO_PSSOA     = VAR_TIPO_PESSOA
        AND PCD.CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Erro no estorno do cupom - 200';
         RAISE VAR_FIM_PROCESSO_ERRO;
      WHEN OTHERS THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Erro no estorno do cupom - 201';

  END ATUALIZA_POSIC_CRRTR_DSTAQ;

  --
  -- ATUALIZA_NOVA_RETIRADA_CUPOM
  -- UPDATE NO REGISTRO DA TABELA ESTOQ_CUPOM_PROML_DSTAQ
  --
  PROCEDURE  ATUALIZA_ESTOQ_CUPOM IS

  BEGIN
     UPDATE ESTOQ_CUPOM_PROML_DSTAQ ECPD
        SET ECPD.CTPO_PSSOA          = null,
            ECPD.CCPF_CNPJ_BASE      = null,
            ECPD.CRGNAL              = 4201,
            ECPD.DALT_REG            = SYSDATE
      WHERE ECPD.CCAMPA_DSTAQ        = PAR_CCAMPA_DSTAQ
        AND ECPD.CCUPOM_PROML_DSTAQ  = PAR_CCUPOM_PROML_DSTAQ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
         ' não estornado para a campanha ' || PAR_CCAMPA_DSTAQ || '!!!';
         RAISE VAR_FIM_PROCESSO_ERRO;
      WHEN OTHERS THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Erro no estorno do cupom - 202';

  END ATUALIZA_ESTOQ_CUPOM;

--*****************************--------------------------------*****************************
--------------------------------- PROGRAMA PRINCIPAL ---------------------------------------
--*****************************--------------------------------*****************************
BEGIN

     -- PROCEDURE INTERNA: VERIFICA SE PARÂMETRO ESTÁ PREENCHIDO CORRETAMENTE
     --
     VERIFICA_PARM;
     IF VAR_ENCERRA = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
     -- PROCEDURE INTERNA: VERIFICA SE A CAMPANHA ESTÁ EM CONDIÇÕES DE PROCESSAMENTO
     --
     VERIFICA_CONDICOES;
     IF VAR_ENCERRA = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
     -- PROCEDURE INTERNA: VERIFICA POSSIBILIDADE DE ESTORNO:
     --
     VERIFICA_SE_CUPOM_RETIRADO;
     IF VAR_ENCERRA  = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
    -- PROCEDURE INTERNA: VERIFICA SE CUPOM FOI RETIRADO
    --
    VERIFICA_SE_CUPOM_RETIRADO;
    IF VAR_ENCERRA  = 1 THEN
      RAISE VAR_FIM_PROCESSO_ERRO;
    END IF;
    -- PROCEDURE INTERNA: ATUALIZA ESTORNO DA RASPADINHA TABLE OSIC_CRRTR_DSTAQ
    ATUALIZA_POSIC_CRRTR_DSTAQ;
    -- PROCEDURE INTERNA: ATUALIZA O REGISTRO DE ESTORNO DO CUPOM - TABLE ESTOQ_CUPOM_PROML_DSTAQ
    ATUALIZA_ESTOQ_CUPOM;

    PAR_COD_RETORNO  := 0;
    PAR_COD_MENSAGEM := 'Estorno efetuado com SUCESSO !!!';

    -- gravando no log
    BEGIN
      INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
             SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB6039', sysdate,
                                            'Estorno Raspadinha = ' || PAR_CCUPOM_PROML_DSTAQ ||
                                            ' da campanha = ' || PAR_CCAMPA_DSTAQ ||
                                            ' Pelo usuário ' || PAR_USUARIO
              FROM LOG_ERRO_IMPOR;
    EXCEPTION
     WHEN OTHERS THEN
            VAR_ENCERRA  := 1;
            PAR_COD_MENSAGEM := 'Erro ao gravar log !!! ';
            ROLLBACK;
            RAISE VAR_FIM_PROCESSO_ERRO;
    END;
    -- fim do log de usuário

    --
    --
    COMMIT;
    --
    --

    EXCEPTION
       WHEN VAR_FIM_PROCESSO_ERRO THEN
            PAR_COD_RETORNO  := 1;

END;
/

