connect vpd/vpd

CREATE OR REPLACE TRIGGER on_logon
AFTER LOGON
ON DATABASE
BEGIN
IF user in ('JF','MH') THEN
vpd.app_security_context.set_empno();
END IF;
END;
/
