CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0330(intrCPF_CNPJ  in CRRTR.CCPF_CNPJ_CRRTR %type,
                                         chrTpPessoa   in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
                                         intrANO       in number,
                                         intrTRIMESTRE in number,
                                         intrMAG_CONTR out MARGM_CONTB_CRRTR.PMARGM_CONTB%type,
                                         intrANO_MGM_CONTR  out number,
                                         intrMES_MGM_CONTR  out number,
                                         
                                         chrNomeRotinaScheduler VARCHAR2 := 'SGPB0330'
                                         
                                         )
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0330
  --      DATA            : 11/01/2007
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Recupero o valor da MARGEM DE CONTRIBUIÇÃO, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  --
  --
  VAR_LOG_ERRO      VARCHAR2(1000);
  chrLocalErro      VARCHAR2(2) := '00';
  intrCPF_CNPJ_BASE CRRTR.CCPF_CNPJ_BASE%type;
  --
  intrDtINIVig           number;
  intrDtFIMVig           number;

  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    -- É passado o CPF_CNPJ completo por isso, calculo o CPF_CNPJ_BASE.
    If chrTpPessoa = 'F' then
      intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 2);
    Else
      intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 6);
    End If;
    
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
  
/*    FOR c IN (Select MAX(PMARGM_CONTB) PMARGM_CONTB,
                Decode(intrTRIMESTRE, 1, 3, 2, 6, 3, 9, 4, 12) MES_MGM_CONTR 
       FOR c IN (select PMARGM_CONTB PMARGM_CONTB,
                        substr(CCOMPT_MARGM, 5, 2) MES_MGM_CONTR,
                        substr(CCOMPT_MARGM, 1, 4) ANO_MGM_CONTR
                   From MARGM_CONTB_CRRTR
               Where ((intrTRIMESTRE = 1 and
                     substr(CCOMPT_MARGM, 5, 2) in ('01', '02', '03')) or
                     (intrTRIMESTRE = 2 and
                     substr(CCOMPT_MARGM, 5, 2) in ('04', '05', '06')) or
                     (intrTRIMESTRE = 3 and
                     substr(CCOMPT_MARGM, 5, 2) in ('07', '08', '09')) or
                     (intrTRIMESTRE = 4 and
                     substr(CCOMPT_MARGM, 5, 2) in ('10', '11', '12')))               
                  and substr(CCOMPT_MARGM, 1, 4) = intrANO
                where CTPO_PSSOA = chrTpPessoa
                 and CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE   
                 and CCOMPT_MARGM = ( select max(CCOMPT_MARGM)
                                        from MARGM_CONTB_CRRTR
                                       where CTPO_PSSOA = chrTpPessoa
                                         and CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE) */
 FOR c IN (Select MAX(PMARGM_CONTB) PMARGM_CONTB,
                  substr(CCOMPT_MARGM, 5, 2) MES_MGM_CONTR,
                  substr(CCOMPT_MARGM, 1, 4) ANO_MGM_CONTR
             From MARGM_CONTB_CRRTR
            where CTPO_PSSOA = chrTpPessoa
              and CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
              and CCOMPT_MARGM =
                  (select max(CCOMPT_MARGM)
                     from MARGM_CONTB_CRRTR
                    where CTPO_PSSOA = chrTpPessoa
                      and CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
                      and CCOMPT_MARGM between intrDtINIVig and intrDtFIMVig)
            group by CCOMPT_MARGM
 ) Loop
    
      intrMAG_CONTR := C.PMARGM_CONTB;

---      intrANO_MGM_CONTR := intrANO;
---      intrMES_MGM_CONTR := C.MES_MGM_CONTR;
      intrANO_MGM_CONTR := C.ANO_MGM_CONTR;
      intrMES_MGM_CONTR := C.MES_MGM_CONTR;
    End Loop;
  END;

BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  --
  --
  --PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
  --                               708,
  --                               PC_UTIL_01.Var_Rotna_Pc);
  --
  --
  geraDetail();
  --
  --
  --PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
   --                              708,
    --                             PC_UTIL_01.Var_Rotna_Po);
  --
  --
  chrLocalErro := '07';
  COMMIT;
  --
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                           ' Compet: (ANO-TRIMESTRE)' || to_char(intrANO) || '-' ||
                           to_char(intrTRIMESTRE) || 
                           ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0330',
                                var_log_erro,
                                pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);
    --
    --
    --PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
     --                              708,
    --                               PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0330;
/

