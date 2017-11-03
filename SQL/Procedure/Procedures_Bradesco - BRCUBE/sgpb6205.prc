CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6205(
RESULSET      OUT SYS_REFCURSOR,
INTRCPF_CNPJ  IN  CRRTR.CCPF_CNPJ_CRRTR%TYPE,
CHRTPPESSOA   IN  CRRTR_UNFCA_CNPJ.CTPO_PSSOA%TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6205
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 13/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : VALIDAR SE O CORRETOR TERA DIREITO A CESTA DE NATAL
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------

BEGIN

OPEN RESULSET FOR

      SELECT 'tipoCesta',
             PCD.CIDTFD_PRMIO_PCIAL,
             'cesta',
             decode(PCD.CIDTFD_PRMIO_PCIAL,
             0, ' ',                               --CONTROLE JAVA
             1, 'Parabéns !!! Você terá direito a uma cesta de Natal',
             2, 'Parabéns !!! Você terá direito a uma cesta de Natal',
             3, 'Parabéns !!! Você terá direito a uma cesta de Natal'
             )
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
    SUBSTR(SQLERRM,1,100), 'SGPB6205');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6205;
/

