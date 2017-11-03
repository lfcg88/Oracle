conn /@tst2 as sysdba
startup force nomount;
alter database mount standby database;
alter database recover managed standby database disconnect;
exit;