SELECT distinct DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)
FROM sys.emp;

SELECT distinct DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID,'BIGFILE')
FROM sys.emp;