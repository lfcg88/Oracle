CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6210_2(

                            pCpf_cnpj             IN  NUMBER,
                            pTipo_pssoa           IN  VARCHAR2,
                            pMensagem             out VARCHAR2,
                            pNome                 out VARCHAR2
                             ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0201R
  --      data            : 12/10/06 14:39:18
  --      autor           : RALPH AGUIAR
  --      objetivo        : Acessar nome do corretor na base.
  --      Explicações     : 14 bytes se CNPJ
  --                        11 bytes se CPF
  -------------------------------------------------------------------------------------------------
  MT_CPFCNPJ  CRRTR_UNFCA_CNPJ.IATUAL_CRRTR%TYPE;
  BEGIN
   -- VERIFICA o IMPEDIMENTO do CORRETOR
    	SELECT UPPER(TAB1.IATUAL_CRRTR) INTO MT_CPFCNPJ FROM CRRTR_UNFCA_CNPJ TAB1
     		  	WHERE TAB1.CCPF_CNPJ_BASE = pCpf_cnpj AND TAB1.CTPO_PSSOA = pTipo_pssoa;
            pNome     := MT_CPFCNPJ;
            pMensagem := 'X';
            RETURN;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
      ROLLBACK;
             pNome     := 'X';
             pMensagem := 'CORRETOR NÃO EXISTE.';
             RETURN;
    	WHEN OTHERS THEN
           pNome     := 'X';
    	     pMensagem := 'ERRO (1) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
END SGPB6210_2;
/

