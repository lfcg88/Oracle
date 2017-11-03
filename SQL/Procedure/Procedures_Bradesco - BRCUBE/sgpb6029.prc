CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6029
( PAR_CCAMPA_DSTAQ             IN  NUMBER,
  PAR_CCUPOM_PROML_DSTAQ       IN  NUMBER,
  PAR_CTPO_PSSOA               IN  VARCHAR2,
  PAR_CPF_CNPJ_BASE            IN  NUMBER,
  PAR_SUCURSAL                 IN  NUMBER,
  PAR_USUARIO                  IN  VARCHAR2,
  PAR_COD_RETORNO              OUT VARCHAR2,
  PAR_COD_MENSAGEM             OUT VARCHAR2
 ) IS
-------------------------------------------------------------------------------------------------
--      bradesco seguros s.a.
--      procedure       : SGPB0201R
--      data            : 11/07/06 14:39:18
--      autor           : MARCELO PITA / RALPH AGUIAR
--      objetivo        : BAIXA DAS RASPADINHAS RETIRADA PELOS CORRETORES
--      Explicações     : Atualmente esta sendo utilizada por aplicação Java
--      Alterações      : ALEXANDRE CYSNE ESTEVES 06/12/2007
--                        1º Retirada a validação para baixa só quando o corretor tiver produção
--                        2º Retirada a validação de limite de baixa para os corretores - produção
--                        3º Retirado update do qcupom_dispn = qcupom_dispn - 1
--
-------------------------------------------------------------------------------------------------

