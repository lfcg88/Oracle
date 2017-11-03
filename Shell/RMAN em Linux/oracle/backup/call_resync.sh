#
#!/bin/sh
#
sudo su - oracle -c /oracle/backup/resync.sh > /var/log/oracle-resync.log 2>&1
