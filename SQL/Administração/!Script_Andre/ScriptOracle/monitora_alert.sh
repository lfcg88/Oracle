Naresh's checkAlertLog.ksh Script
#!/bin/ksh
#-----------------------------------------------------------------------
# site http://www.unixreview.com/documents/s=1344/uni1023811722342/
# PROGRAM       checkAlertLog.ksh
# USAGE         checkAlertLog.ksh        
# FUNCTION      Checks ORACLE Alert logs and pages in case of 
#               any new errors. SID is Oracle database identifier. 
# CALLED BY     cron
# The standard employer-employee disclaimer is in effect: In this script,
# I don't speak for my employer, and my views on all topics are my own. 
# AUTHOR        Naresh Puri 
# Date          Thu Jun  1 18:01:56 PDT 2000
#-----------------------------------------------------------------------

SID=$1                          # Oracle database identifier
PAGEMESSAGES=$2                 # Maximum number of new messages that get paged
PARAM=$#
TMP=/tmp                        # Temporary directory
MAILX=/usr/bin/mailx            # UNIX Mail Program
LIBDIR=/usr/local/lib/fltools   # Directory where useful information is saved 
ALERTDIR=/usr/app/oracle/admin/${SID}/bdump # Directory where 
                                            # Oracle alert file resides
FILE=alert_${SID}.log           # Oracle alert file name
LASTCOUNT=`cat $LIBDIR/.oraErrCount_${SID}` # Count of ORA- errors 
                                            # detected during last program run 
PAGESA=NULL                     # Do not page SA staff
PAGEDBA=DBA                     # Page only DBA staff
PAGEOTHER=NULL                  # Do not page OTHER staff members

export PAGEMESSAGES 
export PARAM 
export TMP 
export MAILX 
export LIBDIR 
export ALERTDIR 
export FILE 
export LASTCOUNT 
export SID 
export PAGESA 
export PAGEDBA 
export PAGEOTHER

checkParameters()

{
   if [ $PARAM -ne 2 ]
   then
      echo "**USAGE** : $0  "
      exit 1
   fi

}

sendAlertMessage()

{
MESSAGE="**ALARM**:${SID}:`grep "ORA-" $ALERTDIR/$FILE | tail  -${count} | head -1`"
   for LIST in `egrep "($PAGESA|$PAGEDBA|$PAGEOTHER)" $LIBDIR/pagers.txt`
   do
      PAGER=`echo $LIST | awk -F: '{ print $2 }'`
      NAME=`echo $LIST | awk -F: '{ print $1 }'`
      EMAIL=`echo $LIST | awk -F: '{ print $3 }'`
      echo $MESSAGE | $MAILX ${PAGER}
      echo $MESSAGE | $MAILX -s"`uname -n`:${SID}:ORACLE Trace file Alert" ${EMAIL}
      echo "$NAME:$MESSAGE:`date`"
   done

}


probeAlertLog()

{
   #set -x
   # Count all Oracle errors - search for string "ORA-"
   CheckError=`grep "ORA-" $ALERTDIR/$FILE | wc -l`

   # keep a count of current errors present in the Alert file
   echo $CheckError > $LIBDIR/.oraErrCount_${SID}

   count=1
   # If new errors are detected (same alert log)
   if [ $CheckError -gt $LASTCOUNT ]
   then
      while [ $LASTCOUNT -lt $CheckError ]
      do
         sendAlertMessage;
         if [ $count -eq $PAGEMESSAGES ]
         then
            break;
         fi
         ((count=$count+1))
         ((LASTCOUNT=$LASTCOUNT+1))
      done
   else
      # Looks like alert log file has been switched!
      if [ $CheckError -lt $LASTCOUNT ]
      then
         while [ $count -le $CheckError ]
         do
            sendAlertMessage;
            if [ $count -eq $PAGEMESSAGES ]
            then
               break;
            fi
            ((count=$count+1))
         done
      fi
   fi

}

checkParameters;
probeAlertLog;
