create or replace procedure sgpb_proc.SGPB1182(
    resulSet           OUT SYS_REFCURSOR,
    intrCodCanal       IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
    intrCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %type,
    chrTpPessoa        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
    intrANO            IN NUMBER,
    intrTRIMESTRE      IN NUMBER
)
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1182
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 19/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES - 2 CAMPANHA
  --      OBJETIVO        : canal extra-banco - Recupero os valores de BONIFICAÇÃO por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   : -

  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO   VARCHAR2(1000);
  chrLocalErro   VARCHAR2(2) := '00';
  intrDtINIVig   NUMBER;
  intrDtFIMVig   NUMBER;

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

        SELECT 'tipoApuracao',
               decode(CTPO_APURC, 1, 'Bônus', 'Bônus Adicional'),
               'producao',
               VPROD_CRRTR,
               'percentual',
               PBONUS_APURC,
               'bonus',
               VPROD_CRRTR * (PBONUS_APURC/100)

          FROM RSUMO_BONUS_CRRTR RBC

          WHERE RBC.CCOMPT BETWEEN intrDtINIVig AND intrDtFIMVig
            AND RBC.CCANAL_VDA_SEGUR = intrCodCanal
            AND RBC.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
            AND RBC.CTPO_PSSOA = chrTpPessoa
            AND RBC.CTPO_COMIS = 'CN';


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

    PR_GRAVA_MSG_LOG_CARGA('SGPB1182',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB1182;
/

