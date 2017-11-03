# Backup script, build by Tiago Quadra && Leo Santos/Lan Designers - 20030615.
# Based on the book "Oracle 9i - O Manual do DBA"
#
#!/bin/sh
#

YYYYMMDD=`date +%Y%m%d`
BACKUPBASE="/oracle/backup"
BACKUPDIR="$BACKUPBASE/diario"
BACKUPTMP="$BACKUPBASE/tmp"

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
su - oracle -c /usr/local/lds-oracle-backup/backup_online.sh;
rm $BACKUPTMP/tmp*.txt -f;
tar -jcf $BACKUPDIR/backup-$YYYYMMDD.tar.bz2 $BACKUPTMP;
rm -f $BACKUPTMP/*;

exit 0;
