connect vpd/vpd

CREATE OR REPLACE PACKAGE vpd_security AS
FUNCTION empno_sec (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY vpd_security AS
FUNCTION empno_sec (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
predicate VARCHAR2 (2000);
j number;
BEGIN
j:=0;
for i in 1..100000 loop
j:=atan(i);
end loop;
predicate := 'employee_id = SYS_CONTEXT(''vpd_context'', ''empno'')';
RETURN predicate;
END;
END;
/

