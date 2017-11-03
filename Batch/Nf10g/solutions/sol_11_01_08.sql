SELECT first_name
FROM sys.emp
WHERE rowid = (SELECT DBMS_ROWID.ROWID_TO_EXTENDED('&rid',NULL,NULL,0)
               FROM dual);

SELECT first_name
FROM sys.emp
WHERE rowid = (SELECT DBMS_ROWID.ROWID_TO_EXTENDED('&rid','SYS','EMP',0)
               FROM dual);
