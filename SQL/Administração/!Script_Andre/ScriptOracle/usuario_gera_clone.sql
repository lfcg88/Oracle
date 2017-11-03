rem =========================================================================
rem 
rem                     create_user_as.sql
rem 
rem     Copyright (C) Oriole Software, 1999
rem 
rem     Downloaded from http://www.oriolecorp.com
rem 
rem     This script for Oracle database administration is free software; you
rem     can redistribute it and/or modify it under the terms of the GNU General
rem     Public License as published by the Free Software Foundation; either
rem     version 2 of the License, or any later version.
rem 
rem     This script is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with this program; if not, write to the Free Software
rem     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
rem 
rem =========================================================================
--
--     This script (must be run by a DBA) creates an Oracle account
--   on the very same lines as an already existing account.
--
--   Usage : @create_user_as <existing user> <new user>
--
--   Important notes :
--      * This script assumes that become.sql (also freely available
--        from www.oriolecorp.com) is located in the same directory
--        as itself. Connection as other users is required for grants.
--      * As we may have to log as several users, reconnecting as a DBA
--        in-between is necessary. This is why the script prompts for
--        a DBA username/password.
--      * The user password is set to the same thing as the username.
--        You may wish to change the script to set it to CHANGE_ASAP
--        or anything able to convey some sense of urgency to your users,
--        or play with the new Oracle8 features (this script works on both
--        Oracle7 and Oracle8) to give a very short lifetime to the initial
--        password.
--      * Note that the 'non default role' feature is unsupported. All roles
--        are granted as default roles. 
--
prompt *** create_user_as.sql, copyright (C) Oriole Software, 1999 ***
accept dbaconnect char default '/' -
       prompt 'Enter DBA username/password [ default  / ] : '
set verify off
set scan on
set pagesize 0
set feedback off
set recsep off
set echo off
set pause off
spool C:\create_&2..sql
select 'create user &2 identified by &2' || chr(10) ||
       'default tablespace ' || default_tablespace || chr(10) ||
       'temporary tablespace ' || temporary_tablespace || chr(10) ||
       'profile ' || profile || chr(10) ||
       '/'
from dba_users
where username = upper('&1')
/
select 'alter user &2' || chr(10) ||
       'quota ' || decode(sign(nvl(max_bytes, -1)),
                          -1, 'unlimited ',
                          to_char(max_bytes / 1024) || ' K ')
        || 'on ' || tablespace_name || chr(10) ||
        '/'
from dba_ts_quotas
where username = upper('&1')
 and max_bytes != 0
/
select 'grant ' || privilege || ' to &2' || chr(10) ||
       decode(admin_option, 'YES', 'with admin option;', '/')
from dba_sys_privs
where grantee = upper('&1')
/
--
-- Non default roles are not handled by the procedure
--
select 'grant ' || granted_role || ' to &2' || chr(10) ||
       decode(admin_option, 'YES', 'with admin option;', '/')
from dba_role_privs
where grantee = upper('&1')
/
column dummy noprint
select grantor dummy,
       1 dummy,
       'connect &dbaconnect' || chr(10) ||
       '@@become ' || grantor
from (select grantor from dba_tab_privs
      where grantee = upper('&1')
      union
      select grantor from dba_col_privs
      where grantee = upper('&1'))
union
select grantor, 2,
       'grant ' || privilege || ' on ' || owner || '.' || table_name
                || chr(10) ||
       'to &2' || decode(grantable, 'YES', ' with grant option;', ';')
from dba_tab_privs
where grantee = upper('&1')
union
select grantor, 3,
       'grant ' || privilege || ' on ' || owner || '.' || table_name
                || '(' || column_name || ')' || chr(10) ||
       'to &2' || decode(grantable, 'YES', ' with grant option;', ';')
from dba_col_privs
where grantee = upper('&1')
order by 1, 2
/
--
--  Reconnect as the original DBA
--
select 'connect &dbaconnect' || chr(10) ||
       '@@become ' || USER
from dual
/
spool off
set feedback on
start create_&2

