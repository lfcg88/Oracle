
. ./env

#
# Kill all the SQL plus connections
#
ps -ef | grep "LOCAL=Y" | awk '{print "kill -9 " $2 }' > x.sh
. ./x.sh

#
# Cleanup ADDM snapshot settings
#
sqlplus -s /NOLOG <<EOF >> /tmp/cleanup_perflab.log 2>&1 

  connect / as sysdba

  rem -- change INTERVAL setting to 30 minute 
  execute dbms_workload_repository.modify_snapshot_settings(interval => 30); 

EOF
