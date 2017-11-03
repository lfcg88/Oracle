CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0179_ACYSNE(
INTRCPF_CNPJ  IN CRRTR.CCPF_CNPJ_CRRTR %TYPE,
CHRTPPESSOA   IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0179
  --      NEGOCIO         : INET PLANO BONUS - SITE CORRETOR
  --      DATA            : 08/05/2007
  --      AUTOR           : VINÍCIUS - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : RECUPERANDO OS CANAIS ELEITOS .
  --      ALTERAÇÕES      :
  --                DATA  : 11/06/2007
  --                AUTOR : ALEXANDRE CYSNE ESTEVES
  --                OBS   : EXCEPTION CORRIGIDO
  -------------------------------------------------------------------------------------------------

  intCpfCnpjBase         NUMBER;

BEGIN

     --Recuperando o CNPJ e CPF base
     IF (chrTpPessoa = 'J') THEN
         intCpfCnpjBase := LPAD(intrCPF_CNPJ,14,0);
         intCpfCnpjBase := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 6);
     ELSE
         intCpfCnpjBase := LPAD(intrCPF_CNPJ,11,0);
         intCpfCnpjBase := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 2);
     END IF;


    SELECT
         CCANAL_VDA_SEGUR
         
         INTO intCpfCnpjBase

    FROM PARM_INFO_CAMPA PIC

    JOIN CRRTR_ELEIT_CAMPA CEC
      ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
     AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM

    JOIN CRRTR_UNFCA_CNPJ CUC
      ON CUC.CCPF_CNPJ_BASE   = CEC.CCPF_CNPJ_BASE
     AND CUC.CTPO_PSSOA       = CEC.CTPO_PSSOA

    JOIN CANAL_VDA_SEGUR CVS
      ON CVS.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR

   WHERE TO_DATE(99991231, 'YYYYMMDD') BETWEEN PIC.DINIC_VGCIA_PARM AND COALESCE(PIC.DFIM_VGCIA_PARM, TO_DATE(99991231, 'YYYYMMDD'))
     AND CEC.CCPF_CNPJ_BASE = intCpfCnpjBase
     AND CEC.CTPO_PSSOA = CHRTPPESSOA;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('INET: CPF_CNPJ'||intCpfCnpjBase||' ERROR: '|| 
    SUBSTR(SQLERRM,1,100), 'SGPB0179');  
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'INET ' || SUBSTR(SQLERRM,1,100));
    
END SGPB0179_ACYSNE;
/

