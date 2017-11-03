CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6003_OLD IS
-------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                            
--  DATA            : 08/10/2007
--  AUTOR           : JO√O GRIMALDE - VALUE TEAM
--  PROGRAMA        : SGPB6003.SQL                                                   
--  OBJETIVO        : CARGA DIARIA DA POSI«√O CORRETOR POR REGIONAL 
--  ALTERA«’ES      :                                                               
--            DATA  : 22/10/2007
--			      AUTOR	: ANA MELO
--            OBS   : ALTERAR O ACESSO NA VIEW PELA TABELA PSIC_RGNAL_DSTAQ
-------------------------------------------------------------------------------------

-- VARIAVEIS DE TRABALHO    
VAR_CROTNA					ARQ_TRAB.CROTNA%TYPE            := 'SGPB6003';
VAR_DINIC_ROTNA         	DATE                            := SYSDATE;          
VAR_CPARM               	PARM_CARGA.CPARM%TYPE           := 752;
VAR_DCARGA		          	PARM_CARGA.DCARGA%TYPE; 
VAR_DPROX_CARGA             PARM_CARGA.DCARGA%TYPE; 
VAR_ERRO 					VARCHAR2(1);
VAR_TABELA      			VARCHAR2(30) 			   		:= 'POSIC_CRRTR_DSTAQ';
VAR_LOG                 	LOG_CARGA.RLOG%TYPE;
VAR_LOG_PROCESSO        	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'P'; 
VAR_LOG_DADO            	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'D'; 
VAR_LOG_ADVERTENCIA     	LOG_CARGA.CTPO_REG_LOG%TYPE     := 'A';   
VAR_TPO_LOG_PROCESSO        LOG_CARGA.CTPO_REG_LOG%TYPE     ;   
VAR_CSIT_CTRLM          	SIT_ROTNA_CTRLM.CSIT_CTRLM%TYPE;
VAR_FIM_PROCESSO_ERRO   	EXCEPTION;   
VAR_CCTRL_ATULZ				NUMBER := 1;	
--                                                    
-- VARIAVEIS PARA CONTROLE DE TEMPO DE PROCESSAMENTO
-- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
VAR_ROTNA_AP		     	SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'AP'; -- A PROCESSAR
VAR_ROTNA_PC	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PC'; -- PROCESSANDO
VAR_ROTNA_PO   		   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PO'; -- PROCESSADO OK
VAR_ROTNA_PE	   	   	    SIT_ROTNA.CSIT_ROTNA%TYPE		:= 'PE'; -- PROCESSADO COM ERRO
VAR_STATUS_ROTNA	   	    SIT_ROTNA.CSIT_ROTNA%TYPE;     
VAR_STATUS_ROTNA_ANT	    SIT_ROTNA.CSIT_ROTNA%TYPE;                                
--               
--          
W_HORA_PROC_INICIAL        DATE  							:= SYSDATE;
W_TEMPO_PROC               NUMBER;
--                                                
-- VARIAVEIS UTILIZADAS NO PROCESSO DE APURA«√O DA PRODU«√O DO CORRETOR 
VAR_CCAMPA_DSTAQ            POSIC_CRRTR_DSTAQ.CCAMPA_DSTAQ%TYPE                := 1;   -- DEVE SER TROCADO VALOR DE RETORNO DA PROCEDURE
VAR_BASE_CNPJ_UNFCA 	    CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE%TYPE;
VAR_TPO_PSSOA               CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE;  
VAR_EXISTE_PROD_COMPL       VARCHAR2(1) := 'N';
VAR_DULT_APURC_DSTAQ        DATE ;                        -- DATA DA ULTIMA APURA«√O DESTAQUE  
VAR_VPRMIO_DSTAQ            CAMPA_DSTAQ.VPRMIO_DSTAQ%TYPE                  ; 
VAR_CIND_DEB_CUPOM          CAMPA_DSTAQ.CIND_DEB_CUPOM%TYPE                ; 
VAR_VPROD_RE                POSIC_CRRTR_DSTAQ.VPROD_RE%TYPE                ; 
VAR_VPROD_AUTO              POSIC_CRRTR_DSTAQ.VPROD_AUTO%TYPE              ; 
VAR_QCUPOM_DISPN            POSIC_CRRTR_DSTAQ.QCUPOM_DISPN%TYPE            ; 
VAR_QCUPOM_RETRD            POSIC_CRRTR_DSTAQ.QCUPOM_RETRD%TYPE            ; 
VAR_VPROD_PRMIO             POSIC_CRRTR_DSTAQ.VPROD_PRMIO%TYPE             ; 
VAR_VPROD_PEND              POSIC_CRRTR_DSTAQ.VPROD_PEND%TYPE              ; 
VAR_CIDTFD_PRMIO_PCIAL      POSIC_CRRTR_DSTAQ.CIDTFD_PRMIO_PCIAL%TYPE      ; 
VAR_NRKING_PROD_NACIO       POSIC_CRRTR_DSTAQ.NRKING_PROD_NACIO%TYPE       ; 
VAR_NRKING_PERC_CRSCT_NACIO POSIC_CRRTR_DSTAQ.NRKING_PERC_CRSCT_NACIO%TYPE ; 
VAR_VPERC_CRSCT_NACIO       POSIC_CRRTR_DSTAQ.VPERC_CRSCT_NACIO%TYPE       ; 
VAR_TOT_REG_PROC           	NUMBER := 0;
VAR_TOT_REG_COM_PROD_DIA   	NUMBER := 0;
VAR_TOT_REG_SEM_PROD_DIA   	NUMBER := 0;

