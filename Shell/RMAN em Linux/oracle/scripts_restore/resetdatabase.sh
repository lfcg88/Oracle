LOGDIR="/oracle/backup/logs"
YYYYMMDD="`date +%Y%m%d`" 

cd $ORACLE_HOME/bin
./rman cmdfile=/oracle/scripts_restore/resetdatabase.rman log=$LOGDIR/resetdatabase-$YYYYMMDD.log
