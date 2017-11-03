CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6602
( PAR_TIPO_BLOQUEIO   IN VARCHAR          
, PAR_CTPO_PSSOA      IN VARCHAR          
, PAR_CCPF_CNPJ_BASE  IN NUMBER           
, PAR_CCAMPA_DSTAQ    IN NUMBER           
, PAR_CUSUARIO        IN VARCHAR2         
, PAR_CCODIGO         IN NUMBER           
, COD_RETORNO         OUT VARCHAR2        
, COD_MENSAGEM        OUT VARCHAR2        
) AS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB6602
--      DATA            : 19/03/2008
--      AUTOR           : THIAGO PELLEGRINO - JAPI INFORMÁTICA
--      OBJETIVO        : BLOQUEIO DE CORRETOR 
--                        CAMPANHA DESTAQUE DE PRODUÇÃO
--      ALTERAÇÕES      : 
--                DATA  :
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
VAR_CIND_CAMPA_ATIVO 	CHAR(1) := '';
VAR_ICAMPA_DSTAQ     	VARCHAR2(50) := '';
VAR_CTPO_PSSOA     	VARCHAR2(1 byte) := '';
--VAR_CCPF_CNPJ_BASE   	NUMBER(9) := 0;
VAR_VALIDA_CORRETOR     NUMBER(4) := 0;
VAR_VALIDA_BLOQUEIO     NUMBER(4) := 0;
VAR_TIPO_BLOQUEIO       VARCHAR2(11) := '';
   	
VAR_ROTINA		     VARCHAR2(10) := 'SGPB6602';
 
