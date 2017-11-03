set line 200;
 
set linesize 200;
 
COLUMN c2  format a30;

column c2 heading "Data   Atual"    Format a30;

SELECT TO_CHAR(SYSDATE, 'DD MONTH, YYYY, HH24:MI:SS') c2
FROM dual;
