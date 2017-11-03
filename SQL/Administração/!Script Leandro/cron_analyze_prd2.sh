#!/bin/ksh
export ORACLE_SID=prd2
export ORACLE_HOME=/u00/app/oracle/product/8.0.5 
export PATH=/u00/app/oracle/product/8.0.5/bin:/usr/sbin:/usr/bin:/usr/ccs/bin:/opt/proctool/bin:/usr/bin:
if [  `ps -ef | grep ora_pmon_$ORACLE_SID | grep -v grep | wc -l` =  0 ]
then
   exit 0;
fi
DIR_LOG=/u00/app/oracle/admin/script/log
export DIR_LOG
SQLPLUS="$ORACLE_HOME/bin/sqlplus -s / "
export SQLPLUS                         

$SQLPLUS << EOF
  set echo off
  set termout off
  set feedback off
  set heading off
  set serveroutput on
  set linesize 80
  spool $DIR_LOG/cron_analyze_prd2.log
  select to_char(sysdate,'dd mm yyyy hh24 mi ss') from dual;
  declare
   vcod char(7);
   vmen varchar2(200);
  begin
   analyze_schema(vcod,vmen);
   dbms_output.put_line('analyze_log codigo de retorno = '||vcod);
   dbms_output.put_line('analyze_log = '||vmen);
  end;
/
  select to_char(sysdate,'dd mm yyyy hh24 mi ss') from dual;
  spool off
  exit
EOF   
