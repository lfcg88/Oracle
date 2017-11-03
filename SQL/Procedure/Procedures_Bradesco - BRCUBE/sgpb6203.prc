CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6203(
RESULSET           OUT SYS_REFCURSOR,
intrCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %TYPE,
CHRTPPESSOA        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
intrREGIONAL       IN POSIC_RGNAL_DSTAQ.CRGNAL %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6203
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 12/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RANKING POR REGIONAL ( R$ ) 1 PRIMEIROS + O CORRETOR LOGADO
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------

BEGIN

OPEN RESULSET FOR

      SELECT 'colocacao',
             NRKING_PROD_RGNAL,
             'regional',
             CRGNAL, 
             'cpfCnpjBase',
             CCPF_CNPJ_BASE, 
             'nome',
             IATUAL_CRRTR,
             'producao',
             PRODUCAO_TOTAL,
            'restricao',
       			 CASE 
             WHEN (VPERC_CRSCT_RGNAL_AUTO < 100 AND VPERC_CRSCT_RGNAL_RE < 100) THEN
             		'Não Classificado ( A + R)'
             WHEN (VPERC_CRSCT_RGNAL_AUTO >= 100 AND VPERC_CRSCT_RGNAL_RE < 100) THEN
             		'Não Classificado ( R )'
             WHEN (VPERC_CRSCT_RGNAL_AUTO < 100 AND VPERC_CRSCT_RGNAL_RE >= 100) THEN
             		'Não Classificado ( A )'
             ELSE
                 'Classificado'
             END CASE
             --
       FROM (SELECT   PRD.NRKING_PROD_RGNAL,
                      PRD.CRGNAL,
                      PRD.CCPF_CNPJ_BASE,
                      CUC.IATUAL_CRRTR,
                      PRD.VPROD_RGNAL_AUTO + PRD.VPROD_RGNAL_RE PRODUCAO_TOTAL,
                      PRD.VPERC_CRSCT_RGNAL_AUTO,
                      PRD.VPERC_CRSCT_RGNAL_RE                      
                 FROM POSIC_RGNAL_DSTAQ PRD,
                      CAMPA_DSTAQ       CD,
                      CRRTR_UNFCA_CNPJ  CUC
                WHERE PRD.CCAMPA_DSTAQ = CD.CCAMPA_DSTAQ
                  AND PRD.DAPURC_DSTAQ = CD.DAPURC_DSTAQ
                  AND PRD.CTPO_PSSOA   = CUC.CTPO_PSSOA
                  AND PRD.CCPF_CNPJ_BASE = CUC.CCPF_CNPJ_BASE
                  AND CD.CCAMPA_DSTAQ  = 1                     --PRIMEIRA CAMPANHA DESTAQUE
                  AND PRD.CRGNAL       = intrREGIONAL          --PARAMETRO REGIONAL LOGADA DO CORRETOR
             ORDER BY 1
             )
       WHERE ROWNUM <=1                                        --TOTAL DE LINHAS
      --  
      UNION
      --
      SELECT   'colocacao',
               PRD.NRKING_PROD_RGNAL,
               'regional',
               PRD.CRGNAL,
               'cpfCnpjBase',
               PRD.CCPF_CNPJ_BASE,
               'nome',
               CUC.IATUAL_CRRTR,
               'producao',
               PRD.VPROD_RGNAL_AUTO + PRD.VPROD_RGNAL_RE PRODUCAO_TOTAL,
              'restricao',
         			 CASE 
               WHEN (VPERC_CRSCT_RGNAL_AUTO < 100 AND VPERC_CRSCT_RGNAL_RE < 100) THEN
               		'Não Classificado ( A + R)'
               WHEN (VPERC_CRSCT_RGNAL_AUTO >= 100 AND VPERC_CRSCT_RGNAL_RE < 100) THEN
               		'Não Classificado ( R )'
               WHEN (VPERC_CRSCT_RGNAL_AUTO < 100 AND VPERC_CRSCT_RGNAL_RE >= 100) THEN
               		'Não Classificado ( A )'
               ELSE
                   'Classificado'
               END CASE
               FROM POSIC_RGNAL_DSTAQ PRD,
                    CAMPA_DSTAQ       CD,
                    CRRTR_UNFCA_CNPJ  CUC
              WHERE PRD.CCAMPA_DSTAQ = CD.CCAMPA_DSTAQ
                AND PRD.DAPURC_DSTAQ = CD.DAPURC_DSTAQ
                AND PRD.CTPO_PSSOA   = CUC.CTPO_PSSOA
                AND PRD.CCPF_CNPJ_BASE = CUC.CCPF_CNPJ_BASE
                AND CD.CCAMPA_DSTAQ  = 1                   --PRIMEIRA CAMPANHA DESTAQUE
                AND PRD.CRGNAL = intrREGIONAL              --PARAMETRO REGIONAL LOGADA DO CORRETOR
                AND PRD.CTPO_PSSOA = CHRTPPESSOA           --PARAMETRO CORRETOR LOGADO
                AND PRD.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE --PARAMETRO CORRETOR LOGADO          
                --
                ORDER BY 2;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: CPF_CNPJ'||intrCPF_CNPJ_BASE||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6203');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6203;
/