--
-- LISTA DE SITUACAO PARA TRATAMENTO DE ERROS DO CONTROL-M.
-- 1 - TÈrmino normal, processos dependentes podem continuar.
-- 2 - TÈrmino com alerta, processos dependentes podem continuar, 
--     e o log dever· ser encaminhado ao analista.
-- 3 - TÈrmino com alerta grave, possÌvel erro de ambiente, 
--     o processo poder· ser reiniciado.
-- 4 - TÈrmino com erro, o processo n„o deve prosseguir. 
--     O analista/DBA dever· ser notificado.
-- 5 - TÈrmino com erro crÌtico, o processo n„o deve prosseguir. 
--     O analista/DBA dever· ser contactado imediatamente.
-- 6 - TÈrmino com erro desconhecido. O processo n„o deve continuar. 
--     O analista dever· ser contactado.

--*******************************************************************
--
--
PROCEDURE PR_INCR_POSIC_DIA_PROD_CRRTR (
					PAR_CCAMPA_DSTAQ            IN NUMBER,
					PAR_CTPO_PSSOA              IN VARCHAR2,
					PAR_CCPF_CNPJ_BASE          IN NUMBER,
					PAR_DAPURC_DSTAQ            IN DATE,
					PAR_QCUPOM_DISPN            IN NUMBER,
					PAR_QCUPOM_RETRD            IN NUMBER,
					PAR_VPROD_PRMIO             IN NUMBER,
					PAR_VPROD_PEND              IN NUMBER,
					PAR_VPROD_RE                IN NUMBER,
					PAR_VPROD_AUTO              IN NUMBER,
					PAR_CIDTFD_PRMIO_PCIAL      IN NUMBER,
					PAR_NRKING_PROD_NACIO       IN NUMBER,
					PAR_NRKING_PERC_CRSCT_NACIO IN NUMBER,
					PAR_DINCL_REG               IN DATE
					)IS              

