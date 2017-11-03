CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6200(
RESULSET      OUT SYS_REFCURSOR,
INTRCPF_CNPJ  IN  CRRTR.CCPF_CNPJ_CRRTR%TYPE,
CHRTPPESSOA   IN  CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6200
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 08/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : VALIDANDO SE O CORRETOR ESTA PARTICIPANDO DA CAMPANHA
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------

  intCpfCnpjBase    NUMBER;

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

      SELECT 'parmInfoCampanha.canalVendaVO.codigo',
             PRD.CRGNAL,                                  --CODIGO DA REGIONAL
             'dataCorretorSelecao',                       
             CD.DAPURC_DSTAQ,                             --VALIDAR
             'corretorUnificado.tipoPessoa',
             PRD.CTPO_PSSOA,                              --TIPO PESSOA
             'corretorUnificado.cnpjBase',
             PRD.CCPF_CNPJ_BASE,                          --CNPJ CPF
             'corretorUnificado.nome',
             CUC.IATUAL_CRRTR,                            --NOME DA CORRETORA
             'parmInfoCampanha.canalVendaVO.nomeRegional',               
             DRS.IDIR_RGNAL_SEGDR,                        --NOME DA REGIONAL                                    
             'parmInfoCampanha.canalVendaVO.dataApuracao',
             TO_CHAR(CD.DAPURC_DSTAQ,'DD/MM/YYYY')        --DATA APURACAO
        FROM CAMPA_DSTAQ           CD,
             POSIC_RGNAL_DSTAQ     PRD,
             CRRTR_UNFCA_CNPJ      CUC,
             DIR_RGNAL_SEGDR_DW    DRS
       WHERE PRD.CCAMPA_DSTAQ      = CD.CCAMPA_DSTAQ
         AND PRD.DAPURC_DSTAQ      = CD.DAPURC_DSTAQ
         AND CD.CCAMPA_DSTAQ       = 1                    --PRIMEIRA CAMPANHA DESTAQUE PLUS    
         AND CD.CIND_CAMPA_ATIVO   = 'S'                  --CAMPANHA ATIVA   
          --
         AND PRD.CTPO_PSSOA        = CUC.CTPO_PSSOA
         AND PRD.CCPF_CNPJ_BASE    = CUC.CCPF_CNPJ_BASE
          --
         AND DRS.CCHAVE_DIR_RGNAL  = PRD.CRGNAL
          --
         AND PRD.CTPO_PSSOA        = CHRTPPESSOA          --TIPO PESSOA
         AND PRD.CCPF_CNPJ_BASE    = intCpfCnpjBase;      --DOC CORRETOR                

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: CPF_CNPJ'||intCpfCnpjBase||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6200');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6200;
/

