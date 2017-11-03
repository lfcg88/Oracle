create or replace procedure sgpb_proc.SGPB6012_OLD is
------------------------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                                                           
--  DATA            : 11/10/2007
--  AUTOR           : DANIEL ALMEIDA - VALUE TEAM                              
--  PROGRAMA        : SGPB6012.SQL                                                                             
--  OBJETIVO        : Ler a tabela POSIC_CRRTR_DSTAQ ( DT-APURACAO = DPROX-CARGA) e 
--                    atualizar o respectivo registro indicando se ele ganhou ou não o prêmio parcial. 
--  ALTERAÇÕES      : Foram feitas correções após homologação, vide abaixo. Ass. Wassily ( 08/11/07 )                                                                                              
--            DATA  : -                                                                                              
--            AUTOR : -                                                                                              
--            OBS   : -                                                                                              
------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS DE TRABALHO         
VAR_ERRO                    VARCHAR2(1)       := 'N';
VAR_LOG                     LOG_CARGA.RLOG%TYPE;
VAR_LOG_ADVERTENCIA         LOG_CARGA.CTPO_REG_LOG%TYPE         := 'A'; 
VAR_LOG_PROCESSO            LOG_CARGA.CTPO_REG_LOG%TYPE         := 'P'; 
VAR_CSIT_CTRLM              SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO       EXCEPTION;
VAR_FIM_PROCESSO_CRITICO    EXCEPTION;
--VAR_ORIGEM_GEN_CORP       ORIGE_DADO.CORIGE_DADO%TYPE  := 1; -- ORIGEM GENERICA DO SISTEMA CORPORATIVO
VAR_CAMPANHA                NUMBER := 1;
VAR_PREMIO                  NUMBER ;
VAR_PREMIO_PERC				NUMBER;
-- VARIAVEIS PARA ABERTURA E MANIPULACAO DO ARQUIVO              
VAR_CAMBTE                  ARQ_TRAB.CAMBTE%TYPE;           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE
VAR_CSIST                   ARQ_TRAB.CSIST%TYPE             := 'SGPB'; 
VAR_CROTNA                  ARQ_TRAB.CROTNA%TYPE            := 'SGPB6012';
VAR_CTPO_ACSSO              ARQ_TRAB.CTPO_ACSSO%TYPE        := 'R';
VAR_CSEQ_ARQ_TRAB           ARQ_TRAB.CSEQ_ARQ_TRAB%TYPE     := 1;
VAR_IARQ_TRAB               ARQ_TRAB.IARQ_TRAB%TYPE;
VAR_IDTRIO_TRAB             DTRIO_TRAB.IDTRIO_TRAB%TYPE;
-- VARIAVEIS DO PARAMETRO DE CARGA
VAR_CPARM                   PARM_CARGA.CPARM%TYPE           := 763;     
VAR_DINIC_ROTNA             DATE                            := SYSDATE;
VAR_ULT_CARGA           	PARM_CARGA.DCARGA%TYPE;            
VAR_DCARGA_ATUAL        	PARM_CARGA.DPROX_CARGA%TYPE; 
VAR_ANOMES_CARGA_ATUAL		NUMBER(8);
VAR_ANOMES_ULT_CARGA		NUMBER(8);  
VAR_DCARGA                  PARM_CARGA.DCARGA%TYPE;
VAR_DPROX_CARGA             PARM_CARGA.DPROX_CARGA%TYPE;
--
-- VARIAVEIS DE TRABALHO NOVO
 VAR_AUXILIAR_1  NUMBER ;
 VAR_PSSOA_LOOPING  VARCHAR2(20);
 VAR_CCPF_CNPJ_BASE_LOOPING NUMBER(9,0);
 VAR_META_RE NUMBER;
 VAR_META_AUTO NUMBER;
 VAR_PREMIO_PARCIAL NUMBER;      
   
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
 VAR_ROTNA_PC       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PC';
 VAR_ROTNA_PO       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PO';
 VAR_ROTNA_PE       SIT_ROTNA.CSIT_ROTNA%TYPE  := 'PE';
 
-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - Termino normal, processos dependentes podem continuar.
-- 2 - Termino com alerta, processos dependentes podem continuar, 
--     e o log deverá ser encaminhado ao analista.
-- 3 - Termino com alerta grave, possível erro de ambiente, 
--     o processo poderá ser reiniciado.
-- 4 - Termino com erro, o processo não deve prosseguir. 
--     O analista/DBA deverá ser notificado.
-- 5 - Termino com erro crítico, o processo não deve prosseguir. 
--     O analista/DBA deverá ser contactado imediatamente.
-- 6 - Termino com erro desconhecido. O processo não deve continuar. 
--     Analista deverá ser contatado.
/* ***************************************************************** */
      
