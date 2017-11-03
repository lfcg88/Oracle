
set echo on

connect / as sysdba

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;
