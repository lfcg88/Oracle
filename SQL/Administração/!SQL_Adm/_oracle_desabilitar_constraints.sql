select 'ALTER TABLE '||OWNER|| '.'||TABLE_NAME||' DISABLE CONSTRAINTS '||CONSTRAINT_NAME||';' from dba_constraints 
WHERE OWNER = 'ODS'
AND CONSTRAINT_TYPE = 'R'