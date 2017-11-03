
#!/usr/bin/ksh

#  Variaveis de ambiente do ORACLE 9.2.0.8 no ARSENIO.
#  Mayr 06/07/2007
#  Leonel do Bomfim Filho - Atualização 08/04/2008
#

## -----------------------------------------------------------------------
## Variaveis do ambiente Oracle
DATABACKUP=`date +20%y%m%d`
set $ORACLE_HOME=/u01/app/oracle/product/9.2.0
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/9.2.0
ORACLE_TERM=xterm
ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
TNS_ADMIN=$ORACLE_HOME/network/admin
ORACLE_SID=orcl
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
LD_LIBRARY_PATH=$ORACLE_HOME/lib
#DBCA_RAW_CONFIG=$ORACLE_BASE/dbca_raw_config
#SRVM_SHARED_CONFIG=/dev/vx/rdsk/racdg/prdapp01_srvmconfig
PATH=/usr/ccs/bin:$ORACLE_HOME/bin:/usr/bin:/usr/local/bin:/usr/openwin/bin
export ORACLE_BASE ORACLE_HOME ORA_NLS33 TNS_ADMIN DBCA_RAW_CONFIG NLS_LANG
export SRVM_SHARED_CONFIG ORACLE_SID PATH LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib
OH=$ORACLE_BASE/9.2.0
export CLASSPATH OH DATABACKUP

## -----------------------------------------------------------------------
## Habilita login SYS as sysdba
/bin/cp /pub/bkp_oracle/script/sqlnet2.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
##  Linha de Comando que executa a " Shutdown abort " da instância de Banco de Desenvolvimento (orcl) .

echo -n "Parando o banco de dados Oracle"
export ORACLE_SID=orcl
cd $ORACLE_HOME/bin
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/stop2.sql

## -----------------------------------------------------------------------
##  Linha de Comando que executa a " Start " da instância de Banco de Desenvolvimento (orcl) .
export ORACLE_SID=orcl
cd $ORACLE_HOME/bin
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/start.sql

## -----------------------------------------------------------------------
##  Linha de Comando que executa a " Shutdown immediate " da instância de Banco de Desenvolvimento (orcl) .
export ORACLE_SID=orcl
cd $ORACLE_HOME/bin
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/stop.sql

## -----------------------------------------------------------------------
## Bloqueia o Listener de comunicação no servidor Arsenio da instância oracle (orcl) de desenvolvimento
lsnrctl stop

## -----------------------------------------------------------------------
## Bloqueia login como SYS as sysdba
/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
