#
#!/bin/sh
#
YYYYMMDD=`date +%Y%m%d`
BACKUPBASE="/oracle/backup"
BACKUPDIR="$BACKUPBASE/diario"
BACKUPTMP="$BACKUPBASE/tmp"
LOGDIR="$BACKUPBASE/logs"

verifica_dirs() {
if [ ! -d $BACKUPBASE ]; then
        if [ -a $BACKUPBASE ]; then
                printf "$BACKUPBASE is not a directory, please correct the error and try again\n"
                exit;
        else
                printf "$BACKUPBASE does not exist, creating...\n"
                mkdir $BACKUPBASE
        fi
fi

if [ ! -d $BACKUPTMP ]; then
        if [ -a $BACKUPTMP ]; then
                printf "$BACKUPTMP is not a directory, please correct the error and try again\n"
                exit;
        else
                printf "$BACKUPTMP does not exist, creating...\n"
      		mkdir $BACKUPTMP
        fi
fi

if [ ! -d $BACKUPDIR ]; then
        if [ -a $BACKUPDIR ]; then
                printf "$BACKUPDIR is not a directory, please correct the error and try again\n"
                exit;
        else
                printf "$BACKUPDIR does not exist, creating...\n"
                mkdir $BACKUPDIR
        fi
fi
}

verifica_dirs;

cd $ORACLE_HOME/bin
./rman cmdfile=/oracle/scripts_backup/backup.rman log=$LOGDIR/backup-$YYYYMMDD.log
./exp rman/rman@rcvcat owner=rman file=$BACKUPTMP/export_catalogo.dmp log=$LOGDIR/export_catalogo-$YYYYMMDD.log consistent=yes
tar -jcf $BACKUPDIR/backup-$YYYYMMDD.tar.bz2 $BACKUPTMP $LOGDIR
rm -rf $BACKUPTMP/*
