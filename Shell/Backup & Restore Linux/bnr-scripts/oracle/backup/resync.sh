#
#!/bin/sh
#
cd $ORACLE_HOME/bin
./rman cmdfile=/oracle/backup/resync.rman log=/oracle/backup/logs/resync.log
