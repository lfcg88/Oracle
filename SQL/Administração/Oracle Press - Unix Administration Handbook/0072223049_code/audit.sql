set linesize 80;
set pagesize 999;
set verify off;

--spool /tmp/audit
set heading off;
PROMPT *********************************************************************
select 'AUDIT OF &&1 ', to_char(sysdate,'mm-dd-yy hh:mm') from dual;
PROMPT *********************************************************************
PROMPT
set heading on;
 
PROMPT *********************************************************************
PROMPT Searching &&1 for any system privileges
PROMPT that are granted WITH ADMIN OPTION...
PROMPT *********************************************************************
column c1 heading "Grantee";
column c2 heading "Privilege";
column c3 heading "Admin?";
select   substr(grantee,1,20)      c1,
         substr(privilege,1,30)    c2,
         substr(admin_option,1,5)  c3
from     sys.dba_sys_privs@&&1
where    admin_option = 'YES'
and      grantee not in ('DB_USER','DB_ADMIN','DBA','ORACLE','SYSTEM','SYS')
order by grantee;
 
 
PROMPT *********************************************************************
PROMPT Searching &&1 for any end-users with system privileges...
PROMPT *********************************************************************
column c1 heading "Grantee";
column c2 heading "Privilege";
column c3 heading "Admin?";
select   substr(grantee,1,20)      c1,
         substr(privilege,1,30)    c2,
         substr(admin_option,1,5)  c3
from     sys.dba_sys_privs@&&1
where    
         grantee not in ('DBA','SYSTEM','SYS','COMMON','ORACLE',
         'RESOURCE','CONNECT','IMP_FULL_DATABASE',
         'DB_USER','DB_ADMIN','DB_OWNER','EXP_FULL_DATABASE')
order by grantee;


PROMPT *********************************************************************
PROMPT Searching &&1 for any non-DBA roles
PROMPT that are granted WITH ADMIN OPTION...
PROMPT *********************************************************************
column c1 heading "Role";
column c2 heading "Privilege";
column c3 heading "Admin?";
select   substr(role,1,20)         c1,
         substr(privilege,1,30)    c2,
         substr(admin_option,1,5)  c3
from     sys.role_sys_privs@&&1
where    admin_option = 'YES'
and      role not in ('DBA','DB_ADMIN')
order by role;

select   substr(grantee,1,20)      c1,
         substr(granted_role,1,22) c2,
         substr(admin_option,1,3)  c3,
         substr(default_role,1,12) c4
from     sys.dba_role_privs@&&1
where    admin_option = 'YES'
and granted_role not in ('RESOURCE','CONNECT')
and grantee not in 
   ('DB_ADMIN','DBA','SYS','SYSTEM','ORACLE','ORACLE')
order by granted_role;
  
PROMPT *********************************************************************
PROMPT Searching &&1 for any table privileges
PROMPT that can be granted to others...
PROMPT *********************************************************************
column c1 heading "Grantee";
column c2 heading "Owner";
column c3 heading "Table";
column c4 heading "Grantor";
column c5 heading "Privilege";
column c6 heading "Grantable?";
select   substr(grantee,1,12)     c1,
         substr(owner,1,12)       c2,
         substr(table_name,1,15)  c3,
         substr(grantor,1,12)     c4,
         substr(privilege,1,9)    c5,
         substr(grantable,1,3)    c6
from     sys.dba_tab_privs@&&1
where    grantable = 'YES'
and grantee not in ('SYS','SYSTEM')
and owner not in ('SYS','SYSTEM','GL','APPLSYS','BOM','ENG',
'PO','AP','PER','WIP','LOGGER')
order by table_name;



PROMPT *********************************************************************
PROMPT Searching &&1 for DBA and RESOURCE Roles (To other than ops$oracle)...
PROMPT *********************************************************************
column c1 heading "Grantee";
column c2 heading "Role";
column c3 heading "Admin?";
column c4 heading "Default Role";
select   substr(grantee,1,20)      c1,
         substr(granted_role,1,22) c2,
         substr(admin_option,1,3)  c3,
         substr(default_role,1,12) c4
from     sys.dba_role_privs@&&1
where    granted_role in ('RESOURCE','DBA') 
and grantee not in ('SYS','SYSTEM','ORACLE')
order by granted_role;


--select to_char(sysdate,'hhmmss') from dual;

create table temp1 as
  select distinct username from dba_users@&&1
  where substr(username,1,4) = 'OPS$';

create table temp2 as
  select distinct grantee from dba_role_privs@&&1
  where granted_role not in ('DB_USER');

PROMPT *********************************************************************
PROMPT Searching &&1 for any users
PROMPT that have no meaningful roles (orphan users)...
PROMPT *********************************************************************

select substr(username,5,20) username from temp1
where username not in
(select grantee from temp2);


drop table temp1;
drop table temp2;
 
--PROMPT *********************************************************************
--PROMPT Searching &&1 for all tables granted to PUBLIC . . .  
--PROMPT *********************************************************************
--column c0 format a10 heading "Owner";
--column c1 heading "Table";
--column c2 format a10 heading "Grantor";
--column c3 format a10;
--select distinct owner c0,
--                table_name c1, 
--                privilege  c3, 
--                grantor    c2
--from sys.dba_tab_privs@&&1 a
--where grantee = 'PUBLIC'
--and
--owner not in ('ORACLE','SYS','SYSTEM')
--and not exists
--   (select * from dba_sequences@&&1 b
--    where a.table_name = b.sequence_name)
--and privilege not in ('EXECUTE')
--order by owner, table_name
--;


PROMPT *********************************************************************
PROMPT Searching &&1 for all objects owned by ops$ users . . .  
PROMPT *********************************************************************

select substr(owner,1,10), 
       substr(object_type,1,20),
       substr(object_name,1,40) 
from dba_objects@&&1
where owner like 'OPS$%'
and owner not in ('ORACLE')
and object_type not in ('SYNONYM')
;
 
spool off;


