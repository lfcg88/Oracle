#!/bin/ksh

# First, we must set the environment . . . .
ORACLE_SID=mon1
export ORACLE_SID
ORACLE_HOME=`cat /etc/oratab|grep $ORACLE_SID:|cut -f2 -d':'`
export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export PATH
vmstat=`echo ~oracle/vmstat`
export vmstat

echo 'Starting Reports'


for db in `cat ${vmstat}/dbnames|awk '{ print $1 }'`
do
   host=`cat ${vmstat}/dbnames|grep $db|awk '{ print $2 }'`
sqlplus /<<!

select count(*) from perfstat.stats\$vmstat;
exit;
!
done
