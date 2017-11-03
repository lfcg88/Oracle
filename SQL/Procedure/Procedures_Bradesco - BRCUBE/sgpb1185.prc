create or replace procedure sgpb_proc.SGPB1185(
    resulSet           OUT SYS_REFCURSOR,
    intrCodCanal       IN CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
    intrCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %type,
    chrTpPessoa        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
    intrANO            IN number,
    intrTRIMESTRE      IN number
)
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1185
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 20/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES - 2 CAMPANHA
  --      OBJETIVO        : canal banco/finasa - Recupero os valores de BONIFICA��O por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERA��ES      : Comentado validacao de trimestre devido o trimestre comecar no quarto trimestre
  --                DATA  : 09/01/2008
  --                AUTOR : ALEXANDRE CYSNE ESTEVES
  --                OBS   : -

  -------------------------------------------------------------------------------------------------
 IS
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  intrDtINIVig           NUMBER;
  intrDtFIMVig           NUMBER;
  VAR_TRIMESTRE          NUMBER := 0;

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

  ----------------------------------------------------------------------------------------
  --RECUPERANDO O TRIMESTRE DO CORRETOR SELECIONADO
  --
  -- tem que mostrar somente a produ��o a partir da data em que foi eleito
  -- Se o trimestre a ser calculado for anterior a data da elei��o n�o vai mostrar nada
  -- wassily
  ----------------------------------------------------------------------------------------
   PROCEDURE getTrimestre(PCodCanal    in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
                          PCpfCnpjBase in CRRTR_UNFCA_CNPJ.CCPF_CNPJ_BASE %TYPE,
                          PCtpoPessoa  in CRRTR_UNFCA_CNPJ.Ctpo_Pssoa %TYPE,
                          VAR_TRIMESTRE out number) IS
    begin
      chrLocalErro := 10;
      -- Pega primeira vez em que o corretor foi eleito
      SELECT TO_CHAR(MIN(DCRRTR_SELEC_CAMPA),'Q') INTO VAR_TRIMESTRE
             FROM crrtr_eleit_campa cec
             WHERE cec.CCANAL_VDA_SEGUR=PCodCanal AND
                   cec.CCPF_CNPJ_BASE=PCpfCnpjBase AND
                   CEC.CTPO_PSSOA=PCtpoPessoa;
     -- tem que pegar o trimestre anterior por que ele foi eleito com base no ultimo trimestre.
     IF VAR_TRIMESTRE <> 1 THEN
        VAR_TRIMESTRE := VAR_TRIMESTRE - 1 ;
     END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
          chrLocalErro := 11;
          PR_GRAVA_MSG_LOG_CARGA('SGPB1185','Cod.Erro: '||chrLocalErro ||' CPF_CNPJ: '||intrCPF_CNPJ_BASE||
                        ' Compet: '||to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                        pc_util_01.VAR_LOG_PROCESSO,NULL, NULL);
          COMMIT;
          Raise_Application_Error(-20210,'ERRO (1) NA CONSULTA DO PLANO DE BONUS. DETALHES DO ERRO FORAM LOGADOS.');
     WHEN OTHERS THEN
          chrLocalErro := 12;
          PR_GRAVA_MSG_LOG_CARGA('SGPB1185','Cod.Erro: '||chrLocalErro ||' CPF_CNPJ: '||intrCPF_CNPJ_BASE||
                        ' Compet: '||to_char(intrDtINIVig)||'-'||to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                        pc_util_01.VAR_LOG_PROCESSO,NULL, NULL);
          COMMIT;
          Raise_Application_Error(-20210,'ERRO (2) NA CONSULTA DO PLANO DE BONUS. DETALHES DO ERRO FORAM LOGADOS.');

    end getTrimestre;
  ----------------------------------------------------------------------------------------geraDetail
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

    /*RECUPERA O TRIMESTRE DO CORRETOR SELECIONADO*/
    --getTrimestre(intrCodCanal,intrCPF_CNPJ_BASE, chrTpPessoa, VAR_TRIMESTRE);

    /*S� EXECUTA A PROCEDURE SE O TRIMESTRE DE PAR�METRO FOR MAIOR
    OU IGUAL AO TRIMESTRE DO CORRETOR SELECIONADO*/
    --IF VAR_TRIMESTRE <= intrTRIMESTRE THEN - Alexandre Cysne 09/01/2008

     OPEN resulSet FOR

        SELECT 'tipoApuracao',
               'B�nus + B�nus Adicional',
               'producao',
               sum(VPROD_CRRTR),
               'percentual',
               max(PBONUS_APURC),
               'bonus',
               sum(VPROD_CRRTR * (PBONUS_APURC/100))

          FROM RSUMO_BONUS_CRRTR RBC

          WHERE RBC.CCOMPT BETWEEN intrDtINIVig AND intrDtFIMVig
            AND RBC.CCANAL_VDA_SEGUR = intrCodCanal
            AND RBC.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
            AND RBC.CTPO_PSSOA = chrTpPessoa
            AND RBC.CTPO_COMIS = 'CN';

    --END IF;

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

    PR_GRAVA_MSG_LOG_CARGA('SGPB1185',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB1185;
/

