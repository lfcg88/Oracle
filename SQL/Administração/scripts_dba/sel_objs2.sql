/* Lista outros objetos que nao tabelas, views, sequences ou indices */

select name,
       type,
       code_size
from sys.dba_object_size
where type not in ('TABLE','SEQUENCE','VIEW','INDEX') and 
      owner like '&owner'
/
