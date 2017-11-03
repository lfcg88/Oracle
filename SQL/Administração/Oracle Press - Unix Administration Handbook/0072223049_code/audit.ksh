#!/bin/ksh

# First, we must set the environment . . . .
ORACLE_SID=mon1
export ORACLE_SID
ORACLE_HOME=`cat /etc/oratab|grep $ORACLE_SID:|cut -f2 -d':'`
export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export PATH
MON=`echo ~oracle/admin/$ORACLE_SID/scripts`
export MON

echo 'Starting Oracle Security Audit'

#for host in `cat ${MON}/revhost|awk '{ print $1 }'`
for host in `cat ${MON}/dbnames|awk '{ print $2 }'`
do
  echo "host is $host"
  for db in `rsh $host "cat /etc/oratab|egrep ':N|:Y'|grep -v \*|cut -f1 -d':'"`
  do
     echo "    database is $db"
     sqlplus /<<!
     connect system/manager
     set pages 9999;
@audit ${db}
     exit
!
  done
done


