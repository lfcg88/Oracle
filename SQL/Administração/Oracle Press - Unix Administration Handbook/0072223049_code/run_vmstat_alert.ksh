#!/bin/ksh

# First, we must set the environment . . . .
ORACLE_SID=$1
export ORACLE_SID
ORACLE_HOME=`cat /var/opt/oracle/oratab|grep $ORACLE_SID:|cut -f2 -d':'`
export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export PATH
vmstat=`echo ~oracle/vmstat`
export vmstat


sqlplus /<<!
spool /tmp/vmstat_$1.lst
@$vmstat/vmstat_alert 7
spool off;
exit;
!

# Mail the report
check_stat=`cat /tmp/vmstat_$1.lst|wc -l`;
oracle_num=`expr $check_stat`
if [ $oracle_num -gt 3 ]
 then
   cat /tmp/vmstat_$1.lst|mailx -s "Rovia vmstat alert" don@remote-dba.net terry.oakes@worldnet.att.net adamf@rovia.com
fi
