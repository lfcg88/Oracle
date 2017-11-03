CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0179_nova(
--RESULSET      OUT SYS_REFCURSOR,
INTRCPF_CNPJ       IN CRRTR.CCPF_CNPJ_CRRTR %TYPE,
CHRTPPESSOA        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
CODIGO             OUT VARCHAR2,
CCANAL_VDA_SEGUR   OUT PARM_INFO_CAMPA.CCANAL_VDA_SEGUR%TYPE,
DESCRICAO          OUT VARCHAR2,
RCANAL_VDA_SEGUR   OUT CANAL_VDA_SEGUR.RCANAL_VDA_SEGUR%TYPE,
NOME               OUT VARCHAR2,
ICANAL_VDA_SEGUR   OUT CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR%TYPE,
DATA               OUT VARCHAR2,
DCRRTR_SELEC_CAMPA OUT CRRTR_ELEIT_CAMPA.DCRRTR_SELEC_CAMPA%TYPE,
TIPOPESSOA         OUT VARCHAR2,
CTPO_PSSOA         OUT CRRTR_ELEIT_CAMPA.CTPO_PSSOA%TYPE,
CNPJBASE           OUT VARCHAR2,
CCPF_CNPJ_BASE     OUT CRRTR_ELEIT_CAMPA.CTPO_PSSOA%TYPE,
UNIFICADO          OUT VARCHAR2,
IATUAL_CRRTR       OUT CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE
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

--OPEN RESULSET FOR
   FOR C IN (
    SELECT
         'parmInfoCampanha.canalVendaVO.codigo' CODIGO,
         CCANAL_VDA_SEGUR,
         'parmInfoCampanha.canalVendaVO.descricao' DESCRICAO,
         RCANAL_VDA_SEGUR,
         'parmInfoCampanha.canalVendaVO.nome' NOME,
         ICANAL_VDA_SEGUR,
         'dataCorretorSelecao' DATA,
         DCRRTR_SELEC_CAMPA,
         'corretorUnificado.tipoPessoa' TIPOPESSOA,
         CTPO_PSSOA,
         'corretorUnificado.cnpjBase' CNPJBASE,
         CCPF_CNPJ_BASE,
         'corretorUnificado.nome' UNIFICADO,
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

   WHERE TO_DATE(99991231, 'YYYYMMDD') BETWEEN PIC.DINIC_VGCIA_PARM AND COALESCE(PIC.DFIM_VGCIA_PARM, TO_DATE(99991231, 'YYYYMMDD'))
   
     --TEMPORARIA PARA O INET
     --AND DCRRTR_SELEC_CAMPA < TO_DATE(20070701,'YYYYMMDD')
        
     AND CEC.CCPF_CNPJ_BASE = intCpfCnpjBase
     AND CEC.CTPO_PSSOA = CHRTPPESSOA
     ) LOOP

           CODIGO                := 'parmInfoCampanha.canalVendaVO.codigo';
           CCANAL_VDA_SEGUR      := C.CCANAL_VDA_SEGUR;
           DESCRICAO             := 'parmInfoCampanha.canalVendaVO.descricao';
           RCANAL_VDA_SEGUR      := C.RCANAL_VDA_SEGUR;
           NOME                  := 'parmInfoCampanha.canalVendaVO.nome';
           ICANAL_VDA_SEGUR      := C.ICANAL_VDA_SEGUR;
           DATA                  := 'dataCorretorSelecao';
           DCRRTR_SELEC_CAMPA    := C.DCRRTR_SELEC_CAMPA;
           TIPOPESSOA            := 'corretorUnificado.tipoPessoa';
           CTPO_PSSOA            := C.CTPO_PSSOA;
           CNPJBASE              := 'corretorUnificado.cnpjBase';
           CCPF_CNPJ_BASE        := C.CCPF_CNPJ_BASE;
           UNIFICADO             := 'corretorUnificado.nome';
           IATUAL_CRRTR          := C.IATUAL_CRRTR;
     
       END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('INET: CPF_CNPJ'||intCpfCnpjBase||' ERROR: '|| 
    SUBSTR(SQLERRM,1,100), 'SGPB0179');  
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'INET ' || SUBSTR(SQLERRM,1,100));
    
END SGPB0179_nova;
/

