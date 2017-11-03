/* Lista resource limits das profiles */

select substr(profile,1,20), resource_name, substr(limit,1,9)
from sys.dba_profiles
where profile like '&perfil'
order by profile, resource_name
/
