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
export SQL=/home/oracle/scripts/bin/free_tbspace.sql
export DESTINO="marcio.silva@colaborador.inpi.gov.br, cjamus@colaborador.inpi.gov.br, andre.lima@colaborador.inpi.gov.br,luiz.guedes@colaborador.inpi.gov.br"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=$1
PATH=$ORACLE_HOME/bin:$PATH

rm -f $ERR 

echo "-------------------- `date` ------------------------" >> $LOG

$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" @$SQL $TMP >/dev/null 2>$ERR
if [ $? != 0 ]
then
    echo "Erro na Execucao da Query" >> $ERR
    echo "Erro na Execucao da Query" >> $LOG
	cat $ERR | mail -s "ERRO - Monitoracao Tablespaces - Instancia $ORACLE_SID" $DESTINO
    exit 1
fi

if [ -s $TMP ]
then
    cat $TMP | mail -s "Monitoracao Tablespaces - Instancia $ORACLE_SID" $DESTINO
    cat $TMP >> $LOG
    echo "Alarme Enviado por Email" >> $LOG
else
    echo "Tudo OK!" >> $LOG
fi

rm -f $TMP
exit
