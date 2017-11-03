#
#!/bin/sh
#
if [ `date +%w` == 0 ]; then
	/usr/local/lds-oracle-backup/bkp_semanal.sh > /var/log/oracle_backup.log 2>&1
else
	/usr/local/lds-oracle-backup/bkp_diario.sh > /var/log/oracle_backup.log 2>&1
fi
exit 0