--***************  VARIAVEIS DE TRABALHO
VAR_PAR_CRGNAL               NUMBER(5)  :=0; -- VARIÁVEL DA PROCEDURE
VAR_ENCERRA                  NUMBER(1)  :=0; -- SE VAR_ENCERRA = 0 (OK), 1 (ERRO)
VAR_DINCL_REG                DATE;
VAR_DALTR_REG                DATE;
VAR_ICAMPA_DSTAQ             VARCHAR2(50);
VAR_DFIM_CAMPA_DSTAQ         DATE;
VAR_CIND_CAMPA_ATIVO         VARCHAR2(1);
VAR_DAPURC_DSTAD             DATE;
VAR_CCAMPA_DSTAQ             NUMBER(3);
VAR_QCUPOM_DISPN             NUMBER(6);
VAR_QCUPOM_RETRD             NUMBER(6);
VAR_VPROD_PEND               NUMBER(15,2);
VAR_FIM_PROCESSO_ERRO        EXCEPTION;
VAR_PAR_COD_ERRO             NUMBER(3);
VAR_PAR_DESC_ERRO            VARCHAR2(250);
VAR_PAR_SUCURSAL             NUMBER(3);
VAR_CRGNAL_ORIGINAL          NUMBER(5)  :=0;
VAR_TIPO_PESSOA              VARCHAR2(1);
VAR_CCPF_CNPJ_BASE           NUMBER(15);
VAR_TESTE_QTD                NUMBER(6);

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
    ELSIF PAR_CTPO_PSSOA IS NULL THEN
        VAR_ENCERRA  := 1;
    ELSIF PAR_CPF_CNPJ_BASE IS NULL THEN
        VAR_ENCERRA  := 1;
    ELSIF PAR_SUCURSAL IS NULL THEN
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
  --

  --
  -- VERIFICA_CONDICOES
  -- VERIFICA SE CAMPANHA ESTÁ EM CONDIÇÃO DE PROCESSAMENTO
  --
  PROCEDURE VERIFICA_CONDICOES IS
  
  BEGIN
     BEGIN
     SELECT T1.ICAMPA_DSTAQ,
            T1.DFIM_CAMPA_DSTAQ,
            T1.CIND_CAMPA_ATIVO,
            T1.CCAMPA_DSTAQ
     INTO   VAR_ICAMPA_DSTAQ,
            VAR_DFIM_CAMPA_DSTAQ,
            VAR_CIND_CAMPA_ATIVO,
            VAR_CCAMPA_DSTAQ
     FROM   CAMPA_DSTAQ T1
     WHERE  T1.CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Código da Campanha informado '|| VAR_CCAMPA_DSTAQ ||
         ' não existe.'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
     END;
  
     --VERIFICA RETORNO DA CONDICAO DE PROCESSAMENTO
  
      IF VAR_CIND_CAMPA_ATIVO <> 'S' THEN
         VAR_ENCERRA := 1;
         PAR_COD_MENSAGEM := 'Campanha '|| VAR_ICAMPA_DSTAQ ||
         ' não está ATIVA! Favor reativar a campanha para efetuar as retiradas.' ;
      END IF;
  
      IF VAR_DFIM_CAMPA_DSTAQ is not null THEN
         VAR_ENCERRA := 2;
      END IF;
  
  END VERIFICA_CONDICOES;

  --
  -- VERIFICA_SALDO_DE_RETIRADA
  -- VERIFICA SE O CORRETOR POSSUI SALDO A RETIRAR
  --
  PROCEDURE VERIFICA_SALDO_DE_RETIRADA IS
  
  BEGIN
  
     SELECT MAX(TRUNC(T2.DAPURC_DSTAQ))
     INTO   VAR_DAPURC_DSTAD
     FROM   POSIC_CRRTR_DSTAQ T2
     WHERE  T2.CCAMPA_DSTAQ   = PAR_CCAMPA_DSTAQ
     AND    T2.CTPO_PSSOA     = PAR_CTPO_PSSOA
     AND    T2.CCPF_CNPJ_BASE = PAR_CPF_CNPJ_BASE ;
  
     -- VERIFICA SE EXISTE DADO  
     IF  VAR_DAPURC_DSTAD IS NULL THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Não existe apuração para o corretor '|| PAR_CPF_CNPJ_BASE ||
         ' na campanha ' || VAR_ICAMPA_DSTAQ;
         RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
  
     -- LER TABELA PARA VERIFICAR CONDIÇÕES DE RETIRADA  
     SELECT T3.QCUPOM_DISPN, T3.VPROD_PEND, T3.QCUPOM_RETRD
     INTO   VAR_QCUPOM_DISPN, VAR_VPROD_PEND, VAR_QCUPOM_RETRD
     FROM   POSIC_CRRTR_DSTAQ T3
     WHERE  T3.DAPURC_DSTAQ   = VAR_DAPURC_DSTAD
     AND    T3.CCAMPA_DSTAQ   = PAR_CCAMPA_DSTAQ
     AND    T3.CTPO_PSSOA     = PAR_CTPO_PSSOA
     AND    T3.CCPF_CNPJ_BASE = PAR_CPF_CNPJ_BASE;
  
     -- VERIFICA SE VPROD_PEND É MENOR OU IGUAL A 0 (ZERO)
     --acysne
     --IF  VAR_VPROD_PEND <= 0 THEN
     --    PAR_COD_RETORNO  := 1;
     --    PAR_COD_MENSAGEM := 'Corretor '|| PAR_CPF_CNPJ_BASE ||
     --    ' possui produção em débito, decorrente de cancelamentos apropriados em sua produção => ' ||
     --     VAR_VPROD_PEND || '. Não é possível efetuar retiradas !!!';
     --     RAISE VAR_FIM_PROCESSO_ERRO;
     --END IF;

     -- VERIFICA SE QCUPOM_DISPN É MENOR OU IGUAL A 0 (ZERO)  
     VAR_TESTE_QTD := VAR_QCUPOM_DISPN; -- - VAR_QCUPOM_RETRD;
     --DBMS_OUTPUT.PUT_LINE('VAR_TESTE_QTD ==> '||VAR_TESTE_QTD);
     --acysne
     --IF  VAR_TESTE_QTD <= 0 THEN
     --    PAR_COD_RETORNO  := 1;
     --    PAR_COD_MENSAGEM := 'Corretor '|| PAR_CPF_CNPJ_BASE ||
     --    ' não possui cupom a retirar !!!';
     --    RAISE VAR_FIM_PROCESSO_ERRO;
     --END IF;

  END VERIFICA_SALDO_DE_RETIRADA;

  --
  -- VERIFICA_SE_CUPOM_RETIRADO
  -- VERIFICA SE O CORRETOR JA FOI RETIRADO
  --
  PROCEDURE VERIFICA_SE_CUPOM_RETIRADO IS
  
  BEGIN  
    BEGIN
     SELECT T4.CTPO_PSSOA,
            T4.CCPF_CNPJ_BASE,
            T4.CRGNAL,
            T4.DINCL_REG,
            T4.DALT_REG
     INTO   VAR_TIPO_PESSOA,
            VAR_CCPF_CNPJ_BASE,
            VAR_CRGNAL_ORIGINAL,
            VAR_DINCL_REG,
            VAR_DALTR_REG
     FROM   ESTOQ_CUPOM_PROML_DSTAQ T4
     WHERE  T4.CCAMPA_DSTAQ        = PAR_CCAMPA_DSTAQ
     AND    T4.CCUPOM_PROML_DSTAQ  = PAR_CCUPOM_PROML_DSTAQ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
         ' não ofertado para a campanha ' || VAR_ICAMPA_DSTAQ || '!!!'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
    END ;
  
       IF   VAR_TIPO_PESSOA IS not NULL
       AND VAR_CCPF_CNPJ_BASE IS not NULL THEN
           VAR_ENCERRA  := 1;
           PAR_COD_MENSAGEM := 'Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
           ' já retirado para a campanha ' || VAR_ICAMPA_DSTAQ || '!!! Para o corretor ' ||
           --VAR_CCPF_CNPJ_BASE || ' em ' || VAR_DALTR_REG;
           VAR_CCPF_CNPJ_BASE || ' em ' || to_char(VAR_DALTR_REG,'dd/MM/yyyy');
           RAISE VAR_FIM_PROCESSO_ERRO;
        END IF;
  --TO_CHAR((TO_DATE(VAR_DALTR_REG)),'DD/MM/YYYY')  
  END VERIFICA_SE_CUPOM_RETIRADO;

  --
  -- ATUALIZA_RETIRADA_RASPADINHA
  -- ATUALIZA RETIRADA DA RASPADINHA NA TABELA ESTOQ_CUPOM_PROML_DSTAQ
  --
  PROCEDURE  ATUALIZA_RETIRADA_RASPADINHA IS
  
  BEGIN
  
     UPDATE POSIC_CRRTR_DSTAQ T5
     --acysne
     SET    --T5.QCUPOM_DISPN = (T5.QCUPOM_DISPN - 1),
            T5.QCUPOM_RETRD = (T5.QCUPOM_RETRD + 1),
            T5.DALT_REG     = SYSDATE
     WHERE  T5.DAPURC_DSTAQ   = VAR_DAPURC_DSTAD
     AND    T5.CCAMPA_DSTAQ   = PAR_CCAMPA_DSTAQ
     AND    T5.CTPO_PSSOA     = PAR_CTPO_PSSOA
     AND    T5.CCPF_CNPJ_BASE = PAR_CPF_CNPJ_BASE;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
         ' não encontrado para a campanha ' || VAR_ICAMPA_DSTAQ || '!!!'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
      WHEN OTHERS THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Erro na BAIXA da RASPADINHA';
  
  END ATUALIZA_RETIRADA_RASPADINHA;

  --
  -- ATUALIZA_NOVA_RETIRADA_CUPOM
  -- UPDATE NO REGISTRO DA TABELA ESTOQ_CUPOM_PROML_DSTAQ
  --
  PROCEDURE  ATUALIZA_NOVA_RETIRADA_CUPOM IS
  
  BEGIN  
     UPDATE ESTOQ_CUPOM_PROML_DSTAQ T6
         SET T6.CTPO_PSSOA          = PAR_CTPO_PSSOA,
             T6.CCPF_CNPJ_BASE      = PAR_CPF_CNPJ_BASE,
             T6.CRGNAL              = VAR_PAR_CRGNAL,
             T6.DALT_REG            = SYSDATE
     WHERE   T6.CCAMPA_DSTAQ        = PAR_CCAMPA_DSTAQ
       AND   T6.CCUPOM_PROML_DSTAQ = PAR_CCUPOM_PROML_DSTAQ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Corretor '|| PAR_CPF_CNPJ_BASE ||
         ' não baixado para a campanha ' || VAR_ICAMPA_DSTAQ || '!!!'  ;
         RAISE VAR_FIM_PROCESSO_ERRO;
      WHEN OTHERS THEN
         VAR_ENCERRA  := 1;
         PAR_COD_MENSAGEM := 'Erro na BAIXA do ESTOQUE RASPADINHA';
  
  END ATUALIZA_NOVA_RETIRADA_CUPOM;