BEGIN 
   BEGIN  
   -- 
           
	  BEGIN


    
          -- Cadastra ProduÁ„o do Corretor na tabela POSIC_CRRTR_DSTAQ
             INSERT INTO POSIC_CRRTR_DSTAQ
             ( CCAMPA_DSTAQ,
		       CTPO_PSSOA,
		       CCPF_CNPJ_BASE,
		       DAPURC_DSTAQ,
		       QCUPOM_DISPN,
		       QCUPOM_RETRD,
		       VPROD_PRMIO,
		       VPROD_PEND,
		       VPROD_RE,
		       VPROD_AUTO,
		       CIDTFD_PRMIO_PCIAL,
		       NRKING_PROD_NACIO,
		       NRKING_PERC_CRSCT_NACIO,
		       DINCL_REG,
		       DALT_REG,
		       VPERC_CRSCT_NACIO)
             VALUES
             ( PAR_CCAMPA_DSTAQ,
		       PAR_CTPO_PSSOA,
		       PAR_CCPF_CNPJ_BASE,
		       PAR_DAPURC_DSTAQ,      -- DATA DA APURA«√O ATUAL
		       nvl(PAR_QCUPOM_DISPN,0),
		       nvl(PAR_QCUPOM_RETRD,0),
		       nvl(PAR_VPROD_PRMIO,0),
		       nvl(PAR_VPROD_PEND,0),
		       nvl(PAR_VPROD_RE,0),
		       nvl(PAR_VPROD_AUTO,0),
		       nvl(PAR_CIDTFD_PRMIO_PCIAL,0),
		       nvl(PAR_NRKING_PROD_NACIO,0),
		       nvl(PAR_NRKING_PERC_CRSCT_NACIO,0),
		       PAR_DINCL_REG,    
		       NULL,            -- DALT_REG
		       0);              -- VPERC_CRSCT_NACIO
          --
	  EXCEPTION     
	    WHEN DUP_VAL_ON_INDEX THEN
           	VAR_LOG := 'PRODU«√O J¡ CADASTRADA NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 20, NULL);
            --
           	VAR_LOG := 'CAMPANHA: '        || TO_CHAR(PAR_CCAMPA_DSTAQ)||
           	           ' CCPF_CNPJ_BASE: ' || LPAD(PAR_CCPF_CNPJ_BASE, 10)||
           	           ' DATA APURA«√O: '  || TO_CHAR(PAR_DAPURC_DSTAQ,'DD/MM/YYYY');
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 21, NULL);
            --
    	WHEN OTHERS THEN    
    	    --			
			VAR_CSIT_CTRLM := 5;
            --
           	VAR_LOG := 'ERRO AO CARREGAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 1, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 2, NULL);
           	--
	  END;  
   --       
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;  
   END;
END;
--
--
PROCEDURE PR_RECUPERA_PARM_APURACAO IS  
BEGIN 
   BEGIN
     SELECT TRUNC(DAPURC_DSTAQ),
            VPRMIO_DSTAQ,
            CIND_DEB_CUPOM
        INTO VAR_DULT_APURC_DSTAQ,
             VAR_VPRMIO_DSTAQ,
             VAR_CIND_DEB_CUPOM
       FROM CAMPA_DSTAQ
      WHERE CCAMPA_DSTAQ = VAR_CCAMPA_DSTAQ;  
  
 
      --> RECUPERA OS DADOS DE PARAMETRO DE CARGA (O C”DIGO DE PAR‚METRO DE CARGA FOI INICIALIZADO NO DECLARE)
      PR_LE_PARAMETRO_CARGA(VAR_CPARM, VAR_DCARGA, VAR_DPROX_CARGA);
      --
       
   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;  
   END;
