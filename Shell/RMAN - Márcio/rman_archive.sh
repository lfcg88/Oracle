######################################################
#Rightway Consultoria e Sistemas
#Criado por Marcio Briso 31/01/2014
######################################################

#Oracle Binaries

        export ORACLE_SID=$1
        export ORACLE_HOME=/u01/oracle/product/10.2
        export ORACLE_BASE=/u01/oracle
        export O_RMAN=$ORACLE_HOME/bin/rman

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Ajuste esses valores para refletir na estrutura de diretorios do BACKUP
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        export O_BACKHOME=/u04/orabackup
        export O_BACKPATH=$O_BACKHOME/rman_archive/$ORACLE_SID
        export O_SCRIPTPATH=$O_BACKHOME/scr
        export O_LOGPATH=$O_BACKHOME/log/$ORACLE_SID
        export O_CMDFILE=$O_SCRIPTPATH/rman_archive.rcv
        export O_MSGLOG=$O_LOGPATH/backup_rman_archive.log
        export O_ZIP=/bin/gzip
        export O_CONNECT='nocatalog target /'
        export HOJE=`date '+%d/%m/%Y'`

#Efetua o backup dos archives atraves do RMAN

$O_RMAN $O_CONNECT CMDFILE=$O_CMDFILE MSGLOG=$O_MSGLOG

#Envia email para notificar o susseco ou falha do backup

#if [ `find $O_MSGLOG -type f -exec grep -l "RMAN-" {} \;` =0 ]
#then
#       tail -7 $O_MSGLOG | mailx -s "Banco $ORACLE_SID - Backup dos Archives com Sucesso - $HOJE" marcio.silva@rightway.com.br
#else
#       cat $O_MSGLOG | mailx -s "Banco $ORACLE_SID - Backup dos Archives com ERRO - $HOJE" marcio.silva@rightway.com.br
#fi