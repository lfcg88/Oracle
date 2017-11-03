create or replace procedure sgpb_proc.SGPB1201(
    resulSet           OUT SYS_REFCURSOR,
    intrCodCanal       IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
    intrCPF_CNPJ_BASE  IN AGPTO_ECONM_CRRTR.CCPF_CNPJ_AGPTO_ECONM_CRRTR %type,
    chrTpPessoa        IN AGPTO_ECONM_CRRTR.CTPO_PSSOA_AGPTO_ECONM_CRRTR %type,    
    intrANO            IN NUMBER,
    intrTRIMESTRE      IN NUMBER
)
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1201
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 19/02/2008 GRUPO ECONOMICO
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES - 2 CAMPANHA
  --      OBJETIVO        : Recupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  intrDtINIVig           number;
  intrDtFIMVig           number;

  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
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

     OPEN resulSet FOR
         
        SELECT 
        'competencia',
               decode(to_number(to_char(to_date(ROC120.CCOMPT, 'yyyymm'), 'mm')),
                1, 'Janeiro',
                2, 'Fevereiro',
                3, 'Março',
                4, 'Abril',
                5, 'Maio',
                6, 'Junho',
                7, 'Julho',
                8, 'Agosto',
                9, 'Setembro',
                10, 'Outubro',
                11, 'Novembro',
                12, 'Dezembro'),
               'canal',
               ROC120.CCANAL_VDA_SEGUR,
               'ramo',
               ROC120.CGRP_RAMO_PLANO,
               'numCpfCnpjBase',
               ROC120.CCPF_CNPJ_AGPTO_ECONM_CRRTR,
               'tipoPessoa',
               ROC120.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
               'tipoComissao',
               ROC120.CTPO_COMIS,

               'producaoAuto',
               ROC120.VPROD_GRP_ECONM,
               'objetivoAuto',
               ROC120.VOBJTV_PROD_AGPTO_ECONM_ALT,
               'itemProducaoAuto',
               ROC120.QTOT_ITEM_PROD,

               'producaoBilhete',
               ROC810.VPROD_GRP_ECONM,
               'objetivoBilhete',
               ROC810.VOBJTV_PROD_AGPTO_ECONM_ALT,
               'itemProducaoBilhete',
               ROC810.QTOT_ITEM_PROD--,

               --'producaoRe',
               --ROC999.VPROD_CRRTR,
               --'objetivoRe',
               --ROC810.VOBJTV_PROD_AGPTO_ECONM_ALT--,
               --ROC999.VOBJTV_PROD_CRRTR_ALT,
               --'itemProducaoRe',
               --ROC999.QTOT_ITEM_PROD

          FROM RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROC120

          join RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROC810
            on ROC810.CCOMPT = ROC120.CCOMPT
           AND ROC810.CCANAL_VDA_SEGUR = ROC120.CCANAL_VDA_SEGUR
           AND ROC810.CCPF_CNPJ_AGPTO_ECONM_CRRTR = ROC120.CCPF_CNPJ_AGPTO_ECONM_CRRTR
           AND ROC810.CTPO_PSSOA_AGPTO_ECONM_CRRTR = ROC120.CTPO_PSSOA_AGPTO_ECONM_CRRTR
           AND ROC810.CTPO_COMIS = 'CN'
           and ROC810.Cgrp_Ramo_Plano = '810'

          --join RSUMO_OBJTV_AGPTO_ECONM_CRRTR ROC999
          --  on ROC999.CCOMPT = ROC120.CCOMPT
          -- AND ROC999.CCANAL_VDA_SEGUR = ROC120.CCANAL_VDA_SEGUR
          -- AND ROC999.CCPF_CNPJ_AGPTO_ECONM_CRRTR = ROC120.CCPF_CNPJ_AGPTO_ECONM_CRRTR
          -- AND ROC999.CTPO_PSSOA_AGPTO_ECONM_CRRTR = ROC120.CTPO_PSSOA_AGPTO_ECONM_CRRTR
          -- AND ROC999.CTPO_COMIS = 'CN'
          -- and ROC999.Cgrp_Ramo_Plano = '999'

          WHERE ROC120.CCOMPT BETWEEN intrDtINIVig AND intrDtFIMVig
            AND ROC120.CCANAL_VDA_SEGUR = intrCodCanal
            AND ROC120.CCPF_CNPJ_AGPTO_ECONM_CRRTR = intrCPF_CNPJ_BASE
            AND ROC120.CTPO_PSSOA_AGPTO_ECONM_CRRTR = chrTpPessoa
            AND ROC120.CTPO_COMIS = 'CN'
            and ROC120.Cgrp_Ramo_Plano = '120'
         ORDER BY ROC120.CCOMPT;
         


  EXCEPTION
      WHEN OTHERS THEN
        --
        --
        ROLLBACK;
        --
        var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                               'CPF_CNPJ: ' || intrCPF_CNPJ_BASE ||
                              ' Compet: ' || to_char(intrDtINIVig) || '-' ||
                               to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                              1,
                              PC_UTIL_01.VAR_TAM_MSG_ERRO);

        PR_GRAVA_MSG_LOG_CARGA('SGPB1201',
                                   var_log_erro,
                                   pc_util_01.VAR_LOG_PROCESSO,
                                    NULL,
                                    NULL);




END SGPB1201;
/

