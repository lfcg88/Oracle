
set echo on

connect / as sysdba

select group_number,file_number,bytes,type,striped
from v$asm_file;
