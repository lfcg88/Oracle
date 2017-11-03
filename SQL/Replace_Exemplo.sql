 select replace( 
        replace( 
		replace( 
		replace(
		replace(
		replace(
		replace(
		replace(
		replace(
		replace(
		replace(
		replace('teste padrao {NUM_CONTRATO}' ,'{NUM_CONTRATO}'      ,'1')
                ,'{NOM_CONTRATO}'       ,'pNomContrato')
                ,'{NUM_BENEFICIARIO}'   ,'pNumBeneficiario')
                ,'{NOM_BENEFICIARIO}'   ,'pNomBeneficiario')                                                    
                ,'{COD_PLANO}'          ,'pCodPlano')
                ,'{NOM_PLANO}'          ,'pNomPlano')                                                
                ,'{COD_PRODUTO_ANS}'    ,'pCodProdutoAns')
                ,'{DEPENDDENTES}'       ,'pDependentes')
                ,'{DATA_SOLICITACAO}'   ,'pDataSolicitacao')
                ,'{DATA_EFETIVACAO}'    ,'pDataEfetivacao')
                ,'{MOTIVO_SOLICITACAO}' ,'pMotivoSoliocitacao')
                ,'{NUM_PROTOCOLO}'      ,'pNumProtocolo')txt_padrao_relatorio
from dual