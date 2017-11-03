create or replace procedure sgpb_proc.SGPB1202(
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
  --      DATA            : 21/02/2008 GRUPO ECONOMICO
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES - 2 CAMPANHA
  --      OBJETIVO        : Lista todos os corretores do grupo economicoRecupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
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
      SELECT 'numCpfCnpjBase',
             CPAE.CCPF_CNPJ_BASE,
             'nome',
             CUC.IATUAL_CRRTR
        FROM CRRTR_PARTC_AGPTO_ECONM CPAE,
             CRRTR_UNFCA_CNPJ CUC
       WHERE CPAE.CTPO_PSSOA = CUC.CTPO_PSSOA
         AND CPAE.CCPF_CNPJ_BASE = CUC.CCPF_CNPJ_BASE
         AND CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR = intrCPF_CNPJ_BASE  --FILTRO
         AND CPAE.CTPO_PSSOA_AGPTO_ECONM_CRRTR = chrTpPessoa       --FILTRO
         ---
         ---O GRUPO ECONOMICO NAO ESTA LIGADO A CAMPANHA E NEM AO TRIMESTRE             
         --AND CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM 
         --BETWEEN TO_DATE(200801,'YYYYMM')                --FILTRO
         --AND LAST_DAY(TO_DATE(200803,'YYYYMM'))          --FILTRO      
         ---
         --AND CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM IS NULL;
         AND LAST_DAY(TO_DATE(intrDtFIMVig, 'YYYYMM')) BETWEEN CPAE.DINIC_VGCIA_PRTCP_AGPTO_ECONM AND NVL(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, TO_DATE(99991231, 'YYYYMMDD'));

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

        PR_GRAVA_MSG_LOG_CARGA('SGPB1202',
                                   var_log_erro,
                                   pc_util_01.VAR_LOG_PROCESSO,
                                    NULL,
                                    NULL);

END SGPB1202;
/

