CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6207(
RESULSET           OUT SYS_REFCURSOR,
intrCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %TYPE,
CHRTPPESSOA        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
intrREGIONAL       IN POSIC_RGNAL_DSTAQ.CRGNAL %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6207
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 23/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : VALIDAR SE O CORRETOR TERA DIREITO AO KIT ESPECIAL
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------

BEGIN

OPEN RESULSET FOR

     SELECT 'kitespecial',
            PRD.CIND_RGNAL_ALCAN_META,
            'msgkitespecial',
             decode(PRD.CIND_RGNAL_ALCAN_META,
             'N', ' ',
             'S', 'Parabéns !!! Você terá direito a um Kit Especial')
       FROM POSIC_RGNAL_DSTAQ PRD,
            CAMPA_DSTAQ       CD
      WHERE PRD.CCAMPA_DSTAQ  = CD.CCAMPA_DSTAQ
        AND PRD.DAPURC_DSTAQ   = CD.DAPURC_DSTAQ
        AND CD.CCAMPA_DSTAQ    = 1
        AND PRD.CRGNAL         = intrREGIONAL
        AND PRD.CTPO_PSSOA     = CHRTPPESSOA
        AND PRD.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: CPF_CNPJ'||intrCPF_CNPJ_BASE||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6207');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6207;
/

