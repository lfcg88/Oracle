/* Lista roles permitidas para cada user */

select substr(grantee,1,15) "Grantee",
       granted_role,
       admin_option,
       default_role 
from sys.dba_role_privs
order by grantee
/
