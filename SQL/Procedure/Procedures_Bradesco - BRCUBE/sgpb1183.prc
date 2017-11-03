CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB1183(
RESULSET           OUT SYS_REFCURSOR,
INTRCODCANAL       IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
INTRCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %TYPE,
CHRTPPESSOA        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
INTRANO            IN NUMBER,
INTRTRIMESTRE      IN NUMBER
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1183 - 2� CAMPANHA.
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 20/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : BUSCA HIST�RICO DOS PAGAMENTOS.
  --      ALTERA��ES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  intrDtINIVig           NUMBER;
  intrDtFIMVig           NUMBER;
  --
BEGIN
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
        -- O ANO DE 2007 ESTA HARD-CODE PARA QUE NO DE 2008
        -- ELE BUSQUE NA TABELA RESUMO O TRIMESTRE DO INICIO
        -- DA CAMPNHA QUE FOI EM 2007
        intrDtINIVig := to_number(2007 || '10');
        intrDtFIMVig := to_number(2007 || '12');
      End If;

      OPEN RESULSET FOR

        SELECT 'valor',
               HDP.VDISTR_PGTO_CRRTR,
               'cpd',
               HDP.CCRRTR,
               'unidadeProducao',
               UP.IUND_PROD
        --
          FROM PGTO_BONUS_CRRTR PBC
        --
          JOIN HIST_DISTR_PGTO HDP ON HDP.CPGTO_BONUS = PBC.CPGTO_BONUS
        --
/*          JOIN CRRTR C ON C.CUND_PROD = HDP.CUND_PROD
                      AND C.CCRRTR = HDP.CCRRTR
                      AND C.CCRRTR BETWEEN Intinicialfaixa AND Intfinalfaixa*/
        --
          JOIN UND_PROD UP ON UP.CUND_PROD = HDP.CUND_PROD
        --
         WHERE PBC.CCOMPT_PGTO BETWEEN intrDtINIVig AND intrDtFIMVig
           AND PBC.CCPF_CNPJ_BASE = INTRCPF_CNPJ_BASE
           AND PBC.CTPO_PSSOA = CHRTPPESSOA
           AND exists (
             SELECT pap.CPGTO_BONUS
               from papel_apurc_pgto pap
              where pap.cpgto_bonus = pbc.cpgto_bonus
                and pap.cindcd_papel = 0
                and pap.ccanal_vda_segur = INTRCODCANAL
           )


           ORDER BY UP.IUND_PROD;

  EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                           'CPF_CNPJ: ' || INTRCPF_CNPJ_BASE || ' # ' || SQLERRM,
                          1,
                          PC_UTIL_01.VAR_TAM_MSG_ERRO);

    PR_GRAVA_MSG_LOG_CARGA('SGPB1183',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB1183;
/

