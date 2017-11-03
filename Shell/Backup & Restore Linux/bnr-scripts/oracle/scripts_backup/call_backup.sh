#
#!/bin/sh
#

sudo su - oracle -c /oracle/scripts_backup/backup.sh > /var/log/oracle_backup.log 2>&1
sudo su - oracle -c /oracle/scripts_backup/backup_limpa.sh
exit 0
