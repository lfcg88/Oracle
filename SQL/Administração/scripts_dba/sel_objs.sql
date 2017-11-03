/* Lista todos objetos pertencentes a algum(ns) usuario(s) */

select substr(owner,1,15) owner, 
       substr(object_name,1,25) nome_objeto, 
       object_type, 
       created, 
       last_ddl_time 
from sys.dba_objects
where owner not in ('SYS','SYSTEM','CDITUT','CDESTUT','CGTUT','NET_CONF',
                    'SYSCASE','SCOTT') and
      object_type in ('TABLE','INDEX','VIEW','SEQUENCE') and
      owner like '&dono'
order by owner, object_type, object_name
/
