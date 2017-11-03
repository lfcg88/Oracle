CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0201R(pCanal                IN parm_crrtr_excec.ccanal_vda_segur%TYPE,
                                      pCpf_cnpj_completo    IN NUMBER,
                                      pTipo_pssoa           IN crrtr_unfca_cnpj.ctpo_pssoa%TYPE,
                                      pAnoInclusao          IN VARCHAR2,
                                      pTrimestreInclusao    IN VARCHAR2,
                                      --pGrupoObjetivo        IN NUMBER,
                                      pValorObjetivo        IN NUMBER,
                                      pUsuario    	        IN VARCHAR2
							) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0201R
  --      data            : 11/07/06 14:39:18
  --      autor           : WASSILY CHUK SEIBLITZ GUANAES / RALPH AGUIAR
  --      objetivo        : ELEGE MANUALMENTE (VIA INTRANET) UM CORRETOR NO PLANO DE BONUS E COLOCA ELE TAMBÉM NA TABELA DE
  --					    EXEÇÕES JÁ QUE ELE FOI ELEITO NA MÃO.
  --      alterações      : 14 bytes se CNPJ
  --                        11 bytes se CPF
  -------------------------------------------------------------------------------------------------
  TT INT;
  DT_INIC_VIG	    	date;
  P_MES_01_PARM     number;
  P_MES_02_PARM     number;
  P_MES_03_PARM     number;
  P_MES_01_PARM_AUX VARCHAR2(2);
  P_MES_02_PARM_AUX VARCHAR2(2);
  P_MES_03_PARM_AUX VARCHAR2(2);
  valorInserido     number;
  dtApur            number;
  pCpf_cnpj_aux	  	NUMBER;
  pCpf_cnpj_base  	crrtr_unfca_cnpj.ccpf_cnpj_base%TYPE;
  pCompetencia      number := pAnoInclusao || pTrimestreInclusao; 
  P_MAX_VERSION     INT;
  P_OBJETIVO        number;
--
PROCEDURE getMaxVerObject(
    P_CCPF_CNPJ_BASE   IN objtv_prod_crrtr.ccpf_cnpj_base %type,
    P_CTPO_PSSOA       IN objtv_prod_crrtr.ctpo_pssoa %type,
    P_CCANAL_VDA_SEGUR IN objtv_prod_crrtr.ccanal_vda_segur %type,
    P_CGRP_RAMO_PLANO  IN objtv_prod_crrtr.cgrp_ramo_plano %type,
    P_CCOMPT_OBJTV     IN objtv_prod_crrtr.cano_mes_compt_objtv %type,
    P_MAX_VERSION      OUT objtv_prod_crrtr.cseq_objtv_crrtr %type)
IS
BEGIN
       SELECT
       MAX(OPC.CSEQ_OBJTV_CRRTR)
       INTO P_MAX_VERSION
       FROM OBJTV_PROD_CRRTR OPC
       WHERE OPC.CTPO_PSSOA         = P_CTPO_PSSOA
       AND OPC.CCPF_CNPJ_BASE       = P_CCPF_CNPJ_BASE
       AND OPC.CCANAL_VDA_SEGUR     = P_CCANAL_VDA_SEGUR
       AND OPC.CGRP_RAMO_PLANO      = P_CGRP_RAMO_PLANO
       AND OPC.CANO_MES_COMPT_OBJTV = P_CCOMPT_OBJTV;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
      	  	RAISE_APPLICATION_ERROR(-20021,'NÃO EXISTE OBJETIVO');
    	   WHEN OTHERS THEN
    	     ROLLBACK;
    		    RAISE_APPLICATION_ERROR(-20021,'ERRO NO SELECT DO OBJETIVO'||SQLERRM);
END getMaxVerObject;

PROCEDURE getMeses(
    P_TRIMESTRE        IN  NUMBER,
    P_MES_01           OUT VARCHAR2,
    P_MES_02           OUT VARCHAR2,
    P_MES_03           OUT VARCHAR2)
IS
BEGIN  
   IF ( P_TRIMESTRE = 1) THEN   
         P_MES_01  := '01';
         P_MES_02  := '02';
         P_MES_03  := '03';
   END IF;  
   IF ( P_TRIMESTRE = 2) THEN   
         P_MES_01  := '04';
         P_MES_02  := '05';
         P_MES_03  := '06';
   END IF; 
   IF ( P_TRIMESTRE = 3) THEN   
         P_MES_01  := '07';
         P_MES_02  := '08';
         P_MES_03  := '09';
   END IF; 
   IF ( P_TRIMESTRE = 4) THEN   
         P_MES_01  := '10';
         P_MES_02  := '11';
         P_MES_03  := '12';
   END IF; 
