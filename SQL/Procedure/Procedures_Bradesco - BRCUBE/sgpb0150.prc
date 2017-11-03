create or replace procedure sgpb_proc.SGPB0150(intrCodCanal  in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
                                     chrNomeCanal  out CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR %TYPE,
                                     intrCPF_CNPJ  in CRRTR.CCPF_CNPJ_CRRTR %type,
                                     chrTpPessoa   in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
                                     intrGrupoRamo out PROD_CRRTR.CGRP_RAMO_PLANO %TYPE,

                                     intrPEL_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrOBJ_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrPERC_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrPEL_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrOBJ_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrPERC_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrPEL_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrOBJ_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrPERC_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,

                                     intrANO       in number,
                                     intrTRIMESTRE in number,

                                     dtDataApuracao out date)

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0150
  --      DATA            : 24/01/2007
  --      AUTOR           : Luiz Vitor - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Recupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      : --- banco e finasa ------
  --                DATA  :
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  chrNomeRotinaScheduler VARCHAR2(8) := 'SGPB0150';
  intrDtINIVig           number;
  intrDtFIMVig           number;
  intCpfCnpjBase         number;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO A ÚLTIMA DATA DE APURAÇÃO
  ----------------------------------------------------------------------------------------
    /* PROCEDURE getDtApuracao(ultDtApuracao out date, dtFimVig in number) IS
  BEGIN
      select case WHEN ultDtApuracao > LAST_DAY(to_date(dtFimVig, 'YYYYMM'))
             THEN LAST_DAY(to_date(dtFimVig, 'YYYYMM'))
             ELSE ultDtApuracao
             END
             INTO ultDtApuracao
             FROM (
                     SELECT nvl(max(demis_apolc),sysdate) ultDtApuracao
                            FROM apolc_prod_crrtr
                  ) TAB_INTERNA;

    SELECT /*+ index(apolc_prod_crrtr XIE2APOLC_PROD_CRRTR) */  /*
             nvl(max(demis_apolc),sysdate) into ultDtApuracao
             FROM apolc_prod_crrtr where demis_apolc > (sysdate - 15);
  END;  */
 PROCEDURE getDtApuracao(ultDtApuracao out date, dtFimVig in number) IS
 BEGIN
 /*
    DECLARE
        CURSOR C_DATA IS SELECT /*+ index(apolc_prod_crrtr XIE2APOLC_PROD_CRRTR) */  /*nvl(max(demis_apolc),sysdate-15)
               	         FROM apolc_prod_crrtr where demis_apolc > (sysdate - 15);
    BEGIN
         OPEN C_DATA;
         FETCH C_DATA INTO ultDtApuracao;
         CLOSE C_DATA;
    END;    */
    DECLARE
        P_DATA DATE := trunc(SYSDATE);
        CURSOR C_DATA IS SELECT /*+ index(apolc_prod_crrtr XIE2APOLC_PROD_CRRTR) */ demis_apolc
               	         FROM apolc_prod_crrtr where demis_apolc = P_DATA;
    BEGIN
         ultDtApuracao := null;
         loop
            OPEN C_DATA;
  			FETCH C_DATA INTO ultDtApuracao;
  			if ultDtApuracao IS NOT NULL then
    		   EXIT;
  			end if;
            CLOSE C_DATA;
            P_DATA := P_DATA - 1;
 		end loop;
    END;
 END;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO O NOME DO CANAL
  ----------------------------------------------------------------------------------------
  PROCEDURE getNomeCanal(CodCanal  in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
                         NomeCanal  out CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR %TYPE) IS
  BEGIN

    SELECT CVS.ICANAL_VDA_SEGUR INTO NomeCanal
      FROM CANAL_VDA_SEGUR CVS
     WHERE CVS.CCANAL_VDA_SEGUR = CodCanal;

  END;
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    DECLARE
  -- Local variables here
  TYPE ARRAY_OUT IS TABLE OF DECIMAL(15,5) index by binary_integer;
  -- ATRIBUINDO AOS ARRAYS
  PEL_AUTO     ARRAY_OUT;
  PEL_RE       ARRAY_OUT;
  PEL_BILHETE ARRAY_OUT;

  PERC_AUTO    ARRAY_OUT;
  PERC_RE      ARRAY_OUT;
  PERC_BILHETE ARRAY_OUT;

  OBJ_AUTO    ARRAY_OUT;
  OBJ_RE      ARRAY_OUT;
  OBJ_BILHETE ARRAY_OUT;

  COMPT NUMBER(6);
  i NUMBER;

  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;

