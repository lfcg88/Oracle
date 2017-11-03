connect / as sysdba

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;

select disk_number,HEADER_STATUS,MODE_STATUS,STATE
from v$asm_disk;


host rm /u02/asmdisks/disk0
