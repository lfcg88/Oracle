if [ -t 0 ]                             # Command executed from a terminal
then
        ORACLE_SID=""
        while [ -z "${ORACLE_SID}" ]
        do
                tput clear; tput rev
                echo "Valid Oracle SIDs are :"
                tput rmso
                for SID in `cat /etc/oratab|grep -v "^#"|cut -f1 -d: -s`
                do
                        echo "                  ${SID}"
                done
                DEFAULT=`cat /etc/oratab|grep -v "^#"|cut -d: -f1 -s|head -1`
                echo "\nEnter the Oracle SID you require (def: $DEFAULT): \c"
                read ANSWER
                [ "${ANSWER}" = "" ] && ANSWER=$DEFAULT
                export ORACLE_SID=`grep "^${ANSWER}:" /etc/oratab|cut -d: -f1 -s`
                export ORACLE_HOME=`grep "^${ANSWER}:" /etc/oratab|cut -d: -f2 -s`
                if [ "${ORACLE_SID}" = "" ]
                then
                        echo "\n\n              ${ANS}: Invalid Oracle SID  \c"
                        sleep 2
                fi
        done
else                                    # Set to first entry in oratab
        export ORACLE_SID=`cat /etc/oratab|grep -v "^#"|cut -d: -f1 -s|head -1`
        export ORACLE_HOME=`cat /etc/oratab|grep -v "^#"|cut -d: -f2 -s|head -1`
fi

export ORACLE_SID=$ORACLE_SID
export ORACLE_HOME=$ORACLE_HOME
export PATH=${PATH}:${ORACLE_HOME}/bin
#ORAENV_ASK=NO
#. ${ORACLE_HOME}/bin/oraenv
#ORAENV_ASK=
echo
echo Oracle SID is now `tput rev`$ORACLE_SID`tput rmso`, Oracle Home is `tput rev`$ORACLE_HOME`tput rmso`
echo   
