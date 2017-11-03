#########################################################
##------------------------------------------------     ##
## Arquivo:		compila_objetos_bdep.sh  	       ##
##------------------------------------------------     ##
## Função:	    Compila objetos para que não fiquem  ##
##                invalidos no ambiente de produção,   ##
##                na instância de Banco de Dados       ##
##                Bdep objetos do esquema  		##
##                "Contbdeptst"                        ##
##                do Bdep de Desenvolvimento(orcl)     ##
## Ambiente: 		LINUX			              ##
##------------------------------------------------     ##
##						              ##
## Criado por:	Leonel do Bomfim Filho            ##
## Data:             18/04/2008                        ## 
## Empresa: 		Bdep                               ##
##						              ##
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
## Comando para gerar a instrução SQL - gera_compile_sql.sql
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/gera_compile_sql.sql

## -----------------------------------------------------------------------
## Compila objetos "Contbdep_esquema" da instância oracle de produção (bdep) 
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/compile_objects_01.sql

## -----------------------------------------------------------------------
## Bloqueia login como SYS as sysdba
/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------

