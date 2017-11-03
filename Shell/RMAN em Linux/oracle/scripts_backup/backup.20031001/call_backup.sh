#
#!/bin/sh
#
if [ `date +%w` == 0 ]; then
        /oracle/scripts_backup/backup.sh > /var/log/oracle_backup.log
 2>&1
else
        /oracle/scripts_backup/backup.sh > /var/log/oracle_backup.log
2>&1
fi
exit 0
