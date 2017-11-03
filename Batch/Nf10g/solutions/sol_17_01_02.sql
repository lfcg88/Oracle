
set echo on

connect vpd/vpd

CREATE OR REPLACE PACKAGE app_security_context IS
PROCEDURE set_empno;
END;
/

CREATE OR REPLACE PACKAGE BODY app_security_context IS
PROCEDURE set_empno
IS
empid NUMBER;
BEGIN
SELECT employee_id INTO empid FROM vpd.employees
WHERE first_name = SYS_CONTEXT('USERENV','SESSION_USER');
DBMS_SESSION.SET_CONTEXT('vpd_context', 'empno', empid);
END;
END;
/
