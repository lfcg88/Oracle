BEGIN
DBMS_REFRESH.CHANGE(
name => '"MEDICAO"."GRUPO_01"',
next_date => SYSDATE,
interval => 'SYSDATE + 45/1440');
END;