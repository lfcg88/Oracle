CREATE OR REPLACE FUNCTION SGPB_PROC.FC_VERIFICA_CNPJCPF_DESTAQUE
	( VAR_CODCPD       IN NUMBER, 
      VAR_SUCURSAL     IN NUMBER,
      VAR_DT_APOLICE   IN DATE,
      VAR_CNPJCPF_RAIZ OUT posic_crrtr_dstaq.ccpf_cnpj_base%type,
      VAR_TIPO_PESSOA  OUT posic_crrtr_dstaq.ctpo_pssoa%type) return NUMBER IS
BEGIN
 	declare
 		INIC_FAIXA NUMBER := 199993;
 	begin
    	if VAR_CODCPD > INIC_FAIXA THEN
    	   SELECT CCPF_CNPJ_BASE INTO VAR_CNPJCPF_RAIZ 
    	          FROM CRRTR_UNFCA_CNPJ A, CRRTR B, MPMTO_AG_CRRTR C 
    	          WHERE C.CCRRTR_ORIGN  = VAR_CODCPD           AND
                        C.CUND_PROD     = VAR_SUCURSAL         AND
                        C.CCRRTR_DSMEM  = B.CCRRTR             AND
                        C.CUND_PROD     = B.CUND_PROD          AND
                        A.CCPF_CNPJ_BASE= B.CCPF_CNPJ_BASE     AND
                        VAR_DT_APOLICE >= MAC.DENTRD_CRRTR_AG  AND
                        VAR_DT_APOLICE < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
	END;
end;
/