END;
--
--
PROCEDURE PR_POSIC_DIA_PROD_CRRTR IS  -- POSICAO DIARIA PRODU«√O CORRETOR
BEGIN 
  
   	VAR_LOG  := '-------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECU«√O CURSOR DE RECUPERA«√O DA PRODU«√O DIARIA DO CORRETOR';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 3, NULL);
    VAR_LOG  := '--------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	-- 
	FOR REG IN(	
               SELECT T1.CCPF_CNPJ_BASE,
                      T1.CTPO_PSSOA,
			                sum(T1.VPROD_RGNAL_AUTO) VPROD_AUTO,
			                sum(T1.VPROD_RGNAL_RE) VPROD_RE
               FROM POSIC_RGNAL_DSTAQ T1
               GROUP BY
                      T1.CCPF_CNPJ_BASE,
                      T1.CTPO_PSSOA
                               
               ) 
    LOOP
    
      BEGIN
        
        -- 
        select nvl(QCUPOM_DISPN,0),  
		       nvl(QCUPOM_RETRD,0),  
		       nvl(VPROD_PRMIO,0),   
		       nvl(VPROD_PEND,0),  
               nvl(VPROD_RE,0),   
		       nvl(VPROD_AUTO,0) , 
		       nvl(CIDTFD_PRMIO_PCIAL,0),           
		       nvl(NRKING_PROD_NACIO,0),            
		       nvl(NRKING_PERC_CRSCT_NACIO,0)       
	     into  VAR_QCUPOM_DISPN,
		       VAR_QCUPOM_RETRD,
		       VAR_VPROD_PRMIO,
		       VAR_VPROD_PEND,
		       VAR_VPROD_RE,
	           VAR_VPROD_AUTO,
		       VAR_CIDTFD_PRMIO_PCIAL,
		       VAR_NRKING_PROD_NACIO,
		       VAR_NRKING_PERC_CRSCT_NACIO
        from POSIC_CRRTR_DSTAQ
         where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ  ;    
          --
		  VAR_VPROD_RE             := VAR_VPROD_RE + REG.VPROD_RE;
	      VAR_VPROD_AUTO           := VAR_VPROD_AUTO + REG.VPROD_AUTO; 
	      --
	      if (VAR_VPROD_AUTO + VAR_VPROD_RE) < 0 and VAR_CIND_DEB_CUPOM = 'S' then	         
	         VAR_VPROD_PRMIO             := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ ) * VAR_VPRMIO_DSTAQ;
	         VAR_VPROD_PEND              := (VAR_VPROD_AUTO + VAR_VPROD_RE) - (VAR_VPROD_PRMIO * -1);   
	         VAR_QCUPOM_DISPN            := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ );
	      elsif (VAR_VPROD_AUTO + VAR_VPROD_RE) < 0 and VAR_CIND_DEB_CUPOM = 'N' then	           
		     VAR_VPROD_PRMIO             := 0;
             VAR_VPROD_PEND              := 0;
             VAR_QCUPOM_DISPN            := 0;
	      else 
		     VAR_VPROD_PRMIO             := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ ) * VAR_VPRMIO_DSTAQ;
             VAR_VPROD_PEND              := (VAR_VPROD_AUTO + VAR_VPROD_RE) - VAR_VPROD_PRMIO;
             VAR_QCUPOM_DISPN            := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ );
          end if;
          --
          VAR_VPERC_CRSCT_NACIO       := 0;

          --
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN              
		     VAR_VPROD_RE                := REG.VPROD_RE;
	         VAR_VPROD_AUTO              := REG.VPROD_AUTO;
	         --
		     if (VAR_VPROD_AUTO + VAR_VPROD_RE) < 0 and VAR_CIND_DEB_CUPOM = 'S' then	         
		        VAR_VPROD_PRMIO             := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ ) * VAR_VPRMIO_DSTAQ;
		        VAR_VPROD_PEND              := (VAR_VPROD_AUTO + VAR_VPROD_RE) - (VAR_VPROD_PRMIO * -1);   
		        VAR_QCUPOM_DISPN            := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ );
		     elsif (VAR_VPROD_AUTO + VAR_VPROD_RE) < 0 and VAR_CIND_DEB_CUPOM = 'N' then	           
			    VAR_VPROD_PRMIO             := 0;
	            VAR_VPROD_PEND              := 0;
	            VAR_QCUPOM_DISPN            := 0;
		     else 
			    VAR_VPROD_PRMIO             := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ ) * VAR_VPRMIO_DSTAQ;
	            VAR_VPROD_PEND              := (VAR_VPROD_AUTO + VAR_VPROD_RE) - VAR_VPROD_PRMIO;
	            VAR_QCUPOM_DISPN            := trunc( (VAR_VPROD_AUTO + VAR_VPROD_RE) / VAR_VPRMIO_DSTAQ );
	         end if;
	         --     
		     VAR_QCUPOM_RETRD            := 0;
		     VAR_CIDTFD_PRMIO_PCIAL      := 0;
		     VAR_NRKING_PROD_NACIO       := 0;
		     VAR_NRKING_PERC_CRSCT_NACIO := 0;
		     VAR_VPERC_CRSCT_NACIO       := 0;
    	WHEN OTHERS THEN    
    	    --			
			VAR_CSIT_CTRLM := 6;
            --
           	VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 4, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 5, NULL);
             --             
		     RAISE VAR_FIM_PROCESSO_ERRO;             
      END;
      
    
      -- Cadastra ProduÁ„o do Corretor na tabela POSIC_CRRTR_DSTAQ 
      PR_INCR_POSIC_DIA_PROD_CRRTR (
					VAR_CCAMPA_DSTAQ            ,
					REG.CTPO_PSSOA              ,
					REG.CCPF_CNPJ_BASE          ,
					VAR_DPROX_CARGA             , -- DATA DA APURA«√O ATUAL
					VAR_QCUPOM_DISPN            ,
					VAR_QCUPOM_RETRD            ,
					VAR_VPROD_PRMIO             ,
					VAR_VPROD_PEND              ,
					VAR_VPROD_RE                ,
					VAR_VPROD_AUTO              ,
					VAR_CIDTFD_PRMIO_PCIAL      ,
					VAR_NRKING_PROD_NACIO       ,
					VAR_NRKING_PERC_CRSCT_NACIO ,
					SYSDATE );             
          --
          VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;	
          --
          VAR_TOT_REG_COM_PROD_DIA := VAR_TOT_REG_COM_PROD_DIA + 1;
          --
	      IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
	         COMMIT;
	      END IF;  
          --
    END LOOP;  
