#!/bin/ksh

# First, we must set the environment . . . . 
ORACLE_SID=prodb1
ORACLE_HOME=`cat /var/opt/oracle/oratab|grep $ORACLE_SID|cut -f2 -d':'`
PATH=$ORACLE_HOME/bin:$PATH
MON=`echo ~oracle/iostat`

#----------------------------------------
# If it is not running, then start it . . .  
#----------------------------------------
check_stat=`ps -ef|grep get_iostat|grep -v grep|wc -l`;
oracle_num=`expr $check_stat`
if [ $oracle_num -lt 1 ]
 then nohup $MON/get_iostat_solaris.ksh > /dev/null 2>&1 &
fi
