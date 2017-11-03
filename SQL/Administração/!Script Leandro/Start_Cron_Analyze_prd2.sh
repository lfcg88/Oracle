#!/bin/ksh
#---------------------------------------------------------------------------
# This product is provided "as-is", without any express or implied warranty.
# This product is NOT part of any application, neither was it developed by 
# Integris. Use it at your own risk. In no moment shall the author or Integris
# be liable for any special, indirect or consequential damages resulting from
# loss of use, data or profit arising out from the use of this product. Written
# permission from the author is required to duplicate, redistribute or modify
# this package or any of its components.
#
# Este produto eh fornecido "tal-qual", sem nenhuma garantia expressa ou impli-
# cita. Este produto nao faz parte de qualquer aplicacao, nem foi desenvolvido
# pela Integris. O risco de uso eh de sua responsabilidade. Em nenhum momento
# o autor ou a Integris poderao ser responsabilizados por qualquer dano espe-
# cial, indireto ou por consequencia resultante da perda de uso, dados ou 
# beneficios oriundos do uso deste produto. Permissao por escrito do autor eh
# necessario para duplicar, redistribuir ou modificar este pacote ou qualquer
# um de seus componentes.
#---------------------------------------------------------------------------
#
# Shell.....:  Lanca o analize para gerar estatisticas do Oracle da base prd2  
#
# Sintaxe...:  /u00/app/oracle/admin/script/sh/Start_Cron_Analize_prd2.sh 
#              (lancado pela cron)
#
# Opcoes....:  Nao ha
#
# Parametros:  e-mail do administrador para envio de log
#
# Requisitos:  Arquivo /u00/app/oracle/admin/script/sh/parametros para buscar 
#              os parametros do shell 
#
# Atributos.:  dono:       = oradba
#              permissoes  = rwxr-x---
#
# Autor.....:  Rudolfo Schulze - Integris
#
# Data......:  27/janeiro/2003
# Alteracao.:  
#
# Descricao.:
# Script para capturar estatisticas de objetos que serao utilizados pelo 
# otimizador. Roda na base prd2.
#--------------------------------------------------------------------------

# Definicao de variaveis

dd=`date +"%d"`
mmn=`date +"%m"`
aa=`date +"%Y"`

CAM_LOG=/u00/app/oracle/admin/script/log
CAM_APP=/u00/app/oracle/admin/script/sh
LOG_APP=cron_analyze_prd2.log
LOG_MAIL=$CAM_LOG/Start_Cron_Analyze_prd2.logmail
LOG_SCR=$CAM_LOG/Start_Cron_Analyze_prd2.log
ARQ_PARAM=/u00/app/oracle/admin/script/sh/parametros
ORACLE_SID=prd2
SERV=`hostname`
MAIL=0

SCR_NAME=Start_Cron_Analyze_prd2.sh
SCR_EX=cron_analyze_prd2.sh

# Verifica de o Oracle esta rodando na maquina

if [ `ps -ef | grep ora_pmon_$ORACLE_SID | grep -v grep | wc -l` =  0 ] ; then
   exit 1
fi

echo "$SCR_NAME ...inicio do shell `date`" > $LOG_SCR

#--------------------------------------------------------------------------
echo "-------------------------------------------------------" >  $LOG_MAIL
echo "         RESULTADO ANALYZE BASE $ORACLE_SID  - $SERV   " >> $LOG_MAIL
echo "-------------------------------------------------------" >> $LOG_MAIL
echo "Inicio: `date +'%d/%m/%y %H:%M'`\n" >> $LOG_MAIL
#--------------------------------------------------------------------------
# Funcao de erro chamada de dentro do script sempre quando ha uma situacao
# bloqueante na geracao ou no conteudo da geracao do script
ERRO ()
{
print "\nHOUVE ERRO NO ANALYZE DA BASE PRD5" >> $LOG_MAIL
print "ENTRAR EM CONTATO COM O RESPONSAVEL (DBA)" >> $LOG_MAIL
mailx -s "$SERV - Analyze $ORACLE_SID - ERRO" $ADM < $LOG_MAIL
mailx -s "$SERV - $SCR_NAME"  $ADM < $LOG_SCR
exit 1
}

