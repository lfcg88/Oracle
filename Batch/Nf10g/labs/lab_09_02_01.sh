
export ORACLE_HOME=/u01/app/oracle/product/10.1.0/db_1
export ORACLE_SID=orcl
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.1.0/db_1/lib:/usr/lib
export PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin:/u01/app/oracle/product/10.1.0/db_1/bin=/usr/bin/env

/u01/app/oracle/product/10.1.0/db_1/bin/sqlplus hr/hr  << END

create table session_history (
  snap_time  TIMESTAMP WITH LOCAL TIME ZONE,
  num_sessions NUMBER);
END