BEGIN

     --Recuperando o CNPJ e CPF base
     IF (chrTpPessoa = 'J') THEN
         intCpfCnpjBase := LPAD(intrCPF_CNPJ,13,0);
         intCpfCnpjBase := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 6);
     ELSE
         intCpfCnpjBase := LPAD(intrCPF_CNPJ,10,0);
         intCpfCnpjBase := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 2);
     END IF;

      If intrTRIMESTRE = 1 then
        -- JANEIRO / FEVEREIRO / MARCO
        intrDtINIVig := to_number(intrANO || '01');
        intrDtFIMVig := to_number(intrANO || '03');
      Elsif intrTRIMESTRE = 2 then
        -- ABRIL / MAIO / JUNHO
        intrDtINIVig := to_number(intrANO || '04');
        intrDtFIMVig := to_number(intrANO || '06');
      Elsif intrTRIMESTRE = 3 then
        -- JULHO / AGOSTO / SETEMBRO
        intrDtINIVig := to_number(intrANO || '07');
        intrDtFIMVig := to_number(intrANO || '09');
      Elsif intrTRIMESTRE = 4 then
        -- OUTUBRO / NOVEMBRO / DEZEMBRO
        intrDtINIVig := to_number(intrANO || '10');
        intrDtFIMVig := to_number(intrANO || '12');
      End If;

      PEL_AUTO(4)   := 0;
      PEL_RE(4)     := 0;
      PEL_BILHETE(4):= 0;

      PERC_AUTO(4)    := 0;
      PERC_RE(4)      := 0;
      PERC_BILHETE(4) := 0;

      OBJ_AUTO(4)    := 0;
      OBJ_RE(4)      := 0;
      OBJ_BILHETE(4) := 0;

    /*PERCORRE OS TRÊS MESES DO TRIMESTRE SELECIONADO*/
    for i in 0..2
    loop

    COMPT := intrDtINIVig + i;

      Pc_Util_01.Sgpb0003(Intinicialfaixa,
                          Intfinalfaixa,
                          intrCodCanal,
                          COMPT);

      -- zerando variaveis. ass. wassily ( 14/06/2007 )
      PEL_AUTO(i)   := 0;
      PEL_RE(i)     := 0;
      PEL_BILHETE(i):= 0;
      OBJ_AUTO(i)   := 0;
      OBJ_RE(i)     := 0;
      OBJ_BILHETE(i):= 0;
      SELECT SUM (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
        		     THEN PC.VPROD_CRRTR
        			   ELSE 0
        		   END
        		 ) TOT_VR_PROD_AUTO,
             SUM (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.ReTodos
        		     THEN PC.VPROD_CRRTR
        			   ELSE 0
        		   END
        		 ) TOT_VR_PROD_RE,
             SUM (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.Re
        		     THEN PC.VPROD_CRRTR
        			   ELSE 0
        		   END
        		 ) TOT_VR_PROD_BILHETE,
             MAX (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
        		     THEN OPC.VOBJTV_PROD_CRRTR_ALT
        			   ELSE 0
        		   END
        		 ) OBJTV_AUTO,
             MAX (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.Re
        		     THEN OPC.VOBJTV_PROD_CRRTR_ALT
        			   ELSE 0
        		   END
        		 ) OBJTV_RE,
             MAX (
               CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.Re
        		     THEN OPC.VOBJTV_PROD_CRRTR_ALT
        			   ELSE 0
        		   END
        		 ) OBJTV_BILHETE

        INTO PEL_AUTO(i), PEL_RE(i), PEL_BILHETE(i),
             OBJ_AUTO(i), OBJ_RE(i), OBJ_BILHETE(i)

        FROM CRRTR C

        JOIN mpmto_ag_crrtr mac
          on mac.ccrrtr_dsmem = c.ccrrtr
         and mac.cund_prod = c.cund_prod
         and last_day(to_date(COMPT, 'YYYYMM')) between mac.dentrd_crrtr_ag and nvl(mac.dsaida_crrtr_ag, to_date(99991231, 'YYYYMMDD'))
         and mac.ccrrtr_orign between intinicialfaixa and Intfinalfaixa

        JOIN GRP_RAMO_PLANO GRP
        ON GRP.CGRP_RAMO_PLANO in (PC_UTIL_01.Auto,PC_UTIL_01.Re,PC_UTIL_01.ReTodos)

        LEFT JOIN PROD_CRRTR PC
          ON PC.CCRRTR    = C.CCRRTR
         AND PC.CUND_PROD = C.CUND_PROD
         AND PC.CGRP_RAMO_PLANO = GRP.CGRP_RAMO_PLANO
         AND PC.CCOMPT_PROD = COMPT
         AND PC.CTPO_COMIS = PC_UTIL_01.COMISSAO_NORMAL

        LEFT JOIN OBJTV_PROD_CRRTR OPC
          ON OPC.CTPO_PSSOA     = C.CTPO_PSSOA
         AND OPC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
         AND OPC.CGRP_RAMO_PLANO = GRP.CGRP_RAMO_PLANO
         AND OPC.CANO_MES_COMPT_OBJTV = COMPT
         AND OPC.CCANAL_VDA_SEGUR = intrCodCanal
         and opc.cind_reg_ativo = 'S'

       WHERE C.CCPF_CNPJ_BASE = intCpfCnpjBase
         AND C.CTPO_PSSOA = chrTpPessoa

       GROUP
          BY C.CCPF_CNPJ_BASE,
             C.CTPO_PSSOA;
        -- tem que colocar aqui o objetivo padrao se algum objetivo for zero.
        --
         
        --CALCULANDO O PERCENTUAL    
                     
        if (OBJ_AUTO(i) <> 0)  THEN
           PERC_AUTO(i) := 100*(PEL_AUTO(i)/OBJ_AUTO(i));
        ELSE
            PERC_AUTO(i) := 0; 
        END IF;
        if (OBJ_RE(i) <> 0)  THEN
           PERC_RE(i)   := 100*(PEL_RE(i)/OBJ_RE(i));
        ELSE
           PERC_RE(i):=0;
        END IF;
        if (OBJ_BILHETE(i) <> 0) THEN
           PERC_BILHETE(i) := 100*(PEL_BILHETE(i)/OBJ_BILHETE(i));
        ELSE
            PERC_BILHETE(i) := 0;
        END IF;

        --TOTALIZANDO O OBJETIVO, PRODUÇÃO E PERCENTUAL DO TRIMESTRE
        PEL_AUTO(4)    := PEL_AUTO(4)   + PEL_AUTO(i);
        PEL_RE(4)      := PEL_RE(4)   + PEL_RE(i);
        PEL_BILHETE(4) := PEL_BILHETE(4)   + PEL_BILHETE(i);
