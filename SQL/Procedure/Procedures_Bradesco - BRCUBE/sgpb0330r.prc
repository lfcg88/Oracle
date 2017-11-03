CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0330R(

--

intrANO                 in  number,
intrTRIMESTRE           in  number,
intrCPF_CNPJ            in  CRRTR.CCPF_CNPJ_CRRTR %type,
chrTpPessoa             in  CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
intrMAG_CONTR           out MARGM_CONTB_CRRTR.PMARGM_CONTB%type,
intrANO_MGM_CONTR_INIC  out number,
intrMES_MGM_CONTR_INIC  out number,
intrANO_MGM_CONTR_FIM   out number, 
intrMES_MGM_CONTR_FIM   out number,
         
chrNomeRotinaScheduler VARCHAR2 := 'SGPB0330R'
                                                                                )
------------------------------------------------------------------
--String query = "{ call SGPB0330( ?, ?, ?, ?, ?, ?, ?, ?, ? ) }";
--callableStatement = connection.prepareCall(query);                                      
------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0330
  --      DATA            : 11/01/2007
  --      AUTOR           : Ralph Aguiar - TESTE
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
  ntrCPF_CNPJ_BASE CRRTR.CCPF_CNPJ_BASE%type;
  ntrchrTpPessoa   CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type;
  --
  ----------------------geraDetail
  
  PROCEDURE geraDetail IS
  BEGIN

      intrMAG_CONTR          := 50000;
      intrANO_MGM_CONTR_INIC := 2006;
      intrMES_MGM_CONTR_INIC := 12;
      intrANO_MGM_CONTR_FIM  := 2007;
      intrMES_MGM_CONTR_FIM  := 01;
      ntrCPF_CNPJ_BASE       := intrCPF_CNPJ;
      ntrchrTpPessoa         := chrTpPessoa;
  END;

BEGIN
  
  --
  geraDetail();
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
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                                   708,
                                   PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0330R;
/

