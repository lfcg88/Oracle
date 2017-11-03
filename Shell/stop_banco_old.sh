
#!/usr/bin/ksh

#  Variaveis de ambiente do ORACLE 9.2.0.4 no ARSENIO.
#  Mayr 06/07/2007
#  Leonel do Bomfim Filho - Atualiza��o 08/04/2008
#

DATABACKUP=`date +20%y%m%d`

## -----------------------------------------------------------------------
## Habilita login SYS as sysdba

/bin/cp /pub/bkp_oracle/script/sqlnet2.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
## Comando para gerar a instru��o SQL - kill_conn_sql.sql

sqlplus "/ as sysdba" @/pub/bkp_oracle/script/kill_conn_sql.sql

## -----------------------------------------------------------------------
## Elimina usuarios logados na inst�ncia oracle de desenvolvimento (orcl), 

sqlplus "/ as sysdba" @/pub/bkp_oracle/script/kill_conn_01.sql

## -----------------------------------------------------------------------
##  Linha de Comando que executa a Stop da inst�ncia de Banco de Desenvolvimento (orcl) .

echo -n "Parando o banco de dados Oracle"
export ORACLE_SID=bdep
cd $ORACLE_HOME/bin
sqlplus "/ as sysdba" @/pub/bkp_oracle/script/stop.sql
lsnrctl stop

## -----------------------------------------------------------------------
## Bloqueia login do SYS as sysdba

/bin/cp /pub/bkp_oracle/script/sqlnet1.ora /u01/app/oracle/product/9.2.0/network/admin/sqlnet.ora

## -----------------------------------------------------------------------
