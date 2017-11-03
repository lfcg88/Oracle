create or replace procedure sgpb_proc.SGPB0170_producao(
      Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
      chrNomeRotinaScheduler VARCHAR2,
      var_documento			 objtv_prod_crrtr.ccpf_cnpj_base%type default null, --var_documento,var_tipo_passoa
      var_tipo_passoa		 objtv_prod_crrtr.ctpo_pssoa%type default null
    ) IS
 -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0170
  --      DATA            :
  --      AUTOR           : Vinícius - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : insere Objetivo Extra-Banco PARA OS TRES PRÓXIMOS MESES A PARTIR DE UMA COMPETENCIA
  --                        PARA INICIAR O TRIMESTRE, AS COMPETENCIAS ACEITAS SÃO: AAAA03, AAAA06, AAAA09, AAAA12.
  --                        ASSIM, SE FOR PASSADO 200703 SERÃO CRIADOS OS OBJETIVOS PARA 200704, 200705, 200706
  --      ALTERAÇÕES      : Dava NO_DATA_FOUND no DELETE e no SELECT do CANAL. Abendava.
  --                        Nao tinha Exceptions. Não tinha o padrão do dwscheduler.
  --                        Ass. Wassily
-------------------------------------------------------------------------------------------------
  intrMesesApurConsiderar 	integer;
  VAR_VOBJTV_PROD_CRRTR     NUMBER;
  Comp_Real_Inicial			number;
  Comp_Real_Final			number;
  var_PARMPRODMINCRRTR		number;
  Comp_Real_CORRENTE		number;
  intComptInicial         	integer;
  intComptInicialAnterior 	integer;
  IntrcompetenciaAnterior 	integer;
  Intinicialfaixa 			Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  Intfinalfaixa   			Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  percentualPadrao 			parm_canal_vda_segur.pcrstc_prod_ano%type;
  vmin_prod_crrtr_J 		PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr%type;
  vmin_prod_crrtr_F 		PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr%type;
  vmin_prod_crrtr    		PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr%type;
  --Var_Crotna 				CONSTANT INT := '852';
  Var_Log_Erro 				Pc_Util_01.Var_Log_Erro%TYPE;
  VAR_PONTO_ERRO            NUMBER;
  VAR_FLAG					CHAR(01);
  -------------------------------------------------------------------------------------------------
  PROCEDURE getMesesApuracaoConsiderar(intrMesesApurConsiderar OUT Parm_Per_Apurc_Canal.Qmes_Anlse%TYPE,
                   Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                   Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                   Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc%TYPE) IS
  BEGIN
    VAR_PONTO_ERRO := 15;
    SELECT ppac.qmes_perdc_apurc INTO intrMesesApurConsiderar
      	   FROM Parm_Per_Apurc_Canal ppac
     WHERE ppac.Ccanal_Vda_Segur = PC_UTIL_01.Extra_Banco and
       Last_Day(To_Date(Intrvigencia||'01','YYYYMMDD')) BETWEEN ppac.Dinic_Vgcia_Parm AND pc_util_01.Sgpb0031(ppac.Dfim_Vgcia_Parm)
       AND ppac.Ctpo_Apurc = Intrtpapurc;
  end getMesesApuracaoConsiderar;
  -------------------------------------------------------------------------------------------------
  procedure getPercentualPadrao
   (
      percentualPadrao out parm_canal_vda_segur.pcrstc_prod_ano %type,
      Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
      Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE
   ) IS
   begin
     VAR_PONTO_ERRO := 16;
     select pcvs.pcrstc_prod_ano
       into percentualPadrao
     from parm_canal_vda_segur pcvs
     where pcvs.ccanal_vda_segur = PC_UTIL_01.Extra_Banco
       and LAST_DAY(To_Date(Intrvigencia||'01', 'YYYYMMDD')) BETWEEN
           PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'dd/MM/yyyy'));
   end getPercentualPadrao;
   ------------------------------------------------------------------------------------------------
    procedure MinimoProducaoauto
   (
      var_PARMPRODMINCRRTR out PARM_PROD_MIN_CRRTR.vmin_prod_crrtr%type,
      Intrcanal      IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
      Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE
   ) IS
   begin
     VAR_PONTO_ERRO := 46;
     select VMIN_PROD_APURC into var_PARMPRODMINCRRTR
     		from PARM_CANAL_VDA_SEGUR
            where ccanal_vda_segur = PC_UTIL_01.Extra_Banco
                  and LAST_DAY(To_Date(Intrvigencia||'01','YYYYMMDD')) BETWEEN
                  DINIC_VGCIA_PARM AND NVL(DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'dd/MM/yyyy'));
     VAR_PONTO_ERRO := 47;
   end MinimoProducaoauto;
  -------------------------------------------------------------------------------------------------
   PROCEDURE getIntervaloFaixa(Intrfaixainicial OUT Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE,
                     Intrfaixafinal OUT Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE,
                     Intrcanal      IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
  BEGIN
    VAR_PONTO_ERRO := 17;
    SELECT PCVS.CINIC_FAIXA_CRRTR, PCVS.CFNAL_FAIXA_CRRTR INTO INTRFAIXAINICIAL, INTRFAIXAFINAL
      FROM PARM_CANAL_VDA_SEGUR PCVS
     WHERE PCVS.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
       AND LAST_DAY(TO_DATE(Intrvigencia||'01', 'YYYYMMDD')) BETWEEN
           PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'DD/MM/YYYY'));
  END getIntervaloFaixa;
  -------------------------------------------------------------------------------------------------
  PROCEDURE getValorObjtvRe(
    vmin_prod_crrtr out PARM_PROD_MIN_CRRTR.Vmin_Prod_Crrtr%type,
    Intrcanal       IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
    chrTpPessoa     in crrtr_unfca_cnpj.ctpo_pssoa%type,
    Intrvigencia    IN Prod_Crrtr.Ccompt_Prod%TYPE
  ) IS
  BEGIN
    VAR_PONTO_ERRO := 18;
    SELECT ppmc.vmin_prod_crrtr INto vmin_prod_crrtr
      		FROM PARM_PROD_MIN_CRRTR PPMC
     WHERE PPMC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
       AND PPMC.CGRP_RAMO_PLANO = PC_UTIL_01.Re
       AND PPMC.CTPO_PSSOA = chrTpPessoa
       AND PPMC.CTPO_PER = 'M'
       AND Last_Day(To_Date(Intrvigencia||'01' , 'YYYYMMDD'))
           BETWEEN PPMC.DINIC_VGCIA_PARM
               AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'));
  END getValorObjtvRe;
  -------------------------------------------------------------------------------------------------
