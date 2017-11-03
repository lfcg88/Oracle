#
#!/bin/sh
#
YYYYMMDD=`date +%Y%m%d`
BACKUPBASE="$ORACLE_BASE/backup"
BACKUPDIR="$BACKUPBASE/diario"
BACKUPTMP="$BACKUPBASE/tmp"

sqlplus /nolog <<EOFcf
	connect / as sysdba
	alter database backup controlfile to '$BACKUPTMP/$YYYYMMDD.ctl';
	alter database backup controlfile to trace;
	exit
EOFcf

sqlplus /nolog <<EOFal
	connect / as sysdba
	set pagesize 0 feedback off
	spool $PWD/tmp.txt
	select '/oracle/oradata/GRPLAN/archive/1_' || sequence# || '.dbf' from v\$log where archived = 'YES';
	spool off
	exit
EOFal

grep -v SQL $PWD/tmp.txt > $PWD/tmp2.txt
for i in $PWD/tmp2.txt; do
	if [ -a $i ]; then
		cp $i $BACKUPTMP;
	fi
done;
rm $PWD/tmp.txt
rm $PWD/tmp2.txt

sqlplus /nolog <<EOFts
	connect / as sysdba
	alter tablespace PCORP_PRD begin backup;
	!cp /oracle/oradata/GRPLAN/pcorp_prd/pcorp_prd.dbf $BACKUPTMP;
	alter tablespace PCORP_PRD end backup;
	alter tablespace PCORP_TMP begin backup;
	!cp /oracle/oradata/GRPLAN/pcorp_tmp/PCORP_TMPv2.dbf $BACKUPTMP;
	alter tablespace PCORP_TMP end backup;
	exit
EOFts

exit 0
