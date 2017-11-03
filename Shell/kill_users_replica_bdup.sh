
#!/usr/bin/ksh

#########################################################
##------------------------------------------------     ##
## Arquivo:		Kill_Repl_Bdup.sh	              ##
##------------------------------------------------     ##
## Fun��o:		Elimina Usuarios conectados e     ##
##                Efetua a Replica��o da algumas       ##
##                tabelas do Bdup_esquema(SIGEP)       ##
##                para base de dados da Inst�ncia      ##
##                do Bdep de Desenvolvimento (orcl)    ##
##                                                     ##
## Ambiente: 		LINUX			              ##
##------------------------------------------------     ##
##						              ##
## Criado por:		Leonel do Bomfim Filho      ##
## Data:                17/03/2008                     ## 
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
OH=$ORACLE_BASE/9.2.0
export CLASSPATH OH DATABACKUP

## -----------------------------------------------------------------------
## Copia do sqlnet.ora para login do SYS - Habilita
/bin/cp /pub/bkp_oracle/script/sqlnet2.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
## Comando para gerar a instru��o SQL - gera_conn_sql.sql
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/gera_conn_sql.sql

## -----------------------------------------------------------------------
## Elimina usuarios logados na inst�ncia oracle de desenvolvimento (orcl)
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/kill_users_01.sql

## -----------------------------------------------------------------------
## Efetua limpeza do tabelas de backup dos sistemas corporativos
## Zerando tabelas de backup de seguran�a
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/bkp_zerar_tab_corpor_old_01.sql

## -----------------------------------------------------------------------
## Executa o backup dos dados anteriores a " pr�xima atualiza��o" 
## obs.: Atualiza��o das tabelas de backup de seguran�a
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/bkp_tab_corpor_old_01.sql

## -----------------------------------------------------------------------
## Executa a replica��o de algumas tabelas do Bdup/Anp inst�ncia oracle de Produ��o 
## prdap1 e prdap2 para a base de dados do Bdep (produ��o - servidor berilo)
## sqlplus "/ as sysdba" @/pub/bkp_oracle/script/replica_bdup_anp.sql
   sqlplus "/ as sysdba" @/pub/bkp_oracle/script/bdup_replica_tab_views.sql

## -----------------------------------------------------------------------
## Efetua limpeza do tabelas corporativas do sistemas do Bdep antes da atualiza��o 
## Estas tabelas s�o as corporativas dos sistemas do Bdep (scp e sircs) 
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/zerar_tab_corpor_01.sql

## -----------------------------------------------------------------------
## Executa atualiza��o das tabelas corporativas BDEP  (tabelas "mestras" vindas do sistema Bdup(Sigep)/Nin/Anp) 
## obs.: tabelas sistemas (scp e sircs)
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/carga_tab_corpor_01.sql

## -----------------------------------------------------------------------
## Atualiza as Estatiscas (contbdep_esquema) dos objetos e armazen� no dicionario de dados
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/analize_esquema.sql

## -----------------------------------------------------------------------
## Copia do sqlnet.ora para login do SYS - Fecha
/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------

