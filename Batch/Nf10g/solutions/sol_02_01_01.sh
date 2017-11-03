
sqlplus / as sysdba  << END

set echo on

connect / as sysdba

shutdown immediate;
exit;
END

cp $ORACLE_BASE/oradata/orcl/* $HOME/DONTTOUCH
cp $ORACLE_HOME/dbs/spfile*.ora $HOME/DONTTOUCH
