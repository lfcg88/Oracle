#!/bin/ksh

# First, we must set the environment . . . . 
ORACLE_SID=xxxx
ORACLE_HOME=`cat /etc/oratab|grep $ORACLE_SID|cut -f2 -d':'`
PATH=$ORACLE_HOME/bin:$PATH
MON=`echo ~oracle/mon`

#----------------------------------------
# If it is not running, then start it . . .  
#----------------------------------------
check_stat=`ps -ef|grep get_iostat_aix|wc -l`;
oracle_num=`expr $check_stat`
if [ $oracle_num -ne 2 ]
 then nohup $MON/get_iostat_aix.ksh > /dev/null 2>&1 &
fi