#--------------------------------------------------------------------------

# Rotina para capturar os parametros deste shell, localizados no
# /u00/app/oracle/admin/script/sh/parametros, cuja linha inicia com o nome
# deste shell

test -f $ARQ_PARAM
if [ $? = 0 ] ; then
   echo "$SCR_NAME ...arquivo de parametros existe" >> $LOG_SCR
   cat $ARQ_PARAM | grep $SCR_NAME > /dev/null
   if [ $? = 0 ] ; then
      PARAM=`awk 'BEGIN{ FS=":" }{
                                  if ( $1 == "'$SCR_NAME'" )
                                     print $0
                                 }' $ARQ_PARAM`
      NPARAM=`echo $PARAM | awk 'BEGIN{ FS=":" } {print NF-1}'`
      echo "$SCR_NAME ...numero de parametro(s) encontrado(s)=$NPARAM">>$LOG_SCR
      if [ $NPARAM = 1 ] ; then
         ADM=`echo $PARAM | awk 'BEGIN{ FS=":" } {print $2}'`
         echo "$SCR_NAME ...parametro 1 = $ADM" >> $LOG_SCR
      else
         echo "$SCR_NAME ...numero de parametros incorreto" >>$LOG_SCR
         exit 1
      fi
   else
      echo "$SCR_NAME ...parametros nao encontrados para este shell" >>$LOG_SCR
      exit 1
   fi
else
   echo "$SCR_NAME ...arquivo de parametros inexistente" >> $LOG_SCR
   exit 1
fi
#--------------------------------------------------------------------------

# Elimina arquivos e logs salvos acima de 7 dias

echo "\n$SCR_NAME ...eliminando arquivos antigos de $CAM_LOG" >> $LOG_SCR

find $CAM_LOG -name "$LOG_APP*" -type f -mtime +6 -exec rm -r {} \;
#--------------------------------------------------------------------------

echo "\n$SCR_NAME ...chamando o script $SCR_EX de geracao" >> $LOG_SCR

test -f $CAM_APP/$SCR_EX
if [ $? -eq 0 ] ; then
   echo "SCR_NAME ...arquivo de execucao existe" >> $LOG_SCR
   su - oradba -c "$CAM_APP/$SCR_EX"
else
   echo "SCR_NAME ...arquivo de execucao nao existe" >> $LOG_SCR
   echo "Arquivo de execucao nao existe" >> LOG_MAIL
   ERRO
fi
#--------------------------------------------------------------------------

if [ -f $CAM_LOG/$LOG_APP ] ; then
   echo "$SCR_NAME ...log do analyze:\n" >> $LOG_SCR
   cat $CAM_LOG/$LOG_APP | tr -s " " | sed '/^[ \t]*$/d' >> $LOG_SCR
   cat $CAM_LOG/$LOG_APP | grep "realizada com sucesso" > /dev/null
   if [ $? -ne 0 ] ; then
     echo "\n$SCR_NAME ...Erro na execucao" >> $LOG_SCR
     echo "Erro na execucao" >> $LOG_MAIL
     ERRO
   else
     echo "\n$SCR_NAME ...Execucao OK" >> $LOG_SCR
     echo "Execucao OK\n" >> $LOG_MAIL
   fi
else
   echo "\n$SCR_NAME ...Nao gerou log de execucao" >> $LOG_SCR
   echo "Nao gerou log de execucao" >> $LOG_MAIL
   ERRO
fi

# Salvando o arquivo de log com outro nome
if [ -f $CAM_LOG/$LOG_APP ] ; then
   echo "\n$SCR_NAME ...alterando o nome do arquivo de log" >> $LOG_SCR
   mv $CAM_LOG/$LOG_APP $CAM_LOG/$LOG_APP-$dd$mmn$aa 
fi
#--------------------------------------------------------------------------

print "OPERACAO REALIZADA COM SUCESSO" >> $LOG_MAIL
print "\nTermino: `date +'%d/%m/%y %H:%M'`" >> $LOG_MAIL
mailx -s "$SERV - Analyze $ORACLE_SID - OK" $ADM < $LOG_MAIL

print "\n$SCR_NAME ...fim do shell `date`" >> $LOG_SCR

exit 0
