CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6038_2(
                            pCupon         IN  NUMBER,
                            pMensagem      out VARCHAR2,
                            pNome          out VARCHAR2
                             ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB6038
  --      data            : 11/12/2007
  --      autor           : ALEXANDRE CYSNE ESTEVES
  --      objetivo        : VALIDA POSSIBILIDADE DE ESTORNO PARA RASPADINHA
  -------------------------------------------------------------------------------------------------
  V_CTPO_PSSOA              VARCHAR2(20);
  V_CCPF_CNPJ_BASE          ESTOQ_CUPOM_PROML_DSTAQ.CCPF_CNPJ_BASE%TYPE;
  V_DALT_REG                ESTOQ_CUPOM_PROML_DSTAQ.DALT_REG%TYPE;
  V_CCUPOM_PROML_DSTAQ      ESTOQ_CUPOM_PROML_DSTAQ.CCUPOM_PROML_DSTAQ%TYPE;

  BEGIN
      SELECT ECPD.CTPO_PSSOA,
             ECPD.CCPF_CNPJ_BASE,
             ECPD.DALT_REG,
             ECPD.CCUPOM_PROML_DSTAQ
        INTO V_CTPO_PSSOA,
             V_CCPF_CNPJ_BASE,
             V_DALT_REG,
             V_CCUPOM_PROML_DSTAQ
        FROM ESTOQ_CUPOM_PROML_DSTAQ ECPD
       WHERE ECPD.CCAMPA_DSTAQ = 1
         AND ECPD.CCUPOM_PROML_DSTAQ = pCupon
         AND ECPD.CTPO_PSSOA IS NOT NULL
         AND ECPD.CCPF_CNPJ_BASE IS NOT NULL;
            --

            if V_CTPO_PSSOA = 'J' then
               V_CTPO_PSSOA := 'Pessoa Jurídica';
            else
               V_CTPO_PSSOA := 'Pessoa Física';
            end if;
            --
            pNome     := 'Cupom de nº '||V_CCUPOM_PROML_DSTAQ||' ofertado para o corretor com o cpf/cnpj base: '||V_CCPF_CNPJ_BASE||' - '||V_CTPO_PSSOA||' em '||to_char(V_DALT_REG,'dd/MM/yyyy');
            pMensagem := 'X';
            RETURN;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
      ROLLBACK;
             pNome     := 'X';
             --pMensagem := 'Cupom de nº '||pCupon||' não disponivel para estorno - '|| to_char(sysdate,'dd/MM/yyyy');
             pMensagem := 'Cupom de nº '||pCupon||' não disponivel para estorno';
             RETURN;
    	WHEN OTHERS THEN
           pNome     := 'X';
    	     pMensagem := 'ERRO (1) CAMPANHA, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
END SGPB6038_2;
/

