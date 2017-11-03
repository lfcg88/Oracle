CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6206(
RESULSET      OUT SYS_REFCURSOR,
INTRCPF_CNPJ  IN  CRRTR.CCPF_CNPJ_CRRTR%TYPE,
CHRTPPESSOA   IN  CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6206
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 15/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RETORNA RASPADINHA DO CORRETOR
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------

BEGIN

OPEN RESULSET FOR

      SELECT 'disponivel',
             PCD.QCUPOM_DISPN,
             'resgatado',
             PCD.QCUPOM_RETRD,
             'saldo',
             PCD.QCUPOM_DISPN - PCD.QCUPOM_RETRD
        FROM POSIC_CRRTR_DSTAQ PCD,
             CAMPA_DSTAQ       CD
       WHERE PCD.CCAMPA_DSTAQ    = CD.CCAMPA_DSTAQ
         AND PCD.DAPURC_DSTAQ    = CD.DAPURC_DSTAQ
         AND CD.CCAMPA_DSTAQ     = 1               --PRIMEIRA CAMPANHA DESTAQUE PLUS
         AND PCD.CTPO_PSSOA      = CHRTPPESSOA     --TIPO PESSOA
         AND PCD.CCPF_CNPJ_BASE  = INTRCPF_CNPJ;   --DOC CORRETOR

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: CPF_CNPJ'||INTRCPF_CNPJ||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6206');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6206;
/

