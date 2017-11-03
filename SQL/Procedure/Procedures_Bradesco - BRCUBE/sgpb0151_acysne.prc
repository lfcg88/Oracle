create or replace procedure sgpb_proc.SGPB0151_ACYSNE(
    resulSet           OUT SYS_REFCURSOR,
    intrCodCanal       in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
    intrCPF_CNPJ_BASE  in CRRTR.CCPF_CNPJ_BASE %type,
    chrTpPessoa   in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
    intrANO       in number,
    intrTRIMESTRE in number
)

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0151
  --      DATA            : 08/05/2007
  --      AUTOR           : Vinícius - ANALISE E DESENVOLVIMENTO DE SISTEMAS
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
        intrDtINIVig := to_number(intrANO || '10');
        intrDtFIMVig := to_number(intrANO || '12');
      End If;
      
     OPEN resulSet FOR
          
        SELECT 'competencia',
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
               ROC120.CCPF_CNPJ_BASE,
               'tipoPessoa',
               ROC120.CTPO_PSSOA,
               'tipoComissao',
               ROC120.CTPO_COMIS,
               
               'producaoAuto',
               ROC120.VPROD_CRRTR,
               'objetivoAuto',
               ROC120.VOBJTV_PROD_CRRTR_ALT,
               'itemProducaoAuto',
               ROC120.QTOT_ITEM_PROD,

               'producaoRe',
               ROC810.VPROD_CRRTR,
               'objetivoRe',
               ROC810.VOBJTV_PROD_CRRTR_ALT,
               'itemProducaoRe',
               ROC810.QTOT_ITEM_PROD,

               'producaoBilhete',
               ROC999.VPROD_CRRTR,
               'objetivoBilhete',
               ROC999.VOBJTV_PROD_CRRTR_ALT,
               'itemProducaoBilhete',
               ROC999.QTOT_ITEM_PROD
               
          FROM RSUMO_OBJTV_CRRTR ROC120
          
          join RSUMO_OBJTV_CRRTR ROC810
            on ROC810.CCOMPT = ROC120.CCOMPT
           AND ROC810.CCANAL_VDA_SEGUR = ROC120.CCANAL_VDA_SEGUR
           AND ROC810.CCPF_CNPJ_BASE = ROC120.CCPF_CNPJ_BASE
           AND ROC810.CTPO_PSSOA = ROC120.CTPO_PSSOA
           AND ROC810.CTPO_COMIS = 'CN'
           and ROC810.Cgrp_Ramo_Plano = '810'

          join RSUMO_OBJTV_CRRTR ROC999
            on ROC999.CCOMPT = ROC120.CCOMPT
           AND ROC999.CCANAL_VDA_SEGUR = ROC120.CCANAL_VDA_SEGUR
           AND ROC999.CCPF_CNPJ_BASE = ROC120.CCPF_CNPJ_BASE
           AND ROC999.CTPO_PSSOA = ROC120.CTPO_PSSOA
           AND ROC999.CTPO_COMIS = 'CN'
           and ROC999.Cgrp_Ramo_Plano = '999'

          WHERE ROC120.CCOMPT BETWEEN intrDtINIVig AND intrDtFIMVig 
            AND ROC120.CCANAL_VDA_SEGUR = intrCodCanal
            AND ROC120.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
            AND ROC120.CTPO_PSSOA = chrTpPessoa
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
    
        PR_GRAVA_MSG_LOG_CARGA('SGPB0151',
                                   var_log_erro,
                                   pc_util_01.VAR_LOG_PROCESSO,
                                    NULL,
                                    NULL);
    



END SGPB0151_ACYSNE;
/

