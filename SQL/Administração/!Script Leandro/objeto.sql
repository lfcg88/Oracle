column owner format a20
column OBJECT_TYPE format a20
column OBJECT_NAME    format a20

set linesize 250
set heading on
       col wu format A10 head "Nome"
       col ws format A5 head "N. do Objeto"
       col ws1 format A7 head "Tipo objeto"
select owner, object_name, OBJECT_TYPE 
from dba_objects  
where object_name  like  ( upper ('%&NomeObj.%'));

