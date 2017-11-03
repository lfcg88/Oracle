SET PAGESIZE 0 ;
SET FEEDBACK OFF ;
SET VERIFY OFF;
SPOOL dropesq.lst
SELECT 'drop ' ||
object_type || ' ' ||
owner || '.' ||
object_name ||
DECODE (object_type, 'TABLE', ' cascade constraints;', ';')
FROM all_objects
WHERE object_type not in ('TRIGGER', 'PACKAGE BODY', 'INDEX', 'LOB')
AND owner = 'GERADOC_HMLG'
ORDER BY 1;
SPOOL OFF ;
SET PAGESIZE 24 ;
SET FEEDBACK ON ;
SET VERIFY ON;
/