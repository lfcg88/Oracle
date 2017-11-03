Prompt #############################################################
Prompt #                                                           #
Prompt #     Indica quais os grants de uma determinada role        #
Prompt #                                                           #
Prompt #############################################################

Accept Grantee prompt "Digite o nome do Usuário ou Role : "
set verify off
column grantee   heading "Usuario"    format a25 wrap
column objeto    heading " "          format a7  wrap
column nome      heading "Objeto"     format a34 wrap
column privilege heading "Privilegio" format a23 wrap
break on grantee on objeto on nome 
set heading off
set feedback off
set pages 1000
set trimspool on

select 'GRANT '||privilege||' ON '
       || OWNER||'.'||table_name
       || ' '||' TO '||grantee||DECODE (GRANTABLE, 'YES',' WITH GRANT OPTION;',';') Comando
from dba_tab_privs
where grantee LIKE UPPER('%&&Grantee%')
order by owner
/

select 'GRANT '||granted_role
       || ' '||' TO '||grantee||';'
from dba_role_privs
where grantee LIKE UPPER('%&&Grantee%')
union all
select 'GRANT '||privilege     
       || ' '||' TO '||grantee||';'
from dba_sys_privs
where grantee LIKE UPPER('%&&Grantee%')
/


UNDEFINE Grantee
clear columns
set verify on
set heading on
set feedback on