END getMeses;

PROCEDURE getObjetivoBancoFinasa(
  P_CCPF_CNPJ_BASE   IN objtv_prod_crrtr.ccpf_cnpj_base %type,
  P_CTPO_PSSOA       IN objtv_prod_crrtr.ctpo_pssoa %type,
  P_CCANAL_VDA_SEGUR IN objtv_prod_crrtr.ccanal_vda_segur %type,
  P_CGRP_RAMO_PLANO  IN objtv_prod_crrtr.cgrp_ramo_plano %type,
  P_CCOMPT_OBJTV     IN objtv_prod_crrtr.cano_mes_compt_objtv %type,
  P_MAX_SEQ          IN objtv_prod_crrtr.cseq_objtv_crrtr %type,
  P_OBJETIVO        OUT objtv_prod_crrtr.vobjtv_prod_crrtr_alt%type)
IS
BEGIN
        SELECT
        vobjtv_prod_crrtr_alt
        INTO P_OBJETIVO
        FROM OBJTV_PROD_CRRTR OPC
        WHERE OPC.CTPO_PSSOA         = P_CTPO_PSSOA
        AND OPC.CCPF_CNPJ_BASE       = P_CCPF_CNPJ_BASE
        AND OPC.CCANAL_VDA_SEGUR     = P_CCANAL_VDA_SEGUR
        AND OPC.CGRP_RAMO_PLANO      = P_CGRP_RAMO_PLANO
        AND OPC.CANO_MES_COMPT_OBJTV = P_CCOMPT_OBJTV
        AND OPC.CSEQ_OBJTV_CRRTR     = P_MAX_SEQ;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
    	      ROLLBACK;
      	    	RAISE_APPLICATION_ERROR(-20021,'NÃO EXISTE OBJETIVO');
    	    WHEN OTHERS THEN
    	      ROLLBACK;
    		      RAISE_APPLICATION_ERROR(-20021,'ERRO NO SELECT DO OBJETIVO'||SQLERRM);   
END getObjetivoBancoFinasa;

PROCEDURE setObjetivoBancoFinasa(
  P_CCPF_CNPJ_BASE    IN  number,
  P_CTPO_PSSOA        IN  VARCHAR2,
  P_CCANAL_VDA_SEGUR  IN  number,
  P_RAMO              IN  number,
  P_ANO               IN  number,
  P_MES_01_PARM       IN  number,
  --P_MES_02_PARM       IN  number,
  P_MES_03_PARM       IN  number,
  P_VALOR_OBJETIVO    IN  number
  )
IS
  conta_mes      NUMBER;
  ano_mes        NUMBER;
  valorObjt      NUMBER;
BEGIN
     conta_mes       :=  P_MES_01_PARM;
     valorObjt       :=  P_VALOR_OBJETIVO / 100;
     WHILE conta_mes <=  P_MES_03_PARM LOOP
           if (conta_mes = 10 or conta_mes = 11 or conta_mes = 12) then
               ano_mes := P_ANO || conta_mes;
           else
               ano_mes := P_ANO || '0' || conta_mes;
           end if;
           INSERT INTO OBJTV_PROD_CRRTR
           (CTPO_PSSOA,
            CCPF_CNPJ_BASE, 
            CGRP_RAMO_PLANO, 
            CCANAL_VDA_SEGUR, 
            CANO_MES_COMPT_OBJTV, 
            CSEQ_OBJTV_CRRTR, 
            VOBJTV_PROD_CRRTR_ALT,
            VOBJTV_PROD_CRRTR_ORIGN,
            CIND_REG_ATIVO,
            DULT_ALT,
            CRESP_ULT_ALT)
  			   VALUES
           (P_CTPO_PSSOA, P_CCPF_CNPJ_BASE,P_RAMO,P_CCANAL_VDA_SEGUR, ano_mes, 1, valorObjt, valorObjt, 'S',SYSDATE,'MANUAL');
           conta_mes := conta_mes + 1;
      END LOOP;
        EXCEPTION
  	 	WHEN OTHERS THEN
    	   ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO INSERT OBJETIVOS BANCO / FINASA, ERRO : '||SQLERRM);   
