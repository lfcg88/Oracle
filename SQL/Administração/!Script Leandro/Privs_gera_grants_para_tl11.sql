SPOOL GRANTS_TL11.SQL

set verify off
column grantee   heading "Usuario"    format a25 wrap
column objeto    heading " "          format a7  wrap
column nome      heading "Objeto"     format a34 wrap
column privilege heading "Privilegio" format a23 wrap
break on grantee on objeto on nome 
set heading off
set feedback off
set pages 5000
set lines 1000
set trimspool on

select 'GRANT '||privilege||' ON '
       || OWNER||'.'||table_name
       || ' '||' TO '||grantee||';' Comando
from dba_tab_privs
where grantee in ('CCO')
ORDER BY OWNER;

select 'GRANT '||granted_role
       || ' '||' TO '||grantee||';'
from dba_role_privs
where grantee in ('CCO')
union all
select 'GRANT '||privilege     
       || ' '||' TO '||grantee||';'
from dba_sys_privs
where grantee in ('CCO');

UNDEFINE Grantee
clear columns
set verify on
set heading on
set feedback on

SPOOL OFF

--'OLN','CLIENTES_WEB','REC','S1A','S2G','S4B','S5B'
