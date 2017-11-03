create or replace procedure sgpb_proc.SGPB0173 --(
--  INTCOMPT OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV %TYPE
--  INTCANAL OBJTV_PROD_CRRTR.CCANAL_VDA_SEGUR     %TYPE,
--  chrNomeRotinaScheduler VARCHAR2
--)
is
 -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0173
  --      DATA            :
  --      AUTOR           : VINÍCIUS FARIA - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : INCLUSÃO DO OBJETIVO E PRODUÇÃO NA TABELA DE RESUMO
  --                        DE OBJETIVO PARA O CANAL BANCO E FINASA
  --      ALTERAÇÕES      : 1) Colocado o paramentro 708 (carga diária). ass. Wassily (22/06/07)
  --                DATA  : 2) cOLOCADAS MENSAGENS DE MONITORAÇÃO. ass. Wassily (22/06/07)
  --					    3) Retirados os paramentros porque era desnecessário. ass. Wassily (22/06/07)
  --                        4) No delete dava abend se não deletadava nada. ass. Wassily (22/06/07)
  --                        5) Colocadas várias clausulas de exception. ass. Wassily (22/06/07)
  --      ALTERAÇÕES      : CORREÇÃO NA QUERY QUE INSERE NA TABELA OS CORRETORES QUE TEM PRODUÇÃO
  --                      : DESMENBRAMENTO - ALEXANDRE CYSNE ESTEVES 10/01/2008
  --
 -------------------------------------------------------------------------------------------------
  chrNomeRotinaScheduler CONSTANT CHAR(08) := 'SGPB0173';
  Intinicialfaixa 		Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  Intfinalfaixa   		Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  VAR_DCARGA 			date;
  VAR_DPROX_CARGA   	date;
  INTCOMPT 				OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%TYPE;
  INTCANAL 				OBJTV_PROD_CRRTR.CCANAL_VDA_SEGUR%TYPE;
  Var_Crotna 			CONSTANT INT := 853;
  Var_Log_Erro 			Pc_Util_01.Var_Log_Erro%TYPE;
  VAR_TRIMESTRE NUMBER := 0;
  COMPT_INICIAL NUMBER(6);
  COMPT_FINAL   NUMBER(6);
  -------------------------------------------------------------------------------------------------
   PROCEDURE getIntervaloFaixa(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr %TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr %TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
  BEGIN
    begin
    	SELECT PCVS.CINIC_FAIXA_CRRTR, PCVS.CFNAL_FAIXA_CRRTR
      		INTO INTRFAIXAINICIAL, INTRFAIXAFINAL
      		FROM PARM_CANAL_VDA_SEGUR PCVS
     		WHERE PCVS.CCANAL_VDA_SEGUR = INTRCANAL
       		AND LAST_DAY(TO_DATE(INTRVIGENCIA, 'YYYYMM'))
       		    BETWEEN PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999','DD/MM/YYYY'));
    exception
      	WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Select da PARM_CANAL_VDA_SEGUR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK;
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    end;
  END getIntervaloFaixa;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO O TRIMESTRE DO CORRETOR SELECIONADO
  ----------------------------------------------------------------------------------------
    PROCEDURE getTrimestre(VAR_TRIMESTRE out number) IS
    begin
      -- Pega primeira vez em que o corretor foi eleito
      --VAR_TRIMESTRE := TO_CHAR(LAST_DAY(TO_DATE(INTCOMPT, 'YYYYMM')),'Q');
      VAR_TRIMESTRE := TO_CHAR(LAST_DAY(TO_DATE(to_char(VAR_DPROX_CARGA,'YYYYMM'), 'YYYYMM')),'Q');
    end getTrimestre;
  ----------------------------------------------------------------------------------------geraDetail
    PROCEDURE getVlObjRe(
      vmin_prod_crrtr out PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr %type,
      Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
      chrTpPessoa     in crrtr_unfca_cnpj.ctpo_pssoa %type,
      Intrvigencia    IN Prod_Crrtr.Ccompt_Prod%TYPE
    ) IS
    BEGIN
      begin
	      SELECT ppmc.vmin_prod_crrtr into vmin_prod_crrtr
        		FROM PARM_PROD_MIN_CRRTR PPMC
       			WHERE PPMC.CCANAL_VDA_SEGUR = Intrcanal
         		AND PPMC.CGRP_RAMO_PLANO = pc_util_01.re
         		AND PPMC.CTPO_PSSOA = chrTpPessoa
         		AND PPMC.CTPO_PER = 'M'
         		AND Last_Day(To_Date( Intrvigencia , 'YYYYMM'))
             		BETWEEN PPMC.DINIC_VGCIA_PARM
                 		AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'));
       exception
      		WHEN OTHERS THEN
      			var_log_erro := substr(' Erro No Select da PARM_PROD_MIN_CRRTR. Compet: '||INTCOMPT||
      			                       ' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      			ROLLBACK;
      			PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      			PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      			COMMIT;
      			RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    end;
    END getVlObjRe;
  ----------------------------------------------------------------------------------------geraDetail
    PROCEDURE insertCascaResumo(P_COMPT RSUMO_OBJTV_CRRTR.CCOMPT%TYPE) IS
    BEGIN
        /*INSERE OS CORRETORES QUE NÃO TEM OBJETIVO - AUTO*/
        INSERT INTO RSUMO_OBJTV_CRRTR
          (CCOMPT,
           CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           CCPF_CNPJ_BASE,
           CTPO_PSSOA,
           CTPO_COMIS,
           VPROD_CRRTR,
           VOBJTV_PROD_CRRTR_ALT,
           VOBJTV_PROD_CRRTR_ORIGN,
           QTOT_ITEM_PROD,
           DINCL_REG,
           DALT_REG)
            SELECT
                 P_COMPT,
                 INTCANAL,
                 120,
                 CEC.CCPF_CNPJ_BASE,
                 CEC.CTPO_PSSOA,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 SYSDATE,
                 SYSDATE
            --
            FROM PARM_INFO_CAMPA PIC
            --
            JOIN CRRTR_ELEIT_CAMPA CEC
              ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM

           WHERE PIC.CCANAL_VDA_SEGUR = INTCANAL
             AND PIC.DFIM_VGCIA_PARM IS NULL
           --
           GROUP BY CEC.CTPO_PSSOA,
                 CEC.CCPF_CNPJ_BASE;
        COMMIT;
       /*INSERE OS CORRETORES QUE NÃO TEM OBJETIVO - RE*/
        INSERT INTO RSUMO_OBJTV_CRRTR
          (CCOMPT,
           CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           CCPF_CNPJ_BASE,
           CTPO_PSSOA,
           CTPO_COMIS,
           VPROD_CRRTR,
           VOBJTV_PROD_CRRTR_ALT,
           VOBJTV_PROD_CRRTR_ORIGN,
           QTOT_ITEM_PROD,
           DINCL_REG,
           DALT_REG)
            SELECT
                 P_COMPT,
                 INTCANAL,
                 810,
                 CEC.CCPF_CNPJ_BASE,
                 CEC.CTPO_PSSOA,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 SYSDATE,
                 SYSDATE
            --
            FROM PARM_INFO_CAMPA PIC
            --
            JOIN CRRTR_ELEIT_CAMPA CEC
              ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
           WHERE PIC.CCANAL_VDA_SEGUR = INTCANAL
             AND PIC.DFIM_VGCIA_PARM IS NULL
           --
           GROUP BY CEC.CTPO_PSSOA,CEC.CCPF_CNPJ_BASE;
        COMMIT;
        /*INSERE OS CORRETORES QUE NÃO TEM OBJETIVO - BILHETE*/
        INSERT INTO RSUMO_OBJTV_CRRTR
          (CCOMPT,
           CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           CCPF_CNPJ_BASE,
           CTPO_PSSOA,
           CTPO_COMIS,
           VPROD_CRRTR,
           VOBJTV_PROD_CRRTR_ALT,
           VOBJTV_PROD_CRRTR_ORIGN,
           QTOT_ITEM_PROD,
           DINCL_REG,
           DALT_REG)
            SELECT
                 P_COMPT,
                 INTCANAL,
                 999,
                 CEC.CCPF_CNPJ_BASE,
                 CEC.CTPO_PSSOA,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 SYSDATE,
                 SYSDATE
            --
            FROM PARM_INFO_CAMPA PIC
            --
            JOIN CRRTR_ELEIT_CAMPA CEC
              ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
             AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM

           WHERE PIC.CCANAL_VDA_SEGUR = INTCANAL
             AND PIC.DFIM_VGCIA_PARM IS NULL
           --
           GROUP BY CEC.CTPO_PSSOA,
                 CEC.CCPF_CNPJ_BASE;
        COMMIT;
   END insertCascaResumo;
  ----------------------------------------------------------------------------------------geraDetail
BEGIN
  -- inicio da procedure, limpando log
  PR_LIMPA_LOG_CARGA(chrNomeRotinaScheduler);
  -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
  PR_LE_PARAMETRO_CARGA(Var_Crotna, VAR_DCARGA, VAR_DPROX_CARGA);
  INTCOMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
  var_log_erro := 'INICIO DO PROCESSAMENTO. COMPETENCIA: '||INTCOMPT||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.Var_Rotna_Pc);
  commit;
  -- VAI FICAR EM LOOPING PARA CADA CANAL ATIVO.
  for INTCANALFOR in ( select distinct CCANAL_VDA_SEGUR from PARM_CANAL_VDA_SEGUR
                              where DFIM_VGCIA_PARM is null AND
                                    CCANAL_VDA_SEGUR <> pc_util_01.Extra_Banco )
  loop
    --
  	INTCANAL := INTCANALFOR.CCANAL_VDA_SEGUR;
  	/*RECUPERA O TRIMESTRE DA COMPETÊNCIA PASSADA POR PARÂMETRO*/
    getTrimestre(VAR_TRIMESTRE);
    --
    /*ATRIBUI O PERÍODO DO TRIMESTRE*/
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
    EnD If;
  	var_log_erro := 'PROCESSAMENTO DO CANAL '||INTCANALFOR.CCANAL_VDA_SEGUR||'.';
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
  	--Recupera o intervalo da faixa do canal
  	getIntervaloFaixa(Intinicialfaixa,Intfinalfaixa,INTCANALFOR.CCANAL_VDA_SEGUR,Intcompt);
  	/*LOOP PARA REALIZAR OS UPDATES*/
  	FOR V_COMPT IN INTCOMPT..COMPT_FINAL
  	LOOP
      /*EXCLUIR TODOS DO CANAL E COMPETÊNCIA*/
      begin
      	DELETE FROM RSUMO_OBJTV_CRRTR ROC
      		WHERE ROC.CCOMPT = V_COMPT
        	AND ROC.CTPO_COMIS = 'CN'
        	AND ROC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR;
      exception
         WHEN No_Data_Found THEN null;
      end;
      /*INSERIR AS CASCAS PARA TODOS OS CORRETORES SEM OBJETIVO E SEM PRODUÇÃO*/
      insertCascaResumo(V_COMPT);
      /*INSERE NA TABELA OS CORRETORES QUE TEM PRODUÇÃO*/
      FOR C IN(SELECT
               PC.CGRP_RAMO_PLANO,
               C.CCPF_CNPJ_BASE,
               C.CTPO_PSSOA,
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
          JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                            AND PC.CUND_PROD = C.CUND_PROD
                            AND PC.CCOMPT_PROD = V_COMPT
                            AND PC.CGRP_RAMO_PLANO IN (120,810,999)
                            AND PC.CTPO_COMIS = 'CN'
          --
          JOIN MPMTO_AG_CRRTR MAC
          	 ON MAC.CUND_PROD = C.CUND_PROD
          	AND MAC.CCRRTR_DSMEM = C.CCRRTR
          	AND MAC.CCRRTR_ORIGN BETWEEN Intinicialfaixa AND Intfinalfaixa
            --AND last_day(TO_DATE(INTCOMPT, 'YYYYMM'))
          	--	BETWEEN MAC.DENTRD_CRRTR_AG AND  NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
            --
            -- ALEXANDRE CYSNE 10/01/2008
            --
            AND LAST_DAY(TO_DATE(V_COMPT, 'YYYYMM')) >= MAC.DENTRD_CRRTR_AG
            AND TRUNC(TO_DATE(V_COMPT,'YYYYMM'),'MM') < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
            --
            --
            --                    
         	GROUP BY C.CTPO_PSSOA,
               C.CCPF_CNPJ_BASE,
               PC.CGRP_RAMO_PLANO,
               PC.CTPO_COMIS)
      LOOP
        /*ATUALIZA A PRODUÇÃO PARA TODOS OS CANAIS*/
        	UPDATE RSUMO_OBJTV_CRRTR ROC
           		SET ROC.VPROD_CRRTR = C.PROD,
               		ROC.QTOT_ITEM_PROD = C.ITEM
         		WHERE CCOMPT = V_COMPT
           			AND CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
           			AND CGRP_RAMO_PLANO = C.CGRP_RAMO_PLANO
           			AND CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
           			AND CTPO_PSSOA = C.CTPO_PSSOA
           			AND CTPO_COMIS = C.CTPO_COMIS;
           COMMIT;
      END LOOP;
      FOR J IN(SELECT ROC.CTPO_PSSOA,ROC.CCPF_CNPJ_BASE,ROC.CGRP_RAMO_PLANO,
           		--
           		CASE
               		WHEN SUM(NVL(OPC.VOBJTV_PROD_CRRTR_ALT,0)) < PCVS.VMIN_PROD_APURC THEN
                  		PCVS.VMIN_PROD_APURC/3
               		ELSE
                  		NVL(OPC1.VOBJTV_PROD_CRRTR_ALT,0)
           		END V_OBJTV_PROD_ALT
           		--
            	FROM RSUMO_OBJTV_CRRTR ROC
          		--
            	JOIN PARM_INFO_CAMPA PIC ON PIC.CCANAL_VDA_SEGUR = ROC.CCANAL_VDA_SEGUR
                	                    AND PIC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
                    	                AND PIC.DFIM_VGCIA_PARM IS NULL
          		--
            	JOIN PARM_CANAL_VDA_SEGUR PCVS ON PCVS.CCANAL_VDA_SEGUR =
                	                              PIC.CCANAL_VDA_SEGUR
                    	                      AND PCVS.DINIC_VGCIA_PARM =
                        	                      PIC.DINIC_VGCIA_PARM
          		--
            	LEFT JOIN OBJTV_PROD_CRRTR OPC ON OPC.CTPO_PSSOA = ROC.CTPO_PSSOA
                		                     AND OPC.CCPF_CNPJ_BASE = ROC.CCPF_CNPJ_BASE
                        		             AND OPC.CGRP_RAMO_PLANO = ROC.CGRP_RAMO_PLANO
                                		     AND OPC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                                     		 AND OPC.CANO_MES_COMPT_OBJTV BETWEEN COMPT_INICIAL AND COMPT_FINAL
              			                       AND OPC.CIND_REG_ATIVO = 'S'
          		--
              LEFT JOIN OBJTV_PROD_CRRTR OPC1 ON OPC1.CTPO_PSSOA = ROC.CTPO_PSSOA
                                AND OPC1.CCPF_CNPJ_BASE = ROC.CCPF_CNPJ_BASE
                                AND OPC1.CGRP_RAMO_PLANO =
                                    ROC.CGRP_RAMO_PLANO
                                AND OPC1.CCANAL_VDA_SEGUR =
                                    PIC.CCANAL_VDA_SEGUR
                                AND OPC1.CANO_MES_COMPT_OBJTV = V_COMPT
                                AND OPC1.CIND_REG_ATIVO = 'S'
              --
           		WHERE ROC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
             		AND ROC.CCOMPT = V_COMPT
             		AND ROC.CGRP_RAMO_PLANO = 120
             		AND ROC.CTPO_COMIS = 'CN'
          		--
           		GROUP BY ROC.CTPO_PSSOA, ROC.CCPF_CNPJ_BASE, ROC.CGRP_RAMO_PLANO,
                       PCVS.VMIN_PROD_APURC, OPC1.VOBJTV_PROD_CRRTR_ALT )
      LOOP
            /*ATUALIZAR A TABELA DE RESUMO DE OBJETIVO PARA INCLUIR OBJETIVO*/
      		UPDATE RSUMO_OBJTV_CRRTR
         	SET VOBJTV_PROD_CRRTR_ALT = J.V_OBJTV_PROD_ALT,
             	VOBJTV_PROD_CRRTR_ORIGN = J.V_OBJTV_PROD_ALT
       			WHERE CCOMPT = V_COMPT
         			AND CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
         			AND CGRP_RAMO_PLANO = J.CGRP_RAMO_PLANO
         			AND CCPF_CNPJ_BASE = J.CCPF_CNPJ_BASE
         			AND CTPO_PSSOA = J.CTPO_PSSOA
         			AND CTPO_COMIS = 'CN';
            COMMIT;
        END LOOP;

        /*RECUPERA O VALOR MÍNIMO PARA APURAÇÃO DO GRUPO RE*/
         FOR K IN ( SELECT ROC.CTPO_PSSOA, ROC.CCPF_CNPJ_BASE, ROC.CGRP_RAMO_PLANO,
     				               NVL(OPC.VOBJTV_PROD_CRRTR_ALT,0) V_OBJTV_PROD_ALT
     				--
      			FROM RSUMO_OBJTV_CRRTR ROC
    				--
      			JOIN PARM_INFO_CAMPA PIC ON PIC.CCANAL_VDA_SEGUR = ROC.CCANAL_VDA_SEGUR
                              			AND PIC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
                              			AND PIC.DFIM_VGCIA_PARM IS NULL
    				--
      			LEFT JOIN OBJTV_PROD_CRRTR OPC ON OPC.CTPO_PSSOA = ROC.CTPO_PSSOA
                               			AND OPC.CCPF_CNPJ_BASE = ROC.CCPF_CNPJ_BASE
                               			AND OPC.CGRP_RAMO_PLANO = ROC.CGRP_RAMO_PLANO
                               			AND OPC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
                               			AND OPC.CANO_MES_COMPT_OBJTV = V_COMPT
                               			AND OPC.CIND_REG_ATIVO = 'S'
    				--
     				WHERE ROC.CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
       				AND ROC.CCOMPT = V_COMPT
       				AND ROC.CGRP_RAMO_PLANO IN (810,999)
       				AND ROC.CTPO_COMIS = 'CN'
    				--
     				GROUP BY ROC.CTPO_PSSOA, ROC.CCPF_CNPJ_BASE, ROC.CGRP_RAMO_PLANO,OPC.VOBJTV_PROD_CRRTR_ALT)
            LOOP

/*       	getVlObjRe(vmin_prod_crrtr_j,pc_util_01.Extra_Banco,'J',V_COMPT);*/
           	/*ATUALIZAR A TABELA DE RESUMO DE OBJETIVO PARA INCLUIR OBJETIVO*/
            UPDATE RSUMO_OBJTV_CRRTR
        		SET VOBJTV_PROD_CRRTR_ALT = K.V_OBJTV_PROD_ALT,
             		VOBJTV_PROD_CRRTR_ORIGN = K.V_OBJTV_PROD_ALT
       			WHERE CCOMPT = V_COMPT
         			AND CCANAL_VDA_SEGUR = INTCANALFOR.CCANAL_VDA_SEGUR
         			AND CGRP_RAMO_PLANO = K.CGRP_RAMO_PLANO
         			AND CCPF_CNPJ_BASE = K.CCPF_CNPJ_BASE
         			AND CTPO_PSSOA = K.CTPO_PSSOA
         			AND CTPO_COMIS = 'CN';
            COMMIT;
        END LOOP;
    END LOOP;
  end loop;
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PO);
  var_log_erro := 'TERMINO DO PROCESSAMENTO DA COMPETENCIA: '||INTCOMPT||'.';
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;
  --
EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor. Competência: ' ||
                             IntCompt || ' # ' || SQLERRM,
                             1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                              Var_Log_Erro,
                              Pc_Util_01.Var_Log_Processo,
                              NULL,
                              NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                               Var_Crotna,
                               PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
    WHEN OTHERS THEN
      var_log_erro := substr(' Compet: '||INTCOMPT||' # '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,Var_Crotna,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,var_log_erro);
end SGPB0173;
/

