Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica o user que usa uma determinada Role            #
Prompt #                                                           #
Prompt #############################################################

Accept granted_role prompt "Digite o nome do Role : "
set verify off
column grantee   heading "Usuario"    format a25 wrap
column objeto    heading " "          format a7  wrap
column nome      heading "Objeto"     format a34 wrap
column privilege heading "Privilegio" format a23 wrap
break on nome on grantee


select granted_role   nome,
       grantee        grantee
from dba_role_privs
where granted_role LIKE UPPER('%&&granted_role%')
order by 1, 2
/


UNDEFINE ROLE
clear columns
set verify on
