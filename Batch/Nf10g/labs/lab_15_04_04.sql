
set echo on

connect / as sysdba

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
