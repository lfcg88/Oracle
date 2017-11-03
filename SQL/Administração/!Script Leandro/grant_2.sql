SELECT owner, table_name, privilege
FROM dba_tab_privs WHERE  table_name LIKE '%SIA_AUDITORIA%';

SELECT owner, table_name, privilege
FROM dba_tab_privs WHERE  table_name LIKE '%SIA_GERENTE_AUDITORIA%';

 
SELECT owner, table_name, privilege
FROM dba_tab_privs WHERE  table_name LIKE '%SIA_GERENTE_AEROPORTO%';



select * from dba_role_privs  where granted_role  in ( 'SIA_GERENTE_AUDITORIA', 'SIA_GERENTE_AEROPORTO');


select distinct GRANTEE FROM dba_role_privs  where granted_role  in ( 'SIA_GERENTE_AUDITORIA', 'SIA_GERENTE_AEROPORTO');