--
--  
EXCEPTION
	WHEN OTHERS THEN    
        --
    	VAR_CSIT_CTRLM := 6;   
        --
         VAR_LOG := 'ERRO NO SUB-PROGRAMA que CARREGA OS DADOS PARA TABELA ' || VAR_TABELA;
         PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 6, NULL); 

        VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 7, NULL);

        RAISE VAR_FIM_PROCESSO_ERRO;
      
END;   

--
/*PROCEDURE PR_POSIC_DIA_PROD_CRRTR_COMPL IS  -- POSICAO DIARIA PRODU«√O CORRETOR COMPLEMENTAR
BEGIN 
    --
   	VAR_LOG  := '--------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	VAR_LOG  := 'INICIO EXECU«√O CURSOR DE RECUPERA«√O DA PRODU«√O DO CORRETOR COMPLEMENTAR';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 8, NULL);
    VAR_LOG  := '--------------------------------------------------------------------------';
   	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	-- 
	FOR REG IN( select CCAMPA_DSTAQ,
                       CCPF_CNPJ_BASE,
                       CTPO_PSSOA
                  from POSIC_CRRTR_DSTAQ
                 where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                   and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ
                minus   
                select CCAMPA_DSTAQ,
                       CCPF_CNPJ_BASE,
                       CTPO_PSSOA
                  from POSIC_CRRTR_DSTAQ
                 where CCAMPA_DSTAQ        = VAR_CCAMPA_DSTAQ
                   and TRUNC(DAPURC_DSTAQ) = VAR_DPROX_CARGA
               ) 
    LOOP
      BEGIN
       -- 
        select nvl(QCUPOM_DISPN,0),  
		       nvl(QCUPOM_RETRD,0),  
		       nvl(VPROD_PRMIO,0),   
		       nvl(VPROD_PEND,0),  
               nvl(VPROD_RE,0),   
		       nvl(VPROD_AUTO,0) , 
		       nvl(CIDTFD_PRMIO_PCIAL,0),           
		       nvl(NRKING_PROD_NACIO,0),            
		       nvl(NRKING_PERC_CRSCT_NACIO,0)       
	     into  VAR_QCUPOM_DISPN,
		       VAR_QCUPOM_RETRD,
		       VAR_VPROD_PRMIO,
		       VAR_VPROD_PEND,
		       VAR_VPROD_RE,
	           VAR_VPROD_AUTO,
		       VAR_CIDTFD_PRMIO_PCIAL,
		       VAR_NRKING_PROD_NACIO,
		       VAR_NRKING_PERC_CRSCT_NACIO
        from POSIC_CRRTR_DSTAQ
         where CCAMPA_DSTAQ        = REG.CCAMPA_DSTAQ
           and CTPO_PSSOA          = REG.CTPO_PSSOA
           and CCPF_CNPJ_BASE      = REG.CCPF_CNPJ_BASE
           and TRUNC(DAPURC_DSTAQ) = VAR_DULT_APURC_DSTAQ  ;    
          --
          VAR_VPERC_CRSCT_NACIO       := 0;
          VAR_EXISTE_PROD_COMPL       := 'S';
          --
	  EXCEPTION
    	WHEN NO_DATA_FOUND THEN 
    	     VAR_EXISTE_PROD_COMPL    := 'N' ;
    	WHEN OTHERS THEN    
    	    --			
			VAR_CSIT_CTRLM := 6;
            --
           	VAR_LOG := 'ERRO AO SELECIONAR REGISTRO NA TABELA ' || VAR_TABELA ;
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 9, NULL);
            --
           	VAR_LOG := 'ERRO ORACLE: '|| SUBSTR(SQLERRM(SQLCODE), 1, 200);
           	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, 10, NULL);
             --             
		     RAISE VAR_FIM_PROCESSO_ERRO;             
      END;
      IF VAR_EXISTE_PROD_COMPL = 'S' THEN
	     -- Cadastra ProduÁ„o do Corretor na tabela POSIC_CRRTR_DSTAQ 
       
         PR_INCR_POSIC_DIA_PROD_CRRTR (
					VAR_CCAMPA_DSTAQ            ,
					REG.CTPO_PSSOA              ,
					REG.CCPF_CNPJ_BASE          ,
					VAR_DPROX_CARGA             , -- DATA DA APURA«√O ATUAL
					VAR_QCUPOM_DISPN            ,
					VAR_QCUPOM_RETRD            ,
					VAR_VPROD_PRMIO             ,
					VAR_VPROD_PEND              ,
					VAR_VPROD_RE                ,
					VAR_VPROD_AUTO              ,
					VAR_CIDTFD_PRMIO_PCIAL      ,
					VAR_NRKING_PROD_NACIO       ,
					VAR_NRKING_PERC_CRSCT_NACIO ,
					SYSDATE );             
	          --
	          VAR_TOT_REG_PROC := VAR_TOT_REG_PROC + 1;	
	          --           
              VAR_TOT_REG_SEM_PROD_DIA := VAR_TOT_REG_SEM_PROD_DIA + 1;
              --
		      IF MOD(VAR_TOT_REG_PROC, 500) = 0 THEN
		         COMMIT;
		      END IF;  
	          --
      END IF;
    END LOOP;  

   EXCEPTION
     WHEN OTHERS THEN
		     RAISE VAR_FIM_PROCESSO_ERRO;  
END;
--*/
------------------------------------  PROGRAMA PRINCIPAL  ------------------------------------
BEGIN
         
	-- A VARI·VEL DE TRATAMENTO DE ERRO DO CONTROL-M SERA INICIALIZADA 
   	-- COM O FLAG DE TERMINO NORMAL COM SUCESSO (=1)
   	VAR_CSIT_CTRLM := 1;

	--> LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
	-- (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
	PR_LIMPA_LOG_CARGA(VAR_CROTNA); 
	
	--> GRAVA LOG INICIAL DE CARGA
	VAR_LOG := 'INICIO DO PROCESSO CARGA DA TABELA '||VAR_TABELA;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);  

   -- TEMPO DE PROCESSAMENTO
   W_TEMPO_PROC := ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
   VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '||TO_CHAR(W_TEMPO_PROC);
   PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	
	
	--> Grava log inicial de carga
	VAR_LOG := '-> STATUS INICIAL DO CTRL-M: '|| VAR_CSIT_CTRLM;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
	
   	--> Verifica status da rotina antes de iniciar o processamento 
   	VAR_LOG := 'VERIFICANDO STATUS DA ROTINA ANTES DE INICIAR O PROCESSAMENTO.';
  	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	VAR_STATUS_ROTNA := FC_RECUPERA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM);
    VAR_LOG := '--> STATUS INICIAL DA ROTINA: ' || VAR_STATUS_ROTNA; 
 	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
   	
   	--> Atualiza status da rotina atual      
 	PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PC);   
      
    --> RECUPERA PAR¬METROS DA CAMPANHA DESTAQUE
    PR_RECUPERA_PARM_APURACAO;
    VAR_LOG  := 'DATA DE APURA«√O: ' || TO_CHAR(VAR_DPROX_CARGA,'DD/MM/YYYY') ||
                ' -- ULTIMA DATA DE APURA«√O: ' || TO_CHAR(VAR_DULT_APURC_DSTAQ,'DD/MM/YYYY');
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    VAR_LOG  := 'PR MIO DESTAQUE: ' || TO_CHAR(VAR_VPRMIO_DSTAQ) ;
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 	
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
	-- 
    VAR_LOG  := 'INICIANDO PROCESSO DE APURA«√O DA PRODU«√O DO CORRETOR';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    --
    VAR_LOG  := '------------------------------------------------------';
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
  
