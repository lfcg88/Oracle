create or replace procedure sgpb_proc.SGPB6201(
RESULSET           OUT SYS_REFCURSOR,
intrCPF_CNPJ_BASE  IN CRRTR.CCPF_CNPJ_BASE %TYPE,
CHRTPPESSOA        IN CRRTR_UNFCA_CNPJ.CTPO_PSSOA %TYPE,
intrREGIONAL       IN POSIC_RGNAL_DSTAQ.CRGNAL %TYPE
)
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6201
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 12/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RETORNAR A PRODUCAO DO AUTO E RE DO CORRETOR POR REGIONAL
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------
 IS

BEGIN

     OPEN resulSet FOR

      SELECT 
             'competencia',
             decode(to_number(to_char(to_date(PRD.DAPURC_DSTAQ, 'dd/mm/yyyy'), 'mm')),
             1, 'Janeiro',
             2, 'Fevereiro',
             3, 'Março',
             4, 'Abril',
             5, 'Maio',
             6, 'Junho',
             7, 'Julho',
             8, 'Agosto',
             9, 'Setembro',
             10, 'Outubro',
             11, 'Novembro',
             12, 'Dezembro'),      
             'producaoAuto',
             PRD.VPROD_RGNAL_AUTO,
             'objetivoAuto',
             MRD.VMETA_AUTO / 3,   
             'pelObjetivoAuto',
             (PRD.VPROD_RGNAL_AUTO/(MRD.VMETA_AUTO/3))*100,
             'producaoRe',
             PRD.VPROD_RGNAL_RE,
             'objetivoRe',
             MRD.VMETA_RE / 3,
             'pelObjetivoRe',
             (PRD.VPROD_RGNAL_RE/(MRD.VMETA_RE/3))*100,
             'mixAutoRe',
             PRD.VPROD_RGNAL_AUTO + PRD.VPROD_RGNAL_RE,
             'mixPercentual',
             (PRD.VPROD_RGNAL_AUTO + PRD.VPROD_RGNAL_RE) / ( (MRD.VMETA_AUTO / 3) + (MRD.VMETA_RE / 3) ) * 100
             --PRD.VPERC_CRSCT_RGNAL
          --   
        FROM POSIC_RGNAL_DSTAQ PRD,
             CAMPA_DSTAQ       CD,
             META_RGNAL_DSTAQ  MRD
          --
       WHERE PRD.CCAMPA_DSTAQ        = CD.CCAMPA_DSTAQ
         AND PRD.DAPURC_DSTAQ        = CD.DAPURC_DSTAQ
          --
         AND PRD.CCAMPA_DSTAQ        = MRD.CCAMPA_DSTAQ
--       AND PRD.DAPURC_DSTAQ        = MRD.DAPURC_DSTAQ
         AND PRD.CTPO_PSSOA          = MRD.CTPO_PSSOA
         AND PRD.CCPF_CNPJ_BASE      = MRD.CCPF_CNPJ_BASE
         AND PRD.CRGNAL              = MRD.CRGNAL
          --
         AND CD.CCAMPA_DSTAQ         = 1
         AND PRD.CTPO_PSSOA          = CHRTPPESSOA
         AND PRD.CCPF_CNPJ_BASE      = intrCPF_CNPJ_BASE
         AND PRD.CRGNAL              = intrREGIONAL
         
union

      SELECT 
             'competencia',
             'Trimestre',      
             'producaoAuto',
             PRD.VPROD_RGNAL_AUTO,
             'objetivoAuto',
             MRD.VMETA_AUTO ,
             'pelObjetivoAuto',
             PRD.VPERC_CRSCT_RGNAL_AUTO,
             'producaoRe',
             PRD.VPROD_RGNAL_RE,
             'objetivoRe',
             MRD.VMETA_RE,
             'pelObjetivoRe',
             PRD.VPERC_CRSCT_RGNAL_RE,
             'mixAutoRe',
             PRD.VPROD_RGNAL_AUTO + PRD.VPROD_RGNAL_RE,
             'mixPercentual',
             PRD.VPERC_CRSCT_RGNAL
          --   
        FROM POSIC_RGNAL_DSTAQ PRD,
             CAMPA_DSTAQ       CD,
             META_RGNAL_DSTAQ  MRD
          --
       WHERE PRD.CCAMPA_DSTAQ        = CD.CCAMPA_DSTAQ
         AND PRD.DAPURC_DSTAQ        = CD.DAPURC_DSTAQ
          --
         AND PRD.CCAMPA_DSTAQ        = MRD.CCAMPA_DSTAQ
--       AND PRD.DAPURC_DSTAQ        = MRD.DAPURC_DSTAQ
         AND PRD.CTPO_PSSOA          = MRD.CTPO_PSSOA
         AND PRD.CCPF_CNPJ_BASE      = MRD.CCPF_CNPJ_BASE
         AND PRD.CRGNAL              = MRD.CRGNAL
          --
         AND CD.CCAMPA_DSTAQ         = 1
         AND PRD.CTPO_PSSOA          = CHRTPPESSOA
         AND PRD.CCPF_CNPJ_BASE      = intrCPF_CNPJ_BASE
         AND PRD.CRGNAL              = intrREGIONAL;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: CPF_CNPJ'||intrCPF_CNPJ_BASE||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6201');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6201;
/