END setObjetivoBancoFinasa;
--
PROCEDURE setValorCalcInserido(
  P_CCANAL_VDA_SEGUR    IN  number,
  P_RAMO                IN  number,
  P_VALOR_OBJT_INSERIDO IN NUMBER,
  P_VALOR_OBJETIVO     out  number
  )
IS
  valorObjt      NUMBER(17,2);
  valorObjtInser NUMBER(17,2);
BEGIN
           SELECT
             vmin_prod_crrtr
           INTO 
             valorObjt
           FROM
             PARM_PROD_MIN_CRRTR
           WHERE
             CGRP_RAMO_PLANO  = P_RAMO AND
             CCANAL_VDA_SEGUR = P_CCANAL_VDA_SEGUR;
            
            valorObjtInser :=  P_VALOR_OBJT_INSERIDO / 100;
            if (valorObjtInser < valorObjt) then
              P_VALOR_OBJETIVO := valorObjt * 100;
           else
              P_VALOR_OBJETIVO := P_VALOR_OBJT_INSERIDO;   
           end if; 

           EXCEPTION  
           WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
      		   RAISE_APPLICATION_ERROR(-20021,'VALOR MINIMO DE META EM BANCO / FINASA NAO ENCONTRADO.');
           WHEN OTHERS THEN
    	     ROLLBACK;
    	       RAISE_APPLICATION_ERROR(-20021,'ERRO NO VALOR MINIMO DE META EM BANCO / FINASA, ERRO : '||SQLERRM);  
              
