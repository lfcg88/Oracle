CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0100(
                                     /*Chave primaria*/ --
                                     pCanal         parm_crrtr_excec.ccanal_vda_segur %TYPE,
                                     pCpf_cnpj_base crrtr_unfca_cnpj.ccpf_cnpj_base %TYPE,
                                     pTipo_pssoa    crrtr_unfca_cnpj.ctpo_pssoa %TYPE,
                                     pIniCompet     IN VARCHAR2,
                                     /*inclusoes*/ --
                                     dtFimCompet IN VARCHAR2,
                                     pUsuario    IN VARCHAR2 --
                                     ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0100
  --      data            : 06/04/06 14:39:18
  --      autor           : victor h. bilouro - analise e desenvolvimento de sistemas
  --      objetivo        : procedure insert um PARM_CRRTR_EXCEC
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
  TT INT;
BEGIN
  --
  BEGIN
    --
    SELECT 1
      INTO TT
      FROM CRRTR_UNFCA_CNPJ CUC
     WHERE CUC.CCPF_CNPJ_BASE = pCpf_cnpj_base
       AND CUC.CTPO_PSSOA = pTipo_pssoa;
    --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      RAISE_APPLICATION_ERROR(-20021, 'CORRETOR NAO ENCONTRADO');

  END;
  --
  INSERT INTO parm_crrtr_excec
    (ccpf_cnpj_base,
     ccanal_vda_segur,
     dinic_vgcia_parm,
     dfim_vgcia_parm,
     dult_alt,
     cresp_ult_alt,
     ctpo_pssoa)
  VALUES
    (pCpf_cnpj_base,
     pCanal,
     to_date(pIniCompet,'YYYYMMDD'),
     to_date(dtFimCompet,'YYYYMMDD'),
     sysdate,
     pUsuario,
     pTipo_pssoa);
  --
END SGPB0100;
/