BEGIN

  BEGIN
  
    --
    --VALIDANDO CAMPOS DE ENTRADA
    IF PAR_TIPO_BLOQUEIO    IS NULL
    OR PAR_CTPO_PSSOA       IS NULL
    OR PAR_CCPF_CNPJ_BASE   IS NULL
    OR PAR_CCAMPA_DSTAQ     IS NULL
    OR PAR_CUSUARIO         IS NULL
    OR PAR_CCODIGO          IS NULL THEN
    
        COD_RETORNO  := '1';   
    END IF;

    IF COD_RETORNO = '1' THEN
       COD_MENSAGEM := 'Campos de entrada são obrigatórios.';
    ELSE
       COD_RETORNO := '0';
    END IF;
	
    IF PAR_CTPO_PSSOA = '1' THEN
       VAR_CTPO_PSSOA:= 'J';
    ELSE   
        VAR_CTPO_PSSOA:= 'F';
    END IF;    
    
    IF PAR_TIPO_BLOQUEIO = 'D' THEN
       VAR_TIPO_BLOQUEIO:= 'Desbloqueio';
    ELSE   
       VAR_TIPO_BLOQUEIO:= 'Bloqueio';
    END IF;  

   --
   --VALIDANDO SE O CORRETOR ESTÁ CADASTRADO NA TABELA CRRTR_UNFCA_CNPJ        
   SELECT COUNT(*) INTO VAR_VALIDA_CORRETOR
      FROM CRRTR_UNFCA_CNPJ
     WHERE CTPO_PSSOA = VAR_CTPO_PSSOA
     AND CCPF_CNPJ_BASE = PAR_CCPF_CNPJ_BASE;
  
   --
   --VALIDANDO SE O CORRETOR JÁ ESTÁ BLOQUEADO OU DESOLOQUEADO        
   SELECT COUNT(*) INTO VAR_VALIDA_BLOQUEIO
      FROM CAMPA_PARM_CARGA_DSTAQ
     WHERE (CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ)
      AND CPARM_CARGA_DSTAQ = PAR_CTPO_PSSOA
      AND CCONTD_PARM_CARGA = PAR_CCPF_CNPJ_BASE;                
     
    IF VAR_VALIDA_CORRETOR > 0 THEN   
   
    --
    --VALIDANDO SE A CAMPANHA ESTA ATIVA
    SELECT CIND_CAMPA_ATIVO ,ICAMPA_DSTAQ
      INTO VAR_CIND_CAMPA_ATIVO,VAR_ICAMPA_DSTAQ
      FROM CAMPA_DSTAQ
     WHERE CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ;
  
    --
    --CONDIÇÃO DA CAMPANHA
      IF VAR_CIND_CAMPA_ATIVO <> 'S' THEN
         COD_RETORNO := '1';
         COD_MENSAGEM := 'Campanha ' || VAR_ICAMPA_DSTAQ || ' já encerrada.';
		   
      ELSIF PAR_TIPO_BLOQUEIO = 'B' AND VAR_VALIDA_BLOQUEIO = 0 THEN 
    
    -- QUERY PARA BLOQUEAR O CORRETOR 
       INSERT INTO CAMPA_PARM_CARGA_DSTAQ(
            CCAMPA_DSTAQ,CPARM_CARGA_DSTAQ,CCONTD_PARM_CARGA,
            IROTNA_ATULZ_PARM_CARGA,DINCL_REG,DALT_REG)       
          VALUES(PAR_CCAMPA_DSTAQ,PAR_CCODIGO,PAR_CCPF_CNPJ_BASE,PAR_CUSUARIO,Sysdate,NULL); 
     COMMIT;
    
     COD_RETORNO := '1';    
     COD_MENSAGEM := 'Bloqueio realizado com sucesso.';    
     
     ELSIF PAR_TIPO_BLOQUEIO = 'D' AND VAR_VALIDA_BLOQUEIO >= 1 THEN   

    -- QUERY PARA DESBLOQUEAR O CORRETOR    
       DELETE FROM CAMPA_PARM_CARGA_DSTAQ
         WHERE (CCAMPA_DSTAQ = PAR_CCAMPA_DSTAQ)
           AND CPARM_CARGA_DSTAQ = PAR_CTPO_PSSOA
           AND CCONTD_PARM_CARGA = PAR_CCPF_CNPJ_BASE; 
           
      COMMIT;		
        
      --
      -- INSERI UM REGISTRO DE HISTÓRICO REFERENTE AO CORRETOR DESBLOQUEADO
      INSERT INTO LOG_ERRO_IMPOR(CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
             SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB6602', SYSDATE,
                    'Bloqueio CNPJ/CPF Destaque = ' || VAR_TIPO_BLOQUEIO  ||
                    ' da campanha = '               || VAR_ICAMPA_DSTAQ   ||
                    ' CNPJ_CPF_RAIZ = '             || PAR_CCPF_CNPJ_BASE ||
                    ' Pelo usuário '                || PAR_CUSUARIO 
               FROM LOG_ERRO_IMPOR;

     COMMIT;		
      
      COD_RETORNO := '1';    
      COD_MENSAGEM := 'Desbloqueio realizado com sucesso.';  
    
      ELSIF (PAR_TIPO_BLOQUEIO = 'C' AND VAR_VALIDA_BLOQUEIO = 0) OR VAR_VALIDA_BLOQUEIO = 0 THEN
      
      COD_RETORNO := '1';    
      COD_MENSAGEM := 'Corretor não está bloqueado.';  
    
      ELSIF (PAR_TIPO_BLOQUEIO = 'C' AND VAR_VALIDA_BLOQUEIO >= 1) OR VAR_VALIDA_BLOQUEIO >= 1 THEN
      
      COD_RETORNO := '1';    
      COD_MENSAGEM := 'Corretor está bloqueado.';  
    
      END IF;   
      
    ELSE 
         COD_RETORNO := '1';
         COD_MENSAGEM := 'Corretor não cadastrado.';
      
    END IF;
    
   EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-99972,'PL ERRO BLOQUEIO DE CORRETORES' || SUBSTR(SQLERRM,1,100));
           ROLLBACK;
           PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||SUBSTR(SQLERRM,1,500),'P',NULL,NULL);
           COMMIT;
   END;

END;
/

