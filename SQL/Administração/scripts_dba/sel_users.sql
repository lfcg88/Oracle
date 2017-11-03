/* Lista usuarios Oracle */
select substr(username,1,12) "Usuario",
       user_id,
       substr(default_tablespace,1,15) "Default TbSpc",
       substr(temporary_tablespace,1,15) "Tempor TbSpc",
       created,
       substr(profile,1,12) "Profile"
from sys.dba_users
order by username
/
