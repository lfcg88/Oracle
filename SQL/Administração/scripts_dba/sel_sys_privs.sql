/* Lista privilegios de sistema doados p/users ou roles */

select *
from sys.dba_sys_privs
order by grantee
/
