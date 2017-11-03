#!/bin/ksh
#-----------------------------------------------------------
export Pacote=a
export PROC_PID=$$
export UNIX95=XPG4
export DiaMesAno=`date '+%d%m%y`
export HoraMinuto=`date '+%H%M`
export Programa=Start_Cron_Monitora_File_System_bmp[$Pacote].sh
export Chave=Cron_Monitora_File_System_bmp[$Pacote]
export NomArqPar=configuracao_script.txt
export DirSh=/opt/app/oracle[$Pacote]/scripts/sh
export DirPar=/opt/app/oracle[$Pacote]/scripts/parametros
export _Pgm2=" Script de Monitoramento Espaco File System "
#-----------------------------------------------------------
Quant=`ps -ef | grep $Programa | grep -v grep | wc -l`
#-----------------------------------------------------------
echo "==== $DiaMesAno - $HoraMinuto ===" >> $LOG
if [ `ps -ef | grep $Programa | grep -v grep | grep -v $PROC_PID | wc -l` -gt 1 ]; then
  echo "processo executando - " >> $LOG
  ps -ef | grep $Programa | grep -v grep | grep -v $PROC_PID >> $LOG
  exit
fi
#----------------------------------------------------------
_Echo() ### ...define shell-function "_Echo()"...
{
if [ -r ${HOME}/.dba ]
then
  sed '/^#/d' ${HOME}/.dba | while read _EmailRcpt
   do
     echo "$2" | mailx -s " maquina `hostname`: $_Pgm2 - Bmp[$Pacote] -  $1 " ${_EmailRcpt}
   done
fi
}
#-----------------------------------------------------------
LINE=` cat $DirParametros/$ArqParametros | grep -v '#' | grep $2 `
echo $LINE
if [ -z  "$LINE" ]
then
  _Echo "*** Erro ***" "Nao Encontrou Entrada no Arquivo de Parametros"
  exit 1
fi
echo "passo 02"
#-----------------------------------------------------------
export Limite=`echo $LINE | awk -F: '{print $2}' -`
export DirLog=`echo $LINE | awk -F: '{print $3}' -`
export ArqLog=`echo $LINE | awk -F: '{print $4}' -`
export DirScript=`echo $LINE | awk -F: '{print $5}' -`
export ArqScript=`echo $LINE | awk -F: '{print $6}' -`
#--------------------------------------------------------------
LOG=$DirLog/$ArqLog
> $LOG
vScript=$DirScript/$ArqScript
echo $vScript
#----------------------------------------------------------------------------------
# para evitar erros na saida do bdf, a mesma foi analisada da direita para esquerda
#----------------------------------------------------------------------------------
for LINE in ` bdf | tr -d % | awk '{ if ( $NF ~ "/mnt" ) print $(NF-1),$NF }' `
do
 vPercUsed   =`echo $LINE | awk -F: '{print $1}' -`
 vFileSystem =`echo $LINE | awk -F: '{print $2}' -`
 If {$vPercUsed -ge $vLimite  }
    then
       echo " File System : $vFileSystem   Espaço Usado: $vPercUsed %" >> $LOG
  #     If  ( $vFileSystem ~ "[$Pacote]1" ) 
  #       Then
  #         echo " File System : $vFileSystem   Espaço Usado: $vPercUsed %" 
  #         $vScript
       fi
  fi
done
#----------------------------------------------------------------------------------
if [ $? -ne 0 ] ;  then
  _Pgm2=" Erro Monitoramento Espaco File System "   
  _Echo "***** Erro **** failure" "`cat $LOG`"
  exit
fi
#----------------------------------------------------------------------------------
if [ -s $LOG ] ;  then # arquivo existe e tamanho > 0 bytes
  _Pgm2=" File System Acima di Limite de $LIMITE(%) "
  _Echo "***** URGENTE *****" "`cat $LOG`"
 # echo "passo4"
fi
#----------------------------------------------------------------------------------
# historico
#----------------------------------------------------------------------------------
#
echo " ----------- $HoraMinuto --------" >> $LOG.[$DiaMesAno]
cat $LOG >> $LOG.[$DiaMesAno]
#
exit


       
