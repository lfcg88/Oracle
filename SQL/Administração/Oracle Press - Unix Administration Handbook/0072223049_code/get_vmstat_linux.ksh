#!/bin/ksh

# This is the linux version

# First, we must set the environment . . . .
#ORACLE_SID=edi1
#export ORACLE_SID
#ORACLE_HOME=`cat /etc/oratab|grep \^$ORACLE_SID:|cut -f2 -d':'`
#export ORACLE_HOME

ORACLE_HOME=/usr/app/oracle/admin/product/8/1/6
export ORACLE_HOME

PATH=$ORACLE_HOME/bin:$PATH
export PATH

SERVER_NAME=`uname -a|awk '{print $2}'`
typeset -u SERVER_NAME
export SERVER_NAME

# sample every five minutes (300 seconds) . . . .
SAMPLE_TIME=300
SAMPLE_TIME=3

while true
do
   vmstat ${SAMPLE_TIME} 2 > /tmp/msg$$


# run vmstat and direct the output into the Oracle table . . .  
cat /tmp/msg$$|sed 1,3d | awk  '{ printf("%s %s %s %s %s %s\n", $1, $8, $9, $14, $15, $16) }' | while read RUNQUE PAGE_IN PAGE_OUT USER_CPU SYSTEM_CPU IDLE_CPU
   do

      $ORACLE_HOME/bin/sqlplus -s perfstat/perfstat@testb1<<EOF
      insert into perfstat.stats\$vmstat
                           values (
                             sysdate, 
                             $SAMPLE_TIME,
                             '$SERVER_NAME',
                             $RUNQUE,
                             $PAGE_IN,
                             $PAGE_OUT,
                             $USER_CPU,
                             $SYSTEM_CPU,
                             $IDLE_CPU,
                             0 
                                  );
      EXIT
EOF
   done
done

rm /tmp/msg$$
