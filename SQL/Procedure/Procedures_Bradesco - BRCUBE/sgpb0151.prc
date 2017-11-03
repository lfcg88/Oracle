create or replace procedure sgpb_proc.SGPB0151(intrCodCanal  in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
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
  --      PROCEDURE       : SGPB0151
  --      DATA            : 24/01/2007
  --      AUTOR           : Luiz Vitor - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Recupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      : Wassily ( 14/04/2007) => Somente mostra o Corretor a partir do trimestre que foi selecionado.
  --                        ----- CANAL EXTRABANCO -------
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  chrNomeRotinaScheduler VARCHAR2(20) := 'SGPB0151';
  intrDtINIVig           number;
  intrDtFIMVig           number;
  intCpfCnpjBase         number;
  parm_percentual_especial number(17,4);
  parm_percentual_default  number(17,4);
  parm_obj_re number(15,2);
  VAR_TRIMESTRE NUMBER := 0;
  VAR_PROD_MINIMA NUMBER; -- criado em 13/06/2007
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO O VALOR DO OBJETIVO RE
  ----------------------------------------------------------------------------------------
  PROCEDURE getVlObjRe(dtFimVig in number) IS
  BEGIN

    SELECT ppmc.vmin_prod_crrtr
      into PARM_OBJ_RE
      FROM PARM_PROD_MIN_CRRTR PPMC
     WHERE PPMC.CCANAL_VDA_SEGUR = intrcodcanal
       AND PPMC.CGRP_RAMO_PLANO = pc_util_01.re
       AND PPMC.CTPO_PSSOA = chrTpPessoa
       AND PPMC.CTPO_PER = 'M'
       AND Last_Day(To_Date( dtFimVig , 'YYYYMM'))
           BETWEEN PPMC.DINIC_VGCIA_PARM
               AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'));
  END getVlObjRe;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO O PERCENTUAL PADRÃO
  ----------------------------------------------------------------------------------------
  procedure getParmPercentual(compt in prod_crrtr.ccompt_prod %type) is
  begin

     select pcvs.pcrstc_prod_ano, PCVS.VMIN_PROD_APURC into parm_percentual_default, VAR_PROD_MINIMA
     from parm_canal_vda_segur pcvs
     where pcvs.ccanal_vda_segur = intrCodCanal
       and LAST_DAY(To_Date(compt, 'YYYYMM')) BETWEEN
           PCVS.DINIC_VGCIA_PARM AND NVL(PCVS.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'dd/MM/yyyy'));
   end getParmPercentual;
  ----------------------------------------------------------------------------------------
  --RECUPERANDO O PERCENTUAL ESPECIAL
  ----------------------------------------------------------------------------------------
  procedure getEspecialPercentual(compt in prod_crrtr.ccompt_prod %type) is
  begin
    BEGIN
        select ccc.pcrsct_prod_alt
          into parm_percentual_especial
          from carac_crrtr_canal ccc,
               parm_info_campa pic
        where ccc.ctpo_pssoa = chrTpPessoa
          and ccc.ccpf_cnpj_base = intCpfCnpjBase
          and ccc.ccanal_vda_segur = intrCodCanal
          AND ccc.ccanal_vda_segur = pic.ccanal_vda_segur
          and ccc.dinic_vgcia_parm = pic.dinic_vgcia_parm
          and LAST_DAY(To_Date(compt, 'YYYYMM')) BETWEEN
             pic.DINIC_VGCIA_PARM AND NVL(pic.DFIM_VGCIA_PARM,TO_DATE('31/12/9999', 'dd/MM/yyyy'));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        parm_percentual_especial := NULL;
    END;
  end getEspecialPercentual;
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
  V_INICIO_ELEICAO DATE;