END setValorCalcInserido;
--
BEGIN
   IF ( pTipo_pssoa = 'J') THEN
         pCpf_cnpj_aux  := LPAD(pCpf_cnpj_completo,14,0);
         pCpf_cnpj_base := substr(pCpf_cnpj_aux, 1, length(pCpf_cnpj_aux) - 6);
   ELSE
         pCpf_cnpj_aux  := LPAD(pCpf_cnpj_completo,11,0);
         pCpf_cnpj_base := substr(pCpf_cnpj_aux, 1, length(pCpf_cnpj_aux) - 2);
   END IF; 
    --
    --  VERIFICA a validade da Apuração
    --
    BEGIN
      SELECT MAX(SUBSTR(TO_CHAR(ccompt_apurc,'999999'),1,5))||'0'||max(to_char(TO_DATE(ccompt_apurc||'01','YYYYMMDD'),'Q'))  
             into dtApur
             from APURC_PROD_CRRTR;                    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	    ROLLBACK;
      		RAISE_APPLICATION_ERROR(-20021,'APURACAO NAO ENCONTRADO NO PLANO DE BONUS.');
    	WHEN OTHERS THEN
    	    ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO SELECT DA APURACAO, ERRO : '||SQLERRM);   
    END;

    IF ( pCompetencia <= dtApur) THEN
         RAISE_APPLICATION_ERROR(-20021,'APURACAO FECHADA PARA O TRIMESTRE.');
    END IF;
    --
    --  VERIFICA a existência do Corretor na BASE de DADOS
    --
   BEGIN
    	SELECT 1 INTO TT
      			FROM CRRTR_UNFCA_CNPJ CUC
     			WHERE CUC.CCPF_CNPJ_BASE = pCpf_cnpj_base AND CUC.CTPO_PSSOA = pTipo_pssoa;
      EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	    ROLLBACK;
      		RAISE_APPLICATION_ERROR(-20021,'CORRETOR E TIPO CORRETOR NAO ENCONTRADO NO PLANO DE BONUS.');
    	WHEN OTHERS THEN
    	    ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO PLANO DE BONUS, ERRO : '||SQLERRM);   
   END;
    --
    --  VERIFICA a validade do CANAL
    --
    BEGIN
      SELECT DINIC_VGCIA_PARM  INTO DT_INIC_VIG
             	FROM PARM_CANAL_VDA_SEGUR
              WHERE CCANAL_VDA_SEGUR=pCanal AND DFIM_VGCIA_PARM IS not NULL; 
    --         	WHERE CCANAL_VDA_SEGUR=pCanal AND DFIM_VGCIA_PARM IS NULL;                    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	    ROLLBACK;
      		RAISE_APPLICATION_ERROR(-20021,'CANAL NAO ENCONTRADO NO PLANO DE BONUS OU CAMPANHA TERMINADA.');
    	WHEN OTHERS THEN
    	    ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO SELECT DO CANAL, PLANO DE BONUS, ERRO : '||SQLERRM);   
    END;
    --
    --  INSERINDO O CORRETOR NA TABELA DE ELEITOS
    --
    BEGIN
	  INSERT INTO CRRTR_ELEIT_CAMPA
    		(CCANAL_VDA_SEGUR,DINIC_VGCIA_PARM, DCRRTR_SELEC_CAMPA, CTPO_PSSOA, CCPF_CNPJ_BASE)
  			VALUES
    		(pCanal,DT_INIC_VIG,SYSDATE,pTipo_pssoa,pCpf_cnpj_base);
    EXCEPTION
     	WHEN OTHERS THEN
    	   ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO INSERT PLANO DE BONUS (ELEITOS), ERRO : '||SQLERRM);   
    END;
    COMMIT;
    --
    -- INSERINDO NA TABELA DE EXCEÇOES
    --
    BEGIN
       INSERT INTO CRRTR_EXCEC_CAMPA
             (CTPO_PSSOA,CCPF_CNPJ_BASE,CCANAL_VDA_SEGUR,DINIC_VGCIA_PARM,RMOTVO_EXCEC_CRRTR,CIND_REG_ATIVO,DULT_ALT,
              CRESP_ULT_ALT,CTPO_EXCEC_CRRTR)
              VALUES
              (pTipo_pssoa,pCpf_cnpj_base,pCanal,DT_INIC_VIG,
              'Eleito Manualmente Para a Campanha Corrente.',
              'S',sysdate,pUsuario,'A');
    EXCEPTION
  	 	WHEN OTHERS THEN
    	   ROLLBACK;
    		RAISE_APPLICATION_ERROR(-20021,'ERRO NO INSERT PLANO DE BONUS (EXCECOES), ERRO : '||SQLERRM);   
    END;
    COMMIT;
    --
    --  CALCULA OBJETIVO, por GRUPO, e define se maior ou menor que o padrão!!
    --
   IF ( pCanal = 1) THEN
       -- Objetivo: Extra-banco - Insere Objetivo: Extra-Banco --
       getMeses(pTrimestreInclusao, P_MES_01_PARM_AUX, P_MES_02_PARM_AUX, P_MES_03_PARM_AUX);
       -- CHAMADA do CÁLCULO do OBJETIVO EXTRA-BANCO
       SGPB0202(pCompetencia, pAnoInclusao || P_MES_01_PARM_AUX, pCpf_cnpj_base);
         
   ELSE
       -- Objetivo: Banco - Finasa - Insere Objetivo: Banco / Finasa
       getMeses(pTrimestreInclusao, P_MES_01_PARM, P_MES_02_PARM, P_MES_03_PARM);
       valorInserido := 0;
       -- Verifica se o OBJETIVO é maior ou menor que o OBJETIVO PADRÃO, caso seja menor, utilizar o OBEJTIVO PADRÃO
       setValorCalcInserido(pCanal,120,pValorObjetivo,valorInserido);
       --setObjetivoBancoFinasa(pCpf_cnpj_base, pTipo_pssoa, pCanal, 120,  pAnoInclusao, P_MES_01_PARM, P_MES_02_PARM, P_MES_03_PARM, valorInserido, pUsuario);
       setObjetivoBancoFinasa(pCpf_cnpj_base, pTipo_pssoa, pCanal, 120,  pAnoInclusao, P_MES_01_PARM, P_MES_03_PARM, valorInserido);
       valorInserido := 0;
       -- Verifica se o OBJETIVO é maior ou menor que o OBJETIVO PADRÃO, caso seja menor, utilizar o OBEJTIVO PADRÃO
       setValorCalcInserido(pCanal,810,pValorObjetivo,valorInserido);
       setObjetivoBancoFinasa(pCpf_cnpj_base, pTipo_pssoa, pCanal, 810,  pAnoInclusao, P_MES_01_PARM, P_MES_03_PARM, valorInserido);
       setObjetivoBancoFinasa(pCpf_cnpj_base, pTipo_pssoa, pCanal, 999,  pAnoInclusao, P_MES_01_PARM, P_MES_03_PARM, pValorObjetivo);
       COMMIT;
   END IF;
END SGPB0201R;
/

