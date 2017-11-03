CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0329Y(
-- IN
intrCPF_CNPJ            in   CRRTR.CCPF_CNPJ_CRRTR %type,
intrANO                 in   number,
intrCANAL               in   number,
chrTpPessoa             in   CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
-- OUT
chrAnoTrimestre         out varchar2,
chrNomeCanal            out varchar2,
datApuracao             out date,
chrCodGrupoRamo         out varchar2,
chrNomeGrupoRamo        out varchar2, 
chrNomeRotinaScheduler VARCHAR2 := 'SGPB0329Y')                                  
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
      chrAnoTrimestre          := '20074S/20073S/20072A/20071F/20064S/20063S/20062S/20061S/20054S/20053S/20052S/20051S/';
      chrNomeCanal             := 'BANCO';
      chrCodGrupoRamo          := '123/456/789/';
      chrNomeGrupoRamo         := 'AUTOMOVEL/RESIDENCIA/VIDA/';
      datApuracao              := '01/01/1900';
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
END SGPB0329Y;
/