BEGIN
    chrLocalErro := 1;
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
      
      PEL_AUTO(4)     := 0;
      PEL_RE(4)       := 0;
      PEL_BILHETE(4)  := 0;
      PERC_AUTO(4)    := 0;
      PERC_RE(4)      := 0;
      PERC_BILHETE(4) := 0;
      OBJ_AUTO(4)     := 0;
      OBJ_RE(4)       := 0;
      OBJ_BILHETE(4)  := 0;      
      chrLocalErro    := 2;

    /*PERCORRE OS TRÊS MESES DO TRIMESTRE SELECIONADO*/
    --
    -- tem que mostrar somente a produção a partir da data em que foi eleito
    -- Se o trimestre a ser calculado for anterior a data da eleição não vai mostrar nada
    -- wassily
      begin
        chrLocalErro := 10;
        -- Pega primeira vez em que o corretor foi eleito
        SELECT TO_CHAR(MIN(DCRRTR_SELEC_CAMPA),'Q') INTO VAR_TRIMESTRE
               FROM crrtr_eleit_campa cec
               WHERE cec.CCANAL_VDA_SEGUR=intrCodCanal AND
                     cec.CCPF_CNPJ_BASE=intCpfCnpjBase AND
                     CEC.CTPO_PSSOA=chrTpPessoa;
       -- tem que pegar o trimestre anterior por que ele foi eleito com base no ultimo trimestre.
       --IF VAR_TRIMESTRE <> 1 THEN
       --   VAR_TRIMESTRE := VAR_TRIMESTRE - 1 ;
       --END IF;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
            chrLocalErro := 11;
            PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB0151','Cod.Erro: '||chrLocalErro ||' CPF_CNPJ: '||intrCPF_CNPJ||
                          ' Compet: '||to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                          pc_util_01.VAR_LOG_PROCESSO,NULL, NULL);
            COMMIT;
            Raise_Application_Error(-20210,'ERRO (1) NA CONSULTA DO PLANO DE BONUS. DETALHES DO ERRO FORAM LOGADOS.');
       WHEN OTHERS THEN
            chrLocalErro := 12;
            PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB0151','Cod.Erro: '||chrLocalErro ||' CPF_CNPJ: '||intrCPF_CNPJ||
                          ' Compet: '||to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                          pc_util_01.VAR_LOG_PROCESSO,NULL, NULL);
            COMMIT;
            Raise_Application_Error(-20210,'ERRO (2) NA CONSULTA DO PLANO DE BONUS. DETALHES DO ERRO FORAM LOGADOS.');
      end;
      chrLocalErro := 97; 
      IF VAR_TRIMESTRE <= intrTRIMESTRE THEN
        chrLocalErro := 95;             
        for i in 0..2
        loop
        	PEL_AUTO(i)    :=0;
        	PEL_RE(i)      :=0;
        	PEL_BILHETE(i) :=0;
        	OBJ_AUTO(i)    :=0;
        	OBJ_RE(i)      :=0;
        	OBJ_BILHETE(i) :=0;
        	chrLocalErro := 96;
        	COMPT := intrDtINIVig + i;
        	chrLocalErro := 99;
        	Pc_Util_01.Sgpb0003(Intinicialfaixa,Intfinalfaixa,intrCodCanal,COMPT);
        	chrLocalErro := 21;
        	getEspecialPercentual(COMPT);
        	getparmpercentual(COMPT);
        	getVlObjRe(COMPT);      
        	chrLocalErro := 14;
        	begin
          	SELECT ATUAL.TOT_VR_PROD_AUTO,
             ATUAL.TOT_VR_PROD_RE,
             ATUAL.TOT_VR_PROD_BILHETE,
             NVL(ANTERIOR.TOT_VR_PROD_AUTO, 0) * ((NVL(PARM_PERCENTUAL_ESPECIAL,PARM_PERCENTUAL_DEFAULT)/100)+1),
             PARM_OBJ_RE,
             PARM_OBJ_RE
            INTO PEL_AUTO(i), PEL_RE(i), PEL_BILHETE(i),
                 OBJ_AUTO(i), OBJ_RE(i), OBJ_BILHETE(i)
          FROM CRRTR_UNFCA_CNPJ CUC 
          LEFT JOIN (
             SELECT C.CCPF_CNPJ_BASE,
                   C.CTPO_PSSOA,
                   SUM (
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
                     CASE WHEN GRP.CGRP_RAMO_PLANO = PC_UTIL_01.RE
              		     THEN PC.VPROD_CRRTR
              			   ELSE 0
              		   END
              		 ) TOT_VR_PROD_BILHETE
              FROM CRRTR C
              JOIN GRP_RAMO_PLANO GRP
              ON GRP.CGRP_RAMO_PLANO in (PC_UTIL_01.Auto, PC_UTIL_01.Re, PC_UTIL_01.ReTodos)
              LEFT JOIN PROD_CRRTR PC
                ON PC.CCRRTR    = C.CCRRTR
               AND PC.CUND_PROD = C.CUND_PROD
               AND PC.CGRP_RAMO_PLANO = GRP.CGRP_RAMO_PLANO
               AND PC.CCOMPT_PROD = COMPT
               AND PC.CTPO_COMIS = PC_UTIL_01.COMISSAO_NORMAL
             WHERE C.CCPF_CNPJ_BASE = intCpfCnpjBase
               AND C.CTPO_PSSOA = chrTpPessoa
               and c.ccrrtr between Intinicialfaixa and IntFINalfaixa
             GROUP
                BY C.CCPF_CNPJ_BASE, C.CTPO_PSSOA
           ) ATUAL
           ON ATUAL.CCPF_CNPJ_BASE = CUC.CCPF_CNPJ_BASE
          AND ATUAL.CTPO_PSSOA     = CUC.CTPO_PSSOA
         LEFT JOIN (
            SELECT C.CCPF_CNPJ_BASE,
                   C.CTPO_PSSOA,
                   SUM (PC.VPROD_CRRTR) TOT_VR_PROD_AUTO
              FROM CRRTR C
              JOIN PROD_CRRTR PC
                ON PC.CCRRTR    = C.CCRRTR
               AND PC.CUND_PROD = C.CUND_PROD
               AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
               AND PC.CCOMPT_PROD = TO_CHAR(ADD_MONTHS(TO_DATE(COMPT , 'YYYYMM'), -12), 'YYYYMM')
               AND PC.CTPO_COMIS = PC_UTIL_01.COMISSAO_NORMAL
             WHERE C.CCPF_CNPJ_BASE = intCpfCnpjBase
               AND C.CTPO_PSSOA = chrTpPessoa
               and c.ccrrtr between Intinicialfaixa and IntFINalfaixa
             GROUP
                BY C.CCPF_CNPJ_BASE, C.CTPO_PSSOA
           ) ANTERIOR
           ON ANTERIOR.CCPF_CNPJ_BASE = CUC.CCPF_CNPJ_BASE
           AND ANTERIOR.CTPO_PSSOA     = CUC.CTPO_PSSOA
         WHERE CUC.CCPF_CNPJ_BASE = intCpfCnpjBase
           AND CUC.CTPO_PSSOA = chrTpPessoa;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL; -- Se nao achou, não faz nada, possivelmente não teve produção em algum mes. Wassily
         WHEN OTHERS THEN
            chrLocalErro := 87;
            PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB0151','Cod.Erro: '||chrLocalErro ||' CPF_CNPJ: '||intrCPF_CNPJ||
                          ' Compet: '||to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                          pc_util_01.VAR_LOG_PROCESSO,NULL, NULL);
            COMMIT;
            Raise_Application_Error(-20210,'ERRO (2) NA CONSULTA DO PLANO DE BONUS. DETALHES DO ERRO FORAM LOGADOS.');
        end;
        IF OBJ_RE(i) = 0 then
           PERC_RE(i)      := 0;
        else
           PERC_RE(i)      := 100*(PEL_re(i) / OBJ_re(i));
        end if;
        if obj_bilhete(i)= 0 then
           PERC_BILHETE(i) := 0;
        else
           PERC_BILHETE(i) := 100*(PEL_bilhete(i) / OBJ_bilhete(i));
        end if;
        chrLocalErro := 15;
        --TOTALIZANDO O OBJETIVO, PRODUÇÃO E PERCENTUAL DO TRIMESTRE
        PEL_AUTO(4)    := PEL_AUTO(4)   + PEL_AUTO(i);
        PEL_RE(4)      := PEL_RE(4)   + PEL_RE(i);
        PEL_BILHETE(4) := PEL_BILHETE(4)   + PEL_BILHETE(i);
        OBJ_AUTO(4)    := OBJ_AUTO(4) + OBJ_AUTO(i) ;
        OBJ_RE(4)      := OBJ_RE(4) + OBJ_RE(i) ;
        OBJ_BILHETE(4) := OBJ_BILHETE(4) + OBJ_BILHETE(i) ;
      end loop;
      
      -- alterado em 13/06/2007 para tirar o hard code. wassily
      if OBJ_AUTO(4) < var_prod_minima then
         OBJ_AUTO(4) := var_prod_minima;
      end if;
      -- BILOURO
      --IF OBJ_AUTO(4) < 30000 THEN
      --  OBJ_AUTO(4) := 30000;
      --end if;

      OBJ_AUTO(0)  := OBJ_AUTO(4) / 3;
      OBJ_AUTO(1)  := OBJ_AUTO(4) / 3;
      OBJ_AUTO(2)  := OBJ_AUTO(4) / 3;

      PERC_AUTO(0) := 100*(PEL_AUTO(0) / OBJ_AUTO(0));
      PERC_AUTO(1) := 100*(PEL_AUTO(1) / OBJ_AUTO(1));
      PERC_AUTO(2) := 100*(PEL_AUTO(2) / OBJ_AUTO(2));
      PERC_AUTO(4) := 100*( PEL_AUTO(4) / OBJ_AUTO(4) );
    
      chrLocalErro := 16;
      IF OBJ_RE(4) <= 0 THEN
         PERC_RE(4) := 0;
      ELSE
         PERC_RE(4) := 100*( PEL_RE(4) / OBJ_RE(4) );
      END IF;

      IF OBJ_BILHETE(4) <= 0 THEN
         PERC_BILHETE(4) := 0;
      ELSE
         PERC_BILHETE(4) := 100*( PEL_BILHETE(4) / OBJ_BILHETE(4) );
      END IF;    
      chrLocalErro := 60; 
      intrPEL_MES1_AUTO := NVL(PEL_AUTO(0), 0);
      intrPEL_MES2_AUTO := NVL(PEL_AUTO(1), 0);
      intrPEL_MES3_AUTO := NVL(PEL_AUTO(2), 0);
      chrLocalErro := 61; 
      intrOBJ_MES1_AUTO := NVL(OBJ_AUTO(0), 0);
      intrOBJ_MES2_AUTO := NVL(OBJ_AUTO(1), 0);
      intrOBJ_MES3_AUTO := NVL(OBJ_AUTO(2), 0);
      chrLocalErro := 62; 
      intrPERC_MES1_AUTO := NVL(PERC_AUTO(0), 0);
      intrPERC_MES2_AUTO := NVL(PERC_AUTO(1), 0);
      intrPERC_MES3_AUTO := NVL(PERC_AUTO(2), 0);
      chrLocalErro := 63; 
      intrPEL_MES1_RE := NVL(PEL_RE(0), 0);
      intrPEL_MES2_RE := NVL(PEL_RE(1), 0);
      intrPEL_MES3_RE := NVL(PEL_RE(2), 0);
      chrLocalErro := 64; 
      intrOBJ_MES1_RE := NVL(OBJ_RE(0), 0);
      intrOBJ_MES2_RE := NVL(OBJ_RE(1), 0);
      intrOBJ_MES3_RE := NVL(OBJ_RE(2), 0);
      chrLocalErro := 65; 
      intrPERC_MES1_RE := NVL(PERC_RE(0), 0);
      intrPERC_MES2_RE := NVL(PERC_RE(1), 0);
      intrPERC_MES3_RE := NVL(PERC_RE(2), 0);
      chrLocalErro := 66; 
      intrPEL_MES1_BILHETE := NVL(PEL_BILHETE(0), 0);
      intrPEL_MES2_BILHETE := NVL(PEL_BILHETE(1), 0);
      intrPEL_MES3_BILHETE := NVL(PEL_BILHETE(2), 0);
      chrLocalErro := 67; 
      intrOBJ_MES1_BILHETE := NVL(OBJ_BILHETE(0), 0);
      intrOBJ_MES2_BILHETE := NVL(OBJ_BILHETE(1), 0);
      intrOBJ_MES3_BILHETE := NVL(OBJ_BILHETE(2), 0);
      chrLocalErro := 68; 
      intrPERC_MES1_BILHETE := NVL(PERC_BILHETE(0), 0);
      intrPERC_MES2_BILHETE := NVL(PERC_BILHETE(1), 0);
      intrPERC_MES3_BILHETE := NVL(PERC_BILHETE(2), 0);
      chrLocalErro := 69;
    -- FINAL DO IF DA DATA DE ELEIÇÃO
    -- ------------------------------
    END IF;
    --TRIMESTRE
    intrPEL_TRI_AUTO     := NVL(PEL_AUTO(4), 0);
    intrPEL_TRI_RE       := NVL(PEL_RE(4), 0);
    intrPEL_TRI_BILHETE  := NVL(PEL_BILHETE(4), 0);
    chrLocalErro := 70; 
    intrOBJ_TRI_AUTO     := NVL(OBJ_AUTO(4), 0);
    intrOBJ_TRI_RE       := NVL(OBJ_RE(4), 0);
    intrOBJ_TRI_BILHETE  := NVL(OBJ_BILHETE(4), 0);
    chrLocalErro := 71; 
    intrPERC_TRI_AUTO    := NVL(PERC_AUTO(4), 0);
    intrPERC_TRI_RE      := NVL(PERC_RE(4), 0);
    intrPERC_TRI_BILHETE := NVL(PERC_BILHETE(4), 0);
    chrLocalErro := 50;
    /*Recupara a última data de apuração*/
    getDtApuracao(dtDataApuracao,intrDtFIMVig);
    chrLocalErro := 51;
    /*Recupera a nome do canal*/
    getNomeCanal(intrCodCanal,chrNomeCanal);
    /*PASSANDO 0 (ZERO), POIS ESTA VARIÁVEL NÃO ESTÁ SENDO
    USADA PARA NADA, PORÉM ESTÁ NA ASSINATURA DO MÉTODO*/
    intrGrupoRamo := 0;
    chrLocalErro := 17;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||' CPF_CNPJ: ' || intrCPF_CNPJ ||
                           ' VAR_TRIMESTRE: '||VAR_TRIMESTRE ||' intrTRIMESTRE: '||intrTRIMESTRE ||
                           ' Compet: ' || to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' ||
                           SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
       PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB0151',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL); 
  End;
END;

BEGIN
  -------------------------------------------------------------------------------------------------
  --  CORPO DA PROCEDURE
  -------------------------------------------------------------------------------------------------
  geraDetail();
  --
END SGPB0151;
/

