CREATE OR REPLACE FUNCTION SGPB_PROC.FC_RETORNA_CODCPD_CNPJCPF_RAIZ
	( VAR_CURSOR	   OUT SYS_REFCURSOR,
      VAR_DT_INICIAL   IN DATE,
      VAR_DT_FINAL     IN DATE,
      VAR_CNPJCPF_RAIZ IN posic_crrtr_dstaq.ccpf_cnpj_base%type,
      VAR_TIPO_PESSOA  IN posic_crrtr_dstaq.ctpo_pssoa%type
    ) 
      return NUMBER IS
BEGIN
 	declare
 		INIC_FAIXA NUMBER := 199993;
 	begin
 		OPEN VAR_CURSOR 
    	      FOR 
    	        SELECT C.CCRRTR_ORIGN, A.CTPO_PSSOA INTO VAR_CNPJCPF_RAIZ, VAR_TIPO_PESSOA  
    	          FROM CRRTR_UNFCA_CNPJ A, CRRTR B, MPMTO_AG_CRRTR C 
    	          WHERE C.CCRRTR_ORIGN  = VAR_CODCPD        AND
                        C.CUND_PROD     = VAR_SUCURSAL      AND
                        C.CCRRTR_DSMEM  = B.CCRRTR          AND
                        C.CUND_PROD     = B.CUND_PROD       AND
                        A.CCPF_CNPJ_BASE= B.CCPF_CNPJ_BASE  AND
                        VAR_DT_INICIAL >= C.DENTRD_CRRTR_AG AND
                        VAR_DT_FINAL < NVL(C.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'));
        RETURN VAR_CNPJCPF_RAIZ;
	END;
end;
/* ---------------------------------------------
                                            
CREATE OR REPLACE PROCEDURE print_emp_by_dept 
(
    i_deptno          emp.deptno%TYPE,
    emp_refcur        in out SYS_REFCURSOR
)
IS
BEGIN
    OPEN emp_refcur FOR SELECT empno, ename FROM emp WHERE deptno = i_deptno;
END; 

-- The following PL/SQL statement is used to harness the above Oracle stored procedure
DECLARE  
deptno        emp.deptno%TYPE;
empno         emp.empno%TYPE;
ename         emp.ename%TYPE;  
emp_refcur    SYS_REFCURSOR;
BEGIN 
        print_emp_by_dept(deptno, emp_refcur);
        DBMS_OUTPUT.PUT_LINE('EMPNO    ENAME');
        DBMS_OUTPUT.PUT_LINE('-----    -------');
        LOOP
           FETCH emp_refcur INTO empno, ename;
           EXIT WHEN emp_refcur%NOTFOUND;
           DBMS_OUTPUT.PUT_LINE(empno || '     ' || ename);
        END LOOP;
        CLOSE emp_refcur;
END;
---------------------------------------- */
/

