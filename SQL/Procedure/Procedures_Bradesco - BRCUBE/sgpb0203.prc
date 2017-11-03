CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0203
         (pCanal              IN  parm_crrtr_excec.ccanal_vda_segur%TYPE,
          pCpf_cnpj_completo  IN  NUMBER,
          pTipo_pssoa         IN  crrtr_unfca_cnpj.ctpo_pssoa%TYPE,
          pUsuario    	      IN  VARCHAR2,
          pMensagem           out VARCHAR2) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0203
  --      data            : 11/07/06 14:39:18
  --      autor           : WASSILY CHUK SEIBLITZ GUANAES
  --      objetivo        : BLOQUEIA MANUALMENTE UM CORRETOR QUE JÁ ESTEJA SENDO ELEITO. FAZ O SEGUINTE:
  --                        1) RETIRA ELE DA TABELA DE ELEITOS
  --                        2) INCLUI ELE NA TABELA DE EXCEÇÕES COMO IMPEDIDO
  --                        --------------------------------------
  --                        12/09/2007 - ALEXANDRE CYSNE ESTEVES
  --                        Incluindo campanha corrente na regra do bloqueio
  --                        Validando duplicidade da PK da CRRTR_EXCEC_CAMPA / update
  --                        26/11/2007 - ALEXANDRE - RALPH - WASSILY
  --                        foi alterado critica para validar se o corretor esta na faixa 100000 no cpvo
  -- -------------------------------------------------------------------------------------------------
  TT                INT;
  MT_CPFCNPJ        CRRTR_EXCEC_CAMPA.RMOTVO_EXCEC_CRRTR%TYPE;
  DT_INIC_VIG	      date;
  pCpf_cnpj_base  	crrtr_unfca_cnpj.ccpf_cnpj_base%TYPE;
