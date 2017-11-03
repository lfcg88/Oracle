
set echo on

startup

host ps -ef | grep ASM

select * from v$asm_diskgroup;

col name format a20
col failgroup format a20

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;

select group_number,file_number,bytes,type,striped
from v$asm_file;
