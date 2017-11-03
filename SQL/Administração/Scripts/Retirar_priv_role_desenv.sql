select 'REVOKE '||privilege||' ON '||OWNER||'.'||table_name||' FROM '||grantee||';' COMANDO
from dba_tab_privs
where grantee LIKE '%DESENV%'
AND PRIVILEGE IN ('INSERT','DELETE','UPDATE')
/