BEGIN
   pCpf_cnpj_base  :=  pCpf_cnpj_completo;
   pMensagem := NULL;
   --  VERIFICA a existência do Corretor na BASE de DADOS
   BEGIN
    	SELECT 1 INTO TT FROM CRRTR_UNFCA_CNPJ CUC
     		  	WHERE CUC.CCPF_CNPJ_BASE = pCpf_cnpj_base AND CUC.CTPO_PSSOA = pTipo_pssoa;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'CPF/CNPF INEXISTENTE NO CADASTRO DE CORRETORES.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (1) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- VERIFICA SE EXISTE CORRETOR NO CPVO PARA O CNPJ_CPF PASSADO
   -- VALIDANDO SE O CORRETOR PERTENCE A FAIXA 100000 PARA OS 3 CANAIS
   -- EXTRA-BANCO - BANCO E FINASA
   BEGIN
        SELECT DISTINCT 1 INTO TT FROM CRRTR, PARM_CANAL_VDA_SEGUR
                 WHERE CCPF_CNPJ_BASE= pCpf_cnpj_base AND
                       CTPO_PSSOA = pTipo_pssoa AND
                       CCRRTR BETWEEN CINIC_FAIXA_CRRTR AND CFNAL_FAIXA_CRRTR AND
                       CCANAL_VDA_SEGUR = 1 AND
                       DFIM_VGCIA_PARM IS NULL;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             pMensagem := 'CORRETOR NÃO PERTENCE AO CANAL DE VENDA INFORMADO.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (2) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- Recupera campanha corrente no SGPB para validar se ele foi incluido manualmente para a campanha
   -- e para quando for retirar o corretor da tabela de eleitos.
   --
   BEGIN
    SELECT PIC.DINIC_VGCIA_PARM INTO DT_INIC_VIG FROM PARM_INFO_CAMPA PIC
    WHERE PIC.DFIM_VGCIA_PARM IS NULL
      AND PIC.CCANAL_VDA_SEGUR = pCanal;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN
             pMensagem := 'CANAL NÃO POSSUI CAMPANHA NO PLANO DE BÔNUS OU CAMPANHA TERMINADA.';
             RETURN;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (3) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- Verifica se o corretor foi incluido manualmente no SGPB
   BEGIN
    	SELECT UPPER(EXC.RMOTVO_EXCEC_CRRTR) INTO MT_CPFCNPJ FROM CRRTR_EXCEC_CAMPA EXC
     		  	WHERE EXC.CTPO_EXCEC_CRRTR IN ('A','I')
           		AND EXC.CCPF_CNPJ_BASE     = pCpf_cnpj_base
           		AND EXC.CTPO_PSSOA         = pTipo_pssoa
           		AND EXC.CCANAL_VDA_SEGUR   = pCanal
           		AND EXC.CIND_REG_ATIVO     = 'S'
              AND EXC.DINIC_VGCIA_PARM   = DT_INIC_VIG;
        pMensagem := 'O CORRETOR JÁ FOI BLOQUEADO MANUALMENTE PARA A CAMPANHA CORRENTE.';
        --pMensagem := 'O CORRETOR JÁ FOI BLOQUEADO MANUALMENTE - '||MT_CPFCNPJ||' - RETIRE A INCLUSÃO MANUAL PARA PROSEGUIR.';
        RETURN;
   EXCEPTION
    	WHEN NO_DATA_FOUND THEN NULL;
    	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (4) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    	  	 RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   -- DELETANDO O CORRETOR NA TABELA DE ELEITOS
   BEGIN
	  DELETE FROM CRRTR_ELEIT_CAMPA
  			  WHERE CCANAL_VDA_SEGUR=pCanal
            AND DINIC_VGCIA_PARM=DT_INIC_VIG
            AND CTPO_PSSOA=pTipo_pssoa
            AND CCPF_CNPJ_BASE=pCpf_cnpj_base;
    EXCEPTION
     	WHEN OTHERS THEN
    	     pMensagem := 'ERRO NA DELEÇÃO DO CORRETOR DA TABELA DE ELEITOS. ERRO : '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,pMensagem);
    END;
    -- INSERINDO NA TABELA DE EXCEÇOES. COLOCANDO ELE COMO IMPEDIDO.
    BEGIN
       INSERT INTO CRRTR_EXCEC_CAMPA
             (CTPO_PSSOA,CCPF_CNPJ_BASE,CCANAL_VDA_SEGUR,DINIC_VGCIA_PARM,RMOTVO_EXCEC_CRRTR,CIND_REG_ATIVO,DULT_ALT,
              CRESP_ULT_ALT,CTPO_EXCEC_CRRTR)
              VALUES (pTipo_pssoa,pCpf_cnpj_base,pCanal,DT_INIC_VIG,'Impedido Manualmente P/ a Campanha Corrente.',
                      'S',sysdate,pUsuario,'I');
    EXCEPTION
      WHEN dup_val_on_index THEN
        --Caso exista em CRRTR_EXCEC_CAMPA
        --update do CIND_REG_ATIVO, RMOTVO_EXCEC_CRRTR, DULT_ALT e CRESP_ULT_ALT
        BEGIN
         UPDATE CRRTR_EXCEC_CAMPA
            SET RMOTVO_EXCEC_CRRTR   = 'Impedido Manualmente P/ a Campanha Corrente.',
                CIND_REG_ATIVO       = 'S',
                DULT_ALT             = sysdate,
                CRESP_ULT_ALT        = pUsuario
          WHERE CTPO_PSSOA           = pTipo_pssoa
            AND CCPF_CNPJ_BASE       = pCpf_cnpj_base
            AND CCANAL_VDA_SEGUR     = pCanal
            AND DINIC_VGCIA_PARM     = DT_INIC_VIG
            AND CTPO_EXCEC_CRRTR     = 'I';
        EXCEPTION
           WHEN OTHERS THEN
           ROLLBACK;
  	       pMensagem := 'ERRO (5) UPDATE CRRTR_EXCEC_CAMPA NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
  		     RAISE_APPLICATION_ERROR(-20021,pMensagem);
        END;
  	 	WHEN OTHERS THEN
    	     pMensagem := 'ERRO (6) NO PLANO DE BÔNUS, ERRO : '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,pMensagem);
    END;
   -- Inserindo no log. Ass. Wassily
   begin
      INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
             SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB0203', sysdate,
                    'CORRETOR BLOQUEADO MANUALMENTE. Canal: '||pCanal||
                    ' Cpf_cnpj_completo: '||pCpf_cnpj_completo||' Cpf_cnpj_base: '||
                    pCpf_cnpj_base||' Tp_pssoa: '||pTipo_pssoa||
                    ' Usuario: '||pUsuario
                    from LOG_ERRO_IMPOR;
   EXCEPTION
  	  WHEN OTHERS THEN
          pMensagem := 'ERRO. NAO FOI POSSIVEL GRAVAR O LOG. pCanal: '||pCanal||
                        ' pCpf_cnpj_completo: '||pCpf_cnpj_completo||' pCpf_cnpj_base: '||
                        pCpf_cnpj_base||' pTipo_pssoa: '||pTipo_pssoa||
                        ' pUsuario: '||pUsuario||' COD.ERRO: '||SQLERRM;
          ROLLBACK;
    	  RAISE_APPLICATION_ERROR(-20021,pMensagem);
   END;
   pMensagem := '0';
   COMMIT;
END SGPB0203;
/

