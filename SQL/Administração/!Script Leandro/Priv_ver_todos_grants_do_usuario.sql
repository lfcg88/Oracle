Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica quais os grants de um determinado usuário      #
Prompt #                                                           #
Prompt #############################################################


set verify off
set linesize 1000                                            
set pagesize 100                                              
                                                             
Accept p_owner prompt "Digite o owner : "

column grantee   heading "Usuario"    format a23 wrap
column objeto    heading "Tipo"       format a10  wrap
column nome      heading "Objeto"     format a40 wrap
column privilege heading "Privilegio" format a23 wrap

break on grantee 

select grantee        grantee,
       'Tabelas'      objeto,
       OWNER||'.'||table_name     nome,
       privilege      privilege
from dba_tab_privs
where grantee = upper('&&p_owner')
  and grantee not in ( select role from dba_roles )
union all
select grantee        grantee,
       'Roles'        objeto,
       granted_role   nome,
       NULL           privilege
from dba_role_privs
where grantee = upper('&&p_owner')
  and grantee not in ( select role from dba_roles )
union all
select grantee       grantee,
       'Sistema'     objeto,
       NULL          nome,
       privilege     privilege
from dba_sys_privs
where grantee = upper('&&p_owner')
  and grantee not in ( select role from dba_roles )
order by 1,2,3
/

undefine p_owner
clear columns
set verify on