--  =================================
-- Limpeza dos dados da tabela POSIC_RGNAL_DSTAQ do dia = VAR_DPROX_CARGA
    
    DELETE POSIC_CRRTR_DSTAQ
    WHERE  DAPURC_DSTAQ = VAR_DPROX_CARGA;
  
    COMMIT;
    
	--  Start das procedures de inclusao na tabela POSIC_RGNAL_DSTAQ 
   PR_POSIC_DIA_PROD_CRRTR;
    --
  -- PR_POSIC_DIA_PROD_CRRTR_COMPL;
    
	-- Fim do START
--=====================================
    VAR_LOG  := 'TOTAL DE REGISTROS COM PRODU«√O INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_COM_PROD_DIA);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
	--
    VAR_LOG  := 'TOTAL DE REGISTROS DE PRODU«√O NOVA INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_SEM_PROD_DIA);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
	--
    VAR_LOG  := 'TOTAL DE REGISTROS INSERIDOS NA TABELA  '||VAR_TABELA ||': '||   TO_CHAR(VAR_TOT_REG_PROC);
	PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL); 
    --
    --> Tempo de processamento
    --W_TEMPO_PROC :=  ROUND(((SYSDATE - W_HORA_PROC_INICIAL ) * 24), 2);
    --VAR_LOG := 'TEMPO DE PROCESSAMENTO EM HORAS : '   TO_CHAR(W_TEMPO_PROC) ;
	--PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);	
	
	IF VAR_CSIT_CTRLM = 1 THEN
                       
		--> Atualiza status termino da rotina  
		PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PO);
		VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PO; 
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

		VAR_LOG := 'TERMINO NORMAL DO PROCESSO (STATUS CTRL-M = 1). ' ||
                   'OS PROCESSOS DEPENDENTES PODEM CONTINUAR.';
		PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
      
		--> Grava a situacao deste processo na tabela de controle do ctrlm   
		PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA, 
                                  VAR_CROTNA     , 
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );           
	ELSE 
	
		RAISE VAR_FIM_PROCESSO_ERRO;

	END IF;
    	
