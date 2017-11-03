#!/bin/bash
# Add /usr/local/bin to the PATH variable so the oraenv command can be found
PATH=$PATH:/usr/local/bin; export PATH
# If a SID is provided as an argument it will be set and oraenv run
# otherwise we will use the current SID.  If no SID is set or provided
# an error message is displayed and the script exits with a status of 1
if [ $1 ]
then
    ORACLE_SID=$1
    ORAENV_ASK=NO
    . oraenv
else
    if [ ! $ORACLE_SID ]
    then
           echo "Error: No ORACLE_SID set or provided as an argument"
           exit 1
    fi
fi
# Set the ORACLE_BASE variable
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
cd $ORACLE_BASE/admin/$ORACLE_SID/bdump
# Copy the current alert log into a temporary file and empty the original
cp alert_$ORACLE_SID.log alert_$ORACLE_SID.log.temp
cp /dev/null alert_$ORACLE_SID.log
# Check the copy in the temporary file for ORA- errors
grep 'ORA-' alert_$ORACLE_SID.log.temp > /dev/null
# If found, email the Oracle user with the contents of the alert log
if [ $? = 0 ]
then
    mail -s "$ORACLE_SID database alert log error" oracle < \
           alert_$ORACLE_SID.log.temp
fi
# Move the contents of the temp file onto the permanent copy of the log
# and remove the temp file.
cat alert_$ORACLE_SID.log.temp >> alert_$ORACLE_SID.log.1
rm alert_$ORACLE_SID.log.temp