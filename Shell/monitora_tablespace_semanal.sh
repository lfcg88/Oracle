#####################################################################################################################################################
# DESCRICAO:  SCRIPT PARA REALIZAR A MONITORACAO DE UTILIZACAO DAS TABELESPACES.
#             LISTA TODAS AS TABLESPACES COM MENOS DE 20% DE ESPACO LIVRE E ENVIA UM EMAIL PARA REALIZACAO DO AUMENTO DA TABLESPACE.
# DATA: 02/07/2013
# MARCIO BRISO
#####################################################################################################################################################

export TMP=/home/oracle/scripts/log/oracle_tmp.$$
export TSTAMP=`date +%d%m%Y`
export LOG=/home/oracle/scripts/log/monitora_tablespaces_$TSTAMP.log
export export ERR=/home/oracle/scripts/log/oracle_t.err
export SQL=/home/oracle/scripts/bin/free_tbspace_semanal.sql
export DESTINO="marcio.silva@colaborador.inpi.gov.br" #, cjamus@colaborador.inpi.gov.br, andre.lima@colaborador.inpi.gov.br,luiz.guedes@colaborador.inpi.gov.br"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=$1
PATH=$ORACLE_HOME/bin:$PATH

echo "-------------------- `date` ------------------------" >> $LOG

$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" @$SQL $TMP >/dev/null 2>$ERR
    cat $TMP | mail -s "Relatório Tablespaces - Instancia $ORACLE_SID" $DESTINO
    cat $TMP >> $LOG
exit
