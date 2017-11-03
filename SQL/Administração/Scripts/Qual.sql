SET VERIFY OFF
COL &1 FORMAT A20
SELECT A.owner
     , A.&1
  FROM quadro_pass A
 WHERE owner = UPPER('&2')
/

COL &1 CLEAR
undefine 1
undefine 2
SET VERIFY ON
