SELECT o.owner, o.object_name, o.object_type, o.LAST_DDL_TIME, 
       DECODE(NVL(e.SEQUENCE, 0), 0, 'No', 'Yes') Has_errors
FROM   dba_OBJECTS o, dba_errors e
WHERE  o.status <> 'VALID'
AND    o.object_type <> 'SYNONYM'
AND    o.owner = e.owner (+)
AND    o.object_name = e.NAME (+)
AND    o.OBJECT_TYPE = e.TYPE (+)
AND    e.SEQUENCE (+) = 1 
ORDER BY 1, 3, 2