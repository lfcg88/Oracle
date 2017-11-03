CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6211RAL
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
  --                        
   -------------------------------------------------------------------------------------------------
                                         

--***************  VARIAVEIS DE TRABALHO 

VAR_PAR_CRGNAL                    NUMBER(5)  :=0; -- VARIÁVEL DA PROCEDURE

VAR_ENCERRA                       NUMBER(1)  :=0; -- SE VAR_ENCERRA = 0 (OK), 1 (ERRO)
VAR_DINCL_REG                     DATE;
VAR_ICAMPA_DSTAQ                  VARCHAR2(50);
VAR_DFIM_CAMPA_DSTAQ              DATE;
VAR_CIND_CAMPA_ATIVO              VARCHAR2(1);
VAR_DAPURC_DSTAD                  DATE;                     
VAR_CCAMPA_DSTAQ                  NUMBER(3);
VAR_QCUPOM_DISPN                  NUMBER(6);
VAR_QCUPOM_RETRD                  NUMBER(6);
VAR_VPROD_PEND                    NUMBER(15,2);
VAR_CAMPANHA                      NUMBER := 1;
VAR_FIM_PROCESSO_ERRO             EXCEPTION;
VAR_PAR_COD_ERRO                  NUMBER(3);
VAR_PAR_DESC_ERRO                 VARCHAR2(250);
VAR_PAR_SUCURSAL                  NUMBER(3);
VAR_CRGNAL_ORIGINAL               NUMBER(5)  :=0;  
VAR_TIPO_PESSOA                   VARCHAR2(1);
VAR_CCPF_CNPJ_BASE                NUMBER(15);
VAR_TESTE_QTD                     NUMBER(6);

--***************  VERIFICA SE PARÂMETROS DE ENTRADA SÃO VÁLIDOS

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

-- VERIFICA SE CAMPANHA ESTÁ EM CONDIÇÃO DE PROCESSAMENTO
 
PROCEDURE VERIFICA_CONDICOES IS

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
   WHERE  T1.CCAMPA_DSTAQ = VAR_CAMPANHA ; 

    IF VAR_ICAMPA_DSTAQ IS NULL THEN
       VAR_ENCERRA := 1;
       RAISE VAR_FIM_PROCESSO_ERRO;
    END IF;
    
--  VERIFICA RETORNO DA CONDICAO DE PROCESSAMENTO  

    IF VAR_CIND_CAMPA_ATIVO <> 'S' THEN 
       VAR_ENCERRA := 1;
       PAR_COD_MENSAGEM := 'Campanha '|| VAR_ICAMPA_DSTAQ ||
       ' não está ATIVA! Favor reativar a campanha para efetuar as retiradas.' ; 
    end if;

    IF VAR_DFIM_CAMPA_DSTAQ is not null THEN 
       VAR_ENCERRA := 2;
    END IF;   
           
END VERIFICA_CONDICOES; 

-- VERIFICA SE O CORRETOR POSSUI SALDO A RETIRAR

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

   IF  VAR_VPROD_PEND <= 0 THEN
       PAR_COD_RETORNO  := 1;                       
       PAR_COD_MENSAGEM := 'Corretor '|| PAR_CPF_CNPJ_BASE ||
       ' possui produção em débito, decorrente de cancelamentos apropriados em sua produção => ' ||
        VAR_VPROD_PEND || '. Não é possível efetuar retiradas !!!';
        RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

-- VERIFICA SE QCUPOM_DISPN É MENOR OU IGUAL A 0 (ZERO)
   
   VAR_TESTE_QTD := VAR_QCUPOM_DISPN - VAR_QCUPOM_RETRD;   
   
   IF  VAR_TESTE_QTD <= 0 THEN
       PAR_COD_RETORNO  := 1;                    
       PAR_COD_MENSAGEM := 'Corretor '|| PAR_CPF_CNPJ_BASE ||
       ' não possui cupom a retirar !!!';
   END IF;
      
END VERIFICA_SALDO_DE_RETIRADA;

PROCEDURE VERIFICA_SE_CUPOM_RETIRADO IS

BEGIN

  BEGIN
   SELECT T4.CTPO_PSSOA,
          T4.CCPF_CNPJ_BASE,
          T4.CRGNAL,   
          T4.DINCL_REG
   INTO   VAR_TIPO_PESSOA,
          VAR_CCPF_CNPJ_BASE,
          VAR_CRGNAL_ORIGINAL,
          VAR_DINCL_REG
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
         VAR_CCPF_CNPJ_BASE || ' em ' || VAR_DINCL_REG;
         RAISE VAR_FIM_PROCESSO_ERRO;
      END IF;

       
END VERIFICA_SE_CUPOM_RETIRADO;

-- ATUALIZA RETIRADA DA RASPADINHA NA TABELA ESTOQ_CUPOM_PROML_DSTAQ

PROCEDURE  ATUALIZA_RETIRADA_RASPADINHA IS

BEGIN
     
   UPDATE POSIC_CRRTR_DSTAQ T5
   SET    T5.QCUPOM_DISPN = (T5.QCUPOM_DISPN - 1),
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

-- UPDATE NO REGISTRO DA TABELA ESTOQ_CUPOM_PROML_DSTAQ

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
                               
/* ****************************--------------------------------************************************* */
                                 -- PROGRAMA PRINCIPAL --
/* ****************************--------------------------------************************************* */
                                   
BEGIN

-- PROCEDURE INTERNA: VERIFICA SE PARÂMETRO ESTÁ PREENCHIDO CORRETAMENTE
   
   VERIFICA_PARM;  	
   
   IF VAR_ENCERRA = 1 THEN
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;
    
-- PROCEDURE INTERNA: VERIFICA SE A CAMPANHA ESTÁ EM CONDIÇÕES DE PROCESSAMENTO

   VERIFICA_CONDICOES;

   IF VAR_ENCERRA = 1 THEN
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

-- PROCEDURE INTERNA: VERIFICA POSSIBILIDADE DE RETIDADA: AVALIA SE O CORRETOR POSSUI SALDO A RETIRAR

   VERIFICA_SALDO_DE_RETIRADA;
   
   IF VAR_ENCERRA  = 1 THEN
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;

-- CHAMADA À PROCEDURE QUE RETORNA PARAMETRO 

  VAR_PAR_SUCURSAL := PAR_SUCURSAL;
  
  PR_RET_RGNAL_DSTAQ ( VAR_PAR_SUCURSAL,
                       VAR_PAR_CRGNAL,
                       VAR_PAR_COD_ERRO,
                       VAR_PAR_DESC_ERRO);  
       IF  VAR_PAR_COD_ERRO <> 0 THEN                                
           VAR_ENCERRA  := 1;
           PAR_COD_MENSAGEM := 'A Sucursal do usuário não possui código de regional válido';
          RAISE VAR_FIM_PROCESSO_ERRO; 
      END IF;      

-- PROCEDURE INTERNA: VERIFICA SE CUPOM FOI RETIRADO

   VERIFICA_SE_CUPOM_RETIRADO;

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
         VAR_CRGNAL_ORIGINAL || ' em ' || VAR_DINCL_REG;
         commit;
         return;
      END IF;

      IF VAR_ENCERRA = 2 THEN
         PAR_COD_MENSAGEM := 'Operação realizada com SUCESSO !!!' ||
         ' Campanha '|| VAR_ICAMPA_DSTAQ ||' já encerrada.' ;  
      END IF;               

  COMMIT;
  
 EXCEPTION
   WHEN VAR_FIM_PROCESSO_ERRO THEN
        PAR_COD_RETORNO  := 1;                                               
                         
END;
/

