#########################################################
##------------------------------------------------     ##
## Arquivo:		kill_users_replica_bdup.sh     ##
##------------------------------------------------     ##
## Função:		Elimina Usuarios conectados e  ##
##                Efetua a Replicação da algumas       ##
##                tabelas do Bdup_esquema(SIGEP)       ##
##                para base de dados da Instância      ##
##                do Bdep de Produção (bdep)           ##
##                                                     ##
## Ambiente: 		LINUX			       ##
##------------------------------------------------     ##
##						       ##
## Criado por:	Leonel do Bomfim Filho                 ##
## Data:             17/03/2008                        ## 
## Empresa: 		Bdep                           ##
##						       ##
#########################################################

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
OH=$ORACLE_BASE/product/9.2.0
export CLASSPATH OH DATABACKUP

## -----------------------------------------------------------------------
## Copia do sqlnet.ora para login do SYS - Habilita
/bin/cp /pub/bkp_oracle/script/sqlnet2.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
## Executa a replicação de algumas tabelas do Bdup/Anp instância oracle de Produção 
## prdap1 e prdap2 para a base de dados do Bdep (produção - servidor berilo - replica_bdup)
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/bdup_replica_tab_views.sql

## -----------------------------------------------------------------------
## Bloqueia login como SYS as sysdba
/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------

