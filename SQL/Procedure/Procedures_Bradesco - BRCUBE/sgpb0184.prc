CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0184
(
  RESULSET          OUT SYS_REFCURSOR,
  INTRCODCANAL      IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
  INTRCPF_CNPJ_BASE IN CRRTR.CCPF_CNPJ_BASE %TYPE,
  CHRTPPESSOA       IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
  INTRANO           IN NUMBER,
  INTRTRIMESTRE     IN NUMBER
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0183
  --      DATA            : 08/05/2007
  --      AUTOR           : VINÍCIUS - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : BUSCA a ultima margem do corretor no periodo..  se nao tiver onjetivo, devolve resultset sem linhas
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  intrDtINIVig NUMBER;
  intrDtFIMVig NUMBER;
  VAR_ANO      NUMBER;
  --

  IntrUltCompt     int;
  ----------------------------------------------------------------------------------------
BEGIN
  IF intrTRIMESTRE = 1 THEN
    -- JANEIRO / FEVEREIRO / MARCO
    intrDtINIVig := to_number(intrANO || '01');
    intrDtFIMVig := to_number(intrANO || '03');
  ELSIF intrTRIMESTRE = 2 THEN
    -- ABRIL / MAIO / JUNHO
    intrDtINIVig := to_number(intrANO || '04');
    intrDtFIMVig := to_number(intrANO || '06');
  ELSIF intrTRIMESTRE = 3 THEN
    -- JULHO / AGOSTO / SETEMBRO
    intrDtINIVig := to_number(intrANO || '07');
    intrDtFIMVig := to_number(intrANO || '09');
  ELSIF intrTRIMESTRE = 4 THEN
    -- OUTUBRO / NOVEMBRO / DEZEMBRO
    intrDtINIVig := to_number(intrANO || '10');
    intrDtFIMVig := to_number(intrANO || '12');
  END IF;

  SELECT nvl(max(mcc.ccompt_margm),-999)
    into IntrUltCompt
    FROM margm_contb_crrtr mcc
   where mcc.ccompt_margm between intrDtINIVig and intrDtFIMVig
     and mcc.ccanal_vda_segur = INTRCODCANAL
     and mcc.ccpf_cnpj_base = INTRCPF_CNPJ_BASE
     and mcc.ctpo_pssoa = CHRTPPESSOA;
     
  IF IntrUltCompt = -999 THEN
     IF intrDtINIVig IN (200701,200801,200901,201001,201101,201201) THEN
        VAR_ANO := TO_NUMBER(intrANO - 89); -- É PARA VOLTAR UM ANO....
     ELSE
        VAR_ANO := TO_NUMBER(intrANO - 1);
     END IF;
     intrDtINIVig := to_number(intrANO);
     SELECT nvl(max(mcc.ccompt_margm),-999) into IntrUltCompt
    			FROM margm_contb_crrtr mcc
		   where mcc.ccompt_margm between intrDtINIVig and intrDtFIMVig
     		and mcc.ccanal_vda_segur = INTRCODCANAL
     		and mcc.ccpf_cnpj_base = INTRCPF_CNPJ_BASE
     		and mcc.ctpo_pssoa = CHRTPPESSOA;
  END IF;

  OPEN RESULSET FOR
    SELECT 'valorMargem',
           mcc.pmargm_contb,
           'competenciaInicial',
           mcc.ccompt_margm,
           'competenciaFinal',
           To_Number(To_Char(Add_Months(To_Date(mcc.ccompt_margm, 'yyyymm'), -11), 'YYYYMM'))
      FROM margm_contb_crrtr mcc
     where mcc.ccompt_margm = IntrUltCompt
       and mcc.ccanal_vda_segur = INTRCODCANAL
       and mcc.ccpf_cnpj_base = INTRCPF_CNPJ_BASE
       and mcc.ctpo_pssoa = CHRTPPESSOA;

EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || 'CPF_CNPJ: ' || INTRCPF_CNPJ_BASE || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0183',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
END SGPB0184;
/

