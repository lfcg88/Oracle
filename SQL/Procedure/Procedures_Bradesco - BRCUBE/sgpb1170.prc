CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB1170
IS
 -------------------------------------------------------------------------------------------------
 --      BRADESCO SEGUROS S.A.
 --      PROCEDURE       : SGPB1170 - GRUPO ECONOMICO
 --                      : PROCEDIMENTO DW-SCHEDULER PARAMETRO 853
 --      DATA            : 24/02/2008
 --      AUTOR           : ALEXANDRE CYSNE ESTEVES - ANALISE E DESENVOLVIMENTO DE SISTEMAS
 --      OBJETIVO        : INCLUSÃO DO OBJETIVO NA TABELA DE OBJTV_PROD_AGPTO_ECONM_CRRTR
 --                        -- nova regra para percentual de crescimento da meta
 --                        -- 1) até 25000 (inclusive) coloca 30000
 --                        -- 2) Maior que 25000 até 300000 (inclusive) coloca 20%
 --                        -- 3) Maior que 300000 até 600000 (inclusive) coloca (10%)
 --                        -- 4) Maior que 600000 em diante (5%)  
 --      ALTERAÇÕES      :
 -------------------------------------------------------------------------------------------------
  chrNomeRotinaScheduler CONSTANT CHAR(08) := 'SGPB1170';
  VAR_DCARGA 			       DATE;
  VAR_DPROX_CARGA   	   DATE;
  INTCOMPT 				       OBJTV_PROD_AGPTO_ECONM_CRRTR.CANO_MES_COMPT_OBJTV%TYPE;
  Var_Crotna 			       CONSTANT INT := 853;
  Var_Log_Erro 			     Pc_Util_01.Var_Log_Erro%TYPE;
  VAR_TRIMESTRE          NUMBER := 0;
  COMPT_INICIAL          NUMBER(6);
  COMPT_FINAL            NUMBER(6);
  VAR_PONTO	 	           NUMBER;
  COMPT_INICIAL_ANTERIOR INTEGER;
  INTINICIALFAIXA 			 PARM_CANAL_VDA_SEGUR.CINIC_FAIXA_CRRTR%TYPE;
  INTFINALFAIXA   			 PARM_CANAL_VDA_SEGUR.CFNAL_FAIXA_CRRTR%TYPE;
  VMIN_PROD_CRRTR_J 		 PARM_PROD_MIN_CRRTR.VMIN_PROD_CRRTR%TYPE;
  VMIN_PROD_CRRTR_F 		 PARM_PROD_MIN_CRRTR.VMIN_PROD_CRRTR%TYPE;
  INTRMESESAPURCONSIDERAR INTEGER;
  -------------------------------------------------------------------------------------------------
  --RECUPERANDO O TRIMESTRE DO CORRETOR SELECIONADO
  -------------------------------------------------------------------------------------------------
  PROCEDURE getTrimestre(VAR_TRIMESTRE out number) IS
   BEGIN
    VAR_PONTO := 1;
    VAR_TRIMESTRE := TO_CHAR(LAST_DAY(TO_DATE(to_char(VAR_DPROX_CARGA,'YYYYMM'), 'YYYYMM')),'Q');
   END getTrimestre;
  -------------------------------------------------------------------------------------------------
  --RECUPERA O INTERVALO DA FAIXA DO CANAL
  -------------------------------------------------------------------------------------------------
   PROCEDURE getIntervaloFaixa(Intrfaixainicial OUT Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE,
                     Intrfaixafinal OUT Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE,
                     Intrcanal      IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
  BEGIN
    VAR_PONTO := 2;
    SELECT PCVS.CINIC_FAIXA_CRRTR, PCVS.CFNAL_FAIXA_CRRTR 
      INTO INTRFAIXAINICIAL, INTRFAIXAFINAL
      FROM PARM_CANAL_VDA_SEGUR PCVS
     WHERE PCVS.CCANAL_VDA_SEGUR = Intrcanal
       AND LAST_DAY(TO_DATE(Intrvigencia||'01', 'YYYYMMDD')) BETWEEN
           PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'DD/MM/YYYY'));
  END getIntervaloFaixa;
  -------------------------------------------------------------------------------------------------
  --RECUPERA O INTERVALO DA FAIXA DO CANAL
  -------------------------------------------------------------------------------------------------
  PROCEDURE getValorObjtvRe(
    vmin_prod_crrtr OUT PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr%type,
    Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
    chrTpPessoa     IN crrtr_unfca_cnpj.ctpo_pssoa%type,
    Intrvigencia    IN Prod_Crrtr.Ccompt_Prod%TYPE
  ) IS
  BEGIN
    VAR_PONTO := 3;
    SELECT PPMC.VMIN_PROD_CRRTR INTO VMIN_PROD_CRRTR
      		FROM PARM_PROD_MIN_CRRTR PPMC
     WHERE PPMC.CCANAL_VDA_SEGUR = Intrcanal
       AND PPMC.CGRP_RAMO_PLANO = PC_UTIL_01.RE
       AND PPMC.CTPO_PSSOA = CHRTPPESSOA
       AND PPMC.CTPO_PER = 'M'
       AND LAST_DAY(TO_DATE(INTRVIGENCIA||'01' , 'YYYYMMDD'))
           BETWEEN PPMC.DINIC_VGCIA_PARM
               AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'));
  END getValorObjtvRe;  
  -------------------------------------------------------------------------------------------------
  --RECUPERA A QUANTIDADE DE MES A CONSIDERAR
  -------------------------------------------------------------------------------------------------
  PROCEDURE getMesesApuracaoConsiderar(intrMesesApurConsiderar OUT Parm_Per_Apurc_Canal.Qmes_Anlse%TYPE,
                   Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                   Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                   Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc%TYPE) IS
  BEGIN
    VAR_PONTO := 4;
    SELECT ppac.qmes_perdc_apurc 
      INTO intrMesesApurConsiderar
      FROM Parm_Per_Apurc_Canal ppac
     WHERE ppac.Ccanal_Vda_Segur = Intrcanal 
       AND Last_Day(To_Date(Intrvigencia||'01','YYYYMMDD')) BETWEEN ppac.Dinic_Vgcia_Parm AND pc_util_01.Sgpb0031(ppac.Dfim_Vgcia_Parm)
       AND ppac.Ctpo_Apurc = Intrtpapurc;
  END getMesesApuracaoConsiderar;  
  --
  BEGIN
  ------------------------------------------------------------------------------------------------
  -- INICIO DA PROCEDURE - LIMPANDO LOG DO DW-SCHEDULER
  ------------------------------------------------------------------------------------------------
  PR_LIMPA_LOG_CARGA(chrNomeRotinaScheduler);
  -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
  PR_LE_PARAMETRO_CARGA(Var_Crotna, VAR_DCARGA, VAR_DPROX_CARGA);
  INTCOMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
  var_log_erro := 'INICIO DO PROCESSAMENTO. COMPETENCIA: '||COMPT_INICIAL||' A '||COMPT_FINAL||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.Var_Rotna_Pc);
  COMMIT;

	--RECUPERA O TRIMESTRE DA COMPETÊNCIA PASSADA POR PARÂMETRO
	VAR_PONTO := 5;
  getTrimestre(VAR_TRIMESTRE);
  --
  --ATRIBUI O PERÍODO DO TRIMESTRE
  VAR_PONTO := 6;
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
    
    COMPT_INICIAL_ANTERIOR := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(COMPT_INICIAL, 'yyyymm'), -12), 'YYYYMM'));
    ---
    ---Recupera o intervalo da faixa do canal
    getIntervaloFaixa(Intinicialfaixa,Intfinalfaixa,PC_UTIL_01.Extra_Banco,COMPT_INICIAL);
    ---
    ---Recupera a producao minima do RE  
    getValorObjtvRe(VMIN_PROD_CRRTR_J,PC_UTIL_01.Extra_Banco,'J',COMPT_INICIAL);
    getValorObjtvRe(VMIN_PROD_CRRTR_F,PC_UTIL_01.Extra_Banco,'F',COMPT_INICIAL); 
    ---Recupera a quantidade de mes a considerar
    getMesesApuracaoConsiderar(INTRMESESAPURCONSIDERAR,1,COMPT_INICIAL,PC_UTIL_01.Extra_Banco);
    ---
    VAR_PONTO := 7;
  	var_log_erro := 'PROCESSAMENTO DO CANAL 1.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;
    VAR_PONTO := 8;
    ---
    ---DELETANDO OBJETIVO DO GRUPO ECONOMICO
    ---
    BEGIN
       DELETE OBJTV_PROD_AGPTO_ECONM_CRRTR OPAE
    		WHERE OPAE.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
      	  AND OPAE.CANO_MES_COMPT_OBJTV BETWEEN COMPT_INICIAL AND COMPT_FINAL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    	WHEN OTHERS THEN
    			var_log_erro := substr(' Erro No Delete da OBJTV_PROD_AGPTO_ECONM_CRRTR. Compet: '||INTCOMPT||
    			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    			ROLLBACK;
    			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
    			COMMIT;
    			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    END;
    COMMIT;
    ---
    ---INSERINDO OBJETIVO DO GRUPO ECONOMICO
    --- 
    FOR V_COMPT IN COMPT_INICIAL..COMPT_FINAL
    LOOP
       ---INSERT AUTO 120
       INSERT INTO OBJTV_PROD_AGPTO_ECONM_CRRTR(  
                   CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                   CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                   DINIC_AGPTO_ECONM_CRRTR,             
                   CGRP_RAMO_PLANO, 
                   CCANAL_VDA_SEGUR,              
                   CANO_MES_COMPT_OBJTV, 
                   VOBJTV_PROD_AGPTO_ECONM_ORIGN, 
                   VOBJTV_PROD_AGPTO_ECONM_ALT, 
                   CRESP_ULT_ALT,
                   DINCL_REG, 
                   DULT_ALT )
                   --
          	SELECT AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                   AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                   AEC.DINIC_AGPTO_ECONM_CRRTR,
                   PC_UTIL_01.Auto,
                   PC_UTIL_01.Extra_Banco,
                   V_COMPT,
                   -- nova regra para percentual de crescimento da meta
                   -- 1) até 25000 (inclusive) coloca 30000
                   -- 2) Maior que 25000 até 300000 (inclusive) coloca 20%
                   -- 3) Maior que 300000 até 600000 (inclusive) coloca (10%)
                   -- 4) Maior que 600000 em diante (5%)               
                   CASE 
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 25000) THEN
                       10000
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 300000) THEN  -- > 25000 &&  <=  300000
                       --20%
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.2
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 600000) THEN  -- > 300000 && <=  600000
                       --10%
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.1
                   ELSE                                              -- > 600000
                       --5%
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.05
                   END CASE,
                   --
                   --
                   --
                   CASE 
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 25000) THEN
                       10000
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 300000) THEN  -- > 25000 &&  <=  300000
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.2
                   WHEN (SUM(NVL(PC.VPROD_CRRTR,0)) <= 600000) THEN  -- > 300000 && <=  600000
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.1
                   ELSE                                              -- > 600000
                       SUM(NVL(PC.VPROD_CRRTR,0)) * 1.05
                   END CASE, 
                   --SUM(NVL(PC.VPROD_CRRTR,0)), 
                   --SUM(NVL(PC.VPROD_CRRTR,0)),
                   'SGPB1170-EXTRABANCO-G',
                   SYSDATE,
                   NULL
                   
              FROM CRRTR C
                --
         			JOIN PARM_INFO_CAMPA PIC
         			  ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
               AND PIC.DFIM_VGCIA_PARM IS NULL
                --
            	JOIN CRRTR_ELEIT_CAMPA CEC
            	  ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
               AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
               AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
               AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
                --
              LEFT JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
               AND PC.CUND_PROD = C.CUND_PROD
               AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
               AND PC.CCOMPT_PROD = COMPT_INICIAL_ANTERIOR
               AND PC.CTPO_COMIS = 'CN'
                --
              JOIN CRRTR_PARTC_AGPTO_ECONM CPAE
                ON CPAE.CTPO_PSSOA = CEC.CTPO_PSSOA
               AND CPAE.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
               --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL  --???????????? validar between
               AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'))
                --
              JOIN AGPTO_ECONM_CRRTR AEC
                ON AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
               AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR  = CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
               --
               AND AEC.DINIC_AGPTO_ECONM_CRRTR      = CPAE.DINIC_AGPTO_ECONM_CRRTR
               --CORRETOR PRINCIPAL PRECISA ESTAR ELEITO
               --AND AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
               --AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
               --
               --AND AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL --???????????? validar between
               AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN AEC.DINIC_AGPTO_ECONM_CRRTR AND NVL(AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR, TO_DATE(99991231, 'YYYYMMDD'))
               --
           	 WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
          GROUP BY AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                   AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                   AEC.DINIC_AGPTO_ECONM_CRRTR;

                   ---
                   ---SOMANDO UM A COMPETENCIA ANTERIOR
                   ---
                   COMPT_INICIAL_ANTERIOR := COMPT_INICIAL_ANTERIOR + 1;

    COMMIT;
    --
       ---INSERT RE 810
       INSERT INTO OBJTV_PROD_AGPTO_ECONM_CRRTR(  
                   CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                   CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                   DINIC_AGPTO_ECONM_CRRTR,             
                   CGRP_RAMO_PLANO, 
                   CCANAL_VDA_SEGUR,              
                   CANO_MES_COMPT_OBJTV, 
                   VOBJTV_PROD_AGPTO_ECONM_ORIGN, 
                   VOBJTV_PROD_AGPTO_ECONM_ALT, 
                   CRESP_ULT_ALT,
                   DINCL_REG, 
                   DULT_ALT )
                  ---
                  SELECT AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                         AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                         AEC.DINIC_AGPTO_ECONM_CRRTR,
                         PC_UTIL_01.Re,
                         PC_UTIL_01.Extra_Banco,
                         V_COMPT,
                         DECODE(AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,'J',VMIN_PROD_CRRTR_J/3, VMIN_PROD_CRRTR_F/3) * INTRMESESAPURCONSIDERAR,
                         DECODE(AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR,'J',VMIN_PROD_CRRTR_J/3, VMIN_PROD_CRRTR_F/3) * INTRMESESAPURCONSIDERAR,
                         'SGPB1170-EXTRABANCO-G',
                         SYSDATE,
                         NULL                         
                    FROM CRRTR C
                      --
                    JOIN PARM_INFO_CAMPA PIC
                      ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
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
                     --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL  --???????????? validar between
                     AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'))
                      --
                    JOIN AGPTO_ECONM_CRRTR AEC
                      ON AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR
                     AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR
                     --CORRETOR PRINCIPAL PRECISA ESTAR ELEITO
                     AND AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CEC.CTPO_PSSOA
                     AND AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = CEC.CCPF_CNPJ_BASE
                     --
                     --AND AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR IS NULL --???????????? validar between
                     AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) BETWEEN AEC.DINIC_AGPTO_ECONM_CRRTR AND NVL(AEC.DFIM_VGCIA_AGPTO_ECONM_CRRTR, TO_DATE(99991231, 'YYYYMMDD'))
                     --
                   WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
                GROUP BY AEC.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 
                         AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
                         AEC.DINIC_AGPTO_ECONM_CRRTR;
       
    COMMIT;
    --
       
    END LOOP;

    VAR_PONTO := 9;
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PO);
    Var_log_erro := 'TERMINO DO PROCESSAMENTO DA COMPETENCIA: '||COMPT_INICIAL||' A '||COMPT_FINAL||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;
  --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
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

END SGPB1170;
/

