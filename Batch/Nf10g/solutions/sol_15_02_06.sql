
set echo on

connect / as sysdba

SELECT count(distinct DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID,'SMALLFILE'))
FROM t;

set timing off;
