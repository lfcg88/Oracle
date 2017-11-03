#!/bin/ksh

# First, we must set the environment . . . .
vmstat=`echo ~oracle/vmstat`
export vmstat
ORACLE_SID=`cat ${vmstat}/mysid`
export ORACLE_SID
ORACLE_HOME=`cat /etc/oratab|grep $ORACLE_SID:|cut -f2 -d':'`
export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export PATH

#----------------------------------------
# If it is not running, then start it . . .  
#----------------------------------------
check_stat=`ps -ef|grep get_vmstat|grep -v grep|wc -l`;
oracle_num=`expr $check_stat`
if [ $oracle_num -le 0 ]
 then nohup $vmstat/get_vmstat.ksh > /dev/null 2>&1 &
fi

HOUR=`date +"%H"`

#if [ $HOUR -gt 19 ] 
#then
   #myvar=`ps|grep get_vmstat|awk '{print $1 }'|wc -l`
   #if [ $myvar -gt 0 ]
   #then kill -9 `ps|grep get_vmstat|awk '{print $1 }'` > /dev/null
   #fi
#fi
