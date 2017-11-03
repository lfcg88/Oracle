LOGDIR=/oracle/backup/logs
YYYYMMDD="`date +%Y%m%d`" 

cd /oracle/scripts_restore
./listaseq.sh
for i in `cat listaseq.log`; do SEQNUM=$i; done;
./gera-rman.sh $SEQNUM;
cd $ORACLE_HOME/bin
#./rman cmdfile=/oracle/scripts_restore/restore_database.rman log=$LOGDIR/restore_database-$YYYYMMDD.log
