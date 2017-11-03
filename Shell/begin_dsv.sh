#!/usr/bin/ksh

#########################################################
##------------------------------------------------     ##
## Arquivo:		bkp_ol.sh		       ##
##------------------------------------------------     ##
## Função:		Faz o Backup Online do Banco   ## 
##                   (BEGIN BACKUP)                    ##
## Ambiente: 		LINUX - Oracle Desenvolvimento ##
##------------------------------------------------     ##
##						       ##
## Criado por:	Leonel do Bomfim Filho	               ##
## Data:  		17/03/2008		       ##
## Empresa: 		Bdep                           ##
## Ambiente Oracle 9.2.0.8 Desenvolvimento             ##
##						       ##
#########################################################

## -----------------------------------------------------------------------
## Variaveis do ambiente Oracle
DATAS=`date +%d_%m_%Y`
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
## Habilita login SYS as sysdba
echo " (Begin-Backup) Habilita login Sys as sysdba !!) Data_$DATAS " >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /pub/bkp_oracle/script/sqlnet2.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------

## -----------------------------------------------------------------------  
## Copia do INIT , SPFILE , CONTROFILE e ARCHIVES
echo " (Begin-Backup) Efetua copia dos arquivos Init, Spfile, Controlfile e Archives!!) Data_$DATAS " >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /u01/app/oracle/product/9.2.0/dbs/spfileorcl.ora  /pub/bkp_oracle/backup_online/  >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /u01/app/oracle/admin/orcl/pfile/initorcl*.*      /pub/bkp_oracle/backup_online/  >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /u01/app/oracle/oradata/orcl/*.ctl                /pub/bkp_oracle/backup_online/  >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /u01/app/oracle/product/9.2.0/network/admin/*.ora /pub/bkp_oracle/backup_online/network/  >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log

## -----------------------------------------------------------------------
## Copia do sqlnet.ora para login do SYS - Fecha
echo " (Begin-Backup) Fecha a conexão do login Sys as sysdba !!) Data_$DATAS " >>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log
/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
