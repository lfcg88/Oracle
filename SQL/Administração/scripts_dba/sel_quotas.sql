/* Exibe quotas em tablespaces para cada usuario */

column tablespace_name format a15
column username        format a15
column bytes           heading "Bytes usados"
column u_max_bytes     format a15 heading "Maximo a usar"

select tablespace_name,
       username,
       bytes,
       decode(max_bytes,-1,'Ilimitado',max_bytes) u_max_bytes
from sys.dba_ts_quotas
order by username, tablespace_name
/