--*****************************--------------------------------*****************************
--------------------------------- PROGRAMA PRINCIPAL ---------------------------------------
--*****************************--------------------------------*****************************
BEGIN

     -- PROCEDURE INTERNA: VERIFICA SE PARÂMETRO ESTÁ PREENCHIDO CORRETAMENTE
     VERIFICA_PARM;
     --
     IF VAR_ENCERRA = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
     -- PROCEDURE INTERNA: VERIFICA SE A CAMPANHA ESTÁ EM CONDIÇÕES DE PROCESSAMENTO
     VERIFICA_CONDICOES;
     --
     IF VAR_ENCERRA = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
     -- PROCEDURE INTERNA: VERIFICA POSSIBILIDADE DE RETIDADA: AVALIA SE O CORRETOR POSSUI SALDO A RETIRAR
     VERIFICA_SALDO_DE_RETIRADA;
     --
     IF VAR_ENCERRA  = 1 THEN
        RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;
     -- CHAMADA À PROCEDURE QUE RETORNA PARAMETRO
     VAR_PAR_SUCURSAL := PAR_SUCURSAL;
     --
     SGPB6220 ( VAR_PAR_SUCURSAL,VAR_PAR_CRGNAL,VAR_PAR_COD_ERRO,VAR_PAR_DESC_ERRO);
     IF  VAR_PAR_COD_ERRO <> 0 THEN
       VAR_ENCERRA  := 1;
       PAR_COD_MENSAGEM := 'A Sucursal do usuário não possui código de regional válido';
       RAISE VAR_FIM_PROCESSO_ERRO;
     END IF;

    --PROCEDIMENTO TEMPORARIO PARA GARANTIR AS REGIONAIS CORRETAS NA BASE DE DADOS
    --IF VAR_PAR_CRGNAL NOT IN(7106,7103,4103,2101,7201,2102,7202,4106,4105,1103,2108,1105,4201,4202,1201,8100) THEN
    --  VAR_ENCERRA  := 1;
    --  PAR_COD_MENSAGEM := 'A Sucursal do usuário não possui código de regional válido para campanha';
    --  RAISE VAR_FIM_PROCESSO_ERRO;
    --END IF;
    --FIM PROCEDIMENTO

    -- PROCEDURE INTERNA: VERIFICA SE CUPOM FOI RETIRADO
    VERIFICA_SE_CUPOM_RETIRADO;
    --
    IF VAR_ENCERRA  = 1 THEN
      RAISE VAR_FIM_PROCESSO_ERRO;
    END IF;
    -- PROCEDURE INTERNA: ATUALIZA RETIRADA DA RASPADINHA
    ATUALIZA_RETIRADA_RASPADINHA;
    -- PROCEDURE INTERNA: ATUALIZA O REGISTRO DE RETIRADA DO CUPOM
    ATUALIZA_NOVA_RETIRADA_CUPOM;

    PAR_COD_RETORNO  := 0;
    PAR_COD_MENSAGEM := 'Atualização do cupom efetuada com SUCESSO !!!';

    IF VAR_CRGNAL_ORIGINAL <> VAR_PAR_CRGNAL THEN
       PAR_COD_MENSAGEM := 'Operação realizada com SUCESSO !!!' ||
       ' Cupom '|| PAR_CCUPOM_PROML_DSTAQ ||
       ' da campanha ' || VAR_ICAMPA_DSTAQ || ', inicialmente foi ofertado a regional ' ||
       VAR_CRGNAL_ORIGINAL || ' em ' || TO_CHAR(TO_DATE(VAR_DINCL_REG,'DD/MM/YYYY'));
    ELSE
      IF VAR_ENCERRA = 2 THEN
       PAR_COD_MENSAGEM := 'Operação realizada com SUCESSO !!!' ||
       ' Campanha '|| VAR_ICAMPA_DSTAQ ||' já encerrada.' ;
      END IF;
    END IF;
    --- log do usuario rever
    --
    BEGIN
      INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
             SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB6029', sysdate,
                                            'Alter.a Raspadinha = ' || PAR_CCUPOM_PROML_DSTAQ ||
                                            ' da campanha = ' || PAR_CCAMPA_DSTAQ ||
                                            ' Pelo usuário ' || PAR_USUARIO ||
                                            ' sucursal ' || PAR_SUCURSAL ||
                                            ' regional ' || VAR_PAR_CRGNAL
               from LOG_ERRO_IMPOR;
    EXCEPTION
     WHEN OTHERS THEN
            VAR_ENCERRA  := 1;
            PAR_COD_MENSAGEM := 'Erro ao gravar log !!! ';
            ROLLBACK;
            RAISE VAR_FIM_PROCESSO_ERRO;
    END;
    -- fim do log de usuário

  COMMIT;

 EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        PAR_COD_RETORNO  := 1;

END;
/

