/* Lista acessos doados (granted) para users not = SYS ou SYSTEM */
select substr(table_name,1,15) "Objeto",
       substr(owner,1,12)      "Dono",
       substr(grantor,1,12)    "Grantor",
       substr(grantee,1,12)    "Grantee",
       substr(privilege,1,15)  "Privilegio",
       grantable
from sys.dba_tab_privs
where grantee = '&privilegiado'
/
