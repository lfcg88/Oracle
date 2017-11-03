
set echo on

connect / as sysdba

select group_number,file_number,bytes,type,striped
from v$asm_file;

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;

host dd if=/dev/zero of=/u02/asmdisks/disk4 bs=1024k count=200

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;

ALTER DISKGROUP dgroup1 
ADD DISK '/u02/asmdisks/disk4';

select operation,power,actual,est_minutes from V$ASM_OPERATION;

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;