begin
  VAR_PONTO_ERRO := 1;
  --  Informa ao scheduler o começo da procedure
  PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,852,PC_UTIL_01.Var_Rotna_Pc);
  commit;
  Comp_Real_Inicial := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(Intrcompetencia||'01','YYYYMMDD'),1),'YYYYMM')); -- Atenção. Somo mais um para deletar o mes seguinte. Wassily
  IF TO_NUMBER(SUBSTR(Intrcompetencia,5,2)) NOT IN (3,6,9,12) THEN
     PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'COMPETENCIA: '||Comp_Real_Inicial||' INVALIDA.',
  		   										 Pc_Util_01.Var_Log_Processo,NULL,NULL);
     COMMIT;
     RAISE_APPLICATION_ERROR(-20023,'COMPETENCIA: '||Comp_Real_Inicial||' INVALIDA.');
  END IF;
  --Recupera os meses de apuração
  VAR_PONTO_ERRO := 2;
  getMesesApuracaoConsiderar(intrMesesApurConsiderar,1,Comp_Real_Inicial,1);
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'Meses de Apuracao a Considerar: '||intrMesesApurConsiderar,
                                            Pc_Util_01.Var_Log_Processo,NULL,NULL);
  COMMIT;
  VAR_PONTO_ERRO := 3;
  intComptInicial := Comp_Real_Inicial;
  vAR_PONTO_ERRO := 4;
  --Recupera o intervalo da faixa do canal
  getIntervaloFaixa(Intinicialfaixa,Intfinalfaixa,1,Comp_Real_Inicial);
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'Competencia Inicial: '||intComptInicial||' Inicio Faixa: '||Intinicialfaixa||
                             ' Final Faixa: '||Intfinalfaixa,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  COMMIT;
  VAR_PONTO_ERRO := 5;
  intComptInicialAnterior := To_Number(To_Char(Add_Months(To_Date(intComptInicial, 'yyyymm'), -12), 'YYYYMM'));
  IntrcompetenciaAnterior := To_Number(To_Char(Add_Months(To_Date(( Comp_Real_Inicial + (intrMesesApurConsiderar-1)),
                                     'yyyymm'),-12),'YYYYMM'));
  VAR_PONTO_ERRO := 6;
  --Recupera o percentual padrão
  getPercentualPadrao( percentualPadrao,1,Comp_Real_Inicial );
  VAR_PONTO_ERRO := 7;
  PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'ComptInicialAnterior: '||intComptInicialAnterior||' competenciaAnterior: '||
  					IntrcompetenciaAnterior||' percentualPadrao: '||percentualPadrao,Pc_Util_01.Var_Log_Processo,NULL,NULL);
  -- -----------------------------------------------------------------------------------------------
  -- A PARTIR DAQUI A LOGICA QUEBRA PORQUE: OU CALCULA PARA TODOS OU CALCULA APENAS PARA UM CORRETOR
  -- ASS. WASSILY. 02/08/2007
  -- -----------------------------------------------------------------------------------------------
  if var_documento is null AND var_tipo_passoa IS NULL then
    VAR_PONTO_ERRO := 20;
    begin
       Comp_Real_Final := (Comp_Real_Inicial + (intrMesesApurConsiderar - 1));
       VAR_PONTO_ERRO := 21;
       PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'Compt. Inicial A Deletar: '||Comp_Real_Inicial||
                                                     ' Competencia Final A Deletar: '||Comp_Real_Final,
                                                     Pc_Util_01.Var_Log_Processo,NULL,NULL);
       COMMIT;
       VAR_PONTO_ERRO := 22;
       DELETE OBJTV_PROD_CRRTR OPC
  	 		WHERE OPC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco AND
  	 		      CANO_MES_COMPT_OBJTV BETWEEN Comp_Real_Inicial AND Comp_Real_Final;
  	   VAR_PONTO_ERRO := 23;
    exception
  	   when no_data_found then null;
  	   when others then
  	         Var_Log_Erro := 'ERRO NO DELETE DO OBJETIVO EXTRABANCO, COMPETENCIA: '||Comp_Real_Inicial||' ERRO : '||SQLERRM;
    	         ROLLBACK;
	    	     PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    		     COMMIT;
    		     RAISE_APPLICATION_ERROR(-20023,Var_Log_Erro);
    END;
    VAR_PONTO_ERRO := 8;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'OS POSSIVEIS OBJETIVOS EXTRABANCO DO PERIODO '||Comp_Real_Inicial||' A '||
                          Comp_Real_Final||' FORAM EXCLUIDOS. EXCLUSOES: '||SQL%ROWCOUNT||' LINHAS.',
                          Pc_Util_01.Var_Log_Processo,NULL,NULL);
    COMMIT;
    for i in 1 .. intrMesesApurConsiderar
    loop
       IF I = 1 THEN
          Comp_Real_CORRENTE := Comp_Real_Inicial;
       ELSE
          Comp_Real_CORRENTE := Comp_Real_CORRENTE + 1;
          intComptInicialAnterior := intComptInicialAnterior + 1;
       END IF;
       VAR_PONTO_ERRO := 80;
       MinimoProducaoauto(var_PARMPRODMINCRRTR,PC_UTIL_01.Extra_Banco,Comp_Real_CORRENTE);
       VAR_PONTO_ERRO := 81;
       PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'INSERINDO OBJETIVOS DA COMPETENCIA: '||Comp_Real_CORRENTE||
       												 ' COMPETENCIA BASE PARA O CALCULO: '||intComptInicialAnterior||
       												 ' MIN.PROD.PADRAO: '||var_PARMPRODMINCRRTR,
       												 Pc_Util_01.Var_Log_Processo,NULL,NULL);
       commit;
       var_PARMPRODMINCRRTR := var_PARMPRODMINCRRTR / 3;
       VAR_PONTO_ERRO := 83;
       INSERT INTO OBJTV_PROD_CRRTR
       (  CTPO_PSSOA, CCPF_CNPJ_BASE, CGRP_RAMO_PLANO, CCANAL_VDA_SEGUR, CANO_MES_COMPT_OBJTV, CSEQ_OBJTV_CRRTR,
          VOBJTV_PROD_CRRTR_ALT, VOBJTV_PROD_CRRTR_ORIGN, CIND_REG_ATIVO, DULT_ALT, CRESP_ULT_ALT
       )
    	SELECT DISTINCT C.CTPO_PSSOA,C.CCPF_CNPJ_BASE,PC_UTIL_01.Auto,PC_UTIL_01.Extra_Banco,Comp_Real_CORRENTE,1,
    	   --DECODE(PC.VPROD_CRRTR,NULL,max(var_PARMPRODMINCRRTR),SUM(PC.VPROD_CRRTR * (1+(NVL(CCC.PCRSCT_PROD_ALT,PERCENTUALPADRAO)/100) ) ) ),
           --DECODE(PC.VPROD_CRRTR,NULL,max(var_PARMPRODMINCRRTR),SUM(PC.VPROD_CRRTR * (1+(NVL(CCC.PCRSCT_PROD_ALT,PERCENTUALPADRAO)/100) ) ) ),
           --SUM(PC.VPROD_CRRTR * (1+(NVL(CCC.PCRSCT_PROD_ALT,20)/100))),
           --SUM(PC.VPROD_CRRTR * (1+(NVL(CCC.PCRSCT_PROD_ALT,20)/100))),
           sum(NVL(PC.VPROD_CRRTR,0)), sum(NVL(PC.VPROD_CRRTR,0)), 'S', SYSDATE, 'SGPB0170-EXTRABANCO-1'
           FROM CRRTR C
      			JOIN PARM_INFO_CAMPA PIC
        			 ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
        			AND PIC.DFIM_VGCIA_PARM IS NULL
      			JOIN CRRTR_ELEIT_CAMPA CEC
       	 			 ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
        		    AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
        			AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
        			AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
      			LEFT JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                    AND PC.CUND_PROD = C.CUND_PROD
                    AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
                    AND PC.CCOMPT_PROD = intComptInicialAnterior
                    AND PC.CTPO_COMIS = 'CN'
      			LEFT JOIN CARAC_CRRTR_CANAL CCC
        			ON CCC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
       				AND CCC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       				AND CCC.CCPF_CNPJ_BASE   = C.CCPF_CNPJ_BASE
       				AND CCC.CTPO_PSSOA       = C.CTPO_PSSOA
       				AND CCC.CIND_PERC_ATIVO = 'S'
     	    WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
     	    GROUP BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE
     		ORDER BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE;
    VAR_PONTO_ERRO := 9;
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'VAI INICIAR O INSERT DO OBJETIVO RE/BILHETE COMPETENCIA: '||Comp_Real_CORRENTE,
       												 Pc_Util_01.Var_Log_Processo,NULL,NULL);
    COMMIT;
    getValorObjtvRe(vmin_prod_crrtr_j,1,'J',Comp_Real_Inicial);
    VAR_PONTO_ERRO := 10;
    getValorObjtvRe(vmin_prod_crrtr_f,1,'F',Comp_Real_Inicial);
    VAR_PONTO_ERRO := 11;
    INSERT INTO objtv_prod_crrtr
      (    ctpo_pssoa,
           ccpf_cnpj_base,
           cgrp_ramo_plano,
           ccanal_vda_segur,
           cano_mes_compt_objtv,
           cseq_objtv_crrtr,
           vobjtv_prod_crrtr_alt,
           vobjtv_prod_crrtr_orign,
           cind_reg_ativo,
           dult_alt,
           cresp_ult_alt
        )
        SELECT C.CTPO_PSSOA,
               C.CCPF_CNPJ_BASE,
               PC_UTIL_01.Re,
               PC_UTIL_01.Extra_Banco,
               Comp_Real_CORRENTE,
               1,
               decode(c.ctpo_pssoa,'J',vmin_prod_crrtr_j/3, vmin_prod_crrtr_f/3) * intrMesesApurConsiderar,
               decode(c.ctpo_pssoa,'J',vmin_prod_crrtr_j/3, vmin_prod_crrtr_f/3) * intrMesesApurConsiderar,
               'S',
               sysdate,
               'SGPB0170-EXTRABANCO-2'
          FROM CRRTR C
          JOIN PARM_INFO_CAMPA PIC
            ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
            AND PIC.DFIM_VGCIA_PARM IS NULL
          JOIN CRRTR_ELEIT_CAMPA CEC
            ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
            AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
            AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
            AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
         WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
         GROUP BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE;
    end loop;
    -- DEPOIS QUE INSERIU VAI FAZER UPDATE PARA COLOCAR A FAIXA DO OBJETIVO
    -- nova regra para percentual de crescimento da meta
    -- 1) até 25000 (inclusive) coloca 30000
    -- 2) Maior que 25000 até 300000 (inclusive) coloca 20%
    -- 3) Maior que 300000 até 600000 (inclusive) coloca (10%)
    -- 4) Maior que 600000 em diante (5%)
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'CALCULANDO AS FAIXAS DE OBJETIVO DO AUTO',
       					   Pc_Util_01.Var_Log_Processo,NULL,NULL);
    COMMIT;
    VAR_PONTO_ERRO := 90;
    FOR I IN ( SELECT ctpo_pssoa, ccpf_cnpj_base, CGRP_RAMO_PLANO, CSEQ_OBJTV_CRRTR,
                      CIND_REG_ATIVO, sum(VOBJTV_PROD_CRRTR_ORIGN) VOBJTV_PROD_CRRTR_ORIGN
                      FROM OBJTV_PROD_CRRTR
                      where CGRP_RAMO_PLANO = PC_UTIL_01.Auto AND
    			            CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final and
    			            CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco AND
    			            CSEQ_OBJTV_CRRTR = 1 AND
    			            CIND_REG_ATIVO = 'S'
    			            group by ctpo_pssoa, ccpf_cnpj_base, CGRP_RAMO_PLANO, CSEQ_OBJTV_CRRTR,
                            CIND_REG_ATIVO)
    LOOP
            VAR_PONTO_ERRO := 91;
            IF I.VOBJTV_PROD_CRRTR_ORIGN <= 25000 THEN
                    VAR_PONTO_ERRO := 92;
    		   		update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = 10000,
    		   		       vobjtv_prod_crrtr_alt   = 10000
    		   			where
    		   		    	ctpo_pssoa = i.ctpo_pssoa and
    		   		    	ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    	CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    	CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    	CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    	CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    	CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		elsif I.VOBJTV_PROD_CRRTR_ORIGN > 25000 and I.VOBJTV_PROD_CRRTR_ORIGN <=  300000 THEN
    		        VAR_PONTO_ERRO := 93;
    		   		update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(20/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(20/100))
    		   			where
    		   		    	ctpo_pssoa = i.ctpo_pssoa and
    		   		    	ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    	CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    	CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    	CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    	CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    	CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		elsif I.VOBJTV_PROD_CRRTR_ORIGN > 300000 and I.VOBJTV_PROD_CRRTR_ORIGN <=  600000 THEN
    		        VAR_PONTO_ERRO := 94;
    				update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(10/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(10/100))
    		   		where
    		   		    ctpo_pssoa = i.ctpo_pssoa and
    		   		    ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		else
    		      VAR_PONTO_ERRO := 95;
    		      update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(5/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(5/100))
    		   		where
    		   		    ctpo_pssoa = i.ctpo_pssoa and
    		   		    ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		end if;
    END LOOP;
    VAR_PONTO_ERRO := 14;
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,852,PC_UTIL_01.VAR_ROTNA_PO);
    PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,'EXECUCAO REALIZADA COM SUCESSO','P', NULL, NULL);
    commit;
  else --------------------------------------------------------------------
    VAR_PONTO_ERRO := 100;
    begin
       Comp_Real_Final := (Comp_Real_Inicial + (intrMesesApurConsiderar - 1));
       VAR_PONTO_ERRO := 101;
       DELETE OBJTV_PROD_CRRTR OPC
  	 		WHERE OPC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco AND
  	 		      OPC.CCPF_CNPJ_BASE = var_documento AND --
  	 		      OPC.CTPO_PSSOA = var_tipo_passoa AND   --
  	 		      CANO_MES_COMPT_OBJTV BETWEEN Comp_Real_Inicial AND Comp_Real_Final;
  	   VAR_PONTO_ERRO := 102;
    exception
  	   when no_data_found then null;
  	   when others then
  	         Var_Log_Erro := 'ERRO NO DELETE DO OBJ. DO CORRETOR: '||var_documento||' COMP: '||Comp_Real_Inicial||
  	                         ' ERRO : '||SQLERRM;
    	         ROLLBACK;
    		     RAISE_APPLICATION_ERROR(-20023,Var_Log_Erro);
    END;
    VAR_PONTO_ERRO := 103;
    for i in 1 .. intrMesesApurConsiderar
    loop
       IF I = 1 THEN
          Comp_Real_CORRENTE := Comp_Real_Inicial;
       ELSE
          Comp_Real_CORRENTE := Comp_Real_CORRENTE + 1;
          intComptInicialAnterior := intComptInicialAnterior + 1;
       END IF;
       VAR_PONTO_ERRO := 104;
       MinimoProducaoauto(var_PARMPRODMINCRRTR,PC_UTIL_01.Extra_Banco,Comp_Real_CORRENTE);
       var_PARMPRODMINCRRTR := var_PARMPRODMINCRRTR / 3;
       VAR_PONTO_ERRO := 105;
       INSERT INTO OBJTV_PROD_CRRTR
       (  CTPO_PSSOA, CCPF_CNPJ_BASE, CGRP_RAMO_PLANO, CCANAL_VDA_SEGUR, CANO_MES_COMPT_OBJTV, CSEQ_OBJTV_CRRTR,
          VOBJTV_PROD_CRRTR_ALT, VOBJTV_PROD_CRRTR_ORIGN, CIND_REG_ATIVO, DULT_ALT, CRESP_ULT_ALT
       )
    	SELECT DISTINCT C.CTPO_PSSOA, C.CCPF_CNPJ_BASE, PC_UTIL_01.Auto, PC_UTIL_01.Extra_Banco, Comp_Real_CORRENTE, 1,
           sum(NVL(PC.VPROD_CRRTR,0)),sum(NVL(PC.VPROD_CRRTR,0)),'S',SYSDATE,'SGPB0170-EXTRABANCO-WEB'
           FROM CRRTR C
      			JOIN PARM_INFO_CAMPA PIC
        			 ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
        			AND PIC.DFIM_VGCIA_PARM IS NULL
      			JOIN CRRTR_ELEIT_CAMPA CEC
       	 			 ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
        		    AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
        			AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
        			AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
        			and CEC.CCPF_CNPJ_BASE = var_documento --
     	            and CEC.ctpo_pssoa = var_tipo_passoa   --
      			LEFT JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                    AND PC.CUND_PROD = C.CUND_PROD
                    AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
                    AND PC.CCOMPT_PROD = intComptInicialAnterior
                    AND PC.CTPO_COMIS = 'CN'
      			LEFT JOIN CARAC_CRRTR_CANAL CCC
        			ON CCC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
       				AND CCC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
       				AND CCC.CCPF_CNPJ_BASE   = C.CCPF_CNPJ_BASE
       				AND CCC.CTPO_PSSOA       = C.CTPO_PSSOA
       				AND CCC.CIND_PERC_ATIVO = 'S'
     	    WHERE ( C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa )
     	    GROUP BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE
     		ORDER BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE;
    VAR_PONTO_ERRO := 106;
    getValorObjtvRe(vmin_prod_crrtr,1,var_tipo_passoa,Comp_Real_Inicial);
    INSERT INTO objtv_prod_crrtr
      (    ctpo_pssoa, ccpf_cnpj_base, cgrp_ramo_plano, ccanal_vda_segur, cano_mes_compt_objtv, cseq_objtv_crrtr,
           vobjtv_prod_crrtr_alt, vobjtv_prod_crrtr_orign, cind_reg_ativo, dult_alt, cresp_ult_alt
        )
        SELECT C.CTPO_PSSOA, C.CCPF_CNPJ_BASE, PC_UTIL_01.Re, PC_UTIL_01.Extra_Banco, Comp_Real_CORRENTE, 1,
               ( vmin_prod_crrtr / 3 ) * intrMesesApurConsiderar, ( vmin_prod_crrtr / 3 ) * intrMesesApurConsiderar,
               'S', sysdate, 'SGPB0170-EXTRABANCO-WEB'
          		FROM CRRTR C
          		JOIN PARM_INFO_CAMPA PIC
            		ON PIC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
		            AND PIC.DFIM_VGCIA_PARM IS NULL
		          JOIN CRRTR_ELEIT_CAMPA CEC
		            ON CEC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
		            AND CEC.CTPO_PSSOA = C.CTPO_PSSOA
		            AND CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
		            AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM
		        	and CEC.CCPF_CNPJ_BASE = var_documento --
		     	    and CEC.ctpo_pssoa = var_tipo_passoa   --
		         WHERE C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa
        		 GROUP BY C.CTPO_PSSOA, C.CCPF_CNPJ_BASE;
    end loop;
    VAR_PONTO_ERRO := 109;
    FOR I IN ( SELECT ctpo_pssoa, ccpf_cnpj_base, CGRP_RAMO_PLANO, CSEQ_OBJTV_CRRTR,
                      CIND_REG_ATIVO, sum(VOBJTV_PROD_CRRTR_ORIGN) VOBJTV_PROD_CRRTR_ORIGN
                      FROM OBJTV_PROD_CRRTR
                      where CGRP_RAMO_PLANO = PC_UTIL_01.Auto AND
    			            CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final and
    			            CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco AND
    			            CSEQ_OBJTV_CRRTR = 1 AND
    			            CIND_REG_ATIVO = 'S' and
        			        CCPF_CNPJ_BASE = var_documento and --
     	                    ctpo_pssoa = var_tipo_passoa       --
    			            group by ctpo_pssoa, ccpf_cnpj_base, CGRP_RAMO_PLANO, CSEQ_OBJTV_CRRTR,
                            CIND_REG_ATIVO)
    LOOP
            VAR_PONTO_ERRO := 110;
            IF I.VOBJTV_PROD_CRRTR_ORIGN <= 25000 THEN
                    VAR_PONTO_ERRO := 92;
    		   		update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = 10000,
    		   		       vobjtv_prod_crrtr_alt   = 10000
    		   			where
    		   		    	ctpo_pssoa = i.ctpo_pssoa and
    		   		    	ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    	CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    	CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    	CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    	CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    	CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		elsif I.VOBJTV_PROD_CRRTR_ORIGN > 25000 and I.VOBJTV_PROD_CRRTR_ORIGN <=  300000 THEN
    		        VAR_PONTO_ERRO := 111;
    		   		update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(20/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(20/100))
    		   			where
    		   		    	ctpo_pssoa = i.ctpo_pssoa and
    		   		    	ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    	CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    	CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    	CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    	CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    	CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		elsif I.VOBJTV_PROD_CRRTR_ORIGN > 300000 and I.VOBJTV_PROD_CRRTR_ORIGN <=  600000 THEN
    		        VAR_PONTO_ERRO := 112;
    				update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(10/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(10/100))
    		   		where
    		   		    ctpo_pssoa = i.ctpo_pssoa and
    		   		    ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		else
    		      VAR_PONTO_ERRO := 113;
    		      update OBJTV_PROD_CRRTR set
    		   		       VOBJTV_PROD_CRRTR_ORIGN = VOBJTV_PROD_CRRTR_ORIGN * (1+(5/100)),
    		   		       vobjtv_prod_crrtr_alt   = VOBJTV_PROD_CRRTR_ORIGN * (1+(5/100))
    		   		where
    		   		    ctpo_pssoa = i.ctpo_pssoa and
    		   		    ccpf_cnpj_base = i.ccpf_cnpj_base and
    		   		    CGRP_RAMO_PLANO = i.CGRP_RAMO_PLANO and
    		   		    CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco and
    		   		    CSEQ_OBJTV_CRRTR = i.CSEQ_OBJTV_CRRTR and
    		   		    CIND_REG_ATIVO = i.CIND_REG_ATIVO and
    		   		    CANO_MES_COMPT_OBJTV between Comp_Real_Inicial and Comp_Real_Final;
    		end if;
    END LOOP;
    VAR_PONTO_ERRO := 114;
    commit;
  end if;
EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor. VAR_PONTO_ERRO: '||VAR_PONTO_ERRO||' Competência:' ||
                             Comp_Real_Inicial || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL, NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,852,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20023,'ERRO NA EXECUCAO DA ROTINA (EXCETION 1). VAR_PONTO_ERRO: '||VAR_PONTO_ERRO||
                                     ' ERRO : '||SQLERRM);
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao inserir objetivo. VAR_PONTO_ERRO: '||VAR_PONTO_ERRO||'  Competência:' ||
                             Comp_Real_Inicial || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(chrNomeRotinaScheduler,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,852,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20023,'ERRO NA EXECUCAO DA ROTINA (EXCETION 2). VAR_PONTO_ERRO: '||VAR_PONTO_ERRO||
                                     ' ERRO : '||SQLERRM);
end SGPB0170_producao;
/

