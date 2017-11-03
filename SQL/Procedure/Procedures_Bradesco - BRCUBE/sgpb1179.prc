CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB1179(
RESULSET      OUT SYS_REFCURSOR,
INTRCPF_CNPJ  IN CRRTR.CCPF_CNPJ_CRRTR %TYPE,
CHRTPPESSOA   IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1179
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 18/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RECUPERANDO OS CANAIS ELEITOS . 2º CAMPANHA
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
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


OPEN RESULSET FOR

    SELECT
         'parmInfoCampanha.canalVendaVO.codigo',
         CCANAL_VDA_SEGUR,
         'parmInfoCampanha.canalVendaVO.descricao',
         RCANAL_VDA_SEGUR,
         'parmInfoCampanha.canalVendaVO.nome',
         ICANAL_VDA_SEGUR,
         'dataCorretorSelecao',
         DCRRTR_SELEC_CAMPA,
         'corretorUnificado.tipoPessoa',
         CTPO_PSSOA,
         'corretorUnificado.cnpjBase',
         CCPF_CNPJ_BASE,
         'corretorUnificado.nome',
         IATUAL_CRRTR

    FROM PARM_INFO_CAMPA PIC

    JOIN CRRTR_ELEIT_CAMPA CEC
      ON CEC.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR
     AND CEC.DINIC_VGCIA_PARM = PIC.DINIC_VGCIA_PARM

    JOIN CRRTR_UNFCA_CNPJ CUC
      ON CUC.CCPF_CNPJ_BASE   = CEC.CCPF_CNPJ_BASE
     AND CUC.CTPO_PSSOA       = CEC.CTPO_PSSOA

    JOIN CANAL_VDA_SEGUR CVS
      ON CVS.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR

   --
   --WHERE TO_DATE(99991231, 'YYYYMMDD') BETWEEN PIC.DINIC_VGCIA_PARM AND COALESCE(PIC.DFIM_VGCIA_PARM, TO_DATE(99991231, 'YYYYMMDD'))
   --WHERE DCRRTR_SELEC_CAMPA BETWEEN TO_DATE(20071001,'YYYYMMDD') AND TO_DATE(20080630, 'YYYYMMDD')
   WHERE PIC.DINIC_VGCIA_PARM =  TO_DATE(20071001,'YYYYMMDD')
   --

     AND CEC.CCPF_CNPJ_BASE = intCpfCnpjBase
     AND CEC.CTPO_PSSOA = CHRTPPESSOA;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET: CPF_CNPJ'||intCpfCnpjBase||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB1179');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET ' || SUBSTR(SQLERRM,1,100));

END SGPB1179;
/

