#!/bin/ksh

# First, we must set the environment . . . .
ORACLE_SID=prodb1
export ORACLE_SID
ORACLE_HOME=`cat /var/opt/oracle/oratab|grep \^$ORACLE_SID:|cut -f2 -d':'`
export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export PATH

SERVER_NAME=`uname -a|awk '{print $2}'`
typeset -u SERVER_NAME
export SERVER_NAME

# sample every five minutes (300 seconds) . . . .
SAMPLE_TIME=300

while true
do
   vmstat ${SAMPLE_TIME} 2 > /tmp/msg$$


# Note that Solaris does not have a wait CPU column
cat /tmp/msg$$|sed 1,3d | awk  '{ printf("%s %s %s %s %s %s\n", $1, $8, $9, $20, $21, $22) }' | while read RUNQUE PAGE_IN PAGE_OUT USER_CPU SYSTEM_CPU IDLE_CPU 
   do

      $ORACLE_HOME/bin/sqlplus -s / <<EOF
      insert into perfstat.stats\$vmstat
                           values (
                             SYSDATE, 
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
