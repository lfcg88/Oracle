select 'alter '||
decode(object_type,'PACKAGE BODY','PACKAGE ',object_type)||' '||
object_name ||' compile '|| decode(object_type,'PACKAGE BODY','BODY','')||';'
from user_objects where status = 'INVALID'
/
