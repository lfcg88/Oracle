CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9991
IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9991
  --      DATA            : 24/05/2007
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        : Corrigir Corretores Desmembrados (apenas faixa 800, alguns casos, DWAT)
  --      ALTERAÇÕES      :
  -------------------------------------------------------------------------------------------------
  VAR_ARQUIVO         			utl_file.file_type;
  VAR_REGISTRO_ARQUIVO 			VARCHAR2(1000);
  VAR_COUNT            			INTEGER := 1;
  VAR_LOG_ERRO 					VARCHAR2(2000);
  VAR_CROTNA 					CONSTANT CHAR(8) := 'SGPB9991';
  VAR_IROTNA 					CONSTANT INT := 722;
  ABRE_ARQUIVO_EXCEPTION 		EXCEPTION;
  ERRO_NA_LEITURA				EXCEPTION;
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100) := '/x0205/P002/dwscheduler/scripts'; 
  VAR_IARQ_TRAB              	varchar2(100) := 'SGPB_AJUSTE_DWAT.dat';
  VAR_CAMBTE                 	varchar2(100);
  VAR_COMPT                     number(6);
  --
  -- Lendo Detalhe
  --
  PROCEDURE DETALHE(VAR_REGISTRO_ARQUIVO VAR_REGISTRO_ARQUIVO%TYPE) IS
    V_CUND_PROD        number;
    V_CCRRTR_ORIGN     number;
    V_CRRTR_APOLC      number;
    V_CCRRTR_DSMEM     number; 
    V_CIA              number;
    V_RAMO             number;
    V_APOLC			   number;
    VAR_DEMISSAO_APOLC DATE;
    VAR_DEMISSAO_C     CHAR(10);
    VAR_POSICAO_LINHA  NUMBER;
    VAR_POSICAO_AUX    NUMBER;
    V_VALOR_PREMIO     NUMBER;
    V_MINIMO_ITEM      NUMBER;
    SPONTO             VARCHAR2(10) := '#XXXX';
  BEGIN  
    -- Corretor    
    SPONTO := '#0001';
    VAR_POSICAO_AUX   := 0;
    VAR_POSICAO_LINHA := 0;  
    SELECT INSTR(VAR_REGISTRO_ARQUIVO,';',1,1) INTO VAR_POSICAO_LINHA FROM DUAL;
    V_CCRRTR_ORIGN := SUBSTR(VAR_REGISTRO_ARQUIVO,1,VAR_POSICAO_LINHA-1);    
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA+1;
    
    --Código do Unidade de Producao
    SPONTO := '#0002';
    SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,1000),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
    V_CUND_PROD := SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,VAR_POSICAO_AUX-1); 
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX+1;      
    
    -- cia seguradora
    SPONTO := '#0003';
    SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,1000),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
    V_CIA := SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA-1,VAR_POSICAO_AUX); 
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX+1;
        
    -- ramo
    SPONTO := '#0004A';
    SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,100),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
    V_RAMO := SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA-1,VAR_POSICAO_AUX); 
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX+1;
    
    -- apolice
    SPONTO := '#0004B';
    SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,100),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
    V_APOLC := SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA-1,VAR_POSICAO_AUX); 
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX+1;
      
    -- Data em que ocorreu a emissao da APOLICE
    BEGIN
        SPONTO := '#0005';
        SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,100),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
        VAR_DEMISSAO_C := SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA-1,10);
        VAR_DEMISSAO_APOLC := TO_DATE(VAR_DEMISSAO_C,'YYYYMMDD');
        VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX + 1;
    EXCEPTION
        WHEN OTHERS THEN
             VAR_LOG_ERRO := 'ERRO NA CONVERSAO DA DATA DE EMISSAO DA APOLICE PARA DATA DE ENTRADA. LINHA: '||VAR_COUNT||
                             ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                             ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||' V_CIA: '||V_CIA||
                             ' V_APOLC: '||V_APOLC||' V_RAMO: '||V_RAMO||' ERRO: '||SUBSTR(SQLERRM,1,200);
             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
             PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
             COMMIT;      
             Raise_Application_Error(-20008,VAR_LOG_ERRO); 
    END;
    SPONTO := '#0006';
    -- valor da apolice
    SELECT INSTR(substr(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA,1000),';',1,1) INTO VAR_POSICAO_AUX FROM DUAL;
    V_VALOR_PREMIO := to_number(SUBSTR(VAR_REGISTRO_ARQUIVO,VAR_POSICAO_LINHA-1,VAR_POSICAO_AUX)); 
    VAR_POSICAO_LINHA := VAR_POSICAO_LINHA + VAR_POSICAO_AUX+1;
    
    SPONTO := '#0007';
    -- Pegando o Código do corretor desmembrado com os dados do corretor (Corretor, Sucursal e a data de emissão da apolice)
    BEGIN
        SELECT CCRRTR_DSMEM INTO V_CCRRTR_DSMEM FROM MPMTO_AG_CRRTR MAC 
               WHERE CCRRTR_ORIGN = V_CCRRTR_ORIGN AND
                     CUND_PROD    = V_CUND_PROD    AND
                     VAR_DEMISSAO_APOLC >= DENTRD_CRRTR_AG AND
                     VAR_DEMISSAO_APOLC < NVL(DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'));
                     
    EXCEPTION            
        WHEN TOO_MANY_ROWS THEN
             VAR_LOG_ERRO := 'CORRETOR EM DUPLICIDADE NO DESMEMBRAMENTO (O PROCESSAMENTO VAI CONTINUAR). LINHA: '||VAR_COUNT||
                             ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                             ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||' V_CIA: '||V_CIA||
                             ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||' V_RAMO: '||V_RAMO;
             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
             PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
             COMMIT;      
             -- Raise_Application_Error(-20008,VAR_LOG_ERRO);
             RETURN;
        WHEN NO_DATA_FOUND THEN
             VAR_LOG_ERRO := 'CORRETOR NAO ENCONTRADO NO DESMEMBRAMENTO (O PROCESSAMENTO VAI CONTINUAR). LINHA: '||VAR_COUNT||
                             ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                             ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||' V_CIA: '||V_CIA||
                             ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||' V_RAMO: '||V_RAMO;
             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
             PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
             COMMIT;      
             --Raise_Application_Error(-20008,VAR_LOG_ERRO); 
             RETURN;
        WHEN OTHERS THEN
             VAR_LOG_ERRO := 'ERRO NO ACESSO AO DESMEMBRAMENTO. LINHA: '||VAR_COUNT||
                             ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                             ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||' V_CIA: '||V_CIA||
                             ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||' V_RAMO: '||V_RAMO||
                             ' ERRO: '||SUBSTR(SQLERRM,1,200);
             PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
             PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
             COMMIT;      
             Raise_Application_Error(-20008,VAR_LOG_ERRO); 
 	end;
 	SPONTO := '#0008';
 	-- vai agora na tabela de apolices ver se o corretor está correto
 	BEGIN
 	   SELECT CCRRTR, min(CITEM_APOLC) into V_CRRTR_APOLC, V_MINIMO_ITEM from APOLC_PROD_CRRTR 
 	   			where cund_prod         = V_CUND_PROD               and
 	   			      ccia_segdr        = V_CIA                     and
 	   			      capolc            = V_APOLC                   and
 	   			      CRAMO_APOLC       = V_RAMO                    and
 	   			      CRAMO_APOLC       in (120,460,519)            and
 	   			      trunc(demis_apolc)= trunc(VAR_DEMISSAO_APOLC)
 	   			      GROUP BY CCRRTR;
 	END;
 	-- vai verificar se o corretor desmembrado está correto
    if V_CCRRTR_DSMEM <> V_CRRTR_APOLC then
       VAR_LOG_ERRO := '*** APOLICE COM CORRETOR DESMEMBRADO COM DIFERENÇAS VAI FAZER UPDATE, LINHA: '||VAR_COUNT||
                     ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||' V_CRRTR_APOLC: '||V_CRRTR_APOLC||
                     ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||
                     ' V_CIA: '||V_CIA||' V_RAMO: '||V_RAMO||
                     ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO;
                     PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
                     BEGIN
                         UPDATE APOLC_PROD_CRRTR SET
                                CCRRTR = V_CCRRTR_DSMEM 
                         		where 	cund_prod         = V_CUND_PROD               and
 	   			      					ccia_segdr        = V_CIA                     and
 	   			      					capolc            = V_APOLC                   and
 	   			      					CRAMO_APOLC       = V_RAMO                    and
 	   			      					CRAMO_APOLC       in (120, 460, 519)          and
 	   			      					CCRRTR            = V_CRRTR_APOLC             and
 	   			      					trunc(demis_apolc)= trunc(VAR_DEMISSAO_APOLC);
                     EXCEPTION
                       when others then
                         VAR_LOG_ERRO := 'ERRO NO UPDATE DA APOLICE, ESTAVA TROCANDO O CORRETOR. LINHA: '||VAR_COUNT||
                                         ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                                         ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||
                                         ' V_CIA: '||V_CIA||
                                         ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||' V_RAMO: '||V_RAMO||
                                         ' ERRO: '||SUBSTR(SQLERRM,1,200);
                                         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
                                         COMMIT;
                     END;
      COMMIT;
    end if;   
 EXCEPTION
 	WHEN NO_DATA_FOUND THEN
 	     VAR_LOG_ERRO := 'APOLICE NÃO ENCONTRADA NO SGPB. LINHA: '||VAR_COUNT||
                    ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                    ' V_CUND_PROD: '||V_CUND_PROD||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||
                    ' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||' V_CIA: '||V_CIA||' V_RAMO: '||V_RAMO||
                    ' V_APOLC: '||V_APOLC;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
         COMMIT;    
    WHEN OTHERS THEN
         VAR_LOG_ERRO := 'ERRO EXCEPTION, SPONTO : '||SPONTO||' LINHA: '||VAR_COUNT||
                      ' V_CCRRTR_ORIGN: '||V_CCRRTR_ORIGN||
                      ' V_CUND_PROD: '||V_CUND_PROD||' V_EMISSAO_APOLC:'||VAR_DEMISSAO_C||
                      ' V_CIA: '||V_CIA||
                      ' V_APOLC: '||V_APOLC||' V_VALOR_PREMIO: '||V_VALOR_PREMIO||' V_RAMO: '||V_RAMO||
                      ' ERRO: '||SUBSTR(SQLERRM,1,200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,'P',NULL,NULL);
         COMMIT;
         Raise_Application_Error(-20008,VAR_LOG_ERRO);
    -- O IF ESTAVA AQUI.. AQUI ELE NÃO SERIA EXECUTADO.
    --
END DETALHE;
  --
BEGIN

   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA);
   
   -- Iniciando o Processamento
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PC);
   
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,'DIRETORIO: '||VAR_IDTRIO_TRAB||' ARQUIVO: '||VAR_IARQ_TRAB,'P',NULL,NULL);
   COMMIT;
   
   -- Abrindo o Arquivo
   BEGIN
           VAR_ARQUIVO := UTL_FILE.FOPEN('/x0205/P002/dwscheduler/scripts','SGPB_AJUSTE_DWAT.dat','R');            
           VAR_LOG_ERRO := 'O ARQUIVO FOI ABERTO VAI INICIAR A LEITURA.';
           PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);  
           COMMIT;
   EXCEPTION
           WHEN OTHERS THEN 
                VAR_LOG_ERRO := 'PROBLEMA NO OPEN DO ARQUIVO -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,200);
                PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
                PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
                COMMIT;      
                Raise_Application_Error(-20008,VAR_LOG_ERRO); 
   END;
   VAR_COUNT := 0;
   -- Varrendo os registros dos arquivos
   BEGIN
       LOOP
          BEGIN
                  UTL_FILE.GET_LINE(VAR_ARQUIVO,VAR_REGISTRO_ARQUIVO);
                  VAR_COUNT := VAR_COUNT + 1;
                  DETALHE(VAR_REGISTRO_ARQUIVO);
          EXCEPTION
                  WHEN OTHERS THEN RAISE;
          END;
       END LOOP;
   END;
   VAR_LOG_ERRO := 'TERMINO DO AJUSTE EM DETERMINADOS CORRETORES DESMEMBRADOS -- REGISTROS PROCESSADOS: '||VAR_COUNT;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
   COMMIT;  
  EXCEPTION
    WHEN ABRE_ARQUIVO_EXCEPTION THEN
         VAR_LOG_ERRO := 'PROBLEMA NA ABERTURA DO ARQUIVO - DIR: '||VAR_IDTRIO_TRAB||
                         ' - ARQ: '||VAR_IARQ_TRAB||' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
         COMMIT;      
         Raise_Application_Error(-20008,VAR_LOG_ERRO);
     WHEN ERRO_NA_LEITURA THEN
         VAR_LOG_ERRO := 'PROBLEMA NA LEITURA DO ARQUIVO - DIR: '||VAR_IDTRIO_TRAB||
                         ' - ARQ: '||VAR_IARQ_TRAB||' -- LINHA: ' ||VAR_COUNT||' REGISTRO: '||VAR_REGISTRO_ARQUIVO||
                         ' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);
         COMMIT;      
         Raise_Application_Error(-20008,VAR_LOG_ERRO);              
    WHEN NO_DATA_FOUND THEN
         UTL_FILE.FCLOSE(VAR_ARQUIVO);
         VAR_LOG_ERRO := 'TERMINO DO AJUSTE EM DETERMINADOS CORRETORES DESMEMBRADOS.' ||
                         ' -- REGISTROS PROCESSADOS: '||VAR_COUNT;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PO);
         COMMIT;  
         Raise_Application_Error(-20005,VAR_LOG_ERRO);
    WHEN OTHERS THEN
         ROLLBACK;
         UTL_FILE.FCLOSE(VAR_ARQUIVO);
         VAR_LOG_ERRO := 'PROBLEMA AO CARREGAR OS REGISTROS DE PRODUÇÃO.'||
                      ' -- LINHA: ' ||VAR_COUNT||' -- ERRO ORACLE: '||SUBSTR(SQLERRM,1,200);
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,VAR_LOG_ERRO,PC_UTIL_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA,VAR_IROTNA,PC_UTIL_01.VAR_ROTNA_PE);COMMIT;      
         Raise_Application_Error(-20009,VAR_LOG_ERRO);
END SGPB9991;
/

