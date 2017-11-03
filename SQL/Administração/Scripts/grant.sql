select distinct GRANTEE,  granted_role FROM dba_role_privs where GRANTEE  not in ('SYS', 'SYSTEM','MANUTENCAO','COMERCIAL','OPS$ORACLE7','XDB','ODM','WKSYS') AND granted_role = 'SIA_AUDITOR';
