CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB1186
(
  RESULSET          OUT SYS_REFCURSOR,
  INTRCODCANAL      IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
  INTRCPF_CNPJ_BASE IN AGPTO_ECONM_CRRTR.CCPF_CNPJ_AGPTO_ECONM_CRRTR %type,
  CHRTPPESSOA       IN AGPTO_ECONM_CRRTR.CTPO_PSSOA_AGPTO_ECONM_CRRTR %type,  
  INTRANO           IN NUMBER,
  INTRTRIMESTRE     IN NUMBER
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1186 - 2º CAMPANHA.
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 19/02/2008
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : BUSCA a ultima margem do GRUPO ECONÔMICO no periodo..  se nao tiver onjetivo, devolve resultset sem linhas
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  intrDtINIVig NUMBER;
  intrDtFIMVig NUMBER;
  IntrUltCompt INT;
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
    -- O ANO DE 2007 ESTA HARD-CODE PARA QUE NO DE 2008
    -- ELE BUSQUE NA TABELA RESUMO O TRIMESTRE DO INICIO
    -- DA CAMPNHA QUE FOI EM 2007
    intrDtINIVig := to_number(2007 || '10');
    intrDtFIMVig := to_number(2007 || '12');
  END IF;
  
  --RECUPERANDO A ULTIMA COMPETENCIA COM MARGEM DO CORRETOR PARA O TRIMESTRE
  SELECT NVL(MAX(MCC.CCOMPT_MARGM),-999)
    INTO IntrUltCompt
    FROM MARGM_CONTB_AGPTO_ECONM_CRRTR MCC
   WHERE MCC.CCOMPT_MARGM BETWEEN intrDtINIVig AND intrDtFIMVig
     AND MCC.CCANAL_VDA_SEGUR = INTRCODCANAL
     AND MCC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = INTRCPF_CNPJ_BASE
     AND MCC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CHRTPPESSOA;     

  OPEN RESULSET FOR
    SELECT 'valorMargem',
           MCC.PMARGM_CONTB,
           'competenciaInicial',
           MCC.CCOMPT_MARGM,
           'competenciaFinal',
           TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(MCC.CCOMPT_MARGM, 'YYYYMM'), -11), 'YYYYMM'))
      FROM MARGM_CONTB_AGPTO_ECONM_CRRTR MCC
     WHERE MCC.CCOMPT_MARGM = IntrUltCompt
       AND MCC.CCANAL_VDA_SEGUR = INTRCODCANAL
       AND MCC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = INTRCPF_CNPJ_BASE
       AND MCC.CTPO_PSSOA_AGPTO_ECONM_CRRTR = CHRTPPESSOA;
       

EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || 'CPF_CNPJ: ' || INTRCPF_CNPJ_BASE || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA('SGPB1186',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
END SGPB1186;
/