PROCEDURE TRATA_PARAMETRO IS        
BEGIN
     
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;
   VAR_LOG := 'PARAMETRO DE AMBIENTE VERIFICADO: ' || VAR_CAMBTE;
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
    --> Recupera os dados de parametro de carga
    PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
                   
   VAR_ANOMES_CARGA_ATUAL   := TO_NUMBER(TO_CHAR(VAR_DCARGA_ATUAL, 'YYYYMM'));   
   
   VAR_ULT_CARGA := VAR_ULT_CARGA + 1;
                                                       
   VAR_LOG  := 'PERIODO DA CARGA ATUAL: '||
               TO_CHAR(VAR_ULT_CARGA, 'DD/MM/YYYY') || ' A ' || 
               TO_CHAR(VAR_DCARGA_ATUAL,  'DD/MM/YYYY');
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END TRATA_PARAMETRO;
/* ***************************************************************** */
PROCEDURE EXECUTA_SCRIPT IS
BEGIN

    VAR_LOG := 'CALCULO EVENTUAL DO PRÊMIO PARCIAL';
    --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
    COMMIT;

    BEGIN
       SELECT VPERC_PRMIO_PCIAL
         -- INTO VAR_PREMIO -- eSSA VARIAVEL E USADA EM BAIXO. ASS. WASSILY
         INTO VAR_PREMIO_PERC
         FROM CAMPA_DSTAQ
         WHERE CCAMPA_DSTAQ = VAR_CAMPANHA ;
    EXCEPTION
       WHEN OTHERS THEN     
          VAR_LOG  := 'ERRO NO TRATA PARAMETRO. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
          PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
          RAISE VAR_FIM_PROCESSO_ERRO;
    END ;
    
    BEGIN
       FOR REG IN ( SELECT  CTPO_PSSOA, CCPF_CNPJ_BASE, VPROD_AUTO, VPROD_RE               		           
                      FROM  POSIC_CRRTR_DSTAQ 
                      where CCAMPA_DSTAQ = VAR_CAMPANHA AND
              	            DAPURC_DSTAQ = VAR_DPROX_CARGA) -- foi inserida a clausula where (Campanha + Data Apuração)
              	            							  -- Não tinha. ass. wassily ( 08/11/07 )
       LOOP            
       		VAR_PSSOA_LOOPING := REG.CTPO_PSSOA;
       		VAR_CCPF_CNPJ_BASE_LOOPING := REG.CCPF_CNPJ_BASE;
       
             SELECT SUM(VMETA_RE), SUM(VMETA_AUTO)
             	INTO VAR_META_RE, VAR_META_AUTO
             	FROM META_RGNAL_DSTAQ
             	WHERE CCAMPA_DSTAQ = VAR_CAMPANHA AND 
                   		CTPO_PSSOA	= VAR_PSSOA_LOOPING AND
                   		CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE_LOOPING;
                  
         VAR_AUXILIAR_1 := (REG.VPROD_AUTO +  REG.VPROD_RE) / (VAR_META_RE + VAR_META_AUTO);
       
      	-- CALCULANDO O PREMIO 
         
      	-- IF   VAR_AUXILIAR_1 < 0.8 THEN
      	IF   VAR_AUXILIAR_1 < ( VAR_PREMIO_PERC / 100 ) THEN -- Estava com o percentual harcode, tirei por que ele vem da VAR_PREMIO.
      											        -- Ass. Wassily ( 08/11/2007)
         	VAR_PREMIO_PARCIAL :=0;
      	ELSE
         	IF (REG.VPROD_AUTO + REG.VPROD_RE) <= 200000 THEN
           		VAR_PREMIO_PARCIAL :=1;
         	--ELSIF ((REG.VPROD_AUTO + REG.VPROD_RE) > 200000) AND ((REG.VPROD_AUTO + REG.VPROD_RE) < 500000) THEN
         	ELSIF ((REG.VPROD_AUTO + REG.VPROD_RE) > 200000) AND ((REG.VPROD_AUTO + REG.VPROD_RE) <= 500000) THEN -- ass. wassily
           		VAR_PREMIO_PARCIAL :=2;
         	ELSIF  (REG.VPROD_AUTO + REG.VPROD_RE) > 500000 THEN
           		VAR_PREMIO_PARCIAL :=3;    
         	END IF;            
     	END IF; 
 
     	-- ATUALIZANDO TABELA COM O PREMIO CALCULADO

      	UPDATE POSIC_CRRTR_DSTAQ 
       	SET    -- CIDTFD_PRMIO_PCIAL = VAR_AUXILIAR_1, -- Aqui é para colocar 0, 1, 2 ou 3, ou seja, a VAR_PREMIO_PARCIAL
       	       -- ass. wassily ( 08/11/07 )
       	        CIDTFD_PRMIO_PCIAL = VAR_PREMIO_PARCIAL,
              	DALT_REG = SYSDATE
       	WHERE  CTPO_PSSOA = VAR_PSSOA_LOOPING AND 
              	CCPF_CNPJ_BASE = VAR_CCPF_CNPJ_BASE_LOOPING AND
              	CCAMPA_DSTAQ = VAR_CAMPANHA AND
              	DAPURC_DSTAQ=VAR_DPROX_CARGA;
      END LOOP;
                
    COMMIT;
