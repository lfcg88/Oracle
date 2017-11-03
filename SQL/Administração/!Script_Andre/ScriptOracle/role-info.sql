-- role-info.sql

-- Last updated: 08/27/1998
-- Update by:	 Mary Gail Manes

-- Shows all roles within the database and all users
-- This can be a very large report and take several minutes to
-- complete if there are a large number of users in the database.

set pause off;
set echo off;
set termout off;
set linesize 80;
set pagesize 5000;
column c1  heading "Role";
column c2  format a40 heading "Table Name";
column c3  heading "Priv.";
break on c1 skip 0 on c2 skip 0

column name noprint new_value xdbname
select name from v$database;
column today noprint new_value xdate
select substr(to_char(sysdate,'Month DD, YYYY HH:MI:SS P.M.'),1,35) today 
from dual;

spool c:\role-info.rpt

set heading off
ttitle left "DATABASE:  "xdbname"  (As Of:  "xdate")"

select 'Executed by:' || user from dual;

ttitle off
set heading on
set echo on

select		*
from		sys.dba_roles;

set echo off
column c1  heading "Role";
column c2  heading "Grantee";
set echo on

select  	substr(granted_role,1,20) c1,
        	substr(grantee,1,20) c2
from 		sys.dba_role_privs
where		grantee not in ('SYS', 'SYSTEM', 'DBA')  
                and grantee not in ( select username from dba_users where ACCOUNT_STATUS='LOCKED' )
order by 1,2;

set echo off
column c1  heading "Grantee";
column c2  heading "Role";
set echo on

select		substr(grantee,1,20) c1,
		substr(granted_role,1,20) c2,
		default_role
from		sys.dba_role_privs
where 		grantee not in ('SYS', 'SYSTEM', 'DBA')
                and grantee not in ( select username from dba_users where ACCOUNT_STATUS='LOCKED' )
order by 1,2;

select		grantee, granted_role, default_role
from		sys.dba_role_privs 
where 		default_role = 'YES' 
and 		granted_role in
		(select role from sys.dba_roles 
		where password_required = 'YES')
                and grantee not in ( select username from dba_users where ACCOUNT_STATUS='LOCKED' );

set echo off
column c1 heading "Grantee";
set echo on

select 		substr(grantee,1,20) c1, 
		ltrim(rtrim(substr(owner,1,10)))||'.'||substr(table_name,1,20) "Table",
		substr(privilege,1,9) "Privilege"
from		sys.dba_tab_privs
where		privilege in ('INSERT', 'UPDATE', 'DELETE','SELECT')
and		grantee in 
		(select role from sys.dba_roles)
                and grantee not in ( select username from dba_users where ACCOUNT_STATUS='LOCKED' );


select 		substr(grantee,1,20) c1, 
		ltrim(rtrim(substr(owner,1,10)))||'.'||substr(table_name,1,20) "Table",
		substr(privilege,1,9) "Privilege"
from		sys.dba_tab_privs
where		privilege in ('INSERT', 'UPDATE', 'DELETE','SELECT')
and		grantee not in 
		(select role from sys.dba_roles)
                and grantee not in ( select username from dba_users where ACCOUNT_STATUS='LOCKED' );


set echo off
column c1  heading "Role";
set echo on

select  	substr(role,1,20) c1,
        	substr(granted_role,1,20) "Granted role"
from 		sys.role_role_privs;

select		granted_role
from		sys.dba_role_privs
where		grantee = 'PUBLIC';

spool off
set echo off
ttitle off
