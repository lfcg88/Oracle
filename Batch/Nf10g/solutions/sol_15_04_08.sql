connect / as sysdba

select disk_number,HEADER_STATUS,MODE_STATUS,STATE
from v$asm_disk;

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;

select operation,power,actual,est_minutes from V$ASM_OPERATION;

-- Wait for a while

select operation,power,actual,est_minutes from V$ASM_OPERATION;

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;
