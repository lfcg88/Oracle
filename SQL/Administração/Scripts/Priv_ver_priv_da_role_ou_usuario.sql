Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica quais os grants de uma determinada role        #
Prompt #                                                           #
Prompt #############################################################

Accept Grantee prompt "Digite o nome do Grantee : "
set verify off
column grantee   heading "Usuario"    format a25 wrap
column objeto    heading " "          format a7  wrap
column nome      heading "Objeto"     format a34 wrap
column privilege heading "Privilegio" format a23 wrap
break on grantee on objeto on nome 


select grantee        grantee,
       'Tabelas'      objeto,
       OWNER||'.'||table_name     nome,
       privilege      privilege
from dba_tab_privs
where grantee LIKE UPPER('%&&Grantee%')
union all
select grantee        grantee,
       'Roles'        objeto,
       granted_role   nome,
       NULL           privilege
from dba_role_privs
where grantee LIKE UPPER('%&&Grantee%')
union all
select grantee       grantee,
       'Sistema'     objeto,
       NULL          nome,
       privilege     privilege
from dba_sys_privs
where grantee LIKE UPPER('%&&Grantee%')
order by 1, 2, 3
/


UNDEFINE ROLE
clear columns
set verify on
