create or replace procedure sgpb_proc.SGPB0182(
    resulSet           OUT SYS_REFCURSOR,
    intrCodCanal       in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
    intrCPF_CNPJ_BASE  in CRRTR.CCPF_CNPJ_BASE %type,
    chrTpPessoa   in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
    intrANO       in number,
    intrTRIMESTRE in number
)
/*
974481
J
2006
3
*/
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0182
  --      DATA            : 08/05/2007
  --      AUTOR           : Vinícius - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : canal extra-banco - Recupero os valores de BONIFICAÇÃO por trimestre, para o SITE CORRETOR (On-Line).
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

    PR_GRAVA_MSG_LOG_CARGA('SGPB0182',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB0182;
/

