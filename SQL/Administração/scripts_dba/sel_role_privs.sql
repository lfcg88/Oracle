/* Lista roles doadas para users ou para outras roles */

select * 
from sys.dba_role_privs
order by granted_role
/
