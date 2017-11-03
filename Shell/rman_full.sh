######################################################
#Rightway Consultoria e Sistemas
#Criado por Marcio Briso 31/01/2014
######################################################

# Testa se o nome da instancia esta vazio
if [ -z $1 ]; then

#*************************************
#AJUDA AO USUARIO
#*************************************

        echo "."
        echo "Uso do RMAN.SH"
        echo "Entre com o seguinte comando RMAN.SH ORACLE_SID"
        echo "ORACLE_SID: a instancia Oracle alvo do backup"
        echo "ex: teste"
        exit;
else

#Oracle Binaries

        export ORACLE_SID=$1
        export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
        export ORACLE_BASE=/u01/app/oracle
        export O_RMAN=$ORACLE_HOME/bin/rman

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Ajuste esses valores para refletir na estrutura de diretÃ³o BACKUP
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


        export O_BACKHOME=/u04/orabackup
        export O_CONTROLFILE=$O_BACKHOME/rman_controlfile/$ORACLE_SID
        export O_BACKPATH=$O_BACKHOME/rman_full/$ORACLE_SID
        export O_SCRIPTPATH=$O_BACKHOME/scr
        export O_LOGPATH=$O_BACKHOME/log/$ORACLE_SID
        export O_CMDFILE=$O_SCRIPTPATH/rman_full.rcv
        export O_MSGLOG=$O_LOGPATH/backup_rman.log
        export O_CONNECT='nocatalog target /'

# Efetua o backup atraves do RMAN

        $O_RMAN $O_CONNECT CMDFILE=$O_CMDFILE MSGLOG=$O_MSGLOG

#Envia email com o status do backup

		if [ `find $O_MSGLOG -type f -exec grep -l "RMAN-" {} \;` =0 ]
				then
						export MSG=`tail -2 $O_MSGLOG`
						export SUBJECT="Banco $ORACLE_SID - Full Backup realizado com SUCESSO - $HOJE"
				else
						export MSG=`tail -20 $O_MSGLOG`
						export SUBJECT="Banco $ORACLE_SID - Falha no Backup Full do banco de Dados - $HOJE"
				fi
exit;