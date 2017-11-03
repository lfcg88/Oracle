SELECT   doc.owner, doc.NAME, doc.TYPE, doc.loads, doc.sharable_mem,
         upper(ins.instance_name) instance_name
FROM     v$db_object_cache doc, v$instance ins
WHERE    doc.loads > 2
AND      doc.TYPE IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TABLE')
ORDER BY doc.loads DESC