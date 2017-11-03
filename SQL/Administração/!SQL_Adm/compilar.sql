SET PAGESIZE 0 ;
SET FEEDBACK OFF ;
SET VERIFY OFF;
SPOOL C:\SQL\COMPILA.LST
SELECT 'ALTER '||OBJECT_TYPE ||' '|| OBJECT_NAME || ' COMPILE ;'
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE','FUNCTION', 'TRIGGER', 'VIEW','PACKAGE')
AND OBJECT_NAME NOT LIKE  'BIN$%' 
AND STATUS = 'INVALID' ;
SPOOL OFF ;
@C:\SQL\COMPILA.LST
SET PAGESIZE 24 ;
SET FEEDBACK ON ;
SET VERIFY ON;
 