END ; 
EXCEPTION
   WHEN OTHERS THEN
   
        VAR_LOG  := 'ERRO AO EXECUTAR O SCRIPT. ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        RAISE VAR_FIM_PROCESSO_ERRO;
   
END EXECUTA_SCRIPT;
----------------------------- PROGRAMA PRINCIPAL  -----------------------------
BEGIN
   -- A VARIAVEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA 
   -- INICIALIZADA COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   VAR_CSIT_CTRLM := 1;
   
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   -- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_CROTNA );
            
   -- GRAVA LOG INICIAL DE CARGA
   VAR_LOG := 'INICIO DO PROCESSO DE CARGA DE TABELAS NO DW';
   --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
   -- ATUALIZA STATUS DA ROTINA  
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);
   
   -- TRATA O PARAMETRO DO PROCESSO 
   TRATA_PARAMETRO;  -- PROCEDURE INTERNA (SUB-PROGRAMA)
   
   --EXECUTA OS SCRIPTS
   EXECUTA_SCRIPT;
    
   IF VAR_CSIT_CTRLM = 1 THEN 
      VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS = 1). ' || 
                 'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
   --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
      
   ELSIF VAR_CSIT_CTRLM = 2 THEN 
      VAR_LOG := 'TERMINO DO PROCESSO COM ADVERTENCIA (STATUS = 2). ' || 
                 ' OS PROCESSOS DEPENDENTES PODEM CONTINUAR '||
                 'E O LOG DEVE SER ENCAMINHADO AO ANALISTA RESPONSAVEL.';
   --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
            
   ELSIF VAR_CSIT_CTRLM = 5 THEN 
      RAISE VAR_FIM_PROCESSO_CRITICO;
   ELSE
      RAISE VAR_FIM_PROCESSO_ERRO;
   END IF;
                 
   -- ATUALIZA STATUS DA ROTINA  
   PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);      
      
   -- GRAVA A SITUACAO DESTE PROCESSO NA TABELA DE CONTROLE DO CTRLM   
   -- EM CASO DE ERRO ESTA GRAVACAO SO SERA FEITA NA EXCEPTION
   PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                              VAR_CROTNA     , 
                              SYSDATE        , -- DFIM_ROTNA
                              NULL           , -- IPROG
                              NULL           , -- CERRO
                              VAR_LOG        , -- RERRO
                              VAR_CSIT_CTRLM             );
   
           
EXCEPTION
   WHEN VAR_FIM_PROCESSO_CRITICO THEN
   
        -- ATUALIZA STATUS DA ROTINA                 
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);   
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO CRITICO (STATUS = 5).'||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                'O ANALISTA/DBA DEVERA SER CONTACTADO.';          
        --PR_GRAVA_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
     PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                                 VAR_CROTNA     , 
                                SYSDATE        , -- DFIM_ROTNA
                                NULL           , -- IPROG
                                NULL           , -- CERRO
                                VAR_LOG        , -- RERRO
                                VAR_CSIT_CTRLM             );
   WHEN VAR_FIM_PROCESSO_ERRO THEN
   
        VAR_CSIT_CTRLM := 6;                                              
        
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);           
   
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6).'||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                'O ANALISTA DEVERA SER CONTACTADO.';          
        --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
     PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                                   VAR_CROTNA     , 
                                SYSDATE        , -- DFIM_ROTNA
                                NULL           , -- IPROG
                                NULL           , -- CERRO
                                VAR_LOG        , -- RERRO
                                VAR_CSIT_CTRLM             );
   WHEN OTHERS THEN                                                               
   
        VAR_CSIT_CTRLM := 6;
   
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);           
        
        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 120);
        --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
                  
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS = 6). '||
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA DEVERA SER CONTACTADO.';
        --PR_GRAVA_LOG_CARGA( VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO);
       
    PR_GRAVA_LOG_EXCUC_CTRLM ( VAR_DINIC_ROTNA, 
                                 VAR_CROTNA     , 
                               SYSDATE        , -- DFIM_ROTNA
                               NULL           , -- IPROG
                               NULL           , -- CERRO
                               VAR_LOG        , -- RERRO
                               VAR_CSIT_CTRLM             );
        
end SGPB6012_OLD;
/

