
#!/usr/bin/ksh

#  Variaveis de ambiente do ORACLE 9.2.0.4 no ARSENIO.
#  Mayr 06/07/2007
#

DATABACKUP=`date +20%y%m%d`
set $ORACLE_HOME=/opt/oracle/product/9.2.0
ORACLE_BASE=/opt/oracle
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
OH=$ORACLE_BASE/product/9.2.0
export CLASSPATH OH DATABACKUP

#  Linha de Comando que executa a Stop da instância de Banco de Desenvolvimeto .
#
echo -n "Baixando o banco de dados Oracle de Desenvolvimento"
export ORACLE_SID
cd $ORACLE_HOME/bin
@/pub/bck_oracle/script/stop.sql