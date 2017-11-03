select role FROM dba_roles order by role

-- System Privs de uma role
select /*+ CHOOSE */ privilege, admin_option from SYS.dba_sys_privs
 where GRANTEE=upper('&GRANTEE')
 order by 1

-- Users com certa role
select /*+ CHOOSE */ drp.grantee,drp.granted_role,
 drp.admin_option,drp.default_role,usr.username 
 from 
   SYS.dba_role_privs drp,
   SYS.dba_users usr
 where 				 
   usr.username(+)=drp.grantee and 
   GRANTED_ROLE=upper('&ROLE')

-- Object Privs de certa role
select GRANTOR, TABLE_NAME "TABLE" , PRIVILEGE, GRANTABLE, OWNER, ' '  from 
 SYS.DBA_TAB_PRIVS 
 where GRANTEE=:USERNM 
 union select GRANTOR, TABLE_NAME "TABLE" , PRIVILEGE, GRANTABLE, OWNER, 
GRANTEE from 
 SYS.DBA_TAB_PRIVS 
 where GRANTEE in ( select granted_role
 from  SYS.dba_role_privs where grantee=:USERNM )

-- roles concedidas a uma certa role
select /*+ CHOOSE */ * from SYS.dba_role_privs
 where GRANTEE=:USERNM

-- Lista de system provileges
select name from system_privilege_map order by 1

-- Roles concedidos a um certo user
select /*+ CHOOSE */ * from SYS.dba_role_privs
 where GRANTEE=:USERNM

-- Objects privs de um certo user
select GRANTOR, TABLE_NAME "TABLE" , PRIVILEGE, GRANTABLE, OWNER, ' '  from 
 SYS.DBA_TAB_PRIVS 
 where GRANTEE=:USERNM 
 union select GRANTOR, TABLE_NAME "TABLE" , PRIVILEGE, GRANTABLE, OWNER, 
GRANTEE from 
 SYS.DBA_TAB_PRIVS 
 where GRANTEE in ( select granted_role
 from  SYS.dba_role_privs where grantee=:USERNM )

-- Sys privs de um certo role
select /*+ CHOOSE */ dba_sys_privs.privilege, dba_sys_privs.admin_option,
 dba_role_privs.granted_role
 from SYS.dba_sys_privs, SYS.dba_role_privs
 where dba_sys_privs.grantee=dba_role_privs.granted_role
 and  dba_role_privs.GRANTEE=:GRANTEE
 order by 1

-- Grants em uma tabela
Select /*+ CHOOSE */ PRIVILEGE, GRANTEE, GRANTABLE, GRANTOR
 from dba_tab_privs
 where table_name = upper('&table')
 and owner=upper('&owner')
 order by grantee


-- Grants em colunas de tabelas
Select /*+ CHOOSE */ PRIVILEGE, GRANTEE, GRANTABLE, GRANTOR, COLUMN_NAME
from dba_col_privs
 where table_name = upper('&table')
 and owner=upper('&owner')
 order by grantee


