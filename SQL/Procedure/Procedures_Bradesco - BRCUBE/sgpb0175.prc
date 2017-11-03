CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0175
IS
 -------------------------------------------------------------------------------------------------
 --      BRADESCO SEGUROS S.A.
 --      PROCEDURE       : SGPB0175 - GRUPO ECONOMICO
 --                      : PROCEDIMENTO DW-SCHEDULER PARAMETRO 853 
 --      DATA            : 23/02/2008 - GRUPO ECONÔMICO
 --      AUTOR           : ALEXANDRE CYSNE ESTEVES - ANALISE E DESENVOLVIMENTO DE SISTEMAS
 --      OBJETIVO        : INCLUSÃO DO OBJETIVO E PRODUÇÃO NA TABELA DE RSUMO_OBJTV_AGPTO_ECONM_CRRTR
 --                        PARA O CANAL EXTRA-BANCO
 --      ALTERAÇÕES      : 
 --      DATA            :
 --      OBS             :
 -------------------------------------------------------------------------------------------------
  chrNomeRotinaScheduler CONSTANT CHAR(08) := 'SGPB0175';
  Intinicialfaixa 		   Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  Intfinalfaixa   		   Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_DCARGA 			       DATE;
  VAR_DPROX_CARGA   	   DATE;
  INTCOMPT 				       OBJTV_PROD_AGPTO_ECONM_CRRTR.CANO_MES_COMPT_OBJTV%TYPE;
  INTCANAL 				       OBJTV_PROD_CRRTR.CCANAL_VDA_SEGUR%TYPE;
  Var_Crotna 			       CONSTANT INT := 853;
  Var_Log_Erro 			     Pc_Util_01.Var_Log_Erro%TYPE;
  VAR_TRIMESTRE          NUMBER := 0;
  COMPT_INICIAL          NUMBER(6);
  COMPT_FINAL            NUMBER(6);
  VAR_PONTO	 	           NUMBER;
 -------------------------------------------------------------------------------------------------

 -------------------------------------------------------------------------------------------------
 --RECUPERA O INTERVALO DA FAIXA DO CANAL
 --100000 E 199992 EXTRA-BANCO
 -------------------------------------------------------------------------------------------------
 PROCEDURE getIntervaloFaixa(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr %TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr %TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE) IS

 BEGIN
   BEGIN
    	SELECT PCVS.CINIC_FAIXA_CRRTR,
           	PCVS.CFNAL_FAIXA_CRRTR
                INTO INTRFAIXAINICIAL, INTRFAIXAFINAL
      		FROM PARM_CANAL_VDA_SEGUR PCVS
     		WHERE PCVS.CCANAL_VDA_SEGUR = INTRCANAL
       			AND LAST_DAY(TO_DATE(INTRVIGENCIA, 'YYYYMM'))
       					BETWEEN PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'DD/MM/YYYY'));
   EXCEPTION
      		WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Select da PARM_CANAL_VDA_SEGUR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK;
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    END;
 END getIntervaloFaixa;
 -------------------------------------------------------------------------------------------------
 --RECUPERANDO O TRIMESTRE DO CORRETOR SELECIONADO
 -------------------------------------------------------------------------------------------------
 PROCEDURE getTrimestre(VAR_TRIMESTRE out number) IS
  begin
    VAR_PONTO := 3;
    --VAR_TRIMESTRE := TO_CHAR(LAST_DAY(TO_DATE(INTCOMPT, 'YYYYMM')),'Q');
    VAR_TRIMESTRE := TO_CHAR(LAST_DAY(TO_DATE(to_char(VAR_DPROX_CARGA,'YYYYMM'), 'YYYYMM')),'Q');
  end getTrimestre;
 -------------------------------------------------------------------------------------------------
 --INSERIR AS CASCAS PARA TODOS OS CORRETORES SEM OBJETIVO E SEM PRODUÇÃO
 -------------------------------------------------------------------------------------------------
 PROCEDURE insertCascaResumo(P_COMPT RSUMO_OBJTV_CRRTR.CCOMPT%TYPE) IS
    BEGIN
        --CASCAS AUTO
        VAR_PONTO := 10;
        INSERT INTO RSUMO_OBJTV_AGPTO_ECONM_CRRTR
          (CCOMPT,
           CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           CCPF_CNPJ_AGPTO_ECONM_CRRTR,
           CTPO_PSSOA_AGPTO_ECONM_CRRTR,
           CTPO_COMIS,
           VPROD_GRP_ECONM,
           VOBJTV_PROD_AGPTO_ECONM_ALT,
           VOBJTV_PROD_AGPTO_ECONM_ORIGN,
           QTOT_ITEM_PROD,
           DINCL_REG,
           DALT_REG,
           DINIC_AGPTO_ECONM_CRRTR)
            SELECT
                 P_COMPT,
                 INTCANAL,
                 PC_UTIL_01.Auto,
                 AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                 AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 SYSDATE,
                 SYSDATE,
                 AEC.DINIC_AGPTO_ECONM_CRRTR --?
            --
            FROM PARM_INFO_CAMPA PIC
            --
            JOIN CRRTR_ELEIT_CAMPA CEC
              ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
            --
            JOIN CRRTR_PARTC_AGPTO_ECONM CPAE
              ON CPAE.CTPO_PSSOA = CEC.CTPO_PSSOA
             AND CPAE.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
             --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL
             AND LAST_DAY(TO_DATE(P_COMPT, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'))
            --
            JOIN AGPTO_ECONM_CRRTR AEC
              ON AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
             AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
            --CORRETOR PRINCIPAL PRECISA ESTAR ELEITO
             AND AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
             AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
            --
             --AND AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL
             AND LAST_DAY(TO_DATE(P_COMPT, 'YYYYMM')) BETWEEN AEC.DINIC_AGPTO_ECONM_CRRTR AND NVL(AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR, TO_DATE(99991231, 'YYYYMMDD'))
             ---???????--TMP
             --AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = 7345957
             ---???????--TMP
           WHERE PIC.CCANAL_VDA_SEGUR = INTCANAL
           --AND PIC.DFIM_VGCIA_PARM = to_date(20070930,'yyyymmdd') --IS NOT NULL --IS NULL
             AND PIC.DFIM_VGCIA_PARM IS NULL
           --
           GROUP BY AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                    AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                    AEC.DINIC_AGPTO_ECONM_CRRTR;  
                 
           COMMIT;

       --CASCAS RE
        VAR_PONTO := 11;
        INSERT INTO RSUMO_OBJTV_AGPTO_ECONM_CRRTR
          (CCOMPT,
           CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           CCPF_CNPJ_AGPTO_ECONM_CRRTR,
           CTPO_PSSOA_AGPTO_ECONM_CRRTR,
           CTPO_COMIS,
           VPROD_GRP_ECONM,
           VOBJTV_PROD_AGPTO_ECONM_ALT,
           VOBJTV_PROD_AGPTO_ECONM_ORIGN,
           QTOT_ITEM_PROD,
           DINCL_REG,
           DALT_REG,
           DINIC_AGPTO_ECONM_CRRTR)
            SELECT
                 P_COMPT,
                 INTCANAL,
                 PC_UTIL_01.Re,
                 AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                 AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 SYSDATE,
                 SYSDATE,
                 AEC.DINIC_AGPTO_ECONM_CRRTR --?
            --
            FROM PARM_INFO_CAMPA PIC
            --
            JOIN CRRTR_ELEIT_CAMPA CEC
              ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
            --
            JOIN CRRTR_PARTC_AGPTO_ECONM CPAE
              ON CPAE.CTPO_PSSOA = CEC.CTPO_PSSOA
             AND CPAE.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
             --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL
             AND LAST_DAY(TO_DATE(P_COMPT, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'))
            --
            JOIN AGPTO_ECONM_CRRTR AEC
              ON AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
             AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
            --CORRETOR PRINCIPAL PRECISA ESTAR ELEITO
             AND AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
             AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
            --
             --AND AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL
             AND LAST_DAY(TO_DATE(P_COMPT, 'YYYYMM')) BETWEEN AEC.DINIC_AGPTO_ECONM_CRRTR AND NVL(AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR, TO_DATE(99991231, 'YYYYMMDD'))
             ---???????--TMP
             --AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = 7345957
             ---???????--TMP
           WHERE PIC.CCANAL_VDA_SEGUR = INTCANAL
           --AND PIC.DFIM_VGCIA_PARM = to_date(20070930,'yyyymmdd') --IS NOT NULL --IS NULL
             AND PIC.DFIM_VGCIA_PARM IS NULL
           --
           GROUP BY AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                    AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                    AEC.DINIC_AGPTO_ECONM_CRRTR;  
           COMMIT;
           
 END insertCascaResumo;     
 -------------------------------------------------------------------------------------------------
BEGIN
  ------------------------------------------------------------------------------------------------
  -- INICIO DA PROCEDURE - LIMPANDO LOG DO DW-SCHEDULER
  ------------------------------------------------------------------------------------------------
  PR_LIMPA_LOG_CARGA(chrNomeRotinaScheduler);
  -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
  PR_LE_PARAMETRO_CARGA(Var_Crotna, VAR_DCARGA, VAR_DPROX_CARGA);
  INTCOMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
  var_log_erro := 'INICIO DO PROCESSAMENTO. COMPETENCIA: '||INTCOMPT||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.Var_Rotna_Pc);
  commit;
  FOR INTCANALFOR IN ( SELECT DISTINCT CCANAL_VDA_SEGUR FROM PARM_CANAL_VDA_SEGUR
                                         WHERE DFIM_VGCIA_PARM IS NOT NULL AND --IS NULL
                                         	   CCANAL_VDA_SEGUR = PC_UTIL_01.EXTRA_BANCO )
  LOOP
  	--
    VAR_PONTO := 1;
  	INTCANAL := INTCANALFOR.CCANAL_VDA_SEGUR;
  	/*RECUPERA O TRIMESTRE DA COMPETÊNCIA PASSADA POR PARÂMETRO*/
  	VAR_PONTO := 2;
    getTrimestre(VAR_TRIMESTRE);
    --
    /*ATRIBUI O PERÍODO DO TRIMESTRE*/
    VAR_PONTO := 4;
    If VAR_TRIMESTRE = 1 then
      -- JANEIRO / FEVEREIRO / MARCO
      COMPT_INICIAL := to_number(substr(INTCOMPT,0, 4) || '01');
      COMPT_FINAL   := to_number(substr(INTCOMPT,0, 4) || '03');
    Elsif VAR_TRIMESTRE = 2 then
      -- ABRIL / MAIO / JUNHO
      COMPT_INICIAL := to_number(substr(INTCOMPT,0, 4) || '04');
      COMPT_FINAL   := to_number(substr(INTCOMPT,0, 4) || '06');
    Elsif VAR_TRIMESTRE = 3 then
      -- JULHO / AGOSTO / SETEMBRO
      COMPT_INICIAL := to_number(substr(INTCOMPT,0, 4) || '07');
      COMPT_FINAL   := to_number(substr(INTCOMPT,0, 4) || '09');
    Elsif VAR_TRIMESTRE = 4 then
      -- OUTUBRO / NOVEMBRO / DEZEMBRO
      COMPT_INICIAL := to_number(substr(INTCOMPT,0, 4) || '10');
      COMPT_FINAL   := to_number(substr(INTCOMPT,0, 4) || '12');
    End If;
    
    VAR_PONTO := 5;
  	var_log_erro := 'PROCESSAMENTO DO CANAL '||INTCANALFOR.CCANAL_VDA_SEGUR||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;
    VAR_PONTO := 6;
    --RECUPERA O INTERVALO DA FAIXA DO CANAL
    getIntervaloFaixa(Intinicialfaixa,Intfinalfaixa,INTCANALFOR.CCANAL_VDA_SEGUR,Intcompt);
        
    -------------------------------
    --LOOP PARA REALIZAR OS UPDATES
    -------------------------------
    VAR_PONTO := 7;
    FOR V_COMPT IN COMPT_INICIAL..COMPT_FINAL
    LOOP
      --
      --EXCLUIR TODOS DO CANAL E COMPETÊNCIA
      --
      VAR_PONTO := 8;
      BEGIN
         DELETE FROM RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROAEC
      		WHERE ROAEC.CCOMPT = V_COMPT
        	  AND ROAEC.CTPO_COMIS = 'CN'
        	  AND ROAEC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR;          
      EXCEPTION
        WHEN No_Data_Found THEN null;
      	WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Delete da RSUMO_OBJTV_AGPTO_ECONM_CRRTR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK;
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
      END;
      ---      
      ---INSERIR AS CASCAS PARA TODOS OS CORRETORES SEM OBJETIVO E SEM PRODUÇÃO
      ---
      VAR_PONTO := 9;
      insertCascaResumo(V_COMPT); 
      ---
      ---INSERE NA TABELA OS CORRETORES QUE TEM PRODUÇÃO
      ---
      VAR_PONTO := 12;
      FOR C IN( 
          SELECT PC.CGRP_RAMO_PLANO,
               	 AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
               	 AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
               	 PC.CTPO_COMIS,
               	 SUM(PC.VPROD_CRRTR) PROD,
               	 SUM(PC.QTOT_ITEM_PROD) ITEM
         			--
       			FROM CRRTR C
         			--
       			JOIN PARM_INFO_CAMPA PIC
       			  ON PIC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
       			 AND PIC.DFIM_VGCIA_PARM IS NULL
         			--
       			JOIN CRRTR_ELEIT_CAMPA CEC
         			ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
       			 AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
       			 AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
       			 AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
         			--
            JOIN CRRTR_PARTC_AGPTO_ECONM CPAE
              ON CPAE.CTPO_PSSOA = CEC.CTPO_PSSOA
             AND CPAE.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
              --ON CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
             --AND CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
             --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL
             AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'))
              --
            JOIN AGPTO_ECONM_CRRTR AEC
              ON AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
             AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR  = CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
             AND AEC.DINIC_AGPTO_ECONM_CRRTR      = CPAE.DINIC_AGPTO_ECONM_CRRTR
            --CORRETOR PRINCIPAL PRECISA ESTAR ELEITO
            --AND AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
            --AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
            --
             --AND AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL
             AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN AEC.DINIC_AGPTO_ECONM_CRRTR AND NVL(AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR, TO_DATE(99991231, 'YYYYMMDD'))
             ---???????--TMP
             --AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = 7345957
             ---???????--TMP
       			JOIN PROD_CRRTR PC 
              ON PC.CCRRTR = C.CCRRTR
             AND PC.CUND_PROD = C.CUND_PROD
             AND PC.CCOMPT_PROD = V_COMPT
             AND PC.CGRP_RAMO_PLANO IN (120,810)
             AND PC.CTPO_COMIS = 'CN'
      				--
     			 WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
         			--
     			 GROUP BY AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
             				AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
            				PC.CGRP_RAMO_PLANO,
               			PC.CTPO_COMIS)
      ---
      LOOP
        ---
        ---ATUALIZA A PRODUÇÃO PARA TODOS OS CANAIS DO GRUPO ECONOMICO
        ---
          VAR_PONTO := 13;
        	UPDATE RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROAEC
           		SET ROAEC.VPROD_GRP_ECONM = C.PROD,
               		ROAEC.QTOT_ITEM_PROD = C.ITEM
         	  WHERE CCOMPT = V_COMPT
           		AND CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
           		AND CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO
           		AND CCPF_CNPJ_AGPTO_ECONM_CRRTR = C.CCPF_CNPJ_AGPTO_ECONM_CRRTR
           		AND CTPO_PSSOA_AGPTO_ECONM_CRRTR = C.CTPO_PSSOA_AGPTO_ECONM_CRRTR
           		AND CTPO_COMIS = C.CTPO_COMIS;
           	COMMIT;
      END LOOP;
      ---
      ---ATUALIZA O OBJETIVO PARA TODOS OS CANAIS DO GRUPO ECONOMICO
      ---120
      ---      
      VAR_PONTO := 14;
      FOR J IN ( 
           SELECT ROAEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                  ROAEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR, 
                  ROAEC.CGRP_RAMO_PLANO,
           				--
           				CASE
               			WHEN SUM(NVL(OPAC.VOBJTV_PROD_AGPTO_ECONM_ALT,0)) < PCVS.VMIN_PROD_APURC THEN
                  			PCVS.VMIN_PROD_APURC / 3
               			ELSE
                  			SUM(NVL(OPAC.VOBJTV_PROD_AGPTO_ECONM_ALT,0)) /3
           				END V_OBJTV_PROD_ALT
           				--
            			FROM RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROAEC
          				--
            			JOIN PARM_INFO_CAMPA PIC 
                    ON PIC.CCANAL_VDA_SEGUR = ROAEC.CCANAL_VDA_SEGUR
                   AND PIC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
                   AND PIC.DFIM_VGCIA_PARM IS NULL
          				--
            			JOIN PARM_CANAL_VDA_SEGUR PCVS 
                    ON PCVS.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             			 AND PCVS.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
          				--
       			      LEFT JOIN OBJTV_PROD_AGPTO_ECONM_CRRTR OPAC 
                    ON OPAC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = ROAEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR
                   AND OPAC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = ROAEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR
                   AND OPAC.CGRP_RAMO_PLANO = ROAEC.CGRP_RAMO_PLANO
                   AND OPAC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                   AND OPAC.CANO_MES_COMPT_OBJTV BETWEEN COMPT_INICIAL AND COMPT_FINAL
          				--
           			 WHERE ROAEC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
             		   AND ROAEC.CCOMPT = V_COMPT
             			 AND ROAEC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
             			 AND ROAEC.CTPO_COMIS = 'CN'
          				--
           			 GROUP BY ROAEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                          ROAEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR, 
                          ROAEC.CGRP_RAMO_PLANO, 
                          PCVS.VMIN_PROD_APURC)          
       LOOP
       		---
          ---ATUALIZAR A TABELA DE RESUMO DE OBJETIVO PARA INCLUIR OBJETIVO
          ---120
          ---
       		VAR_PONTO := 15;
      		 UPDATE RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROAEC
        		  SET ROAEC.VOBJTV_PROD_AGPTO_ECONM_ALT = J.V_OBJTV_PROD_ALT,
              	  ROAEC.VOBJTV_PROD_AGPTO_ECONM_ORIGN = J.V_OBJTV_PROD_ALT
       			WHERE ROAEC.CCOMPT = V_COMPT
         			AND ROAEC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
         			AND ROAEC.CGRP_RAMO_PLANO = J.CGRP_RAMO_PLANO
         			AND ROAEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = J.CCPF_CNPJ_AGPTO_ECONM_CRRTR
         			AND ROAEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = J.CTPO_PSSOA_AGPTO_ECONM_CRRTR
         			AND ROAEC.CTPO_COMIS = 'CN';
        	COMMIT;
        END LOOP;
        VAR_PONTO := 16;
        ---
       	---RECUPERA O VALOR MÍNIMO PARA APURAÇÃO DO GRUPO RE
        ---810
        ---
          FOR K IN ( 
          SELECT ROAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                 ROAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR, 
                 ROAE.CGRP_RAMO_PLANO,
     				     NVL(OPAE.VOBJTV_PROD_AGPTO_ECONM_ALT,0) VOBJTV_PROD_AGPTO_ECONM_ALT
     				--
      			FROM RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROAE
    				--
      			JOIN PARM_INFO_CAMPA PIC 
              ON PIC.CCANAL_VDA_SEGUR = ROAE.CCANAL_VDA_SEGUR
           	 AND PIC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
         		 AND PIC.DFIM_VGCIA_PARM IS NULL
    				--
      			LEFT JOIN OBJTV_PROD_AGPTO_ECONM_CRRTR OPAE 
              ON OPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR = ROAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
        		 AND OPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR = ROAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
             AND OPAE.CGRP_RAMO_PLANO = ROAE.CGRP_RAMO_PLANO
             AND OPAE.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND OPAE.CANO_MES_COMPT_OBJTV = V_COMPT
    				--
     			 WHERE ROAE.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
       			 AND ROAE.CCOMPT = V_COMPT
       			 AND ROAE.CGRP_RAMO_PLANO IN (810)
       			 AND ROAE.CTPO_COMIS = 'CN'
    				--
     			 GROUP BY ROAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                    ROAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR, 
                    ROAE.CGRP_RAMO_PLANO,
                    OPAE.VOBJTV_PROD_AGPTO_ECONM_ALT)
          LOOP
          	VAR_PONTO := 17;
           	--ATUALIZAR A TABELA DE RESUMO DE OBJETIVO PARA INCLUIR OBJETIVO
            UPDATE RSUMO_OBJTV_AGPTO_ECONM_CRRTR
        		SET VOBJTV_PROD_AGPTO_ECONM_ALT = K.VOBJTV_PROD_AGPTO_ECONM_ALT,
             		VOBJTV_PROD_AGPTO_ECONM_ORIGN = K.VOBJTV_PROD_AGPTO_ECONM_ALT
       			WHERE CCOMPT = V_COMPT
         			AND CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
         			AND CGRP_RAMO_PLANO = K.CGRP_RAMO_PLANO
         			AND CCPF_CNPJ_AGPTO_ECONM_CRRTR = K.CCPF_CNPJ_AGPTO_ECONM_CRRTR
         			AND CTPO_PSSOA_AGPTO_ECONM_CRRTR = K.CTPO_PSSOA_AGPTO_ECONM_CRRTR
         			AND CTPO_COMIS = 'CN';
            COMMIT;
        END LOOP;
  	END LOOP;
  END LOOP;

  VAR_PONTO := 20;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PO);
  Var_log_erro := 'TERMINO DO PROCESSAMENTO DA COMPETENCIA: '||INTCOMPT||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;
  --
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor. Ponto: '||VAR_PONTO||' Competência: ' ||
                             IntCompt || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    WHEN OTHERS THEN
      var_log_erro := substr(' Compet: '||INTCOMPT||' Ponto: '||VAR_PONTO||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
      
end SGPB0175;
/