--AQUI
--        PERC_AUTO(4)    := PERC_AUTO(4)  + PERC_AUTO(i) ;
--        PERC_RE(4)      := PERC_RE(4)  + PERC_RE(i) ;
--        PERC_BILHETE(4) := PERC_BILHETE(4)  + PERC_BILHETE(i) ;

        OBJ_AUTO(4)    := OBJ_AUTO(4) + OBJ_AUTO(i) ;
        OBJ_RE(4)      := OBJ_RE(4) + OBJ_RE(i) ;
        OBJ_BILHETE(4) := OBJ_BILHETE(4) + OBJ_BILHETE(i) ;

    end loop;

-- BILOURO
    IF OBJ_AUTO(4) = 0 THEN
        PERC_AUTO(4)    := 0; 
    ELSE
        PERC_AUTO(4)    := 100*( PEL_AUTO(4) / OBJ_AUTO(4) );
    END IF;

    IF OBJ_RE(4) = 0 THEN
        PERC_RE(4)      := 0;  
    ELSE
        PERC_RE(4)      := 100*( PEL_RE(4) / OBJ_RE(4) );
    END IF;

    IF OBJ_BILHETE(4) = 0 THEN
        PERC_BILHETE(4) := 0;  
    ELSE
        PERC_BILHETE(4) := 100*( PEL_BILHETE(4) / OBJ_BILHETE(4) );
    END IF;

    intrPEL_MES1_AUTO := NVL(PEL_AUTO(0), 0);
    intrPEL_MES2_AUTO := NVL(PEL_AUTO(1), 0);
    intrPEL_MES3_AUTO := NVL(PEL_AUTO(2), 0);    
    
    intrOBJ_MES1_AUTO := NVL(OBJ_AUTO(0), 0);
    intrOBJ_MES2_AUTO := NVL(OBJ_AUTO(1), 0);
    intrOBJ_MES3_AUTO := NVL(OBJ_AUTO(2), 0);

    intrPERC_MES1_AUTO := NVL(PERC_AUTO(0), 0);
    intrPERC_MES2_AUTO := NVL(PERC_AUTO(1), 0);
    intrPERC_MES3_AUTO := NVL(PERC_AUTO(2), 0);

    intrPEL_MES1_RE := NVL(PEL_RE(0), 0);
    intrPEL_MES2_RE := NVL(PEL_RE(1), 0);
    intrPEL_MES3_RE := NVL(PEL_RE(2), 0);

    intrOBJ_MES1_RE := NVL(OBJ_RE(0), 0);
    intrOBJ_MES2_RE := NVL(OBJ_RE(1), 0);
    intrOBJ_MES3_RE := NVL(OBJ_RE(2), 0);

    intrPERC_MES1_RE := NVL(PERC_RE(0), 0);
    intrPERC_MES2_RE := NVL(PERC_RE(1), 0);
    intrPERC_MES3_RE := NVL(PERC_RE(2), 0);

    intrPEL_MES1_BILHETE := NVL(PEL_BILHETE(0), 0);
    intrPEL_MES2_BILHETE := NVL(PEL_BILHETE(1), 0);
    intrPEL_MES3_BILHETE := NVL(PEL_BILHETE(2), 0);

    intrOBJ_MES1_BILHETE := NVL(OBJ_BILHETE(0), 0);
    intrOBJ_MES2_BILHETE := NVL(OBJ_BILHETE(1), 0);
    intrOBJ_MES3_BILHETE := NVL(OBJ_BILHETE(2), 0);

    intrPERC_MES1_BILHETE := NVL(PERC_BILHETE(0), 0);
    intrPERC_MES2_BILHETE := NVL(PERC_BILHETE(1), 0);
    intrPERC_MES3_BILHETE := NVL(PERC_BILHETE(2), 0);

    --TRIMESTRE
    intrPEL_TRI_AUTO  := PEL_AUTO(4);
    intrPEL_TRI_RE  := PEL_RE(4);
    intrPEL_TRI_BILHETE  := PEL_BILHETE(4);

    intrOBJ_TRI_AUTO := OBJ_AUTO(4);
    intrOBJ_TRI_RE := OBJ_RE(4);
    intrOBJ_TRI_BILHETE := OBJ_BILHETE(4);

    intrPERC_TRI_AUTO := PERC_AUTO(4);
    intrPERC_TRI_RE := PERC_RE(4);
    intrPERC_TRI_BILHETE := PERC_BILHETE(4);


    /*Recupara a última data de apuração*/
    getDtApuracao(dtDataApuracao,intrDtFIMVig);
    /*Recupera a nome do canal*/
    getNomeCanal(intrCodCanal,chrNomeCanal);

  /*PASSANDO 0 (ZERO), POIS ESTA VARIÁVEL NÃO ESTÁ SENDO
  USADA PARA NADA, PORÉM ESTÁ NA ASSINATURA DO MÉTODO*/
  intrGrupoRamo := 0;

  EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                           'CPF_CNPJ: ' || intrCPF_CNPJ ||
                          ' Compet: ' || to_char(intrDtINIVig) || '-' ||
                           to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                          1,
                          PC_UTIL_01.VAR_TAM_MSG_ERRO);

    PR_GRAVA_MSG_LOG_CARGA('SGPB0150',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                  708,
                                   PC_UTIL_01.VAR_ROTNA_PE);

  End;
  END;

  BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  geraDetail();


END SGPB0150;
/

