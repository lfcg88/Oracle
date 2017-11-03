CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0329K(
-- IN
intrANO                 in   number,
intrTRIMESTRE           in   number,
intrCPF_CNPJ            in   CRRTR.CCPF_CNPJ_CRRTR %type,
chrTpPessoa             in   CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
intrCANAL               in   number,
-- OUT
percMargemContrib       out  number,
percBonus	              out  number,
percBonusAdicional      out  number,
premBonusAdicional      out  number,
premBonificacao	        out  number,
premLiqAuto	            out  number,
premLiqBResid	          out  number,
listaDistribuicao       out  VARCHAR2,
chrNomeRotinaScheduler VARCHAR2 := 'SGPB0329K')                                  
------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0330
  --      DATA            : 11/01/2007
  --      AUTOR           : Ralph Aguiar - TESTE
  --      OBJETIVO        : Plano Bônus - V02
--------------------------------------------------------------------
 IS
  --
  VAR_LOG_ERRO      VARCHAR2(1000);
  chrLocalErro      VARCHAR2(2) := '00';
  ntrCPF_CNPJ_BASE  CRRTR.CCPF_CNPJ_BASE%type;
  ntrchrTpPessoa    CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type;
  --
----------------------geraDetail
  
  PROCEDURE geraDetail IS
  BEGIN
            percMargemContrib     := 12560000;
            percBonus	            := 12560000;
            percBonusAdicional    := 12560000;
            premBonusAdicional    := 12560000;
            premBonificacao	      := 12560000;
            premLiqAuto	          := 12560000;
            premLiqBResid	        := 12560000;
            listaDistribuicao     := '10110000112345678901234567890/20220000212345678901234567890/30330000312345678901234567890/';

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
    
    --
END SGPB0329K;
/

