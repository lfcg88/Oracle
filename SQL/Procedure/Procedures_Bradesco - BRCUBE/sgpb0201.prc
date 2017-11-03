CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0201(
                            pCanal                IN  parm_crrtr_excec.ccanal_vda_segur%TYPE,
                            pCpf_cnpj_completo    IN  NUMBER,
                            pTipo_pssoa           IN  crrtr_unfca_cnpj.ctpo_pssoa%TYPE,
                            pAnoInclusao          IN  VARCHAR2,
                            pTrimestreInclusao    IN  VARCHAR2,
                            pCompetencia          IN  NUMBER,
                            pValorObjetivo        IN  NUMBER,
                            pUsuario    	        IN  VARCHAR2,
                            pMensagem             out VARCHAR2,
                            pCespIns              IN  VARCHAR2,
                            pCespRet              out VARCHAR2
                             ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0201R
  --      data            : 11/07/06 14:39:18
  --      autor           : WASSILY CHUK SEIBLITZ GUANAES / RALPH AGUIAR
  --      objetivo        : ELEGE MANUALMENTE (VIA INTRANET) UM CORRETOR NO PLANO DE BONUS E COLOCA ELE TAMBÉM NA TABELA DE
  --					    EXEÇÕES JÁ QUE ELE FOI ELEITO NA MÃO.
  --      Explicações     : 14 bytes se CNPJ
  --                        11 bytes se CPF
  --
  --                        VARIAVEL RECEBIDA DO JAVA E TRATAMENTO
  --                        --------------------------------------
  --                        pCespIns = 0 => O PL vai checar se o corretor está no CESP, se estiver dá Return, voltando "pCespRet = 0".
  --                                        Se não estiver no CESP vai incluir e vai retornar "pCespRet = 1".
  --				        pCespIns = 1 => Não vai ao Cesp, continua o PL e vai incluir e vai retornar "pCespRet = 1".
  --
  --                        26/11/2007 - ALEXANDRE - RALPH - WASSILY
  --                        foi alterado critica para validar se o corretor esta na faixa 100000 no cpvo
  -------------------------------------------------------------------------------------------------
  TT                INT;
  TT_CPFCNPJ        number;
  MT_CPFCNPJ        CRRTR_EXCEC_CAMPA.RMOTVO_EXCEC_CRRTR%TYPE;
  DT_INIC_VIG	      date;
  P_MES_01_PARM     number;
  P_MES_02_PARM     number;
  P_MES_03_PARM     number;
  P_MES_01_PARM_AUX VARCHAR2(2);
  P_MES_02_PARM_AUX VARCHAR2(2);
  P_MES_03_PARM_AUX VARCHAR2(2);
  mesageCalc        VARCHAR2(30);
  valorObjetivoIn   number;
  valorInserido     number;
  dtApur            number;
  pCpf_cnpj_aux	  	NUMBER;
  pCpf_cnpj_base  	crrtr_unfca_cnpj.ccpf_cnpj_base%TYPE;
  pCompetencia_apur number := pAnoInclusao || pTrimestreInclusao;
  var_flag          char(01);
  VAR_CESP		    INFO_LISTA_NEGRA_CRRTR.CSIT_CRRTR_BDSCO%TYPE;
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
PROCEDURE setObjetivoBancoFinasa(
  P_CCPF_CNPJ_BASE    IN  number,
  P_CTPO_PSSOA        IN  VARCHAR2,
  P_CCANAL_VDA_SEGUR  IN  number,
  P_RAMO              IN  number,
  P_ANO               IN  number,
  P_MES_01_PARM       IN  number,
  P_MES_03_PARM       IN  number,
  P_VALOR_OBJETIVO    IN  number )
IS
  conta_mes    NUMBER;
  ano_mes      NUMBER;
  valorObjt    NUMBER(17,2);
BEGIN
     conta_mes :=  P_MES_01_PARM;
     valorObjt :=  P_VALOR_OBJETIVO;
     pMensagem := NULL;
     WHILE conta_mes <=  P_MES_03_PARM
     LOOP
           if (conta_mes = 10 or conta_mes = 11 or conta_mes = 12)
           then
               ano_mes := P_ANO || conta_mes;
           else
               ano_mes := P_ANO || '0' || conta_mes;
           end if;
           INSERT INTO OBJTV_PROD_CRRTR
           		(CTPO_PSSOA, CCPF_CNPJ_BASE, CGRP_RAMO_PLANO, CCANAL_VDA_SEGUR, CANO_MES_COMPT_OBJTV,
                 CSEQ_OBJTV_CRRTR, VOBJTV_PROD_CRRTR_ALT, VOBJTV_PROD_CRRTR_ORIGN, CIND_REG_ATIVO,
                 DULT_ALT, CRESP_ULT_ALT)
  			     VALUES (P_CTPO_PSSOA, P_CCPF_CNPJ_BASE, P_RAMO, P_CCANAL_VDA_SEGUR,
  			             ano_mes, 1, valorObjt, valorObjt, 'S',SYSDATE,'SGPB0201-BANCOFINASA-WEB');
           conta_mes := conta_mes + 1;
     END LOOP;
EXCEPTION
  	 	WHEN OTHERS THEN
  	 	     pMensagem := 'ERRO NO INSERT OBJETIVOS BANCO/FINASA - ERRO : '||SQLERRM;
  	 	     ROLLBACK;
             DELETE from CRRTR_ELEIT_CAMPA where ccpf_cnpj_base = P_CCPF_CNPJ_BASE and
                                                 CTPO_PSSOA = P_CTPO_PSSOA and
                                                 CCANAL_VDA_SEGUR = P_CCANAL_VDA_SEGUR;
             commit;
    	     RAISE_APPLICATION_ERROR(-20021,pMensagem);
END setObjetivoBancoFinasa;
PROCEDURE setValorCalcInserido(
  P_CCANAL_VDA_SEGUR    IN number,
  P_RAMO                IN number,
  P_VALOR_OBJT_INSERIDO IN NUMBER,
  P_VALOR_OBJETIVO     out number)
IS
  valorObjt      NUMBER(17,2);
  valorObjtInser NUMBER(17,2);
BEGIN
           pMensagem := NULL;
           SELECT vmin_prod_crrtr INTO valorObjt
           			FROM PARM_PROD_MIN_CRRTR
           			WHERE CGRP_RAMO_PLANO  = P_RAMO AND CCANAL_VDA_SEGUR = P_CCANAL_VDA_SEGUR;
           valorObjtInser :=  P_VALOR_OBJT_INSERIDO;
           if (valorObjtInser < valorObjt) then
              P_VALOR_OBJETIVO := valorObjt;
           else
              P_VALOR_OBJETIVO := valorObjtInser;
           end if;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
    	       ROLLBACK;
               pMensagem := 'META EM BANCO/FINASA NAO INFORMADA.';
               RETURN;
           WHEN OTHERS THEN
               pMensagem := 'ERRO NO ACESSO do VALOR MINIMO DE META EM BANCO/FINASA, ERRO : '||SQLERRM;
    	       ROLLBACK;
    	       RAISE_APPLICATION_ERROR(-20021,pMensagem);
END setValorCalcInserido;
BEGIN
   pCpf_cnpj_base  :=  pCpf_cnpj_completo;
   valorObjetivoIn :=  pValorObjetivo;
   pCespRet        := 0;
   -- verificando se pCespIns foi passada corretamente.
   pMensagem := NULL;
   if ( pCespIns not in (1,0) )
   then
      pMensagem := 'ERRO, VARIAVEL INDICATIVA DO SESP COM VALOR DIFERENTE DE 0 OU 1 - INCLUSÃO DESPREZADA.';
      pCespRet := 0;
      RETURN;
   end if;
   -- indo no cesp se pCespIns = 0
   if ( pCespIns = 0 )
   then
   	  BEGIN
        SELECT DISTINCT CSIT_CRRTR_BDSCO INTO VAR_CESP FROM INFO_LISTA_NEGRA_CRRTR
                 WHERE CCPF_CNPJ_BASE= pCpf_cnpj_base AND
                       CTPO_PSSOA = pTipo_pssoa AND
                       CSIT_CRRTR_BDSCO in (5); -- se estiver no CESP dá RETURN. Ass. Wassily
        pMensagem := 'CORRETOR NO CESP.';
        pCespRet  := 1;
        RETURN;
      EXCEPTION
    	--WHEN NO_DATA_FOUND THEN null; -- O corretor nao está no SESP vai tentar incluir.
      WHEN NO_DATA_FOUND
      THEN
      pCespRet := 0; -- O corretor nao está no SESP vai tentar incluir.
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (99) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
      END;
   end if;
   --  VERIFICA a validade da Apuração
   BEGIN
      SELECT MAX(SUBSTR(TO_CHAR(ccompt_apurc,'999999'),1,5))||'0'||max(to_char(TO_DATE(ccompt_apurc||'01','YYYYMMDD'),'Q'))
             into dtApur from APURC_PROD_CRRTR;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'ANO INVÁLIDO PARA SGPB.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO NO SELECT DA APURACAO, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   IF ( pCompetencia_apur <= dtApur ) THEN
        ROLLBACK;
        pMensagem := 'TRIMESTRE FECHADO. APURAÇÃO ENCERRADA.';
        RETURN;
   END IF;
   --  VERIFICA a existência do Corretor na BASE de DADOS
   BEGIN
    	SELECT 1 INTO TT FROM CRRTR_UNFCA_CNPJ CUC
     		  	WHERE CUC.CCPF_CNPJ_BASE = pCpf_cnpj_base AND CUC.CTPO_PSSOA = pTipo_pssoa;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'CPF/CNPF INEXISTENTE NO CADASTRO DE CORRETORES.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (1) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- VERIFICA SE EXISTE CORRETOR NO CPVO PARA O CNPJ_CPF PASSADO
   -- VALIDANDO SE O CORRETOR PERTENCE A FAIXA 100000 PARA OS 3 CANAIS
   -- EXTRA-BANCO - BANCO E FINASA
   BEGIN
        SELECT DISTINCT 1 INTO TT FROM CRRTR, PARM_CANAL_VDA_SEGUR
                 WHERE CCPF_CNPJ_BASE= pCpf_cnpj_base AND
                       CTPO_PSSOA = pTipo_pssoa AND
                       CCRRTR BETWEEN CINIC_FAIXA_CRRTR AND CFNAL_FAIXA_CRRTR AND
                       CCANAL_VDA_SEGUR = 1 AND
                       DFIM_VGCIA_PARM IS NULL;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'CORRETOR NÃO PERTENCE AO CANAL DE VENDA INFORMADO.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (2) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- VERIFICA SE O CORRETOR ESTÁ  NO CCC
   BEGIN
        SELECT DISTINCT CSIT_CRRTR_BDSCO INTO VAR_CESP FROM INFO_LISTA_NEGRA_CRRTR
                 WHERE CCPF_CNPJ_BASE= pCpf_cnpj_base AND
                       CTPO_PSSOA = pTipo_pssoa AND
                       CSIT_CRRTR_BDSCO not in (5,0); -- se zero tudo bem, se Cesp tambem. Ass. Wassily

    	ROLLBACK;
        pMensagem := 'CORRETOR POSSUI RESTRIÇÕES.';
        RETURN;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN null;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (2A) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   
   --  VERIFICA a Data do CANAL
   BEGIN
      SELECT DINIC_VGCIA_PARM  INTO DT_INIC_VIG
              FROM PARM_INFO_CAMPA
              WHERE CCANAL_VDA_SEGUR=pCanal and DFIM_VGCIA_PARM is NULL;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'CANAL NÃO POSSUI CAMPANHA NO PLANO DE BÔNUS OU CAMPANHA TERMINADA.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (3) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   
   --  VERIFICA o IMPEDIMENTO do CORRETOR
   BEGIN
    	SELECT UPPER(EXC.RMOTVO_EXCEC_CRRTR) INTO MT_CPFCNPJ FROM CRRTR_EXCEC_CAMPA EXC
     		  	WHERE EXC.CTPO_EXCEC_CRRTR = 'I'
            AND   EXC.CCPF_CNPJ_BASE   = pCpf_cnpj_base
            AND   EXC.CTPO_PSSOA       = pTipo_pssoa
            AND   EXC.CCANAL_VDA_SEGUR = pCanal
            AND   EXC.CIND_REG_ATIVO   = 'S'
            AND   EXC.DINIC_VGCIA_PARM = DT_INIC_VIG;
            pMensagem := 'CORRETOR IMPEDIDO MANUALMENTE - '||MT_CPFCNPJ||' - RETIRE O IMPEDIMENTO.';
            RETURN;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN NULL;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (1) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   
   --  INSERINDO O CORRETOR NA TABELA DE ELEITOS
   BEGIN
	  INSERT INTO CRRTR_ELEIT_CAMPA (CCANAL_VDA_SEGUR,DINIC_VGCIA_PARM,DCRRTR_SELEC_CAMPA,CTPO_PSSOA,CCPF_CNPJ_BASE)
  			VALUES
    		(pCanal,DT_INIC_VIG,SYSDATE,pTipo_pssoa,pCpf_cnpj_base);
    EXCEPTION
      WHEN dup_val_on_index THEN
    	     ROLLBACK;
           pMensagem := 'CORRETOR JÁ ELEITO PARA ESTE CANAL.';
           RETURN;
     	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (4) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		   RAISE_APPLICATION_ERROR(-20021,pMensagem);
    END;

    -- INSERINDO NA TABELA DE EXCEÇOES
    BEGIN
       INSERT INTO CRRTR_EXCEC_CAMPA
             (CTPO_PSSOA,CCPF_CNPJ_BASE,CCANAL_VDA_SEGUR,DINIC_VGCIA_PARM,RMOTVO_EXCEC_CRRTR,CIND_REG_ATIVO,DULT_ALT,
              CRESP_ULT_ALT,CTPO_EXCEC_CRRTR)
              VALUES (pTipo_pssoa,pCpf_cnpj_base,pCanal,DT_INIC_VIG,'Eleito Manualmente P/ a Campanha Corrente.',
                      'S',sysdate,pUsuario,'A');
    EXCEPTION
      --Caso EXISTA em CRRTR_EXCEC_CAMPA ==>> Executar UPDATE
      WHEN dup_val_on_index THEN
        BEGIN
          UPDATE CRRTR_EXCEC_CAMPA
                 SET CTPO_PSSOA = pTipo_pssoa, CCPF_CNPJ_BASE = pCpf_cnpj_base, CCANAL_VDA_SEGUR = pCanal,
                     DINIC_VGCIA_PARM = DT_INIC_VIG, RMOTVO_EXCEC_CRRTR = 'Eleito Manualmente P/ a Campanha Corrente.',
                     CIND_REG_ATIVO = 'S', DULT_ALT = sysdate, CTPO_EXCEC_CRRTR = 'A'
                 WHERE
                     CTPO_PSSOA       = pTipo_pssoa    and
                     CCPF_CNPJ_BASE   = pCpf_cnpj_base and
                     CCANAL_VDA_SEGUR = pCanal         and
                     DINIC_VGCIA_PARM = DT_INIC_VIG    and
                     CTPO_EXCEC_CRRTR = 'A';
                 EXCEPTION
                    WHEN OTHERS THEN
                    ROLLBACK;
          	        pMensagem := 'ERRO UPDATE CRRTR_EXCEC_CAMPA NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
          		      RAISE_APPLICATION_ERROR(-20021,pMensagem);
        END;
  	 	WHEN OTHERS THEN
    	     pMensagem := 'ERRO ACESSO CRRTR_EXCEC_CAMPA NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		   RAISE_APPLICATION_ERROR(-20021,pMensagem);
    END;
    COMMIT;
    IF ( pCanal = Pc_Util_01.Extra_Banco) THEN
       pMensagem := NULL;
       getMeses(pTrimestreInclusao, P_MES_01_PARM_AUX, P_MES_02_PARM_AUX, P_MES_03_PARM_AUX);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       -- -------------------------------------------------------------------------------------------------------
       -- CHAMADA do CÁLCULO do OBJETIVO EXTRA-BANCO
       -- Vai chamar o SGPB0170 que será alterado para calcular objetivo por corretor ou para todos. ass. wassily
       -- ATENCAO: 1) O JAVA PASSA AAAA01, AAAA04, AAAA07 OU AAAA10
       --          2) O CALCULO DO OBJETIVO EXTRABANCO PRECISA DE AAAA03, AAAA06, AAAA09 OU AAAA12.
       --          3) ENTAO SERÁ FEITA A CONVERSAO: SE AAAA01 FICA NNNN12 ( ONDE NNNN = AAAA - 1)
       --                                           SE AAAA04 FICA AAAA03
       --                                           SE AAAA07 FICA AAAA06
       --                                           SE AAAA10 FICA AAAA09
       -- --------------------------------------------------------------------------------------------------------
       SGPB0170(TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(pCompetencia||'01','YYYYMMDD'),-1),'YYYYMM')),
                'SGPB0201',pCpf_cnpj_base,pTipo_pssoa);
       -- verifica se foi cadastrado o objetivo extra banco.
       begin
         var_flag := NULL;
         select distinct 'x' into var_flag
              from OBJTV_PROD_CRRTR
              where CANO_MES_COMPT_OBJTV in ( pCompetencia, pCompetencia+1, pCompetencia+2) and
                    CCPF_CNPJ_BASE = pCpf_cnpj_base and
                    CTPO_PSSOA = pTipo_pssoa AND
                    CGRP_RAMO_PLANO IN (PC_UTIL_01.Re, PC_UTIL_01.AUTO);
         IF var_flag IS NULL THEN
            pMensagem := 'NÃO FOI GERADO OBJETIVO PARA O CORRETOR. CCPF_CNPJ_BASE= '||pCpf_cnpj_base||
                         ' pTipo_pssoa: '||pTipo_pssoa||' pCompetencia: '||pCompetencia;
    	    ROLLBACK;
    	    RETURN;
   		 END IF;
       EXCEPTION
  	 	 WHEN OTHERS THEN
    	     pMensagem := 'NÃO FOI GERADO OBJTV PARA O CORRETOR EXTRA. CCPF_CNPJ_BASE= '||pCpf_cnpj_base||
                         ' pTipo_pssoa: '||pTipo_pssoa||' pCompetencia: '||pCompetencia||
                         ' COD.ERRO: '||SQLERRM;
    	     ROLLBACK;
    	     RETURN;
       END;
   ELSE
       -- Objetivo: Banco - Finasa - Insere Objetivo: Banco / Finasa
       pMensagem := NULL;
       getMeses(pTrimestreInclusao,P_MES_01_PARM,P_MES_02_PARM,P_MES_03_PARM);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       valorInserido := 0;
       -- Verifica se o OBJETIVO é maior ou menor que o OBJETIVO PADRÃO, caso seja menor, utilizar o OBEJTIVO PADRÃO
       pMensagem := NULL;
       setValorCalcInserido(pCanal,PC_UTIL_01.AUTO,pValorObjetivo,valorInserido);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       setObjetivoBancoFinasa(pCpf_cnpj_base,pTipo_pssoa,pCanal,PC_UTIL_01.AUTO, pAnoInclusao, P_MES_01_PARM, P_MES_03_PARM, valorInserido);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       valorInserido := 0;
       -- Verifica se o OBJETIVO é maior ou menor que o OBJETIVO PADRÃO, caso seja menor, utilizar o OBEJTIVO PADRÃO
       pMensagem := NULL;
       setValorCalcInserido(pCanal,PC_UTIL_01.RE,pValorObjetivo,valorInserido);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       setObjetivoBancoFinasa(pCpf_cnpj_base,pTipo_pssoa, pCanal,PC_UTIL_01.RE,pAnoInclusao,P_MES_01_PARM, P_MES_03_PARM,valorInserido);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       setObjetivoBancoFinasa(pCpf_cnpj_base, pTipo_pssoa, pCanal, PC_UTIL_01.RETODOS,pAnoInclusao,P_MES_01_PARM,P_MES_03_PARM, valorObjetivoIn);
       IF ( pMensagem <> NULL ) THEN
          RETURN;
       END IF;
       COMMIT;
   END IF;
   -- Inserindo no log. Ass. Wassily
   begin
      INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
             SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB0201', sysdate,
                    'INCLUSAO MANUAL DO CORRETOR. Canal: '||pCanal||
                    ' Cpf_cnpj_completo: '||pCpf_cnpj_completo||' Cpf_cnpj_base: '||
                    pCpf_cnpj_base||' Tp_pssoa: '||pTipo_pssoa||
                    ' Competencia: '||pCompetencia||' Usuario: '||pUsuario|| ' Metodo: ' ||
                    DECODE(pCespIns,0,'IGNORADO POSSIVEL REGISTRO NO SESP, USUARIO AVISADO.','CHEGAGEM COMPLETA')||
                    ' AnoInclusao: '||pAnoInclusao||' Trimestre: '||pTrimestreInclusao
                    from LOG_ERRO_IMPOR;
   EXCEPTION
  	  WHEN OTHERS THEN
          pMensagem := 'ERRO. NAO FOI POSSIVEL GRAVAR O LOG. pCanal: '||pCanal||
                        ' pCpf_cnpj_completo: '||pCpf_cnpj_completo||' pCpf_cnpj_base: '||
                        pCpf_cnpj_base||' pTipo_pssoa: '||pTipo_pssoa||
                        ' pCompetencia: '||pCompetencia||' pUsuario: '||pUsuario||
                       ' COD.ERRO: '||SQLERRM;
          ROLLBACK;
    	    RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   pMensagem := 'X';
   pCespRet := 0;
END SGPB0201;
/

