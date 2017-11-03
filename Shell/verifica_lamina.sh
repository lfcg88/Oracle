#Interpretador
#!/bin/bash

# Definicao das variaveis do script
DATA=`/bin/date +%d-%m-%Y_%H%M`
LOG="//ext/informix/scripts/LOG_LAMINA-$DATA.log"

cd /

echo "--------------------------------------------------" >> $LOG
echo "******  VERSAO LINUX - $HOSTNAME ****** " >> $LOG
echo "--------------------------------------------------" >> $LOG
cat /proc/version >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "******  INFORMACAO CPU - $HOSTNAME ****** " >> $LOG
echo "--------------------------------------------------" >> $LOG
cat /proc/cpuinfo >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "******  INFORMACAO PARTICAO - $HOSTNAME ****** " >> $LOG
echo "--------------------------------------------------" >> $LOG
cat /proc/partitions >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "******  INFORMACAO MEMORIA - $HOSTNAME ****** " >> $LOG
echo "--------------------------------------------------" >> $LOG
cat /proc/meminfo >> $LOG
echo "--------------------------------------------------" >> $LOG


