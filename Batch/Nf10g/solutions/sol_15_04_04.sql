connect / as sysdba

DROP DISKGROUP dgroup1 INCLUDING CONTENTS;

host rm /u02/asmdisks/disk0
host rm /u02/asmdisks/disk1
host rm /u02/asmdisks/disk2
host rm /u02/asmdisks/disk3
host rm /u02/asmdisks/disk4

shutdown abort

host dd if=/dev/zero of=/u02/asmdisks/disk0 bs=1024k count=200
host dd if=/dev/zero of=/u02/asmdisks/disk1 bs=1024k count=200
host dd if=/dev/zero of=/u02/asmdisks/disk2 bs=1024k count=200

startup;



CREATE DISKGROUP dgroup1
NORMAL REDUNDANCY
DISK '/u02/asmdisks/disk*';

select name,free_mb,failgroup,bytes_read,bytes_written
from v$asm_disk;