EXCEPTION
	WHEN VAR_FIM_PROCESSO_ERRO THEN
	
        --> Atualiza status termino da rotina  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);

        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = ' || VAR_CSIT_CTRLM || 
                   ' ). OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        DBMS_OUTPUT.PUT_LINE(VAR_LOG);

   	    PR_GRAVA_LOG_EXCUC_CTRLM(VAR_DINIC_ROTNA, 
                              	 VAR_CROTNA     , 
                                 SYSDATE        , -- DFIM_ROTNA
                                 NULL           , -- IPROG
                                 NULL           , -- CERRO
                                 VAR_LOG        , -- RERRO
                                 VAR_CSIT_CTRLM             );

	WHEN OTHERS THEN   
    	                                              
        VAR_CSIT_CTRLM := 6;                   

        --> Atualiza status termino da rotina  
        PR_ATUALIZA_STATUS_ROTINA(VAR_CROTNA, VAR_CPARM, VAR_ROTNA_PE);
        VAR_LOG := '--> STATUS FINAL DA ROTINA: ' || VAR_ROTNA_PE; 
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);

        VAR_LOG := 'EXCEPTION OTHERS - ERRO ORACLE: '|| SUBSTR(SQLERRM, 1, 200);
        PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA, VAR_LOG, VAR_LOG_PROCESSO, NULL, NULL);
                
        VAR_LOG := 'ESTE PROCESSO FOI FINALIZADO COM ERRO (STATUS CTRL-M = 6). ' || 
                   'OS PROCESSOS DEPENDENTES NAO DEVEM CONTINUAR. '				 ||
                   'O ANALISTA/DBA DEVERA SER CONTACTADO IMEDIATAMENTE.';
	    PR_GRAVA_MSG_LOG_CARGA(VAR_CROTNA,  VAR_LOG,  VAR_LOG_PROCESSO, NULL, NULL);
        
   	    PR_GRAVA_LOG_EXCUC_CTRLM( VAR_DINIC_ROTNA, 
                              	  VAR_CROTNA     , 
                                  SYSDATE        , -- DFIM_ROTNA
                                  NULL           , -- IPROG
                                  NULL           , -- CERRO
                                  VAR_LOG        , -- RERRO
                                  VAR_CSIT_CTRLM             );

 END;
/

