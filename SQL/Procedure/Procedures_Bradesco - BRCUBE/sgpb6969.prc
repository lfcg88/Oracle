CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB6969(
RESULSET      IN SYS_REFCURSOR
--INTRCPF_CNPJ  IN CRRTR.CCPF_CNPJ_CRRTR%TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6969
  --      NEGOCIO         : FECHANDO CURSOR SYS_REFCURSOR
  --      DATA            : 17/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : PROCEDIMENTO CRIADO PARA FECHAR O SYS_REFCURSOR VIA JAVA EJB
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------
  --intCpfCnpjBase         NUMBER;
  
BEGIN

  --intCpfCnpjBase := LPAD(intrCPF_CNPJ,14,0);
  
  --fechando cursor
  CLOSE RESULSET;
  --

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('INET: CLOSE SYS_REFCURSOR'||' ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6969');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'INET ' || SUBSTR(SQLERRM,1,100));

END SGPB6969;
/

